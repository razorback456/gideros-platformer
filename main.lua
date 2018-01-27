local dx, dy, w, h = application:getDeviceSafeArea(true)

ScreenW = w
ScreenH = h

stage:setPosition(dx, dy)

local scene = GameScene.new()
stage:addChild(scene)
