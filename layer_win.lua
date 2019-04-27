WinLayer = Layer:extend()

function WinLayer:new()
    WinLayer.super.new(self)
    self.layer_name = "WinLayer"
end

-- CALLBACKS

function WinLayer:draw()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("You win!", 10, 10)
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