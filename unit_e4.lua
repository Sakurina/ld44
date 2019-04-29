E4Unit = Unit:extend()

function E4Unit:new(x, y)
    E4Unit.super.new(self, x, y)
    self.unit_name = "Martin"
    self.mana_color = 'green'
    self.user_controlled = false
    self.sprite_sheet = love.graphics.newImage('gfx/enemy/e4_1.png')
    local loaded_sheet = anim8.newGrid(48, 48, self.sprite_sheet:getWidth(), self.sprite_sheet:getHeight(), 0, 0)
    self.walk_animation = anim8.newAnimation(loaded_sheet('1-1', 1), constants.walk_animation_frame_length)
    self.cast_animation = anim8.newAnimation(loaded_sheet('4-4', 1), constants.animation_frame_length)
    self.damage_animation = anim8.newAnimation(loaded_sheet('5-5', 1), constants.animation_frame_length)
    self.walk_animation:pauseAtStart()
    self.facing_left = true
    
    -- Movement
    self.move_range = constants.e4_move_range

    -- Combat math
    self.max_hp = constants.e4_max_hp
    self.hp = constants.e4_max_hp
    self.atk = constants.e4_atk
    self.def = constants.e4_def
end
