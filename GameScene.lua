-- collision engine
local bump = require("Stuff/bump")

GameScene = Core.class(Sprite)

function GameScene:init()
	self.camera = Camera.new()
	self:addChild(self.camera)
	
	self.world = bump.newWorld(32)
	self:setupWorld()
	
	self.level = Level.new(self.world)
	self:loadLevel("map")
	
	self:addEventListener(Event.ENTER_FRAME, self.update, self)
	self:addEventListener(Event.KEY_DOWN, self.keyDown, self)
	self:addEventListener(Event.KEY_UP, self.keyUp, self)
end
--
function GameScene:update(e)
	local dt = e.deltaTime
	
	self.player:update(dt)
	self.camera:focus(self.player)
	self.fpsCounter:update(dt)
end
--
function GameScene:keyDown(e)
	if (e.keyCode == KeyCode.LEFT) then self.player:moveLeft(true) end
	if (e.keyCode == KeyCode.RIGHT) then self.player:moveRight(true) end
	if (e.keyCode == KeyCode.UP) then self.player:jump() end
	if (e.keyCode == KeyCode.Z) then self.player:applyForceAtAngle(315, 25, 1000 ) end
end
--
function GameScene:keyUp(e)
	if (e.keyCode == KeyCode.LEFT) then self.player:moveLeft(false) end
	if (e.keyCode == KeyCode.RIGHT) then self.player:moveRight(false) end
end
--
function GameScene:setupWorld()
	local slide, cross = bump.responses.slide, bump.responses.cross

	local oneWay = function(world, col, x, y, w, h, goalX, goalY, filter)
		if col.normal.y < 0 and not col.overlaps then
			col.didTouch = true
			return slide(world, col, x, y, w, h, goalX, goalY, filter)
		else
			return cross(world, col, x, y, w, h, goalX, goalY, filter)
		end
	end

	self.world:addResponse("oneWay", oneWay)
end
--
function GameScene:loadLevel(name)
	local data = self.level:load(name)
	self.camera:loadLayers(data.layers)
	
	self.camera:addLayer("ui", 0)
	
	self.fpsCounter = FpsCounter.new()
	self.fpsCounter:setScale(2, 2)
	self.fpsCounter:setPosition(10, 20)
	self.camera:add("ui", self.fpsCounter)
	
	self.player = Player.new(
		self.world, 
		{x = data.playerData.x, y = data.playerData.y, w = 16, h = 16}
	)
	self.camera:add("frontPlatforms", self.player)
end