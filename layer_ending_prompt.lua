EndingPromptLayer = Layer:extend()

function EndingPromptLayer:new()
    EndingPromptLayer.super.new(self)
    self.layer_name = "EndingPromptLayer"
    self.selected_index = 1
    self.question1 = "Congratulations... You won fair and square."
    self.question2 = "What is your wish?"
    self.items = {"Play Again", "View Ending" }
    self.img = love.graphics.newImage("gfx/cutscene/end_0.png")
    self.propagate_update_to_underlying = false

    self.counter = 0
    self.duration = 1

    self.faded_bg_layer = false
    self.faded_overlay_and_box = false
    self.faded_alpha = false
    self.faded_menu = false
    self.killed_underlying_layer = false
end

-- CALLBACKS

function EndingPromptLayer:draw()
    -- background layer 
    local bg_interpolation = self.counter
    if self.faded_bg_layer == true then
        bg_interpolation = 1
    end
    love.graphics.setColor(constants.end_bg_r, constants.end_bg_g, constants.end_bg_b, bg_interpolation)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- character overlay
    local overlay_interpolation = self.counter
    if self.faded_bg_layer == true then
        if self.faded_overlay_and_box == true then
            overlay_interpolation = 1
        end
        love.graphics.setColor(1, 1, 1, overlay_interpolation)
        love.graphics.draw(self.img, 240, 8, 0, 4, 4)
    end
    
    if self.faded_overlay_and_box == true then
        -- second alpha layer
        local alpha_interpolation = self.counter * 0.5
        if self.faded_alpha == true then
            alpha_interpolation = 0.5
        end
        love.graphics.setColor(constants.end_bg_r, constants.end_bg_g, constants.end_bg_b, alpha_interpolation)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    -- question box
    if self.faded_bg_layer == true then
        love.graphics.setColor(constants.ui_border_r, constants.ui_border_g, constants.ui_border_b, overlay_interpolation)
        love.graphics.rectangle('fill',
            constants.hover_ui_x - constants.pixel_integer_scale,
            constants.hover_ui_y - constants.pixel_integer_scale - 56,
            constants.hover_ui_width + 2 * constants.pixel_integer_scale,
            constants.hover_ui_height + 2 * constants.pixel_integer_scale + 56)
    
        love.graphics.setColor(constants.ui_bg_r, constants.ui_bg_g, constants.ui_bg_b, overlay_interpolation)
        love.graphics.rectangle('fill', 
            constants.hover_ui_x, 
            constants.hover_ui_y - 56, 
            constants.hover_ui_width, 
            constants.hover_ui_height + 56)
        love.graphics.setFont(constants.big_font)
        love.graphics.setColor(constants.ui_text_r, constants.ui_text_g, constants.ui_text_b, overlay_interpolation)
        love.graphics.print(self.question1, constants.hover_ui_x + 16 , constants.hover_ui_y + 2 - 56)
        love.graphics.print(self.question2, constants.hover_ui_x + 16 , constants.hover_ui_y + 2)
    end
    
    -- menu box
    if self.faded_alpha == true then
        local menu_interpolation = self.counter
        if self.faded_menu == true then
            menu_interpolation = 1
        end
        local menu_x = 501 - 16
        local menu_border_x = menu_x - 4
        local menu_y = 223 + constants.unit_menu_height_per_item - 16
        local menu_border_y = menu_y - 4
        local menu_width = 310
        local menu_height = 16 + 2 * constants.unit_menu_height_per_item + 16
        local menu_border_width = menu_width + 8
        local menu_border_height = menu_height + 8
    
        love.graphics.setColor(constants.ui_border_r, constants.ui_border_g, constants.ui_border_b, menu_interpolation)
        love.graphics.rectangle('fill',
            menu_border_x,
            menu_border_y,
            menu_border_width,
            menu_border_height)

        love.graphics.setColor(constants.ui_bg_r, constants.ui_bg_g, constants.ui_bg_b, menu_interpolation)
        love.graphics.rectangle('fill', 
            menu_x, 
            menu_y, 
            menu_width, 
            menu_height)

        -- menu items
        for i = 1, #self.items do
            if i == self.selected_index then
                love.graphics.setColor(constants.ui_em_r, constants.ui_em_g, constants.ui_em_b, menu_interpolation)
            else
                love.graphics.setColor(constants.ui_deem_r, constants.ui_deem_g, constants.ui_deem_b, menu_interpolation)
            end
            local y = 223 + i * constants.unit_menu_height_per_item
            love.graphics.print(self.items[i], 501, y)
        end
    end
    
end

function EndingPromptLayer:update(dt)
    self.counter = self.counter + dt

    if self.counter >= self.duration then
        if self.faded_bg_layer == false then
            self.faded_bg_layer = true
            layer_manager:remove_last()
        elseif self.faded_overlay_and_box == false then
            self.faded_overlay_and_box = true
        elseif self.faded_alpha == false then
            self.faded_alpha = true
        elseif self.faded_menu == false then
            self.faded_menu = true
        end
        self.counter = 0
    end

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