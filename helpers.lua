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