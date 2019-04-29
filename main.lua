lume = require "deps/lume"
lovebird = require "deps/lovebird"
Object = require "deps/classic"
json = require "deps/json"
anim8 = require "deps/anim8"
require("deps/tesound")
require('deps/camera')
require("helpers")
require("layer")
require("layermanager")
require("layer_transition")
require("layer_controls_overlay")
require("layer_controls")
require("layer_menu")
require("layer_srpg")
require("layer_ending_prompt")
require("layer_win")
require("layer_srpg_hover")
require("layer_srpg_unit_menu")
require("layer_srpg_mana_menu")
require("constants")
require("unit")
require("unit_p1")
require("unit_p2")
require("unit_u1")
require("unit_u2")
require("unit_u3")
require("unit_e1")
require("unit_e2")
require("unit_e3")
require("unit_e4")
require("unit_e5")

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.keyboard.setKeyRepeat(true)
    layer_manager = LayerManager()
    layer_manager:reload_controls()
    local initial_layer = MenuLayer()
    layer_manager:prepend(initial_layer)
    TEsound.playLooping("music/Lazy Marine - Piracy Beat.wav", 'music')
end

function love.draw()
    layer_manager:draw()
end

function love.update(dt)
    lovebird.update()
    layer_manager:update(dt)
    TEsound.cleanup()
end

function love.keypressed(key, scancode, isrepeat)
    layer_manager:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    layer_manager:keyreleased(key, scancode)
end