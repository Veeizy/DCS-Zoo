Util = Util or {}

do
    ---@type table<number,Util_looper>
    Util.looper_manager = {}

    Util.looper = {}

    --- func desc
    ---@param self Util_looper
    function Util.looper.run(self)
        if not self.running then
            self.running = true
            self:looping()
        end
    end
    ---@param self Util_looper
    function Util.looper.stop(self)
        if self.running then
            self.running = false
        end
    end
    --- func desc
    ---@param self Util_looper
    function Util.looper.looping(self)
        if (next(self.func_list)==nil) then
            self:stop()
        end
        if self.running then
            for f, _ in pairs(self.func_list) do
                pcall(f)
            end
            timer.scheduleFunction(
                self.looping,self,timer.getTime()+self.interval
            )
        end
    end
    --- func desc
    ---@param self Util_looper
    ---@param func function
    function Util.looper.add_task(self,func)
        local is_first_task = (next(self.func_list)==nil)
        self.func_list[func]=func
        if is_first_task then
            self:run()
        end
    end

    ---@param self Util_looper
    ---@param func function
    function Util.looper.remove_task(self,func)
        self.func_list[func]=nil
    end
    --- func desc
    ---@param func function
    ---@param interval number
    function Util.loop(func,interval)
        if not Util.looper_manager[interval]then
            Util.looper_manager[interval] =setmetatable(
                {
                    func_list = {},
                    interval = interval
                },{__index = Util.looper}
            )
        end
        local l  = Util.looper_manager[interval]
        l:add_task(func)
    end

    function Util.stop_loop(func,interval)
        if Util.looper_manager[interval]then
            Util.looper_manager[interval]:remove_task(func)
        end
    end

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