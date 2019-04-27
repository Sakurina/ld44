E5Unit = Unit:extend()

function E5Unit:new(x, y)
    E5Unit.super.new(self, x, y)
    self.unit_name = "E5"
    self.sprite_sheet = love.graphics.newImage('gfx/enemy/e5_1.png')
    local loaded_sheet = anim8.newGrid(48, 48, self.sprite_sheet:getWidth(), self.sprite_sheet:getHeight(), 0, 0)
    self.walk_animation = anim8.newAnimation(loaded_sheet('1-1', 1), 0.1)
    self.cast_animation = anim8.newAnimation(loaded_sheet('4-4', 1), 0.1)
    self.damage_animation = anim8.newAnimation(loaded_sheet('5-5', 1), 0.1)

    -- Movement
    self.move_range = constants.e5_move_range

    -- Combat math
    self.hp = 8
    self.atk = 4
    self.def = 3
end
