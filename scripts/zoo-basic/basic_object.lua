Basic = Basic or {}

do
    -- method for object
    function Basic.class:__verify_object()
        if not self.__object then
            Guard.basic_wrong_method_called("cant call update method for class "..self.class_id)
        end
    end
    function Basic.class:__set_state(state)
        self:__verify_object()
        if not self.status[state] then
            Guard.basic_state_is_undefined(state)
        end
        self.__state = state
    end

    function Basic.class:update_with_condition(condition_container)
        local state_changed = false
        for condition_id, value in pairs(condition_container) do
            if not state_changed and value.func(self) then
                state_changed = true
                self:__set_state(value.to)
            end
        end
        return state_changed
    end

    function Basic.class:do_action()
        if self.actions[self.__state] then
            for _, action in pairs(self.actions[self.__state]) do
                action(self)
            end
        end
    end

    function Basic.class:update_with_common_condition()
        local rtn = self:update_with_condition(self.common_condition)
        if rtn then
            self:do_action()
        end
        return rtn
    end

    function Basic.class:update_with_state_condition()
        if not self.conditions[self.__state] then
            return false
        end
        local rtn = self:update_with_condition(self.conditions[self.__state])
        if rtn then
            self:do_action()
        end
        return rtn
    end
    --该函数仅在创建对象时用以将新对象加入索引中(已废弃，不要调用)
    function Basic.class:add_to_index()
        self:__verify_object()
        for var, _ in pairs(self.object_index) do
            self:update_index_var(var,self:get(var))
        end
    end

    function Basic.class:update_index_var(var,value,from)
        self:__verify_object()
        --确认索引存在
        if not self.object_index[var] then
            Guard.basic_index_is_undefined(var)
        end
        
        if not self.object_index[var].conflict then
            --处理非冲突索引
            --当旧值非空时，则检查旧索引是否存在，并移除旧索引
            if from and self.object_index[var].objects[from] then
                self.object_index[var].objects[from][self] = nil
            else
                --当旧值为空时，从空表删除旧索引
                self.object_index[var]._nil[self] = nil
            end
            --确认当前索引表不为nil
            self.object_index[var].objects[value] = self.object_index[var].objects[value] or {}
            --如果当前索引值不为空，则存入数值表 若否则存入空表
            if value then
                self.object_index[var].objects[value][self] = self
            else
                self.object_index[var]._nil[self] = self
            end
        else
            --确认目标值是否存在冲突
            if self.object_index[var].objects[value] then
                Guard.basic_index_conflict(var,value)
            end
            --删除旧索引
            if from and self.object_index[var].objects[from] then
                self.object_index[var].objects[from] = nil
            end
            --冲突索引值不能为空
            if value then
                self.object_index[var].objects[value] = self
            else
                Guard.basic_index_error("conflict index ["..var.."] cant not be nil")
            end
        end
    end

    function Basic.class:update()
        self:__verify_object()
        if not self:update_with_common_condition() then
            self:update_with_state_condition()
        end
        self:dump()
    end
    
    function Basic.class:get(key)
        self:__verify_object()
        return self.field[key]
    end
    function Basic.class:set(key,v)
        self:__verify_object()
        self:un_set(key,v)
        self:update()
    end

    function Basic.class:multi_set(args)
        self:__verify_object()
        if type(args) ~= "table" then
            Guard.basic_type_error("args for multi_set must be a table")
        end
        for k, v in pairs(args) do
            self:un_set(k,v)
        end
        self:update()
    end

    function Basic.class:un_set(key,v)
        self:__verify_object()
        if self.object_index[key] then
            self:update_index_var(key,v,self.field[key])
        end
        self.field[key] = v
    end
    
    function Basic.class:dump()
        self:__verify_object()
        local d = {}
        for k, v in pairs(self.field) do
            if not self.vars[k] then
                table.insert(d,k)
            end
        end
        for _, k in pairs(d) do
            self.field[k] = nil
        end
    end
end