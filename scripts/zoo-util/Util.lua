Util = Util or {}

do
    function Util.deepcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[Util.deepcopy(orig_key)] = Util.deepcopy(orig_value)
            end
            setmetatable(copy, Util.deepcopy(getmetatable(orig)))
        else 
            copy = orig
        end
        return copy
    end
end