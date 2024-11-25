z_gate = {}
--[[
    z_gate是zoo的入口

    包含了对zoo项目的依赖管理

    zoo项目在启动时，需要从任务端读取zoo gate。和init脚本
    init脚本需要告知gate zoo所在路径，以及游戏资源所在路径
    然后init脚本需要调用所启动的zoo项目的项目id，并传入目标
    项目所需的参数列表

    zoo gate在启动项目时，会检查自己是否以及初始化。若还未初始化
    则zoo gate会进行一次初始化
    zoo gate在初始化时，会检查zoo项目路径是否正确
    然后会扫描zoo项目路径中所有以zoo结尾的文件，并dofile
    
    所有的zoo文件中都应当调用z_gate的函数，来定义模块的id以及依赖关系
    所需参数，启动时如何向依赖框架传递参数。模块对所依赖的模块究竟依赖
    哪些内容。zoo gate会对依赖的模块进行自检，以确保模块可以正常的被
    调用

    并且zoo gate会检查是否存在依赖未传递必须的参数

    zoo在运行zoo项目时，会根据项目id找到已经加载的定义，并根据定义依次
    加载各个模块，并对需要初始化的模块调用init函数，并根据依赖关系的定义
    传递参数

    module = {
        module_id = 模块在框架中的id (string)
        object = 模块在程序中的对象名，用于调用init以及当程序运行时，调用main (string)
        dependencies = 所有的依赖模块id(list)
        init_mode = none optional must 用以表示该模块是否需要初始化
        args = {
            "arg_name" = {
                "type" = optional must
                "default" = 默认值
            }
        }用以表示参数是可填还是必须，并且可以提供默认值
        arg_table = {
            "module_id" = {
                "to" = "from"
            }
        }用以表示当前模块如何向下传递参数
    }
    
]]

do
    local _err = function(message)
        env.info(message)
        error(message)
    end
    
    local _zoo_table = nil
    local _loaded = nil

    if not lfs then
        _err("can not initialize zoo without module:lfs")
        return
    end

    z_gate.module = {}

    z_gate.module.INIT_MODE = {
        NON = 0,
        OPTIONAL = 1,
        MUST = 2
    }
    z_gate.module.ARG_TYPE = {
        OPTIONAL = 0,
        MUST = 1
    }

    z_gate.modules= {}

    function z_gate.module:depend(module_id)
        table.insert(self.dependencies,module_id)
        return self
    end
    function z_gate.module:object(object_name)
        self.object_name = object_name
        return self
    end
    function z_gate.module:get_object()
        return loadstring("return "..self.object_name)()
    end

    function z_gate.module:non_init()
        self.init_mode = z_gate.module.INIT_MODE.NON
        return self
    end

    function z_gate.module:optional_init()
        self.init_mode = z_gate.module.INIT_MODE.OPTIONAL
        return self
    end

    function z_gate.module:must_init()
        self.init_mode = z_gate.module.INIT_MODE.MUST
        return self
    end

    function z_gate.module:optional_arg(arg_name,default)
        return self:arg(arg_name,z_gate.module.ARG_TYPE.OPTIONAL,default)
    end

    function z_gate.module:must_arg(arg_name,default)
        return self:arg(arg_name,z_gate.module.ARG_TYPE.MUST,default)
    end

    function z_gate.module:arg(arg_name,arg_type,default)
        arg_type = arg_type or z_gate.module.ARG_TYPE.OPTIONAL

        self.args[arg_name] = {
            type = arg_type,
            default = default
        }
        return self
    end

    function z_gate.module:arg_to(module,from,to)
        self.args_table[module] = self.args_table[module] or {}

        self.args_table[module][to] = from

        return self
    end

    function z_gate.new_module(module_id)
        if type(module_id) == "number" then
            module_id = tostring(module_id)
        elseif type(module_id) ~= "string" then
            _err("type error :module_id get "..type(module_id).." needs string or number")
            return nil
        end

        local t = setmetatable(
        {
            id =module_id,
            init_mode = z_gate.module.INIT_MODE.NON,
            dependencies = {},
            args={},
            args_table ={}
        },{
            __index = z_gate.module
        })
        
        if z_gate.modules[module_id] then
            _err("Module Duplicate Definition :"..module_id)
        end
        z_gate.modules[module_id] = t
        z_gate.last_module = t
        return t
    end 

    function z_gate.get_module(module)
        return z_gate.modules[module]
    end


    
    --[[
        init逻辑：
            记录zoo_path下所有的文件夹，并寻找.zoo文件，并运行当前文件夹里所有的zoo文件
            若当前文件夹里没有找到zoo，则对所有记录的文件夹递归。
            若当前已经找到zoo，则记录该zoo文件的名称和路径，当加载模块的模块与zoo文件名
            一致时，则会根据id索引到路径，并加载路径及其下面所有的lua文件
    ]]
    function z_gate.load_zoo(path)
        local dir = {}
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local absolute_path = path..'/'..file
                local attr = lfs.attributes(absolute_path)
                if attr.mode == "directory" then
                    table.insert(dir,absolute_path)
                else
                    if string.match(file,'[.]zoo$') then
                        local module_name = file:gsub("%.[^.]+$", "")
                        _zoo_table[module_name] = path
                        z_gate.new_module(module_name)
                        dofile(absolute_path)
                        return 
                    end
                end
            end
        end
        for _, p in pairs(dir) do
            z_gate.load_zoo(p)
        end

    end

    function z_gate.init(zoo_path)
        _zoo_table = {}

        if not zoo_path:match("^[A-Za-z]:") then
            zoo_path = lfs.writedir()..zoo_path
        end
        if not lfs.attributes(zoo_path) then
            _err("zoo path is not found")
            return 
        end

        z_gate.load_zoo(zoo_path)

    end

    function z_gate.load_scripts(path)
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local absolute_path = path..'/'..file
                local attr = lfs.attributes(absolute_path)
                if attr.mode == "directory" then
                    z_gate.load_scripts(absolute_path)
                else
                    if string.match(file,'[.]lua$') then
                        dofile(absolute_path)
                    end
                end
            end
        end
    end

    function z_gate.load(module)
        if _loaded[module] then
            return 
        end

        local m = z_gate.get_module(module)
        if not m then
            _err("module not found:"..module)
            return
        end
        _loaded[module] = true
        if m.dependencies then
            for _, d in pairs(m.dependencies) do
                z_gate.load(d)
            end
        end

        z_gate.load_scripts(_zoo_table[module])

    end
    --[[
        运行时，先初始化所有依赖。
        如果当前模块不需要初始化，或没有初始化函数，则仅传递参数，不进行初始化
        若当前模块需要初始化，且为optional，则检查所有的must参数是否包含。
        若不满足所有的must参数，则不进行初始化。
        若当前模块must初始化，则检查所有的must参数是否都存在，若不存在且没有default
        则报错
        若当前不为is_init则运行main函数
    ]]

    function z_gate.run_dependencies(module)
        for _, d in pairs(module.dependencies) do
            if module.args_table and module.args_table[d] then
                local depened_arg = {}
                for to, from in pairs(module.args_table[d]) do
                    depened_arg[to] = args[from]
                end
                z_gate.run(d,depened_arg,true)
            else
                z_gate.run(d,nil,true)
            end 
        end
    end

    function z_gate.run(module,args,is_init)
        if _loaded[module] then
            return 
        end
        _loaded[module] = true

        local m = z_gate.get_module(module)

        z_gate.run_dependencies(m)
        
        local o = m:get_object()

        if not o then
            _err("can not found module object:"..m.module_id)
        end

        if is_init then
            
            if m.init_mode == z_gate.module.INIT_MODE.NON or not o.init then
                return 
            end
            if m.args then
                for arg_name, attr in pairs(m.args) do
                    if not args[arg_name] then
                        if attr.type == z_gate.module.ARG_TYPE.OPTIONAL or 
                            (attr.type == z_gate.module.ARG_TYPE.MUST and attr.default) then
                            args[arg_name] = attr.default
                        else
                            if m.init_mode == z_gate.module.INIT_MODE.MUST then
                                _err("can not initialize module:"..m.module_id.." without arg "..arg_name)
                            end
                            return 
                        end
                    end
                end
                o.init(args)
            else
                o.init()
            end
            
        else
            o.main(args)
        end
    end

    function z_gate.go(module,args)
        _loaded = {}
        z_gate.load(module)
        _loaded = {}
        z_gate.run(module,args)
        
        _zoo_table = nil
        _loaded = nil
    end

    
    function Zoo(zoo_path,module,args)
        if not _zoo_table then
            z_gate.init(zoo_path)
        end
        z_gate.go(module,args)
    end

    function Zoo_module()
        return z_gate.last_module        
    end
   
end