SRPGLayer = Layer:extend()

function SRPGLayer:new()
    SRPGLayer.super.new(self)
    self.game_ended = false
    self.layer_name = "SRPGLayer"
    self.active_mode = 'overview'
    self.hover_ui = nil

    -- cursor placement
    self.cursor_tile_x = 8
    self.cursor_tile_y = 14
    self.cursor_tile_target_x = 8
    self.cursor_tile_target_y = 14
    self.cursor_tile_anim_accumulator = 0

    -- map loading and dimensions
    self.map_img_file = 'gfx/map/1-1.png'
    self.map_img = love.graphics.newImage(self.map_img_file)
    self.map_img_width = 1944
    self.map_img_height = 696
    camera:setBounds(0, 0, self.map_img_width * constants.pixel_integer_scale, self.map_img_height * constants.pixel_integer_scale)
    self.tile_width_count = self.map_img_width / constants.pixel_tile_width
    self.tile_height_count = self.map_img_height / constants.pixel_tile_height
    log(lume.format("[{1}] loaded map {2} ({3}x{4}px, {5}x{6} tile count)", {self.layer_name, self.map_img_file, self.map_img_width, self.map_img_height, self.tile_width_count, self.tile_height_count }))

    -- selection mode stuff
    self.selection_intention = 'move' -- 'move' or 'attack'
    self.allowed_tiles = {}
    self.selected_unit = nil
    self.target_unit = nil

    -- units and animations
    self.units = {}
    table.insert(self.units, P1Unit(8,14))
    table.insert(self.units, U1Unit(7,13))
    table.insert(self.units, U2Unit(7,15))
    table.insert(self.units, E2Unit(18,14))
    table.insert(self.units, E4Unit(19,13))
    table.insert(self.units, E5Unit(19,15))
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
end

function SRPGLayer:update(dt)
    if self.paused == true then
        return
    end
    if self.game_ended == true then
        return
    end
    if self.hover_ui == nil and not layer_manager:topmost():is(TransitionLayer) then
        self.hover_ui = HoverUILayer()
        layer_manager:prepend(self.hover_ui)
        self:populate_hover_ui()
    end

    self.units = lume.filter(self.units, function(u) return u.purge == false end)
    local player_units = lume.filter(self.units, function(u) return u.user_controlled == true end)
    local enemy_units = lume.filter(self.units, function(u) return u.user_controlled == false end)
    if #player_units <= 0 then
        self.game_ended = true
        log(lume.format("[{1}] game over (all friendly units dead)", { self.layer_name }))
        if self.hover_ui ~= nil then
            layer_manager:remove_first()
        end
        local win_layer = LoseLayer()
        layer_manager:transition(self, win_layer)
        return
    end
    if #enemy_units <= 0 then
        self.game_ended = true
        log(lume.format("[{1}] you win (all enemy units dead)", { self.layer_name }))
        if self.hover_ui ~= nil then
            layer_manager:remove_first()
        end
        local lose_layer = WinLayer()
        layer_manager:transition(self, lose_layer)
        return
    end
    if self.active_mode == 'animation_wait' then
        if self.selection_intention == 'move' then
            if self.selected_unit ~= nil and self.selected_unit.processing_move_queue == false then
                local viable_attacks = self:viable_attack_tiles(self.selected_unit)
                if #viable_attacks > 0 then
                    self.active_mode = 'selection'
                    self.selection_intention = 'attack'
                    self.allowed_tiles = viable_attacks
                else
                    self.active_mode = 'overview'
                    self.selected_unit = nil
                end
                self:populate_hover_ui()
            end
        elseif self.selection_intention == 'attack' then
            self:combat_phase_atk_cast(self.selected_unit, self.target_unit)
        elseif self.selection_intention == 'attack2' then
            self:combat_phase_atk_receive(self.selected_unit, self.target_unit)
        elseif self.selection_intention == 'attack3' then
            self:combat_phase_post_atk(self.selected_unit, self.target_unit)
        elseif self.selection_intention == 'attack4' and self.cursor_tile_x == self.cursor_tile_target_x and self.cursor_tile_y == self.cursor_tile_target_y then
            self:combat_phase_retaliation_damage(self.selected_unit, self.target_unit)
        elseif self.selection_intention == 'attack5' then
            self:combat_phase_ret_cast(self.selected_unit, self.target_unit)
        elseif self.selection_intention == 'attack6' then
            self:combat_phase_ret_receive(self.selected_unit, self.target_unit)
        elseif self.selection_intention == 'attack7' then
            self:combat_phase_post_ret(self.selected_unit, self.target_unit)
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
            log(lume.format("[{1}] x={2}, y={3}", { self.layer_name, self.cursor_tile_x, self.cursor_tile_y }))
            self:populate_hover_ui()
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
        if self.active_mode == 'selection' then
            self.active_mode = 'overview'
            self.allowed_tiles = {}
        end
    elseif key == layer_manager.controls["Confirm"] then
        if self.active_mode == 'overview' then
            self:confirm_pressed_overview()
        elseif self.active_mode == 'selection' and self.selection_intention == 'move' then
            self:confirm_move_selection()
        elseif self.active_mode == 'selection' and self.selection_intention == 'attack' then
            self:confirm_attack_selection()
        end
    elseif key == '4' then
        self:reset_player_turn()
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

function SRPGLayer:confirm_pressed_overview()
    local units = lume.filter(self.units, function(u) return u.tile_x == self.cursor_tile_x and u.tile_y == self.cursor_tile_y end)
    if #units > 0 and units[1].user_controlled == true and units[1].moved_this_turn == false then
        self.active_mode = 'selection'
        self.selection_intention = 'move'
        self.selected_unit = units[1]
        self.allowed_tiles = self:viable_move_tiles(units[1])
    else
        -- no selectable units, pop a menu to end turn
    end
end

function SRPGLayer:confirm_move_selection()
    self.active_mode = 'animation_wait'
    self.selected_unit.processing_move_queue = true
end

function SRPGLayer:confirm_attack_selection() 
    log(lume.format("[{1}] entering combat", { self.layer_name }))
    local attacker = self.selected_unit
    log(lume.format("[{1}] attacker: {2}", { self.layer_name, attacker.unit_name }))
    local target_units = lume.filter(self.units, function(u) return u.user_controlled == not attacker.user_controlled and u.tile_x == self.cursor_tile_x and u.tile_y == self.cursor_tile_y end)
    if #target_units > 0 then
        local defender = target_units[1]
        self.target_unit = defender
        log(lume.format("[{1}] defender: {2}", { self.layer_name, defender.unit_name }))
        self.active_mode = 'animation_wait'
        self:combat_phase_initial_damage(attacker, defender)
    else
        log(lume.format("[{1}] no unit targeted", { self.layer_name }))
        self:combat_phase_ended(attacker, nil)
    end
end

function SRPGLayer:combat_phase_initial_damage(attacker, defender)
    -- Deal the initial damage
    local damage = attack_formula(attacker.atk, defender.def)
    log(lume.format("[{1}] {2} deals {4} damage to {3}", { self.layer_name, attacker.unit_name, defender.unit_name, damage }))
    defender.hp = defender.hp - damage
end

function SRPGLayer:combat_phase_atk_cast(attacker, defender)
    -- Attacker casts spell
    local that = self
    attacker:enter_cast_animation(function() 
        that.selection_intention = 'attack2' 
    end)
end

function SRPGLayer:combat_phase_atk_receive(attacker, defender)
    -- Defender receives damage, attacker returns to normal
    local that = self
    attacker.active_animation = 'walk_animation'
    defender:enter_damage_animation(function()
        defender.active_animation = 'walk_animation'
        that.selection_intention = 'attack3'
        that:animate_hp_hit(defender.hp)
    end)
end

function SRPGLayer:combat_phase_post_atk(attacker, defender)
    -- If defender should be dead, purge the unit from storage
    -- Otherwise, restore the defender's walk animation and move to next phase
    if defender.hp <= 0 then
        defender.purge = true
        self:combat_phase_ended(attacker, defender)
    else
        self:combat_phase_atk_cursor_move(attacker, defender)
    end
end

function SRPGLayer:combat_phase_atk_cursor_move(attacker, defender)
    -- Move the cursor to focus on the defender's retaliation damage
    self.cursor_tile_target_x = attacker.tile_x
    self.cursor_tile_target_y = attacker.tile_y
    self.selection_intention = 'attack4'
end

function SRPGLayer:combat_phase_retaliation_damage(attacker, defender)
    -- Deal the initial damage
    local damage = attack_formula(defender.atk, attacker.def)
    log(lume.format("[{1}] {2} deals {4} damage to {3}", { self.layer_name, attacker.unit_name, defender.unit_name, damage }))
    attacker.hp = attacker.hp - damage
    self.selection_intention = 'attack5'
end

function SRPGLayer:combat_phase_ret_cast(attacker, defender)
    log("7")
    -- Defender casts spell
    defender.active_animation = 'cast_animation'
    self.selection_intention = 'attack6'
end

function SRPGLayer:combat_phase_ret_receive(attacker, defender)
    log("8")
    -- Attacker receives damage, defender returns to normal
    defender.active_animation = 'walk_animation'
    attacker.active_animation = 'damage_animation'
    self:animate_hp_hit(attacker.hp)
    self.selection_intention = 'attack7'
end

function SRPGLayer:combat_phase_post_ret(attacker, defender)
    log("9")
    if attacker.hp <= 0 then
        attacker.purge = true
        self:combat_phase_ended(attacker, defender)
    else
        attacker.active_animation = 'walk_animation'
        self:combat_phase_ret_cursor_move(attacker, defender)
    end
end

function SRPGLayer:combat_phase_ret_cursor_move(attacker, defender)
    log("10")
    self.cursor_tile_target_x = attacker.tile_x
    self.cursor_tile_target_y = attacker.tile_y
    self:combat_phase_ended(attacker, defender)
end

function SRPGLayer:combat_phase_ended(attacker, defender)
    log("11 END")
    -- perform cleanup and regain control
    self.active_mode = 'overview'
end

function SRPGLayer:viable_attack_tiles(unit)
    -- return immediately adjacent tiles with attackable units
    local opposite_player = not unit.user_controlled
    local left_x = unit.tile_x - 1
    local right_x = unit.tile_x + 1
    local up_y = unit.tile_y - 1
    local down_y = unit.tile_y + 1
    local units = lume.filter(self.units, function(u)
        return u.user_controlled == opposite_player and
            ((u.tile_x == left_x and u.tile_y == unit.tile_y) or
            (u.tile_x == right_x and u.tile_y == unit.tile_y) or
            (u.tile_x == unit.tile_x and u.tile_y == up_y) or
            (u.tile_x == unit.tile_x and u.tile_y == down_y))
    end)
    local tiles = lume.map(units, function(u) return { x = u.tile_x, y = u.tile_y } end)
    if #tiles > 0 then
        table.insert(tiles, { x = unit.tile_x, y = unit.tile_y })
    end
    return tiles
end

function SRPGLayer:viable_move_tiles(unit)
    local raw_tiles = unit:raw_allowed_tiles()
    local filtered_tiles = lume.filter(raw_tiles, function(t)
        return not lume.any(self.units, function(u)
            return u ~= unit and u.tile_x == t.x and u.tile_y == t.y
        end)
    end)
    return filtered_tiles
end

function SRPGLayer:reset_player_turn()
    local player_units = lume.filter(self.units, function(u) return u.user_controlled == true end)
    lume.each(player_units, function(u) u.moved_this_turn = false end)
end

function SRPGLayer:populate_hover_ui()
    local units = lume.filter(self.units, function(u) return u.tile_x == self.cursor_tile_x and u.tile_y == self.cursor_tile_y end)
    if #units > 0 then
        local u = units[1]
        self.hover_ui.show_ui = true
        self.hover_ui.max_hp = u.max_hp
        self.hover_ui.from_hp = u.hp
        self.hover_ui.to_hp = u.hp
        self.hover_ui.unit_name = u.unit_name
    else
        self.hover_ui.show_ui = false
    end
end

function SRPGLayer:animate_hp_hit(hp)
    self.hover_ui.to_hp = hp
end