WinLayer = Layer:extend()

function WinLayer:new()
    WinLayer.super.new(self)
    self.layer_name = "WinLayer"
    self.bg_img = love.graphics.newImage('gfx/cutscene/end_1.png')
end

-- CALLBACKS

function WinLayer:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.bg_img, 0, 0, 0, 4, 4)
end

function WinLayer:update(dt)
    return
end

function WinLayer:keypressed(key, scancode, isrepeat)
    if self.paused == 1 then
        return
    end
    if isrepeat == true then
        return
    end

    if key == layer_manager.controls["Confirm"] then
        local menu = MenuLayer()
        layer_manager:transition(self, menu)
    end
end

function WinLayer:keyreleased(key, scancode)
    return
end