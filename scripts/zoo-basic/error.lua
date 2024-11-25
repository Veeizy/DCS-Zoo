Guard.basic_class_duplicate = nil
Guard.basic_class_no_found = nil
Guard.basic_condition_duplicate = nil
Guard.basic_state_is_undefined = nil
Guard.basic_variable_is_undefined = nil
Guard.basic_index_is_undefined = nil
Guard.basic_wrong_method_called = nil
Guard.basic_type_error = nil
Guard.basic_index_duplicate = nil
Guard.basic_index_conflict = function(k,v)
    local msg=msg..tostring(k).." : "..tostring(v)
    Guard.message(msg)
end