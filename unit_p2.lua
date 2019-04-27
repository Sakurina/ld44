P2Unit = Unit:extend()

function P2Unit:new(x, y)
    P2Unit.super.new(self, x, y)
    self.unit_name = "P2"
    self.sprite_sheet = love.graphics.newImage('gfx/player/p2_1.png')
    local loaded_sheet = anim8.newGrid(48, 48, self.sprite_sheet:getWidth(), self.sprite_sheet:getHeight(), 0, 0)
    self.walk_animation = anim8.newAnimation(loaded_sheet('1-3', 1), 0.1)
    self.cast_animation = anim8.newAnimation(loaded_sheet('4-4', 1), 0.1)
    self.damage_animation = anim8.newAnimation(loaded_sheet('5-5', 1), 0.1)

    -- Movement
    self.move_range = constants.p2_move_range

    -- Combat math
    self.hp = 15
    self.atk = 7
    self.def = 5
end
