Guard = Guard or {}

do
    local unpack = unpack or table.unpack
    function Guard.error (message)
        env.info(message)
        error(message)
    end 
    function Guard.message(error_type,message)
        return error_type.." : "..message
    end
    Guard._err_table = {
        __call = function(self,...)
            Guard.error(self.message_handler(self.error_type,unpack({...})))
        end
    }
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