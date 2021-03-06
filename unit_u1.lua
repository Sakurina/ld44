U1Unit = Unit:extend()

function U1Unit:new(x, y)
    U1Unit.super.new(self, x, y)
    self.unit_name = "Jerry"
    self.mana_color = 'red'
    self.user_controlled = true
    self.sprite_sheet = love.graphics.newImage('gfx/player/u1_1.png')
    local loaded_sheet = anim8.newGrid(48, 48, self.sprite_sheet:getWidth(), self.sprite_sheet:getHeight(), 0, 0)
    self.walk_animation = anim8.newAnimation(loaded_sheet('1-1', 1), constants.walk_animation_frame_length)
    self.cast_animation = anim8.newAnimation(loaded_sheet('4-4', 1), constants.animation_frame_length)
    self.damage_animation = anim8.newAnimation(loaded_sheet('5-5', 1), constants.animation_frame_length)
    self.walk_animation:pauseAtStart()
    
    -- Movement
    self.move_range = constants.u1_move_range

    -- Combat math
    self.max_hp = constants.u1_max_hp
    self.hp = constants.u1_max_hp
    self.atk = constants.u1_atk
    self.def = constants.u1_def
end
