Level = Core.class(Sprite)

function Level:init(world)
	self.world = world
	self.width = 0
	self.height = 0
	self.tilewidth = 0
	self.tileheight = 0
end
--
function Level:load(name)
	local map = require("levels/" .. name)
	self.width = map.width
	self.height = map.height
	self.tilewidth = map.tilewidth
	self.tileheight = map.tileheight
	
	local tilesetTexture = Texture.new(map.tilesets[1].image)
	local tilesetWidth   = tilesetTexture:getWidth() // self.tilewidth
	
	local data = {
		layers = {},
		playerData = {}
	}
	
	for i = 1, #map.layers do
		local layer = map.layers[i]
		
		if (layer.type == "imagelayer") then
			local camLayer = Layer.new(layer.name, layer.properties.paralax)
			local bmp = Bitmap.new(Texture.new(layer.image, true))
			bmp:setAnchorPosition(-layer.offsetx, -layer.offsety)
			camLayer:setAlpha(layer.opacity)
			camLayer:addChild(bmp)
			
			--camLayer:setPosition(layer.offsetx, layer.offsety)
			data.layers[#data.layers+1] = camLayer
		elseif (layer.type == "tilelayer") then
			local camLayer = Layer.new(layer.name, layer.properties.paralax)
			local tilemap = TileMap.new(layer.width, layer.height, tilesetTexture, self.tilewidth, self.tileheight)
			
			for y=1,layer.height do
				for x=1,layer.width do
					local i = x + (y - 1) * layer.width
					local gid = layer.data[i]
					
					if (gid > 0) then
						local tx = (gid - 1) %  tilesetWidth + 1
						local ty = (gid - 1) // tilesetWidth + 1
						
						tilemap:setTile(x, y, tx, ty)
					end
				end
			end
			camLayer:setAlpha(layer.opacity)
			camLayer:addChild(tilemap)
			data.layers[#data.layers+1] = camLayer
		elseif (layer.type == "objectgroup") then
			if (self.world ~= nil) then
				for _,v in ipairs(layer.objects) do
					-- ONLY non rotated rectangles, becouse collision engine is for AABB's (:
					if (v.shape == "rectangle" and v.rotation == 0) then
						self.world:add(v.properties, v.x, v.y, v.width, v.height)
					elseif (v.shape == "point" and v.rotation == 0) then
						data.playerData = v.properties
						data.playerData.x = v.x
						data.playerData.y = v.y
					end
				end
			end
		end
		
	end
	
	return data
end
