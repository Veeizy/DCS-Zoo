Basic = Basic or {}
--[[
    数据源有两种形式
    一种是主动数据源，通过调取外部函数获取数据
    然后将数据同步进对象中
    另一种是被动数据源，通过外部调用输入函数然后
    根据数据的输入传给对象

    主动数据源的工作流程：
        定时循环工作： 获取原始数据 - 封装处理 - 路由到各个目标对象 

    被动数据源：
        当某个事件发生时，调用数据源的入口函数 - 根据数据内容进行路由

    数据收集(主动) ->数据预处理(主动) -> 数据传入 -> 匹配处理器 -> 匹配路由器 -> 传送至目标对象
                                                                    |
                                                                    v
                                                                创建新对象
]]
do
    ---@type table<string,Basic_data_source>
    Basic.data_source_manager = {}

    ---@param data_source_id string
    ---@return Basic_data_source
    function Basic.data_source(data_source_id)
        if Basic.data_source_manager[data_source_id] then
            Guard.basic_data_source_duplicate(data_source_id)
            return
        end
        if type(data_source_id)~= "string" then
            Guard.basic_type_error("data_source_id must be string")
        end
        Basic.data_source_manager[data_source_id] = {
            data_source_id = data_source_id
        }
        return Basic.data_source_manager[data_source_id]
    end

end