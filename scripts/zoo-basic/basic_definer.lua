Basic = Basic or {}

do

    local unpack = unpack or table.unpack
    Basic.definer = {}
    Basic.definer.metatable={}

    -- 按 "__" 分割，并自动忽略所有空字符串
    local function split_by_double_underscore(s)
        local parts = {}
        local start = 1
        while true do
            local pos = string.find(s, "__", start, true)  -- 纯文本查找
            if pos then
                local part = string.sub(s, start, pos - 1)
                if part ~= "" then
                    table.insert(parts, part)
                end
                start = pos + 2
            else
                local part = string.sub(s, start)
                if part ~= "" then
                    table.insert(parts, part)
                end
                break
            end
        end
        return parts
    end
    function Basic.definer.metatable.__newindex(t,k,v)
            -- 只允许字符串类型的 key
            if type(k) ~= "string" then
                Guard.basic_not_definer_function("newIndex nest a key which is not a string")
            end

            -- 按一个或多个下划线分割（提取非下划线部分）
            local parts = split_by_double_underscore(k)

            -- 必须至少有一个部分作为函数名
            if #parts < 1 then
                Guard.basic_not_definer_function("newIndex nest an empty string")
            end

            local func_name = parts[1]
            local args = {}

            table.insert(args,rawget(t,"__c"))
            for i = 2, #parts do
                table.insert(args, parts[i])
            end
            -- v 作为最后一个参数传入
            table.insert(args, v)

            -- 查找处理函数
            local func = rawget(t,"__c")[func_name]
            if not func or type(func) ~= "function" then
                Guard.basic_not_definer_function(("function is undefined: '%s'"):format(tostring(func_name)))
            end

            -- 安全调用
            local success, err = pcall(func, unpack(args))
            if not success then
                Guard.basic_not_definer_function(("call '%s' fail: %s"):format(func_name, err))
            end

    end


    ---@param class Basic_class
    ---@return table
    function Basic.definer.proxy(class)
        local p = {__c = class}
        return setmetatable(p,Basic.definer.metatable)
    end 

    ---@param class string
    ---@return table
    function Basic.definer.new(class)
        return Basic.definer.proxy(Basic.define(class))
    end 

end