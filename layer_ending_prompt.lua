EndingPromptLayer = Layer:extend()

function EndingPromptLayer:new()
    EndingPromptLayer.super.new(self)
    self.layer_name = "EndingPromptLayer"
    self.selected_index = 1
    self.items = {"Play Again", "View Ending" }
end

-- CALLBACKS

function EndingPromptLayer:draw()
    love.graphics.setColor(constants.ui_bg_r, constants.ui_bg_g, constants.ui_bg_b, 1.0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    for i = 1, #self.items do
        if i == self.selected_index then
            love.graphics.setColor(constants.ui_em_r, constants.ui_em_g, constants.ui_em_b, 1.0)
        else
            love.graphics.setColor(constants.ui_deem_r, constants.ui_deem_g, constants.ui_deem_b, 1.0)
        end
        local y = 10 + i * 35
        love.graphics.print(self.items[i], 10, y)
    end
end

function EndingPromptLayer:update(dt)
    return
end

function EndingPromptLayer:keypressed(key, scancode, isrepeat)
    if self.paused == 1 then
        return
    end
    if isrepeat == true then
        return
    end

    if key == layer_manager.controls["Up"] then
        self:previous_item()
    elseif key == layer_manager.controls["Down"] then
        self:next_item()
    elseif key == layer_manager.controls["Confirm"] then
        self:select_item()
    end
end

function EndingPromptLayer:keyreleased(key, scancode)
    return
end

-- FUNCTIONALITY 

function EndingPromptLayer:previous_item()
    local dest = self.selected_index - 1
    if dest < 1 then
        dest = #self.items
    end
    self.selected_index = dest
end

function EndingPromptLayer:next_item()
    local dest = self.selected_index + 1
    if dest > #self.items then
        dest = 1
    end
    self.selected_index = dest
end

function EndingPromptLayer:select_item()
    log(lume.format("[{1}] Index {2} selected", { self.layer_name, self.selected_index }))
    local destination_layer = null
    if self.selected_index == 1 then
        destination_layer = SRPGLayer()
    end
    if self.selected_index == 2 then
        destination_layer = WinLayer()
    end
    if destination_layer ~= nil then
        layer_manager:transition(self, destination_layer)
    end
end