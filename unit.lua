Unit = Object:extend()

function Unit:new(tile_x, tile_y)
    self.unit_name = "Unknown Unit"
    self.user_controlled = false

    self.purge = false
    
    -- Sprite
    self.sprite_sheet = nil
    self.sacrifice_fx_sheet = love.graphics.newImage('gfx/fx/sacrifice.png')
    local loaded_sacrifice_grid = anim8.newGrid(48, 48, self.sacrifice_fx_sheet:getWidth(), self.sacrifice_fx_sheet:getHeight(), 0, 0)
    self.hitspark_fx_sheet = love.graphics.newImage('gfx/fx/hitspark.png')
    local loaded_hitspark_grid = anim8.newGrid(48, 48, self.hitspark_fx_sheet:getWidth(), self.hitspark_fx_sheet:getHeight(), 0, 0)
    self.reflect_fx_sheet = love.graphics.newImage('gfx/fx/reflect.png')
    local loaded_reflect_grid = anim8.newGrid(24, 24, self.reflect_fx_sheet:getWidth(), self.reflect_fx_sheet:getHeight())
    self.healing_fx_sheet = love.graphics.newImage('gfx/fx/healspark.png')
    local loaded_healing_grid = anim8.newGrid(13, 13, self.healing_fx_sheet:getWidth(), self.healing_fx_sheet:getHeight())
    self.active_animation = 'walk_animation'
    self.has_feet = false
    self.facing_left = false
    self.mana_color = 'none'
    
    self.walk_animation = nil
    self.cast_animation = nil
    self.damage_animation = nil
    self.cast_animation_callback = nil
    self.damage_animation_callback = nil
    self.cast_animation_accumulator = 0
    self.damage_animation_accumulator = 0
    self.show_sacrifice_animation = false
    self.show_hitspark_animation = false
    self.show_reflect_animation = false

    self.sacrifice_animation = anim8.newAnimation(loaded_sacrifice_grid('1-5', 1), 
        constants.animation_frame_length,
        function(l)
            if self.sacrifice_animation_callback ~= nil then
                self.sacrifice_animation_callback()
                self.sacrifice_animation_callback = nil
                self.sacrifice_animation:pauseAtStart()
                self.show_sacrifice_animation = false
            end
        end)
    self.sacrifice_animation:pauseAtStart()
    self.sacrifice_animation_callback = nil

    self.hitspark_animation = anim8.newAnimation(loaded_hitspark_grid('1-5', 1), 
        constants.animation_frame_length,
        function(l)
            if self.hitspark_animation_callback ~= nil then
                local cb = self.hitspark_animation_callback
                self.hitspark_animation_callback = nil
                self.hitspark_animation:pauseAtStart()
                self.show_hitspark_animation = false
                cb()
            end
        end)
    self.hitspark_animation:pauseAtStart()
    self.hitspark_animation_callback = nil

    self.reflect_animation = anim8.newAnimation(loaded_reflect_grid('1-5', 1),
        constants.animation_frame_length,
        function(l)
            if self.reflect_animation_callback ~= nil then
                self.reflect_animation_callback()
                self.reflect_animation_callback = nil
                self.reflect_animation:pauseAtStart()
                self.show_reflect_animation = false
            end
        end)
    self.reflect_animation:pauseAtStart()
    self.reflect_animation_callback = nil

    self.healing_animation = anim8.newAnimation(loaded_healing_grid('1-6', 1),
        constants.animation_frame_length,
        function(l)
            if self.healing_animation_callback ~= nil then
                self.healing_animation_loops = self.healing_animation_loops + 1
                if self.healing_animation_loops == 2 then
                    local cb = self.healing_animation_callback
                    self.healing_animation_callback = nil
                    self.healing_animation:pauseAtStart()
                    self.show_healing_animation = false
                    cb()
                end
            end
        end)
    self.healing_animation_callback = nil

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
    self.healauraed_this_turn = false

    -- Combat math
    self.hp = 0
    self.atk = 0
    self.def = 0

    -- Special abilities
    self.has_doublestr = false
    self.has_reflect = false
    self.has_healaura = false
    self.has_hungering = false
end

-- UPDATE RUN LOOP
function Unit:update(dt)
    if self.tile_target_x < self.tile_x then
        self.facing_left = true
    elseif self.tile_target_x > self.tile_x then
        self.facing_left = false
    end

    if self[self.active_animation].flippedH == not self.facing_left then
        self[self.active_animation]:flipH()
    end
    if self.hitspark_animation.flippedH == not self.facing_left then
        self.hitspark_animation:flipH()
    end
    if self.reflect_animation.flippedH == not self.facing_left then
        self.reflect_animation:flipH()
    end

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
    end

    if self.show_sacrifice_animation == true then
        self.sacrifice_animation:update(dt)
    end
    if self.show_hitspark_animation == true then
        self.hitspark_animation:update(dt)
    end
    if self.show_reflect_animation == true then
        self.reflect_animation:update(dt)
    end
    if self.show_healing_animation == true then
        self.healing_animation:update(dt)
    end

    if self.processing_move_queue == true then
        self:process_move_queue()
    end

    local offset_x = (constants.pixel_sprite_width - constants.pixel_tile_width) * 0.5 * constants.pixel_integer_scale;
    local offset_y = (constants.pixel_sprite_height - constants.pixel_tile_width) * 0.5 * constants.pixel_integer_scale;
    if self.active_animation == 'walk_animation' and (self[self.active_animation].position == 2 or self[self.active_animation].position == 4) then
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
    
    love.graphics.setColor(1, 1, 1, 1)
    if self.show_sacrifice_animation == true then
        self.sacrifice_animation:draw(self.sacrifice_fx_sheet, self.pixel_x, self.pixel_y, 0, constants.pixel_integer_scale, constants.pixel_integer_scale)
    end
    if self.show_hitspark_animation == true then
        self.hitspark_animation:draw(self.hitspark_fx_sheet, self.pixel_x, self.pixel_y, 0, constants.pixel_integer_scale, constants.pixel_integer_scale)
    end
    if self.show_reflect_animation == true then
        local reflect_x = self.pixel_x + (12*4)
        local reflect_y = self.pixel_y + (12*4)
        self.reflect_animation:draw(self.reflect_fx_sheet, reflect_x, reflect_y, 0, constants.pixel_integer_scale, constants.pixel_integer_scale)
    end
    if self.show_healing_animation == true then
        local healing_x = self.pixel_x
        local healing_y = self.pixel_y
        if self.healing_animation_loops == 0 then
            healing_x = healing_x + (11*4)
            healing_y = healing_y + (11*4)
        elseif self.healing_animation_loops == 1 then
            healing_x = healing_x + (48*4) - (11*4) - (13*4)
            healing_y = healing_y + (48*4) - (11*4) - (13*4)
        end
        self.healing_animation:draw(self.healing_fx_sheet, healing_x, healing_y, 0, constants.pixel_integer_scale, constants.pixel_integer_scale)
    end
end

function Unit:queue_move(x, y)
    table.insert(self.move_queue, { x = x, y = y })
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
    self.active_animation = 'damage_animation'
    self.show_hitspark_animation = true
    self.hitspark_animation_callback = callback
    self.hitspark_animation:resume()
end

function Unit:enter_sacrifice_animation(callback)
    self.active_animation = 'damage_animation'
    self.show_sacrifice_animation = true
    self.sacrifice_animation_callback = callback
    self.sacrifice_animation:resume()
end

function Unit:enter_reflect_animation(callback)
    self.show_reflect_animation = true
    self.reflect_animation_callback = callback
    self.reflect_animation:resume()
end

function Unit:enter_healing_animation(callback)
    self.healing_animation_loops = 0
    self.show_healing_animation = true
    self.healing_animation_callback = callback
    self.healing_animation:resume()
end