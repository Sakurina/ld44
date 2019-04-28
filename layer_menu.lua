MenuLayer = Layer:extend()

function MenuLayer:new()
    MenuLayer.super.new(self)
    self.layer_name = "MenuLayer"
    self.selected_index = 1
    self.items = {"Play", "Controls", "Quit", "Hover Debug"}
end

-- CALLBACKS

function MenuLayer:draw()
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    for i = 1, #self.items do
        if i == self.selected_index then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        local y = 10 + i * 35
        love.graphics.print(self.items[i], 10, y)
    end
end

function MenuLayer:update(dt)
    return
end

function MenuLayer:keypressed(key, scancode, isrepeat)
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

function MenuLayer:keyreleased(key, scancode)
    return
end

-- FUNCTIONALITY 

function MenuLayer:previous_item()
    local dest = self.selected_index - 1
    if dest < 1 then
        dest = #self.items
    end
    self.selected_index = dest
end

function MenuLayer:next_item()
    local dest = self.selected_index + 1
    if dest > #self.items then
        dest = 1
    end
    self.selected_index = dest
end

function MenuLayer:select_item()
    log(lume.format("[{1}] Index {2} selected", { self.layer_name, self.selected_index }))
    local destination_layer = null
    if self.selected_index == 1 then
        destination_layer = SRPGLayer()
    end
    if self.selected_index == 2 then
        destination_layer = ControlsLayer()
    end
    if self.selected_index == 4 then
        destination_layer = HoverUILayer()
    end
    if destination_layer ~= nil then
        layer_manager:transition(self, destination_layer)
    end
    if self.selected_index == 3 then
        love.event.push('quit')
    end
end