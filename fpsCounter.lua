FpsCounter = Core.class(Sprite)

function FpsCounter:init(font)
	self.tf = TextField.new(font, "FPS: -")
	self:addChild(self.tf)
	
	self.counter = 0
end
--
function FpsCounter:update(dt)
	self.counter += dt
	if (self.counter >= 1) then
		self.counter = 0
		self.tf:setText("FPS: " .. 1//dt)
	end
end