--[[
	杂七杂八各种util 
--]]

--[[
	delete所有对象
	obj_list可以是容器: List、 table
	delete后, 容器会变成空, 但建议外界额外显式赋值 obj_list={} 或 obj_list = nil
--]]
function DeleteMeAll(obj_list)
    if not obj_list then
        return
    end
    if obj_list.__is_list then
        while List.Size(obj_list) > 0 do
            List.PopBack(obj_list):DeleteMe()
        end
    else
    	for key, obj in pairs(obj_list) do
    		obj:DeleteMe()
    		obj_list[key] = nil
    	end
    end
end

