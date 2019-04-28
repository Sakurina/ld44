E2Unit = Unit:extend()

function E2Unit:new(x, y)
    E2Unit.super.new(self, x, y)
    self.unit_name = "Paige"
    self.is_hero = true
    self.has_feet = true
    self.user_controlled = false
    self.sprite_sheet = love.graphics.newImage('gfx/enemy/e2_1.png')
    local loaded_sheet = anim8.newGrid(48, 48, self.sprite_sheet:getWidth(), self.sprite_sheet:getHeight(), 0, 0)
    self.walk_animation = anim8.newAnimation(loaded_sheet('1-3', 1), constants.animation_frame_length)
    self.cast_animation = anim8.newAnimation(loaded_sheet('4-4', 1), constants.animation_frame_length)
    self.damage_animation = anim8.newAnimation(loaded_sheet('5-5', 1), constants.animation_frame_length)
    self.walk_animation:pauseAtStart()
    
    -- Movement
    self.move_range = constants.e2_move_range

    -- Combat math
    self.max_hp = constants.e2_max_hp
    self.hp = constants.e2_max_hp
    self.atk = constants.e2_atk
    self.def = constants.e2_def
end
