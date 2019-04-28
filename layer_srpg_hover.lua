HoverUILayer = Layer:extend()

function HoverUILayer:new()
    HoverUILayer.super.new(self)
    self.layer_name = "HoverUILayer"

    self.from_hp = 4
    self.to_hp = 4
    self.max_hp = 4
    self.counter = 0
    self.unit_name = "(no selection)"
    self.show_ui = false
    self.animation_length = constants.hover_ui_hpbar_speed
end

-- CALLBACKS

function HoverUILayer:draw()
    if self.show_ui == false then
        return
    end

    -- background
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill',
        constants.hover_ui_hpbar_x - constants.pixel_integer_scale,
        constants.hover_ui_hpbar_y - constants.pixel_integer_scale,
        constants.hover_ui_width + 2 * constants.pixel_integer_scale,
        constants.hover_ui_hpbar_height + constants.hover_ui_height + 2 * constants.pixel_integer_scale)
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.rectangle('fill', 
        constants.hover_ui_x, 
        constants.hover_ui_y, 
        constants.hover_ui_width, 
        constants.hover_ui_height)

    -- hp bar (empty)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('fill',
        constants.hover_ui_hpbar_x,
        constants.hover_ui_hpbar_y,
        constants.hover_ui_hpbar_width,
        constants.hover_ui_hpbar_height)

    -- hp bar (fill)
    local display_hp = self.from_hp
    if self.from_hp ~= self.to_hp then
        local interpolation = self.counter / self.animation_length
        display_hp = lume.smooth(self.from_hp, self.to_hp, interpolation)
    end
    local fill_fraction = display_hp / self.max_hp
    if fill_fraction < 0 then
        fill_fraction = 0
    end
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill',
        constants.hover_ui_hpbar_x,
        constants.hover_ui_hpbar_y,
        constants.hover_ui_hpbar_width * fill_fraction,
        constants.hover_ui_hpbar_height)

    -- unit name
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(love.graphics.newFont(72))
    love.graphics.print(self.unit_name, constants.hover_ui_x + 16 , constants.hover_ui_y + 16)
end

function HoverUILayer:update(dt)
    if self.from_hp ~= self.to_hp then
        self.counter = self.counter + dt
    end
    if self.counter >= self.animation_length then
        self.from_hp = self.to_hp
        self.counter = 0
    end
    return
end

function HoverUILayer:keypressed(key, scancode, isrepeat)
    return
end

function HoverUILayer:keyreleased(key, scancode)
    return
end