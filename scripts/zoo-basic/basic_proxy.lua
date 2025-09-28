Basic = Basic or {}

do
    Basic.proxy = {}
    Basic.proxy.RAW_KEY = "_p"
    Basic.proxy.UPADTE_COMMAND = "U"
    Basic.proxy.SAFE_SET = "_safe"
    Basic.proxy.MULT_SET = "_mult"
    --[[
        

    ]]
    function Basic.proxy.index(t,k)
        if k ~= Basic.proxy.RAW_KEY and k ~= Basic.proxy.SAFE_SET and k ~= Basic.proxy.MULT_SET then
            if k:upper() == Basic.proxy.UPADTE_COMMAND then
                if not rawget(t,Basic.proxy.UPADTE_COMMAND) then
                    rawset(t,Basic.proxy.UPADTE_COMMAND,function(self)
                        t[Basic.proxy.RAW_KEY]:update()
                    end)
                end
                return rawget(t,Basic.proxy.UPADTE_COMMAND)
            end
            local f = t[Basic.proxy.RAW_KEY]:get_func(k)
            if f then
                return f
            end
            return t[Basic.proxy.RAW_KEY]:get(k)
        else
            return t[k]
        end
    end

    function Basic.proxy.newIndex(t,k,v)
        t[Basic.proxy.RAW_KEY]:set(k,v)
    end

    function Basic.proxy.raw_newIndex(t,k,v)
        t[Basic.proxy.RAW_KEY]:un_set(k,v)
    end

    function Basic.proxy.mult_newIndex(t,k,v)
        if type(v) == "table" then
            t[Basic.proxy.RAW_KEY]:multi_set(k,v)
        else
            t[Basic.proxy.RAW_KEY]:set(k,v)
        end
    end

    Basic.proxy.metatable={
        __index = Basic.proxy.index,
        __newindex = Basic.proxy.newIndex
    }
    Basic.proxy.raw_set_metatable={
        __index = Basic.proxy.index,
        __newindex = Basic.proxy.raw_newIndex
    }
    Basic.proxy.mult_set_metatable={
        __index = Basic.proxy.index,
        __newindex = Basic.proxy.mult_newIndex
    }

    ---@param class Basic_class
    ---@param args table<string,any>|nil
    ---@param state string
    ---@return table
    function Basic.proxy.new(class,args,state)
        local o = class:new(args,state)

        return Basic.proxy.decorate(o)
    end

    function Basic.proxy.decorate(o)
        local p = {
            [Basic.proxy.RAW_KEY] = o,
            
            [Basic.proxy.SAFE_SET] = setmetatable({[Basic.proxy.RAW_KEY] = o},Basic.proxy.raw_set_metatable),
            
            [Basic.proxy.MULT_SET] = setmetatable({[Basic.proxy.RAW_KEY] = o},Basic.proxy.mult_set_metatable)
        }
        return setmetatable(p,Basic.proxy.metatable)
    end

    --- func desc
    ---@param class Basic_class
    ---@param index string
    ---@param value string
    ---@return Basic_object|table<Basic_object,Basic_object>
    function Basic.proxy.get_objects(class,index,value)
        local r = class:get_objects(index,value)

        if not index then
            return Basic.proxy.decorate(r)
        else
            local set = {}
            for _,  o in pairs(r) do
                local p = Basic.proxy.decorate(o)
                set[p]=p
            end
            return set
        end
    end


end