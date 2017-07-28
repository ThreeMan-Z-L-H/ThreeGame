--[[
	table库函数扩展
--]]


--任意table转为字符串
local local_inspect = require("utils/inspect")
function Inspect(t, depth)
   return local_inspect(t, {
   		depth = depth,
   		filter = function(v, path)
   			return path[#path] == "DeleteMe" or path[#path] == "_class_type" or path[#path] == "<metatable>"
   		end
   		})
end

function InspectAll(t, depth)
	return local_inspect(t, {depth = depth})
end

--table元素数量 
function table.size(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

--判断是否空表
function table.empty(t)
	return next(t) == nil
end

--两个table合并(相同key会覆盖)
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
    return dest
end

--连接数组型table
function table.joinArray(dest, src)
	for _, v in ipairs(src) do
		dest[#dest + 1] = v
	end
	return dest
end

--是否存在某值
function table.exists(t, item)
    return table.keyOfItem(t, item) ~= nil
end

--获取table元素索引
function table.keyOfItem(t, item)
    for k, v in pairs(t) do
        if v == item then return k end
    end
    return nil
end

--新key的table
function table.transkey(t, key_name)
	local new_t = {}

	if key_name ~= nil then
		for _, v in pairs(t) do
			new_t[v[key_name]] = v
		end
	else
		for _, v in pairs(t) do
			table.insert(new_t, v)
		end
	end

	return new_t
end

-- 生成数组型table
function table.toArray(t)
	local new_t = {}
	for _, v in pairs(t) do
		new_t[#new_t + 1] = v
	end
	return new_t
end

-- 每一项进行变换
function table.transform(t, trans_func)
	for k, v in pairs(t) do
		t[k] = trans_func(k, v)
	end
end

--获取table第一个元素
function table.firstItem(t)
	return next(t)
end

--过滤
function table.filter(tb, filter_func)
	local t = {}

	for k, v in pairs(tb) do
		if filter_func(k, v) then
			t[k] = v
		end
	end

	return t
end

function table.ifilter(tb, filter_func)
	local t = {}

	for i = 1, #tb do
		if filter_func(i, tb[i]) then
			t[#t + 1] = tb[i]
		end
	end

	return t
end

-- 反序
function table.reverse(t)
	local n = #t
	for i = 1, n / 2 do
		local temp = t[i]
		local j = n + 1 - i
		t[i] = t[j]
		t[j] = temp
	end
	
	return t
end

--[[打乱数组的排顺，is_delete-是否从tb中删除]]
function table.shuffle(tb, max_n, is_delete)
    if #tb == 0 then
        return {}
    end

    max_n = max_n or #tb
    is_delete = NVL(is_delete, false)
    local res_tb = {}

    if is_delete then
        while #tb > 0 and max_n > 0 do
            res_tb[#res_tb + 1] = table.remove(tb, math.random(1, #tb))
            max_n = max_n - 1
        end
    else
        local len = #tb
        local random_temp = {}
        for i = 1, len do
            random_temp[i] = i 
        end

        random_temp = table.shuffle(random_temp, len, true)
        for i = 1, max_n do
            res_tb[i] = tb[random_temp[i]]
        end
    end

    return res_tb 
end

-- [[ 排序遍历的pairs ]]
function table.sortPairs(t, func)
	local temp = {}
	for k, v in pairs(t) do 
		temp[#temp + 1] = {key = k, value = v}
	end
	table.sort(temp, function(p1, p2)
		if func then
			return func(p1.key, p2.key, p1.value, p2.value)
		else
			return p1.key < p2.key
		end
	end)

	for i = 1, #temp do
		temp[i] = temp[i].key
	end

	local i = 0
	local iter = function()
		i = i + 1
		if temp[i] == nil then
			return nil
		else
			return temp[i], t[temp[i]]
		end
	end

	return iter
end

function table.sortKeyPairs(t, key_compare_func)
	return table.sortPairs(t, function(k1, k2)
		if key_compare_func ~= nil then
			return key_compare_func(k1, k2)
		else
			return k1 < k2
		end
	end)
end

function table.sortValuePairs(t, value_compare_func)
	return table.sortPairs(t, function(k1, k2, v1, v2)
		if value_compare_func then
			return value_compare_func(v1, v2)
		else
			return v1 < v2
		end
	end)
end

-- 取数组的一部分子数组
function table.subArray(t, start_index, end_index)
	start_index = start_index or 1
	end_index = end_index or #t

	if start_index < 0 then
		start_index = #t + 1 + start_index
	end
	if start_index <= 0 then
		start_index = 1
	end
	if end_index < 0 then
		end_index = #t + 1 + end_index
	end
	if end_index > #t then
		end_index = #t
	end

	local sub = {}
	for i = start_index, end_index do
		sub[#sub + 1] = t[i]
	end
	return sub
end

-- 抽取value 形成 {[value1]=true, [value2]=true ..}
function table.getValueMap(t)
	local value_map = {}
	for _, v in pairs(t) do
		value_map[v] = true
	end
	return value_map
end

-- 抽取key 形成列表
function table.getKeyList(t)
	local key_list = {}
	for k, _ in pairs(t) do
		key_list[#key_list + 1] = k
	end
	return key_list
end

-- 以key为标准 返回表1存在但表2不存在的部分
function table.diffByKey(t1, t2)
	local t = {}
	for k, v in pairs(t1) do
		if not t2[k] then
			t[k] = v
		end
	end
	return t
end

-- 提取table每一项的某个字段
-- ToMap:   {{key="a"}, {key="b"}}  => {["a"] = true, ["b"] = true}
-- ToArray: {{key="a"}, {key="b"}}  => {"a", "b"}
function table.extractToMap(t, key_name)
	local m = {}
	for k, v in pairs(t) do
		m[v[key_name]] = true
	end

	return m
end

function table.extractToArray(t, key_name, is_t_array)
	local arr = {}
	if is_t_array then
		for k, v in ipairs(t) do
			arr[#arr + 1] = v[key_name]
		end
	else
		for k, v in pairs(t) do
			arr[#arr + 1] = v[key_name]
		end
	end

	return arr
end

-- 上面table.extract的反向操作
-- FromMap:   {["aa"] = true, ["bb"] = true}  => {{key = "aa"}, {key = "bb"}}
-- FromArray: {"aa", "bb"}                    => {{key = "aa"}, {key = "bb"}}
function table.extendFromMap(m, key_name)
	local t = {}
	for k, v in pairs(m) do
		if v then
			t[#t + 1] = {[key_name] = k}
		end
	end

	return t
end

function table.extendFromArray(arr, key_name)
	local t = {}
	for k, v in ipairs(arr) do
		t[k] = {[key_name] = v}
	end

	return t
end

-- function TabToStr( tab, flag )
-- 	local result = ""
-- 	result = string.format( "%s{", result )

-- 	local filter = function( str )
-- 		str = string.gsub( str, "%[", " " )
-- 		str = string.gsub( str, "%]", " " )
-- 		str = string.gsub( str, "\"", " " )
-- 		str	= string.gsub( str, "%'", " " )
-- 		str	= string.gsub( str, "\\", " " )
-- 		str	= string.gsub( str, "%%", " " )
-- 		return str
-- 	end

-- 	for k,v in pairs(tab) do
-- 		if type(k) == "number" then
-- 			if type(v) == "table" then
-- 				result = string.format( "%s[%d]=%s,", result, k, TabToStr( v, flag ) )
-- 			elseif type(v) == "number" then
-- 				result = string.format( "%s[%d]=%d,", result, k, v )
-- 			elseif type(v) == "string" then
-- 				result = string.format( "%s[%d]=%q,", result, k, v )
-- 			elseif type(v) == "boolean" then
-- 				result = string.format( "%s[%d]=%s,", result, k, tostring(v) )
-- 			else
-- 				if flag then
-- 					result = string.format( "%s[%d]=%q,", result, k, type(v) )
-- 				else
-- 					error("the type of value is a function or userdata")
-- 				end
-- 			end
-- 		else
-- 			if type(v) == "table" then
-- 				result = string.format( "%s%s=%s,", result, k, TabToStr( v, flag ) )
-- 			elseif type(v) == "number" then
-- 				result = string.format( "%s%s=%d,", result, k, v )
-- 			elseif type(v) == "string" then
-- 				result = string.format( "%s%s=%q,", result, k, v )
-- 			elseif type(v) == "boolean" then
-- 				result = string.format( "%s%s=%s,", result, k, tostring(v) )
-- 			else
-- 				if flag then
-- 					result = string.format( "%s[%s]=%q,", result, k, type(v) )
-- 				else
-- 					error("the type of value is a function or userdata")
-- 				end
-- 			end
-- 		end
-- 	end
-- 	result = string.format( "%s}", result )
-- 	return result
-- end

-- function Serialize( tab, level, strStart, strEnd )
-- 	local rep = string.rep
-- 	strStart = strStart or "\""
-- 	strEnd = strEnd or "\""
-- 	level = level or 0

-- 	local str = "\n" .. rep( "\t", level ) .. "{\n"
-- 	for k,v in pairs(tab) do
-- 		local kIsStr = 0
-- 		if type(k) == "string" then
-- 			kIsStr = 1
-- 		end
-- 		if type(v) == "table" then
-- 			str = str .. rep( "\t", level+1 ) .. "[" .. rep( strStart, kIsStr ) .. k .. rep( strEnd, kIsStr ) .. "]" .. " = " .. Serialize( v, level+1 ) .. "\n"
-- 		else
-- 			local vIsStr = 0
-- 			if type(v) == "string" then
-- 				vIsStr = 1
-- 			end
-- 			str = str .. rep( "\t", level+1 ) .. "[" .. rep( strStart, kIsStr ) .. k .. rep( strEnd, kIsStr ) .. "]" .. " = "..rep( strStart, vIsStr ) .. v .. rep( strEnd, vIsStr ) .. ",\n"
-- 		end
-- 	end
-- 	str = str .. rep( "\t", level ) .. "},"
-- 	return str
-- end

function assert_TableSameSize(tb1, tb2, msg)
	assert(table.size(tb1) == table.size(tb2), msg or "table size NOT same!! \n" .. debug.traceback())
end

function assert_TableIsArray(tb, msg)
	assert(table.size(tb) == #tb, msg)
end

function assert_TableIsBase0Array(tb, msg)
	assert(table.size(tb) == #tb + 1 and tb[0] ~= nil, msg)
end

