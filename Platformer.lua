local GRAVITY = 1200

Platformer = Core.class(Sprite)

function Platformer:init(world, params)
	self.world = world
	self.w = params.w
	self.h = params.h
	
	self.world:add(self, params.x, params.y, params.w, params.h)
	
	-- events --
	self.hitLeftWall = Event.new("hitLeftWall")
	self.hitRightWall = Event.new("hitRightWall")
	self.landedEvent = Event.new("onLanded")
	self.fallEvent = Event.new("onWalkOff") -- triggers when walk off from floor
	self.jumpEvent = Event.new("onJump")
	self.airJumpEvent = Event.new("onAirJump")
	self.triggerHit = Event.new("onTriggerHit")
	self.triggerHit.name = ""
	
	-- settings --
	self.dx = 0
	self.dy = 0
	self.jumpCount = 1	-- how many times platformer can jump
	self.jumpStr = 650	-- jump strength
	self.moveSpeed = 50	
	self.friction = 5	
	self.curJumps = 1	-- how many times platformer already jumped
	
	--
	self.isOnFloor = false
	self.movingLeft = false
	self.movingRight = false
	
	-- bump's collison filter function
	self.filter = function(item, other)
		if (other.isOneWay) then return "oneWay" 
		elseif (other.isWall) then return "slide" 
		elseif (other.isTrigger) then return "cross"
		end
	end
	
	self:setPosition(params.x, params.y)
end
--
function Platformer:update(dt)
	local x, y = self:getPosition()
	
	if (self.movingLeft) then
		self.dx -= self.moveSpeed * dt
	end if (self.movingRight) then
		self.dx += self.moveSpeed * dt
	end
	-- applying friction
	self.dx *= (1 - ((dt * self.friction)><1))
	x += self.dx
	
	-- applying gravity
	if (not(self.isOnFloor)) then
		self.dy += GRAVITY * dt
	end
	
	y += self.dy * dt
	
	-- checking collisons
	self:checkCollisions(self.world:move(self, x, y, self.filter))
end
--
function Platformer:checkCollisions(actualX, actualY, cols, colLen)
	self:setPosition(actualX, actualY)
	
	for k, col in ipairs(cols) do
		-- if colliding with wall
		if (col.other.isWall) then
			-- hit wall from top
			if (col.normal.y == -1) then
				self.isOnFloor = true
				self.curJumps = 0
				self.dy = 0
				self:dispatchEvent(self.landedEvent)
			-- hit wall from bottom
			elseif (col.normal.y == 1) then 
				self.dy = 0
			end
			
			-- hit wall from left
			if (col.normal.x == -1) then
				self.dx = 0
				self:dispatchEvent(self.hitRightWall)
			-- hit wall from right
			elseif (col.normal.x == 1) then
				self.dx = 0
				self:dispatchEvent(self.hitLeftWall)
			end
		-- colliding with one-way platforms
		elseif (col.other.isOneWay) then
			if (col.normal.y == -1 and col.didTouch) then
				self.isOnFloor = true
				self.dy = 0
				self:dispatchEvent(self.landedEvent)
			end
		-- colliding with triggers
		elseif (col.other.isTrigger) then
			-- parsing params which is string like "1, 2, 3"
			local params = split(col.other.params, ", +")
			-- call "triggerName" method with params
			if (pcall(self[col.other.triggerName], self, unpack(params))) then
				self:dispatchEvent(self.triggerHit)
				self.triggerHit.name = col.other.triggerName
			end
		end
	end	
	
	if (self:checkFall(actualX, actualY)) then
		if (self.isOnFloor)  then 
			self.isOnFloor = false
			self.curJumps = self.jumpCount - 1
			self:dispatchEvent(self.fallEvent)
		end
	end
end
--
function Platformer:checkFall(x,y)
	local _,l = self.world:project("ray", x, y+self.h, self.w, 2, x, y+self.h)
	return l == 0
end
--
function Platformer:moveLeft(flag) self.movingLeft = flag end

function Platformer:moveRight(flag) self.movingRight = flag end

function Platformer:jump(str)
	str = tonumber(str) or -self.jumpStr
	if (self.isOnFloor) then
		self.isOnFloor = false
		self.curJumps = 1
		self.dy = str
	elseif (self.curJumps + 1 <= self.jumpCount) then
		self.curJumps += 1
		self.dy = str
		self:dispatchEvent(self.airJumpEvent)
	end
end
--
function Platformer:applyForceAtAngle(ang, forceX, forceY)
	ang=^<ang
	forceY = forceY or forceX
	forceX = tonumber(forceX)
	forceY = tonumber(forceY)
	self.dx += forceX * math.cos(ang)
	self.dy += forceY * math.sin(ang)
	if (self.dy ~= 0) then
		self.curJumps = 1
		self.isOnFloor = false
		self:dispatchEvent(self.jumpEvent)
	end	
end
--
function Platformer:applyForceX(force) self.dx += tonumber(force) end

function Platformer:applyForceY(force)
	self.dy += tonumber(force)
	if (self.dy ~= 0) then
		self.curJumps = 1
		self.isOnFloor = false
		self:dispatchEvent(self.jumpEvent)
	end	
end
--
function Platformer:applyForce(forceX, forceY) 
	self.dx += tonumber(forceX)
	self.dy += tonumber(forceY)
	if (self.dy ~= 0) then
		self.curJumps = 1
		self.isOnFloor = false
		self:dispatchEvent(self.jumpEvent)
	end	
end
--
function Platformer:setForceX(force) self.dx = tonumber(force) end

function Platformer:setForceY(force) 
	self.dy = tonumber(force) 
	if (self.dy ~= 0) then
		self.curJumps = 1
		self.isOnFloor = false
		self:dispatchEvent(self.jumpEvent)
	end
end
--
function Platformer:setForce(forceX, forceY) 
	self.dx = tonumber(forceX)
	self.dy = tonumber(forceY)
	if (forceY ~= 0) then
		self.curJumps = 1
		self.isOnFloor = false
		self:dispatchEvent(self.jumpEvent)
	end
end
--
function Platformer:setGravity(grav) GRAVITY = tonumber(grav) end

function Platformer:setPosition(x, y)
	x = tonumber(x)
	y = tonumber(y)
	
	self.world:update(self, x, y)
	Sprite.setPosition(self, x, y)
end
--
function Platformer:setX(x)
	x = tonumber(x)
	self.world:update(self, x, self:getY())
	Sprite.setX(self, x)
end
--
function Platformer:setY(y)	
	y = tonumber(y)
	self.world:update(self, self:getX(), y)
	Sprite.setY(self, y)
end