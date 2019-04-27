SRPGLayer = Layer:extend()

function SRPGLayer:new()
    SRPGLayer.super.new(self)
    self.layer_name = "SRPGLayer"
    self.active_mode = 'overview'

    -- cursor placement
    self.cursor_tile_x = 0
    self.cursor_tile_y = 0
    self.cursor_tile_target_x = 0
    self.cursor_tile_target_y = 0
    self.cursor_tile_anim_accumulator = 0

    -- map loading and dimensions
    self.map_img_file = 'maps/testmap.png'
    self.map_img = love.graphics.newImage(self.map_img_file)
    self.map_img_width = 1280
    self.map_img_height = 1280
    camera:setBounds(0, 0, self.map_img_width * constants.pixel_integer_scale, self.map_img_height * constants.pixel_integer_scale)
    self.tile_width_count = self.map_img_width / constants.pixel_tile_width
    self.tile_height_count = self.map_img_height / constants.pixel_tile_height
    log(lume.format("[{1}] loaded map {2} ({3}x{4}px, {5}x{6} tile count)", {self.layer_name, self.map_img_file, self.map_img_width, self.map_img_height, self.tile_width_count, self.tile_height_count }))

    -- selection mode stuff
    self.allowed_tiles = {}
    self.selected_unit = nil
    self.target_unit = nil

    -- units and animations
    self.units = {}
    table.insert(self.units, P1Unit(2,2))
    table.insert(self.units, U1Unit(3,3))
    table.insert(self.units, U2Unit(2,3))
    table.insert(self.units, E2Unit(5,5))
    table.insert(self.units, E4Unit(6,6))
end

-- CALLBACKS

function SRPGLayer:draw()
    camera:set()

    local tile_width_px = constants.pixel_tile_width * constants.pixel_integer_scale
    local tile_height_px = constants.pixel_tile_height * constants.pixel_integer_scale

    -- bottom: draw the map
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.map_img, 0, 0, 0, 4, 4)

    -- in selection mode, gray out areas that cannot be targeted
    if self.active_mode == 'selection' then
        for y=0, self.tile_height_count, 1 do
            for x=0, self.tile_width_count, 1 do
                if lume.any(self.allowed_tiles, function(t) return t.x == x and t.y == y end) == false then
                    local restricted_tile_x = x_for_tile(x)
                    local restricted_tile_y = y_for_tile(y)
                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.rectangle('fill', restricted_tile_x, restricted_tile_y, tile_width_px, tile_height_px)
                end
            end
        end
    end

    -- middle: other entities
    love.graphics.setColor(1, 1, 1, 1)
    lume.each(self.units, "draw")

    -- top: draw the cursor
    local cursor_x = x_for_tile(self.cursor_tile_x)
    local cursor_y = y_for_tile(self.cursor_tile_y)
    local cursor_proj_x = x_for_tile(self.cursor_tile_target_x)
    local cursor_proj_y = y_for_tile(self.cursor_tile_target_y)
    if cursor_x ~= cursor_proj_x or cursor_y ~= cursor_proj_y then
        local interpolation = self.cursor_tile_anim_accumulator / constants.cursor_move_speed
        cursor_x = lume.lerp(cursor_x, cursor_proj_x, interpolation)
        cursor_y = lume.lerp(cursor_y, cursor_proj_y, interpolation)
    end

    love.graphics.setColor(0, 0, 1, 0.5)
    love.graphics.rectangle('fill', cursor_x, cursor_y, tile_width_px, tile_height_px)

    camera:unset()

    -- draw UI?
end

function SRPGLayer:update(dt)
    if self.active_mode == 'animation_wait' then
        if self.selected_unit ~= nil and self.selected_unit.processing_move_queue == false then
            self.active_mode = 'overview'
            self.selected_unit = nil
        end
    end
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local cursor_x = x_for_tile(self.cursor_tile_x)
    local cursor_y = y_for_tile(self.cursor_tile_y)
    local cursor_proj_x = x_for_tile(self.cursor_tile_target_x)
    local cursor_proj_y = y_for_tile(self.cursor_tile_target_y)

    if cursor_x ~= cursor_proj_x or cursor_y ~= cursor_proj_y then
        self.cursor_tile_anim_accumulator = self.cursor_tile_anim_accumulator + dt
        local interpolation = self.cursor_tile_anim_accumulator / constants.cursor_move_speed
        cursor_x = lume.lerp(cursor_x, cursor_proj_x, interpolation)
        cursor_y = lume.lerp(cursor_y, cursor_proj_y, interpolation)
        if self.cursor_tile_anim_accumulator > constants.cursor_move_speed then
            self.cursor_tile_x = self.cursor_tile_target_x
            self.cursor_tile_y = self.cursor_tile_target_y
            self.cursor_tile_anim_accumulator = 0
        end
    end

    local cursor_width = constants.pixel_tile_width * constants.pixel_integer_scale
    local cursor_height = constants.pixel_tile_height * constants.pixel_integer_scale
    local camera_x = cursor_x - window_width / 2 + cursor_width / 2
    local camera_y = cursor_y - window_height / 2 + cursor_height / 2
    local max_x = x_for_tile(self.tile_width_count) - window_width
    local max_y = y_for_tile(self.tile_height_count) - window_height
    camera_x = lume.clamp(camera_x, camera_x, max_x)
    camera_y = lume.clamp(camera_y, camera_y, max_y)
    camera:setPosition(camera_x, camera_y)

    lume.each(self.units, "update", dt)
end

function SRPGLayer:keypressed(key, scancode, isrepeat)
    if self.paused == 1 then
        return
    end
    if self.cursor_tile_anim_accumulator ~= 0 then
        return
    end

    if key == layer_manager.controls["Up"] then
        self.cursor_tile_target_y = self.cursor_tile_target_y - 1
    elseif key == layer_manager.controls["Down"] then
        self.cursor_tile_target_y = self.cursor_tile_target_y + 1
    elseif key == layer_manager.controls["Left"] then
        self.cursor_tile_target_x = self.cursor_tile_target_x - 1
    elseif key == layer_manager.controls["Right"] then
        self.cursor_tile_target_x = self.cursor_tile_target_x + 1
    elseif key == layer_manager.controls["Back"] then
        self.active_mode = 'overview'
        self.allowed_tiles = {}
    elseif key == layer_manager.controls["Confirm"] then
        if self.active_mode == 'overview' then
            local units = lume.filter(self.units, function(u) return u.tile_x == self.cursor_tile_x and u.tile_y == self.cursor_tile_y end)
            if #units > 0 and units[1].user_controlled == true and units[1].moved_this_turn == false then
                self.active_mode = 'selection'
                self.selected_unit = units[1]
                self.allowed_tiles = units[1]:raw_allowed_tiles()
            end
        elseif self.active_mode == 'selection' then
            self.active_mode = 'animation_wait'
            self.selected_unit.processing_move_queue = true
        end
    elseif key == '1' then
        lume.each(self.units, function(u) u.active_animation = 'walk_animation' end)
    elseif key == '2' then
        lume.each(self.units, function(u) u.active_animation = 'cast_animation' end)
    elseif key == '3' then
        lume.each(self.units, function(u) u.active_animation = 'damage_animation' end)
    end

    self.cursor_tile_target_x = lume.clamp(self.cursor_tile_target_x, 0, self.tile_width_count - 1)
    self.cursor_tile_target_y = lume.clamp(self.cursor_tile_target_y, 0, self.tile_height_count - 1)

    if self.active_mode == 'selection' then
        if lume.any(self.allowed_tiles, function(t) return t.x == self.cursor_tile_target_x and t.y == self.cursor_tile_target_y end) == false then
            self.cursor_tile_target_x = self.cursor_tile_x
            self.cursor_tile_target_y = self.cursor_tile_y
        end
        if self.selected_unit ~= nil and (self.cursor_tile_x ~= self.cursor_tile_target_x or self.cursor_tile_y ~= self.cursor_tile_target_y) then
            self.selected_unit:queue_move(self.cursor_tile_target_x, self.cursor_tile_target_y)
        end
    end
    
end

function SRPGLayer:keyreleased(key, scancode)
    return
end

-- FUNCTIONALITY