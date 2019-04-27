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