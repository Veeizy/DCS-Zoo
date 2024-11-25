Basic = Basic or {}
--[[
]]
do
    Basic.class_manager = {}
    -- class_id must be string
    function Basic.define(class_id)
        if Basic.class_manager[class_id] then
            Guard.basic_class_duplicate(class_id)
            return
        end
        if type(class_id)~= "string" then
            Guard.basic_type_error("class_id must be string")
        end

        Basic.class_manager[class_id] = setmetatable(
            {
                class_id = class_id,
                vars = {},
                status = {},
                common_condition = {},
                conditions = {},
                actions = {},
                object_index = {},
                objects = {}
            },
            {
                __index = Basic.class
            }
        )
        return Basic.class_manager[class_id]
    end
    function __new(class,args,state)
        return __class(class):new(args,state)
    end
    function __class(class)
        if not class or type(class) ~= "string" then
            Guard.basic_type_error("param of function [__class] must be string")
        end
        if not Basic.class_manager[class] then
            Guard.basic_class_no_found(class)
        end
        return Basic.class_manager[class]
    end
end