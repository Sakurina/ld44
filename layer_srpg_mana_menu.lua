ManaAbilityMenuLayer = Layer:extend()

function ManaAbilityMenuLayer:new(unit, callback)
    ManaAbilityMenuLayer.super.new(self)
    self.layer_name = "ManaAbilityMenuLayer"
    self.abilities = {}
    self.icons_sheet = love.graphics.newImage('gfx/gui/icons_1.png')
    local loaded_sheet = anim8.newGrid(16, 16, self.icons_sheet:getWidth(), self.icons_sheet:getHeight(), 0, 0)
    self.red_icon = anim8.newAnimation(loaded_sheet('1-1', 1), constants.animation_frame_length)
    self.green_icon = anim8.newAnimation(loaded_sheet('3-3', 1), constants.animation_frame_length)
    self.blue_icon = anim8.newAnimation(loaded_sheet('2-2', 1), constants.animation_frame_length)
    self.red_available = 0
    self.green_available = 0
    self.blue_available = 0

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
    local top_row_height = 16*4 + 16 * 2
    local height = top_row_height + constants.unit_menu_height_per_item * (#(self.abilities) + 2) + constants.unit_menu_bottom_padding
    
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
    local blue_x = constants.mana_menu_width - 16 - (16 * 4)
    local green_x = blue_x - 16 - (16 * 4)
    local red_x = green_x - 16 - (16 * 4)
    local blue_cost_x = blue_x + 20
    local green_cost_x = green_x + 20
    local red_cost_x = red_x + 20
    self.red_icon:draw(self.icons_sheet, red_x, 32, 0, 4, 4)
    self.green_icon:draw(self.icons_sheet, green_x, 32, 0, 4, 4)
    self.blue_icon:draw(self.icons_sheet, blue_x, 32, 0, 4 , 4)

    -- available mana
    love.graphics.setFont(constants.big_font)
    love.graphics.setColor(constants.ui_text_r, constants.ui_text_g, constants.ui_text_b, 1.0)
    love.graphics.print("Redeemable Sacrificed Units", 32, top_row_height)          -- name
    love.graphics.print(self.red_available, red_cost_x, top_row_height)     -- r cost
    love.graphics.print(self.green_available, green_cost_x, top_row_height)   -- g cost
    love.graphics.print(self.blue_available, blue_cost_x, top_row_height)    -- b cost
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
        local y = top_row_height + j * constants.unit_menu_height_per_item
        love.graphics.print(self.abilities[i].name, 32, y)          -- name
        love.graphics.print(self.abilities[i].r_cost, red_cost_x, y)     -- r cost
        love.graphics.print(self.abilities[i].g_cost, green_cost_x, y)   -- g cost
        love.graphics.print(self.abilities[i].b_cost, blue_cost_x, y)    -- b cost
        if i == self.selected_index then
            y = top_row_height + (j + 1) * constants.unit_menu_height_per_item
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