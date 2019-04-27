lume = require "deps/lume"
lovebird = require "deps/lovebird"
sti = require "deps/sti"
Object = require "deps/classic"
json = require "deps/json"
require("helpers")
require("layer")
require("layermanager")
require("layer_transition")
require("layer_controls_overlay")
require("layer_controls")
require("layer_menu")
require("layer_srpg")

function love.load()
    layer_manager = LayerManager()
    layer_manager:reload_controls()
    local initial_layer = MenuLayer()
    layer_manager:prepend(initial_layer)
end

function love.draw()
    layer_manager:draw()
end

function love.update(dt)
    lovebird.update()
    layer_manager:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    return
    layer_manager:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    return
    layer_manager:keyreleased(key, scancode)
end