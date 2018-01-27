Player = Core.class(Platformer)

function Player:init(world, params)
	self.jumpStr = 680
	self.moveSpeed = 35
	
	local pic = Bitmap.new(Texture.new("gfx/char.png"))
	self:addChild(pic)	
end