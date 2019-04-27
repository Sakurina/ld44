ControlsLayer = Layer:extend()

function ControlsLayer:new()
    ControlsLayer.super.new(self)
    self.layer_name = "ControlsLayer"
    self.selected_index = 1
    self.bindings = shallowcopy(layer_manager.controls)
end

-- CALLBACKS

function ControlsLayer:draw()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local i = 1
    for k, v in pairs(self.bindings) do
        if i == self.selected_index then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        local y = 10 + i * 35
        love.graphics.print(k, 10, y)
        love.graphics.print(v, 100, y)
        i = i + 1
    end
end

function ControlsLayer:update(dt)
    return
end

function ControlsLayer:keypressed(key, scancode, isrepeat)
    if self.paused == true then
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
    elseif key == layer_manager.controls["Back"] then
        self:save_bindings()
        local destination_layer = MenuLayer()
        destination_layer:pause()
        layer_manager:reload_controls()
        layer_manager:transition(self, destination_layer)
    end
end

function ControlsLayer:keyreleased(key, scancode)
    return
end

-- FUNCTIONALITY

function ControlsLayer:previous_item()
    local dest = self.selected_index - 1
    if dest < 1 then
        dest = tablelength(self.bindings)
    end
    self.selected_index = dest
end

function ControlsLayer:next_item()
    local dest = self.selected_index + 1
    if dest > tablelength(self.bindings) then
        dest = 1
    end
    self.selected_index = dest
end

function ControlsLayer:select_item()
    local i = 1
    for k, v in pairs(self.bindings) do
        if i == self.selected_index then
            local destination_layer = ControlsOverlayLayer()
            destination_layer.table_key = k
            self:pause()
            layer_manager:prepend(destination_layer)
        end
        i = i + 1
    end
end

function ControlsLayer:register_binding(table_key, key)
    self.bindings[table_key] = key
end

function ControlsLayer:save_bindings()
    local as_json = json.encode(self.bindings)
    love.filesystem.write("controls.json", as_json)
end