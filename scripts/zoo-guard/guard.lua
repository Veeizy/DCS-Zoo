Guard = Guard or {}

do
    local unpack = unpack or table.unpack
    function Guard.error (message)
        env.info(message)
        error(message,3)
    end 
    function Guard.message(error_type,message)
        return error_type.." : "..message
    end
    Guard._err_table = {
        __call = function(self,...)
            Guard.error(self.message_handler(self.error_type,unpack({...})))
        end
    }
    --更新Gurad的函数时，需在此行以前添加，在此以后添加的内容均被视为异常
    Guard = setmetatable(Guard,{__newindex  = function(self,k,v)
        rawset(self,k,setmetatable(
            {
                error_type = k,
                message_handler = v or Guard.message
            },
            Guard._err_table 
        ))
    end})

    Guard.test_error=nil
        
end