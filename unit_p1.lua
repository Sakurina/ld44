P1Unit = Unit:extend()

function P1Unit:new(x, y)
    P1Unit.super.new(self, x, y)
    self.unit_name = "P1"
    self.is_hero = true
    self.has_feet = true
    self.user_controlled = true
    self.sprite_sheet = love.graphics.newImage('gfx/player/p1_1.png')
    local loaded_sheet = anim8.newGrid(48, 48, self.sprite_sheet:getWidth(), self.sprite_sheet:getHeight(), 0, 0)
    self.walk_animation = anim8.newAnimation(loaded_sheet(1, 1, 2, 1, 1, 1, 3, 1), constants.animation_frame_length)
    self.cast_animation = anim8.newAnimation(loaded_sheet('4-4', 1), constants.animation_frame_length)
    self.damage_animation = anim8.newAnimation(loaded_sheet('5-5', 1), constants.animation_frame_length)
    self.walk_animation:pauseAtStart()
    
    -- Movement
    self.move_range = constants.p1_move_range

    -- Combat math
    self.max_hp = constants.p1_max_hp
    self.hp = constants.p1_max_hp
    self.atk = constants.p1_atk
    self.def = constants.p1_def
end
