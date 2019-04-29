HoverUILayer = Layer:extend()

function HoverUILayer:new()
    HoverUILayer.super.new(self)
    self.layer_name = "HoverUILayer"

    self.from_hp = 4
    self.to_hp = 4
    self.max_hp = 4
    self.atk = 0
    self.def = 0
    self.counter = 0
    self.unit_name = "(no selection)"
    self.show_ui = false
    self.animation_length = constants.hover_ui_hpbar_speed
    self.pause_length = 0.3
    self.did_pause_complete = true
end

-- CALLBACKS

function HoverUILayer:draw()
    if self.show_ui == false then
        return
    end

    -- background
    love.graphics.setColor(constants.ui_border_r, constants.ui_border_g, constants.ui_border_b, 1.0)
    love.graphics.rectangle('fill',
        constants.hover_ui_hpbar_x - constants.pixel_integer_scale,
        constants.hover_ui_hpbar_y - constants.pixel_integer_scale,
        constants.hover_ui_width + 2 * constants.pixel_integer_scale,
        constants.hover_ui_hpbar_height + constants.hover_ui_height + 2 * constants.pixel_integer_scale)
    love.graphics.setColor(constants.ui_bg_r, constants.ui_bg_g, constants.ui_bg_b, 1.0)
    love.graphics.rectangle('fill', 
        constants.hover_ui_x, 
        constants.hover_ui_y, 
        constants.hover_ui_width, 
        constants.hover_ui_height)

    -- hp bar (empty)
    love.graphics.setColor(constants.ui_hp_empty_r, constants.ui_hp_empty_g, constants.ui_hp_empty_b, 1.0)
    love.graphics.rectangle('fill',
        constants.hover_ui_hpbar_x,
        constants.hover_ui_hpbar_y,
        constants.hover_ui_hpbar_width,
        constants.hover_ui_hpbar_height)

    -- hp bar (fill)
    local display_hp = self.from_hp
    if self.from_hp ~= self.to_hp then
        local interpolation = self.counter / self.animation_length
        if interpolation > 1 then
            interpolation = 1
        end
        display_hp = lume.smooth(self.from_hp, self.to_hp, interpolation)
    end
    local fill_fraction = display_hp / self.max_hp
    if fill_fraction < 0 then
        fill_fraction = 0
    end
    love.graphics.setColor(constants.ui_hp_fill_r, constants.ui_hp_fill_g, constants.ui_hp_fill_b, 1)
    love.graphics.rectangle('fill',
        constants.hover_ui_hpbar_x,
        constants.hover_ui_hpbar_y,
        constants.hover_ui_hpbar_width * fill_fraction,
        constants.hover_ui_hpbar_height)

    -- unit name
    love.graphics.setFont(constants.big_font)
    love.graphics.setColor(constants.ui_text_r, constants.ui_text_g, constants.ui_text_b, 1.0)
    love.graphics.print(self.unit_name, constants.hover_ui_x + 16 , constants.hover_ui_y + 2)

    local def_x = constants.hover_ui_x + constants.hover_ui_width - 16 - 55
    local def_lbl_x = def_x - 16 - 75
    local atk_x = def_lbl_x - 16 - 55
    local atk_lbl_x = atk_x - 16 - 75
    local hp_x = atk_lbl_x - 16 - 55
    local hp_lbl_x = hp_x - 16 - 55

    love.graphics.setColor(constants.ui_em_r, constants.ui_em_g, constants.ui_em_b, 1.0)
    love.graphics.print("DEF", def_lbl_x, constants.hover_ui_y + 2)
    love.graphics.print("ATK", atk_lbl_x, constants.hover_ui_y + 2)
    love.graphics.print("HP", hp_lbl_x, constants.hover_ui_y + 2)
    love.graphics.setColor(constants.ui_text_r, constants.ui_text_g, constants.ui_text_b, 1.0)
    love.graphics.print(self.def, def_x, constants.hover_ui_y + 2)
    love.graphics.print(self.atk, atk_x, constants.hover_ui_y + 2)
    love.graphics.print(self.from_hp, hp_x, constants.hover_ui_y + 2)
end

function HoverUILayer:update(dt)
    if self.from_hp ~= self.to_hp or not self.did_pause_complete then
        self.counter = self.counter + dt
    end
    if self.counter >= self.animation_length then
        self.from_hp = self.to_hp
    end
    if self.counter >= self.animation_length + self.pause_length then
        self.did_pause_complete = true
        self.counter = 0
        if self.hp_animation_callback ~= nil then
            self.hp_animation_callback()
            self.hp_animation_callback = nil
        end
    end
end

function HoverUILayer:keypressed(key, scancode, isrepeat)
    return
end

function HoverUILayer:keyreleased(key, scancode)
    return
end

function HoverUILayer:animate_to(hp, callback)
    self.to_hp = hp
    self.did_pause_complete = false
    self.hp_animation_callback = callback
end