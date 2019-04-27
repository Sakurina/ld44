E4Unit = Unit:extend()

function E4Unit:new(x, y)
    E4Unit.super.new(self, x, y)
    self.unit_name = "E4"
    self.user_controlled = false
    self.sprite_sheet = love.graphics.newImage('gfx/enemy/e4_1.png')
    local loaded_sheet = anim8.newGrid(48, 48, self.sprite_sheet:getWidth(), self.sprite_sheet:getHeight(), 0, 0)
    self.walk_animation = anim8.newAnimation(loaded_sheet('1-1', 1), constants.animation_frame_length)
    self.cast_animation = anim8.newAnimation(loaded_sheet('4-4', 1), constants.animation_frame_length)
    self.damage_animation = anim8.newAnimation(loaded_sheet('5-5', 1), constants.animation_frame_length)
    self.walk_animation:pauseAtStart()
    
    -- Movement
    self.move_range = constants.e4_move_range

    -- Combat math
    self.hp = 8
    self.atk = 4
    self.def = 3
end
