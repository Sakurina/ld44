function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
  
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function log(msg)
    if lovebird ~= nil then
        lovebird.print(msg)
    end
end

function x_for_tile(x)
    return constants.pixel_tile_width * constants.pixel_integer_scale * x
end

function y_for_tile(y)
    return constants.pixel_tile_height * constants.pixel_integer_scale * y
end

function attack_formula(attacker_atk, defender_def)
    local odds = {
        ["miss"] = constants.miss_hit_odds,
        ["critical"] = constants.critical_hit_odds,
        ["normal"] = constants.normal_hit_odds,
        ["weak"] = constants.weak_hit_odds
    }
    local multipliers = {
        miss = constants.miss_hit_mult,
        critical = constants.critical_hit_mult,
        normal = constants.normal_hit_mult, 
        weak = constants.weak_hit_mult
    }
    local roll = lume.weightedchoice(odds)
    local atk_multiplier = multipliers[roll]
    local theoretical_attack = attacker_atk - defender_def
    if theoretical_attack <= 0 then
        theoretical_attack = 1
    end
    return math.ceil(theoretical_attack * atk_multiplier)
end

function enemy_ai_target(attacker, attack_tiles, player_units)
    local target = nil
    local type = nil

    -- if there are any attack targets in range, prioritize the lowest health one
    local viable_attack_targets = lume.filter(player_units, function(pu)
        return lume.any(attack_tiles, function(at)
            return at.x == pu.tile_x and at.y == pu.tile_y
        end)
    end)
    if #viable_attack_targets > 0 then
        viable_attack_targets = lume.sort(viable_attack_targets, "hp")
        target = lume.last(viable_attack_targets)
        type = 'adjacent'
    else
        -- if there are none in range, use the shortest distance one
        local sorted = lume.sort(player_units, function(u1, u2)
            return lume.distance(attacker.tile_x, attacker.tile_y, u1.tile_x, u1.tile_y, true) < lume.distance(attacker.tile_x, attacker.tile_y, u2.tile_x, u2.tile_y, true)
        end)
        target = lume.first(sorted)
        type = 'get_closer'
    end

    return { target = target, type = type }
end

function map_for_allowed_tiles(unit, allowed_tiles)
    local dimension = (unit.move_range * 2) + 1
    local player_xy = unit.move_range + 1
    local map = {}
    for row_num=1, dimension, 1 do
        local row = {}
        for col_num = 1, dimension, 1 do
            local col = 1
            table.insert(row, col)
        end
        table.insert(map, row)
    end

    map[player_xy][player_xy] = 0
    lume.each(allowed_tiles, function(tile)
        local relative_x = tile.x - unit.tile_x
        local relative_y = tile.y - unit.tile_y
        local map_x = player_xy + relative_x
        local map_y = player_xy + relative_y
        map[map_y][map_x] = 0
    end)

    return map
end

function path_nodes_to_move_queue(unit, path)
    if path == nil then
        return nil
    end
    local queue = {}
    local player_xy = unit.move_range + 1
    for node, count in path:nodes() do
        local relative_x = node:getX() - player_xy
        local relative_y = node:getY() - player_xy
        local abs_x = relative_x + unit.tile_x
        local abs_y = relative_y + unit.tile_y
        table.insert(queue, { x = abs_x, y = abs_y })
    end
    return queue
end

function path_for_point_in_allowed_tiles(unit, point, allowed_tiles)
    local Grid = require('deps/jumper.grid')
    local Pathfinder = require('deps/jumper.pathfinder')

    local map = map_for_allowed_tiles(unit, allowed_tiles)

    local grid = Grid(map)
    local finder = Pathfinder(grid, 'JPS', 0)
    finder:setMode('ORTHOGONAL')
    local origin_x, origin_y = unit.move_range + 1, unit.move_range + 1
    local relative_target_x = point.x - unit.tile_x
    local relative_target_y = point.y - unit.tile_y
    local target_x, target_y = origin_x + relative_target_x, origin_y + relative_target_y
    local path = finder:getPath(origin_x, origin_y, target_x, target_y)

    return path_nodes_to_move_queue(unit, path)
end