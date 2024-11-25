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