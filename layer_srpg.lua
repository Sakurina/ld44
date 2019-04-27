SRPGLayer = Layer:extend()

function SRPGLayer:new()
    SRPGLayer.super.new(self)
    self.layer_name = "SRPGLayer"

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

    -- units and animations
    self.p1 = P1Unit(2, 2)
    self.u1 = U1Unit(3, 3)
    self.u2 = U2Unit(2, 3)
    self.e2 = E2Unit(5, 5)
    self.e4 = E4Unit(6, 6)
end

-- CALLBACKS

function SRPGLayer:draw()
    camera:set()

    -- bottom: draw the map
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.map_img, 0, 0, 0, 4, 4)

    -- middle: other entities
    self.p1:draw()
    self.u1:draw()
    self.u2:draw()
    self.e2:draw()
    self.e4:draw()

    -- top: draw the cursor
    local cursor_x = constants.pixel_tile_width * constants.pixel_integer_scale * self.cursor_tile_x
    local cursor_y = constants.pixel_tile_height * constants.pixel_integer_scale * self.cursor_tile_y
    local cursor_proj_x = constants.pixel_tile_width * constants.pixel_integer_scale * self.cursor_tile_target_x
    local cursor_proj_y = constants.pixel_tile_height * constants.pixel_integer_scale * self.cursor_tile_target_y
    if cursor_x ~= cursor_proj_x or cursor_y ~= cursor_proj_y then
        local interpolation = self.cursor_tile_anim_accumulator / constants.cursor_move_speed
        cursor_x = lume.lerp(cursor_x, cursor_proj_x, interpolation)
        cursor_y = lume.lerp(cursor_y, cursor_proj_y, interpolation)
    end
    local cursor_width = constants.pixel_tile_width * constants.pixel_integer_scale
    local cursor_height = constants.pixel_tile_height * constants.pixel_integer_scale
    love.graphics.setColor(0, 0, 1, 0.5)
    love.graphics.rectangle('fill', cursor_x, cursor_y, cursor_width, cursor_height)

    camera:unset()

    -- draw UI?
end

function SRPGLayer:update(dt)
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local cursor_x = constants.pixel_tile_width * constants.pixel_integer_scale * self.cursor_tile_x
    local cursor_y = constants.pixel_tile_height * constants.pixel_integer_scale * self.cursor_tile_y
    local cursor_proj_x = constants.pixel_tile_width * constants.pixel_integer_scale * self.cursor_tile_target_x
    local cursor_proj_y = constants.pixel_tile_height * constants.pixel_integer_scale * self.cursor_tile_target_y
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
    local max_x = self.tile_width_count * constants.pixel_tile_width * constants.pixel_integer_scale - window_width
    local max_y = self.tile_height_count * constants.pixel_tile_height * constants.pixel_integer_scale - window_height
    camera_x = lume.clamp(camera_x, camera_x, max_x)
    camera_y = lume.clamp(camera_y, camera_y, max_y)
    camera:setPosition(camera_x, camera_y)

    self.p1:update(dt)
    self.u1:update(dt)
    self.u2:update(dt)
    self.e2:update(dt)
    self.e4:update(dt)
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
    elseif key == '1' then
        self.p1.active_animation = 'walk_animation'
        self.u1.active_animation = 'walk_animation'
        self.u2.active_animation = 'walk_animation'
        self.e2.active_animation = 'walk_animation'
        self.e4.active_animation = 'walk_animation'
    elseif key == '2' then
        self.p1.active_animation = 'cast_animation'
        self.u1.active_animation = 'cast_animation'
        self.u2.active_animation = 'cast_animation'
        self.e2.active_animation = 'cast_animation'
        self.e4.active_animation = 'cast_animation'
    elseif key == '3' then
        self.p1.active_animation = 'damage_animation'
        self.u1.active_animation = 'damage_animation'
        self.u2.active_animation = 'damage_animation'
        self.e2.active_animation = 'damage_animation'
        self.e4.active_animation = 'damage_animation'
    end

    self.cursor_tile_target_x = lume.clamp(self.cursor_tile_target_x, 0, self.tile_width_count - 1)
    self.cursor_tile_target_y = lume.clamp(self.cursor_tile_target_y, 0, self.tile_height_count - 1)
end

function SRPGLayer:keyreleased(key, scancode)
    return
end

-- FUNCTIONALITY