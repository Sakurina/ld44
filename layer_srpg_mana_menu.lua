ManaAbilityMenuLayer = Layer:extend()

function ManaAbilityMenuLayer:new(unit, callback)
    ManaAbilityMenuLayer.super.new(self)
    self.layer_name = "ManaAbilityMenuLayer"
    self.abilities = {}

    if unit.has_doublestr == false then
        table.insert(self.abilities, {
            name = "Double Strike",
            description = "Deal 2 hits when attacking.",
            r_cost = 4,
            g_cost = 0,
            b_cost = 0
        })
    end
    if unit.has_reflect == false then
        table.insert(self.abilities, {
            name = "Reflector Gate",
            description = "Reflect 50% damage taken when defending.",
            r_cost = 1,
            b_cost = 2,
            g_cost = 0
        })
    end
    if unit.has_healaura == false then
        table.insert(self.abilities, {
            name = "Healing Aura",
            description = "15% heal at start of turn.",
            r_cost = 0,
            g_cost = 2,
            b_cost = 1
        })
    end
    if unit.has_hungering == false then
        table.insert(self.abilities, {
            name = "Hunger Blade",
            description = "Heal 50% damage dealt when attacking.",
            r_cost = 2,
            g_cost = 1,
            b_cost = 0
        })
    end
    self.mode = mode
    self.selected_index = 1
    self.propagate_input_to_underlying = false
    self.callback = callback
end

-- CALLBACKS

function ManaAbilityMenuLayer:draw()
    local height = constants.unit_menu_height_per_item * (#(self.abilities) + 2) + constants.unit_menu_bottom_padding
    
    -- border
    love.graphics.setColor(constants.ui_border_r, constants.ui_border_g, constants.ui_border_b, 1.0)
    love.graphics.rectangle('fill', 
        constants.unit_menu_x - 4, 
        constants.unit_menu_y - 4, 
        constants.mana_menu_width + 8, 
        height + 8)

    -- background
    love.graphics.setColor(constants.ui_bg_r, constants.ui_bg_g, constants.ui_bg_b, 1.0)
    love.graphics.rectangle('fill', 
        constants.unit_menu_x, 
        constants.unit_menu_y, 
        constants.mana_menu_width, 
        height)

    -- column header icons
    -- todo

    -- available mana
    love.graphics.setFont(constants.big_font)

    -- ability list
    local did_selected = false
    for i = 1, #self.abilities do
        if i == self.selected_index then
            love.graphics.setColor(constants.ui_em_r, constants.ui_em_g, constants.ui_em_b, 1.0)
        else
            love.graphics.setColor(constants.ui_deem_r, constants.ui_deem_g, constants.ui_deem_b, 1.0)
        end
        local j = i
        if did_selected == true then
            j = j + 1
        end
        local y = 16 + j * constants.unit_menu_height_per_item
        love.graphics.print(self.abilities[i].name, 32, y)  -- name
                                                            -- r cost
                                                            -- g cost
                                                            -- b cost
        if i == self.selected_index then
            y = 16 + (i + 1) * constants.unit_menu_height_per_item
            love.graphics.setColor(constants.ui_text_r, constants.ui_text_g, constants.ui_text_b, 1.0)
            love.graphics.print(self.abilities[self.selected_index].description, 48, y)
            did_selected = true
        end
    end
end

function ManaAbilityMenuLayer:update(dt)
    return
end

function ManaAbilityMenuLayer:keypressed(key, scancode, isrepeat)
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

function ManaAbilityMenuLayer:keyreleased(key, scancode)
    return
end

-- FUNCTIONALITY 

function ManaAbilityMenuLayer:previous_item()
    local dest = self.selected_index - 1
    if dest < 1 then
        dest = #self.abilities
    end
    self.selected_index = dest
end

function ManaAbilityMenuLayer:next_item()
    local dest = self.selected_index + 1
    if dest > #self.abilities then
        dest = 1
    end
    self.selected_index = dest
end

function ManaAbilityMenuLayer:select_item()
    log(lume.format("[{1}] Index {2} selected", { self.layer_name, self.selected_index }))
    if self.callback ~= nil then
        self.callback(self.abilities[self.selected_index])
    end
end

function ManaAbilityMenuLayer:dismiss_menu()
    if self.callback ~= nil then
        self.callback(nil)
    end
end