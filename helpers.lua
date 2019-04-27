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
        ["whiff"] = 15,
        ["critical"] = 5,
        ["normal"] = 65,
        ["weak"] = 15
    }
    local multipliers = {
        whiff = 0,
        critical = 3,
        normal = 1, 
        weak = 0.6
    }
    local roll = lume.weightedchoice(odds)
    local atk_multiplier = multipliers[roll]
    local theoretical_attack = attacker_atk - defender_def
    if theoretical_attack <= 0 then
        theoretical_attack = 1
    end
    return theoretical_attack * atk_multiplier
end