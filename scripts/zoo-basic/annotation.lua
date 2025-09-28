do  
    

    ---@class Basic_index
    ---@field objects table<string,table<Basic_object,Basic_object>>|table<string,Basic_object>
    ---@field _nil table<Basic_object,Basic_object>
    ---@field conflict boolean
    ---@field invalid boolean

    ---@class condition_handler
    ---@field func fun(self:Basic_object):boolean
    ---@field weight number
    ---@field to string

    ---@class Basic_object:Basic_class
    ---@field field table<string,any>
    ---@field __object boolean
    ---@field __state string
    ---@field __verify_object fun(self:Basic_object)
    ---@field __set_state fun(self:Basic_object,state:string)
    ---@field update_with_condition fun(self:Basic_object,condition_container:table<string,condition_handler>):boolean
    ---@field update_with_common_condition fun(self:Basic_object):boolean
    ---@field update_with_state_condition fun(self:Basic_object):boolean
    ---@field do_action fun(self:Basic_object,from:string)
    ---@field add_to_index fun(self:Basic_object)
    ---@field update_index_var fun(self:Basic_object,var:string,value:any,from:any|nil)
    ---@field update fun(self:Basic_object)
    ---@field get fun(self:Basic_object,key:string):any
    ---@field set fun(self:Basic_object,key:string,v:any)
    ---@field multi_set fun(self:Basic_object,args:table<string,any>)
    ---@field un_set fun(self:Basic_object,key:string,v:any)
    ---@field dump fun(self:Basic_object)

    ---@class Basic_class
    ---@field class_id string
    ---@field vars table<string,table<string,string>>
    ---@field status table<string,string>
    ---@field common_condition table<string,condition_handler>
    ---@field conditions table<string,table<string,condition_handler>>
    ---@field actions table<string,fun(self:Basic_object)[]>
    ---@field actions_from table<string,table<string,fun(self:Basic_object)[]>>
    ---@field object_index table<string,Basic_index>
    ---@field objects table<Basic_object,Basic_object>
    ---@field state_index table<string,Basic_index>
    ---@field attached_class table<string,string>
    ---@field attached_method table<string,fun(self:Basic_object,class:Basic_class):Basic_object>
    ---@field functions table<string,function>
    ---@field attach fun(self:Basic_class,class:string,key:string,func:fun(self:Basic_object,class:Basic_class):Basic_object)
    ---@field state fun(self:Basic_class,name:string):Basic_class 
    ---@field var fun(self:Basic_class,name:string,default:any):Basic_class 
    ---@field func fun(self:Basic_class,name:string,func:function):Basic_class
    ---@field condition fun(self:Basic_class,condition_id:string,from:string,to:string,func:fun(self:Basic_object):boolean):Basic_class
    ---@field new fun(self:Basic_class,args:table<string,any>,state:string):Basic_object 
    ---@field action fun(self:Basic_class,state:string,from:string|nil,func:fun(self:Basic_object)):Basic_class
    ---@field index fun(self:Basic_class,var:string,conflict:boolean):Basic_class 
    ---@field build_index_conflict fun(self:Basic_class,var:string):table<string,Basic_object>
    ---@field build_index_no_conflict fun(self:Basic_class,var:string) table<string,table<Basic_object,Basic_object>>,table<Basic_object,Basic_object>
    ---@field build_index_var fun(self:Basic_class,var:string)
    ---@field invalid_index fun(self:Basic_class,var:string)
    ---@field build_index fun(self:Basic_class)
    ---@field get_objects fun(self:Basic_class,index:string|nil,value:any)Basic_object|table<Basic_object,Basic_object>
    ---@field get_objects_with_state fun(self:Basic_class,state:string)table<Basic_object,Basic_object>
    ---@field has_index_conflict fun(self:Basic_class,var:string):boolean
    ---@field get_func fun(self:Basic_class,name:string):function
    
end