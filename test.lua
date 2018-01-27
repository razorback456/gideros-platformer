local TILE = 32
player = {
	x = 250,				-- позиция по Y
	y = 100,				-- позиция по Y
	dx = 0,					-- ускорение по X
	dy = 0,					-- ускорение по Y
	width = TILE,			-- ширина игрока
	height = TILE*1.5,		-- высота игрока
	friction = 7,			-- трение
	jumpPower = 680,		-- сила прыжка
	speed = 2000,			-- максимальная скорость передвижения
	maxFallSpeed = 650,		-- максимальная скорость падения
	isOnGround = false		-- стоит игрок или нет
}
local fdy = 0

function player:setPosition(x, y)
	self.x = x
	self.y = y
end

function player:jump(str)
	if self.isOnGround then
		self.dy = -str
		self.isOnGround = false
	end
end

function player:draw()
	-- отрисовка области в которой проверяются столкновения
	-- self:drawBounds() 
	GR.setColor(0, 150, 255, 255)
	GR.rectangle("fill", self.x, self.y, self.width, self.height)
	--[[
	GR.setColor(255, 255, 255, 255)
	GR.print(self.dx, self.x, self.y)
	GR.print(fdy, self.x, self.y+20)
	]]
end

function player:collide(d)
	for y = math.floor((self.y+E)/TILE), math.floor((self.y+self.height-E)/TILE) do
		for x = math.floor((self.x+E)/TILE), math.floor((self.x+self.width-E)/TILE) do
			local val = currentMap.nums[y][x]
			-- если задели стену
			if val == 1 then
				-- проверка столкновений по X
				if d == 0 then 
					if self.dx < 0 then -- слева
						self.x = x*TILE+self.width
						self.dx = 0
					end
				
					if self.dx > 0 then -- справа
						self.x = x*TILE-self.width
						self.dx = 0
					end
				else
				-- проверка столкновений по Y
					if self.dy < 0 then -- сверху
						self.y = y*TILE+TILE
						self.dy = 0
					end
					
					if self.dy > 0 then -- снизу
						self.y = y*TILE-self.height
						self.dy = 0
						self.isOnGround = true
					end
				end
			-- если задели желтый блок
			elseif val == 2 then
				-- удалить с карты
				removeItemFromMap(x, y)
				Scores = Scores + 1
			end
		end
	end
end

function player:update(dt)
	-- физика падения
	if not self.isOnGround then
		if self.dy < self.maxFallSpeed then 
			self.dy = self.dy + GRAVITY * dt
		end
		self.y = self.y + self.dy * dt
		
	else
		if math.abs(math.floor(self.dy)) == math.floor(GRAVITY*dt) then 
			self.dy = 0
		end
	end
	if love.keyboard.isDown("up") then
		self:jump(self.jumpPower)
	end
	self.isOnGround = false
	self:collide(1)
	-- физика передвижения влево, вправо
	if love.keyboard.isDown("right") and self.dx < self.speed then
		self.dx = self.dx + self.speed * dt
	elseif love.keyboard.isDown("left") and self.dx > -self.speed then
		self.dx = self.dx - self.speed * dt
	end
	self.dx = self.dx * (1 - math.min(dt * self.friction, 1))
	local fdx = math.abs(math.floor(self.dx))
	if fdx == 0 or fdx == 1 then self.dx = 0 end
	self.x = self.x + self.dx * dt
	self:collide(0)
	
	-- камера
	if self.x > -scrollX + scrW/2 then
		if math.abs(self.dx) > self.speed*dt then scrollX = scrollX - math.abs(self.dx) * dt end
	end
	if self.x < -scrollX + scrW/2 then
		if math.abs(self.dx) > self.speed*dt then scrollX = scrollX + math.abs(self.dx) * dt end
	end
	
	if self.y > -scrollY + scrH/2 then
		if math.abs(self.dy) > 0 then scrollY = scrollY - math.abs(self.dy) * dt end
	end
	if self.y < -scrollY + scrH/2 then
		if math.abs(self.dy) > 0 then scrollY = scrollY + math.abs(self.dy) * dt end
	end
	scrollX = clamp(scrollX, -((getMapWidth()*TILE)-scrW/2)/2, 0)
	scrollY = clamp(scrollY, -((getMapHeight()*TILE)-scrH/2)/2, 0)
end

function player:drawBounds()
	local left = math.floor((self.x+E)/TILE)
	local right = math.floor((self.x+self.width-E)/TILE)
	local top = math.floor((self.y+E)/TILE)
	local bottom = math.floor((self.y+self.height-E)/TILE)
	
	GR.setColor(255, 120, 0, 50)
	for y = top, bottom do
		for x = left, right do
			GR.rectangle("fill", x*TILE, y*TILE, TILE, TILE)
		end
	end
end