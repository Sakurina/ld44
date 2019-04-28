UnitSelectMenuLayer = Layer:extend()

function UnitSelectMenuLayer:new(mode, callback)
    UnitSelectMenuLayer.super.new(self)
    self.layer_name = "UnitSelectMenuLayer"
    self.mode = mode
    self.selected_index = 1
    self.items = self:items_for_mode(mode)
    self.propagate_input_to_underlying = false
    self.callback = callback
end

-- CALLBACKS

function UnitSelectMenuLayer:draw()
    local height = constants.unit_menu_height_per_item * #(self.items) + constants.unit_menu_bottom_padding
    love.graphics.setColor(constants.ui_border_r, constants.ui_border_g, constants.ui_border_b, 1.0)
    love.graphics.rectangle('fill', 
        constants.unit_menu_x - 4, 
        constants.unit_menu_y - 4, 
        constants.unit_menu_width + 8, 
        height + 8)
    love.graphics.setColor(constants.ui_bg_r, constants.ui_bg_g, constants.ui_bg_b, 1.0)
    love.graphics.rectangle('fill', 
        constants.unit_menu_x, 
        constants.unit_menu_y, 
        constants.unit_menu_width, 
        height)

    love.graphics.setFont(constants.big_font)
    for i = 1, #self.items do
        if i == self.selected_index then
            love.graphics.setColor(constants.ui_em_r, constants.ui_em_g, constants.ui_em_b, 1.0)
        else
            love.graphics.setColor(constants.ui_text_r, constants.ui_text_g, constants.ui_text_b, 1.0)
        end
        local y = 16 + (i-1) * constants.unit_menu_height_per_item
        love.graphics.print(self.items[i], 32, y)
    end 
end

function UnitSelectMenuLayer:update(dt)
    return
end

function UnitSelectMenuLayer:keypressed(key, scancode, isrepeat)
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
    elseif key == layer_manager.controls["Back"] then
        self:dismiss_menu()
    end
end

function UnitSelectMenuLayer:keyreleased(key, scancode)
    return
end

-- FUNCTIONALITY 

function UnitSelectMenuLayer:previous_item()
    local dest = self.selected_index - 1
    if dest < 1 then
        dest = #self.items
    end
    self.selected_index = dest
end

function UnitSelectMenuLayer:next_item()
    local dest = self.selected_index + 1
    if dest > #self.items then
        dest = 1
    end
    self.selected_index = dest
end

function UnitSelectMenuLayer:select_item()
    log(lume.format("[{1}] Index {2} selected", { self.layer_name, self.selected_index }))
    if self.callback ~= nil then
        self.callback(self.items[self.selected_index])
    end
end

function UnitSelectMenuLayer:items_for_mode(mode)
    if mode == 'blank_tile' then
        return { "Pass Turn" }
    elseif mode == 'basic_unit' then
        return { "Move", "Attack", "Sacrifice", "Wait", "Pass Turn" }
    elseif mode == 'basic_unit_no_atk' then
        return { "Move", "Sacrifice", "Wait", "Pass Turn" }
    elseif mode == 'hero_unit' then
        return { "Move", "Attack", "Special", "Wait", "Pass Turn" }
    elseif mode == 'hero_unit_no_atk' then
        return { "Move", "Special", "Wait", "Pass Turn" }
    end
end

function UnitSelectMenuLayer:dismiss_menu()
    if self.callback ~= nil then
        self.callback(nil)
    end
end