LoseLayer = Layer:extend()

function LoseLayer:new()
    LoseLayer.super.new(self)
    self.layer_name = "LoseLayer"
end

-- CALLBACKS

function LoseLayer:draw()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Game over!", 10, 10)
end

function LoseLayer:update(dt)
    return
end

function LoseLayer:keypressed(key, scancode, isrepeat)
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

function LoseLayer:keyreleased(key, scancode)
    return
end