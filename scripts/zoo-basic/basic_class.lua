Basic = Basic or {}

do
    Basic.class = {}
    -- 定义一个状态
    --- func desc
    ---@param self Basic_class
    ---@param name string
    ---@return Basic_class
    function Basic.class.state(self,name)
        self.status[name] = name
        return self
    end
    -- 定义成员变量
    -- 未定义的变量在检查状态后会被清除
    --- func desc
    ---@param self Basic_class
    ---@param name any
    ---@param default any
    function Basic.class.var(self,name,default)
        self.vars[name] = {default = default}
        return self
    end
    --- func desc
    ---@param self Basic_class
    ---@param condition_id string
    ---@param from string|nil
    ---@param to string
    ---@param func fun(self:Basic_object):boolean
    ---@param weight number
    function Basic.class.condition(self,condition_id,from,to,func,weight)
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
        
        local condition_handler = {func = func , to = to ,weight = weight or 1 }

        condition_container[condition_id] = condition_handler
        return self
    end

    ---@param self Basic_class
    ---@param args table<string,any>|nil
    ---@param state string
    ---@return Basic_object
    function Basic.class.new(self,args,state)
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
        for var, _ in pairs(self.vars) do
            if args[var] then
                o:un_set(var,args[var])
            else
                o:un_set(var,self.vars[var].default)
            end
        end
        self.objects[o] = o
        self.state_index[state] = self.state_index[state] or {}
        self.state_index[state][o] = o
        return o 
    end

    --- func desc
    ---@param self Basic_class
    ---@param state string
    ---@param from string|nil
    ---@param func fun(self:Basic_object)
    function Basic.class.action(self,state,from,func)

        if not self.status[state] then
            Guard.basic_state_is_undefined(state)
        end
        if from and not self.status[from] then
            Guard.basic_state_is_undefined(from)
        end
        
        if from then
            self.actions_from[state] = self.actions_from[state] or {}
            self.actions_from[state][from] = self.actions_from[state][from] or {}
            table.insert(self.actions_from[state][from],func)
        else
            self.actions[state] = self.actions[state] or {}
            table.insert(self.actions[state],func)
        end
        
        return self
    end

    --- func desc
    ---@param self Basic_class
    ---@param var string
    ---@param conflict boolean
    function Basic.class.index(self,var,conflict)
        if not self.vars[var] then
            Guard.basic_variable_is_undefined(var)
        end
        if self.object_index[var] then
            Guard.basic_index_duplicate(var)
        end

        self.object_index[var] = {
            objects ={},
            _nil ={},
            conflict = conflict,
            invalid = false
        }
        return self
    end

    --- func desc
    ---@param self Basic_class
    ---@param name string
    ---@param func function
    ---@return Basic_class
    function Basic.class.func(self,name,func)
        if func ~= nil and type(func) == "function" then
            self.functions[name]=func
        end
        return self
    end

    --- func desc
    ---@param self Basic_class
    ---@param name string
    ---@return function
    function Basic.class.get_func(self,name)
        return self.functions[name]
    end

    --- func desc
    ---@param self Basic_class
    ---@param var string
    ---@return table<string,Basic_object>
    function Basic.class.build_index_conflict(self,var)
        local list = {}
        for o, _ in pairs(self.objects) do
            local v = o:get(var)
            if v then
                if list[v] then
                    Guard.basic_index_conflict(var,v)
                else
                    list[v] = o
                end
            else
                Guard.basic_index_error("conflict index ["..var.."] cant not be nil")
            end
        end
        return list
    end

    --- func desc
    ---@param self Basic_class
    ---@param var string
    ---@return table<string,table<Basic_object,Basic_object>> , table<Basic_object,Basic_object>
    function Basic.class.build_index_no_conflict(self,var)
        local list = {}
        local _nil = {}
        for o, _ in pairs(self.objects) do
            local v = o:get(var)
            if v then
                list[v] = list[v] or {}
                list[v][o]=o
            else
                _nil[o]=o
            end
        end
        return list,_nil
    end

    --- func desc
    ---@param self Basic_class
    ---@param var string
    function Basic.class.build_index_var(self,var)
        if not self.object_index[var] then
            Guard.basic_index_is_undefined(self.class_id.." has no ["..var.."] index")
        end
        
        if not self.object_index[var].invalid then
            return
        end
        if self.object_index[var].conflict then
            self.object_index[var].objects = self:build_index_conflict(var)
        else
            self.object_index[var].objects,self.object_index[var]._nil = self:build_index_no_conflict(var)
        end
        self.object_index[var].invalid = false
    end

    --- func desc
    ---@param self Basic_class
    ---@param var string
    function Basic.class.invalid_index(self,var)
        if var then
            if not self.object_index[var] then
                Guard.basic_index_is_undefined(self.class_id.." has no ["..var.."] index")
            end
            self.object_index[var].invalid = true
        else
            for var, _ in pairs(self.object_index) do
                self:invalid_index(var)
            end
        end
    end

    --- func desc
    ---@param self Basic_class
    function Basic.class.build_index(self)
        for var, _ in pairs(self.object_index) do
            self:build_index_var(var)
        end
    end
    --- func desc
    ---@param self Basic_class
    ---@param index string
    ---@param value string
    ---@return Basic_object|table<Basic_object,Basic_object>
    function Basic.class.get_objects(self,index,value)
        if not index then
            return self.objects
        end
        if not self.object_index[index] then
            Guard.basic_index_is_undefined(var)
        else
            self:build_index_var(index)
            if self.object_index[index].conflict then
                return self.object_index[index].objects[value]
            else
                if value then
                    return self.object_index[index].objects[value] or {}
                else
                    return self.object_index[index]._nil
                end
            end
        end
    end

    --- func desc
    ---@param self Basic_class
    ---@param state any
    ---@return table<Basic_object,Basic_object>
    function Basic.class.get_objects_with_state(self,state)
        return self.state_index[state] or {}
    end
    --- func desc
    ---@param self Basic_class
    ---@param var string
    ---@return boolean
    function Basic.class.has_index_conflict(self,var)
        if not self.object_index[var] then
            return false
        end
        return self.object_index[var].conflict
    end

    --- func desc
    ---@param self Basic_class
    ---@param class string
    ---@param key string
    ---@param func nil|fun(self:Basic_object,class:Basic_class):Basic_object
    ---@return Basic_class
    function Basic.class.attach(self,class,key,func)
        if  type(func)=="function" then
            self.attached_method[class] = func
        elseif type(key)=="string" then
            if not __class(class):has_index_conflict(key)then
                Guard.basic_index_error("cant attach to class without conflict index")
            else
                self.attached_class[class] = key
            end
        end
    end



end