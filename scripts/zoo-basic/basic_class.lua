Basic = Basic or {}

do
    Basic.class = {}
    -- 定义一个状态
    function Basic.class:state(name)
        self.status[name] = name
        return self
    end
    -- 定义成员变量
    -- 未定义的变量在检查状态后会被清除
    function Basic.class:var(name,default)
        self.vars[name] = {default = default}
        return self
    end
    -- 
    function Basic.class:condition(condition_id,from,to,func)
        --参数校验  
        if not self.status[from] then
            Guard.basic_state_is_undefined(from)
        end
        if not self.status[to] then
            Guard.basic_state_is_undefined(to)
        end
        --确定容器
        local condition_container= nil
        if not from then
            condition_container = self.common_condition
        else
            self.conditions[from] = self.conditions[from] or {}
            condition_container = self.conditions[from]
        end
        --参数校验
        if condition_container[condition_id] then
            Guard.basic_condition_duplicate(condition_id)
        end
        

        
        condition_container[condition_id] = {func = func , to = to}
        return self
    end
    -- 
    function Basic.class:new(args,state)
        if args == nil then
            args = {}
        end
        --参数校验
        if type(state)~= "string" then
            Guard.basic_type_error("state must be string")
        end
        if type(args)~= "table" then
            Guard.basic_type_error("args must be a table")
        end
        if not self.status[state] then
            Guard.basic_state_is_undefined("cant create a new object with state: "..state)
        end
        
        local o = setmetatable({
            __object = true,
            __state = state,
            field = {}
        },{__index = self})
        for _, var in pairs(self.vars) do
            if args[var] then
                o[var] = args[var]
            else
                o[var] = self.vars.default
            end
        end

        table.insert(self.objects,o)

        return o 
    end

    function Basic.class:action(state,func)
        self.actions[state] = self.actions[state] or {}
        table.insert(self.actions[state],func)
        return self
    end

    function Basic.class:index(var,conflict)
        if not self.vars[var] then
            Guard.basic_variable_is_undefined(var)
        end
        if self.object_index[var] then
            Guard.basic_index_duplicate(var)
        end

        self.object_index[var] = {
            objects ={},
            conflict = conflict
        }
    end

    function Basic.class:build_index_conflict(var)
        local list = {}
        for _, o in pairs(self.objects) do
            local v = o:get(var)
            if list[v] then
                Guard.basic_index_conflict(o)
            else
                list[v] = o
            end
        end
        return list
    end
    function Basic.class:build_index_no_conflict(var)
        local list = {}
        for _, o in pairs(self.objects) do
            local v = o:get(var)
            list[v] = list[v] or {}
            table.insert(list[v],o)
        end
        return list
    end

    function Basic.class:build_index_var(var)
        if not self.object_index[var] then
            Guard.basic_index_is_undefined(self.class_id.." has no ["..var.."] index")
        end
        if self.object_index[var].conflict then
            self.object_index[var].objects = self:build_index_conflict(var)
        else
            self.object_index[var].objects = self:build_index_no_conflict(var)
        end
    end

    function Basic.class:build_index()
        for var, _ in pairs(self.object_index) do
            self:build_index_var(var)
        end
    end

    function Basic.class:get_objects(index,value)
        if not index then
            return self.objects
        end
        if not self.get_objects[index] then
            return nil
        elseif self.get_objects[index].conflict then
            return self.get_objects[index].objects[value]
        else
            return self.get_objects[index].objects[value] or {}
        end
    end
end