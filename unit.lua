Unit = Object:extend()

function Unit:new(tile_x, tile_y)
    self.unit_name = "Unknown Unit"
    self.user_controlled = false

    self.purge = false
    
    -- Sprite
    self.sprite_sheet = nil 
    self.active_animation = 'walk_animation'
    self.has_feet = false
    self.walk_animation = nil
    self.cast_animation = nil
    self.damage_animation = nil
    self.cast_animation_callback = nil
    self.damage_animation_callback = nil
    self.cast_animation_accumulator = 0
    self.damage_animation_accumulator = 0

    -- Movement
    self.move_range = 0
    self.tile_x = tile_x
    self.tile_y = tile_y
    self.tile_target_x = tile_x
    self.tile_target_y = tile_y
    self.pixel_x = constants.pixel_tile_width * constants.pixel_integer_scale * self.tile_x
    self.pixel_y = constants.pixel_tile_height * constants.pixel_integer_scale * self.tile_y
    self.tile_move_accumulator = 0
    self.move_queue = {}
    self.processing_move_queue = false
    self.moved_this_turn = false

    -- Combat math
    self.hp = 0
    self.atk = 0
    self.def = 0
end

-- UPDATE RUN LOOP
function Unit:update(dt)
    if self.tile_x ~= self.tile_target_x or self.tile_y ~= self.tile_target_y then
        self.tile_move_accumulator = self.tile_move_accumulator + dt
    end
    if self.tile_move_accumulator > constants.unit_move_speed then
        self.tile_x = self.tile_target_x
        self.tile_y = self.tile_target_y
        self.tile_move_accumulator = 0
    end
    if self.active_animation == 'cast_animation' and self.cast_animation_callback ~= nil then
        self.cast_animation_accumulator = self.cast_animation_accumulator + dt
        if self.cast_animation_accumulator >= constants.cast_animation_length then
            self.cast_animation_accumulator = 0
            self.cast_animation_callback()
            self.cast_animation_callback = nil
        end
    elseif self.active_animation == 'damage_animation' and self.damage_animation_callback ~= nil then
        self.damage_animation_accumulator = self.damage_animation_accumulator + dt
        if self.damage_animation_accumulator >= constants.damage_animation_length then
            self.cast_animation_accumulator = 0
            self.damage_animation_callback()
            self.damage_animation_callback = nil
        end
    end

    if self.processing_move_queue == true then
        self:process_move_queue()
    end

    local offset_x = (constants.pixel_sprite_width - constants.pixel_tile_width) * 0.5 * constants.pixel_integer_scale;
    local offset_y = (constants.pixel_sprite_height - constants.pixel_tile_width) * 0.5 * constants.pixel_integer_scale;
    if self.active_animation == 'walk_animation' and self[self.active_animation].position == 2 then
        offset_y = offset_y + constants.pixel_integer_scale
    end
    if self.has_feet == true then
        offset_y = offset_y + constants.pixel_sprite_foot_offset
    end
    local pixel_x = constants.pixel_tile_width * constants.pixel_integer_scale * self.tile_x - offset_x
    local pixel_y = constants.pixel_tile_height * constants.pixel_integer_scale * self.tile_y - offset_y
    local pixel_proj_x = constants.pixel_tile_width * constants.pixel_integer_scale * self.tile_target_x - offset_x
    local pixel_proj_y = constants.pixel_tile_height * constants.pixel_integer_scale * self.tile_target_y - offset_y
    local interpolation = self.tile_move_accumulator / constants.unit_move_speed
    self.pixel_x = lume.lerp(pixel_x, pixel_proj_x, interpolation)
    self.pixel_y = lume.lerp(pixel_y, pixel_proj_y, interpolation)
    self.walk_animation:update(dt)
end

function Unit:draw()
    if self.moved_this_turn == true then
        love.graphics.setColor(1, 1, 1, 0.5)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    self[self.active_animation]:draw(self.sprite_sheet, self.pixel_x, self.pixel_y, 0, constants.pixel_integer_scale, constants.pixel_integer_scale)
end

function Unit:queue_move(x, y)
    table.insert(self.move_queue, { x = x, y = y })
    log(lume.format("[{1}] {2}", { self.unit_name, lume.serialize(self.move_queue) }))
end

function Unit:process_move_queue()
    if self.tile_x == self.tile_target_x and self.tile_y == self.tile_target_y then
        if #(self.move_queue) > 0 then
            local first = self.move_queue[1]
            self.tile_target_x = first.x
            self.tile_target_y = first.y
            self.active_animation = 'walk_animation'
            self[self.active_animation]:resume()
            lume.remove(self.move_queue, first)
        else
            self.processing_move_queue = false
            self[self.active_animation]:pauseAtStart()
            self.moved_this_turn = true
        end
    end
end

function Unit:raw_allowed_tiles()
    local result = {}
    for y=self.move_range, 0, -1 do
        table.insert(result, { x = self.tile_x , y = self.tile_y + y })
        table.insert(result, { x = self.tile_x , y = self.tile_y - y })
        for x = 0, self.move_range - y, 1 do
            table.insert(result, { x = self.tile_x - x, y = self.tile_y - y })
            table.insert(result, { x = self.tile_x - x, y = self.tile_y + y })
            table.insert(result, { x = self.tile_x + x, y = self.tile_y - y })
            table.insert(result, { x = self.tile_x + x, y = self.tile_y + y })
        end
    end
    for x=self.move_range, 0, -1 do
        table.insert(result, { x = self.tile_x - x, y = self.tile_y })
        table.insert(result, { x = self.tile_x + x, y = self.tile_y })
    end
    return result
end

function Unit:enter_cast_animation(callback)
    self.cast_animation_callback = callback
    self.active_animation = 'cast_animation'
end

function Unit:enter_damage_animation(callback)
    self.damage_animation_callback = callback
    self.active_animation = 'damage_animation'
end