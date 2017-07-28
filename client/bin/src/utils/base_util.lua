--[[
	基础性的工具函数
--]]

-- var args
function _ARG(...)
	local arg = {...}
	arg.n = select('#', ...)

	return arg
end

--[[
-- 重定向print
function print(...)
    local s = ""
    local arg = {...}
    for i = 1, select('#', ...) do
    	if i > 1 then s = s .. " " end
    	s = s..tostring(arg[i])
    end
    
	CCLuaLog(s)
end
--]]

-- LUA ERROR HANDLER
-- function __G__TRACKBACK__(msg)
--     Log.info("-----------------------------------------------------------------------")
--     Log.info("[LUA ERROR] " .. tostring(msg) .. "\n")
--     Log.info(debug.traceback("", 2))
--     Log.info("-----------------------------------------------------------------------")
-- end

-- 深拷贝对象
function DeepCopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end

		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end

		return setmetatable(new_table, getmetatable(object))
	end

	return _copy(object)
end

-- 浅拷贝
function ShallowCopy(tb)
	if type(tb) == "table" then
		local t = {}
		for k, v in pairs(tb) do
			t[k] = v
		end
		
		return t
	end

	return tb
end

-- obj和成员函数, 打包成函数对象
-- 支持两种方式: HANDLER(self, self.FuncName)   HANDLER(self, "FuncName")
function HANDLER(target, method)
	if type(method) == "string" then
		assert(target and target[method], "HANDLER nil !!" .. debug.traceback())
		return function(...)
			return target[method](target, ...)
		end
	else
		assert(type(method) == "function", "HANDLER invalid !!" .. debug.traceback())
	    return function(...)
	        return method(target, ...)
	    end
	end
end

-- nil时返回默认值
function NVL(var, default_value)
	if var == nil then
		return default_value
	else
		return var
	end
end

-- nil或空时返回默认值
function NVLstr(var, default_value)
	if var == nil or var == "" then
		return default_value
	else
		return var
	end
end

-- 三元表达式
function IF(expression, true_ret, false_ret)
	if expression then
		return true_ret
	else
		return false_ret
	end
end

-- C风格bool (非0即为真)
function toCbool(val)
	return val and (val ~= 0)
end

-- lua风格bool
function tobool(val)
	return not not val
end

-- 扩展traceback信息
function dump_traceback(skip_lev)
	local t = {" stack traceback:"}
	local ex_str = "    -- Variable Values --\n"

	local level = 2 + (skip_lev or 0)
	while true do
		local ar = debug.getinfo(level, "Snl")
		if not ar then break end

		t[#t + 1] = "    File: " .. tostring(ar.short_src) .. " :" .. tostring(ar.currentline) .. " " .. tostring(ar.name)
		
		if string.len(ex_str) < 1024 then
			local index = 1
			while true do
				local name, value = debug.getlocal(level, index)
				if not name then break end

				if string.sub(name, 1, 1) ~= "(" and name ~= "self" and name ~= "ctrl" and name ~= "view" and name ~= "model" and name ~= "data" and name ~= "_class" then
					ex_str = ex_str .. "    local " .. name .. " = " .. (type(value) == "table" and Inspect(value, 3) or tostring(value)) .. "\n"
				end
				
				index = index + 1
			end

			local func = debug.getinfo(level).func
			index = 1
			while func do
				local name, value = debug.getupvalue(func, index)
				if not name then break end

				if string.sub(name, 1, 1) ~= "(" and name ~= "self" and name ~= "ctrl" and name ~= "view" and name ~= "model" and name ~= "data" and name ~= "_class" then
					ex_str = ex_str .. "    upval " .. name .. " = " .. (type(value) == "table" and Inspect(value, 3) or tostring(value)) .. "\n"
				end

				index = index + 1
			end

			ex_str = ex_str .. "    --" .. "\n"
		end

		level = level + 1
	end

	return table.concat(t, "\n") .. "\n" .. ex_str
end

function dump_caller(skip_lev)
	local level = 2 + (skip_lev or 0)
	local ar = debug.getinfo(level, "Snl")
	if ar then
		return tostring(ar.short_src) .. " :" .. tostring(ar.currentline) .. " " .. tostring(ar.name)
	end
	
	return ""
end

-- 是否iOS
function IsTargetIOS()
	_TARGET_PLATFORM = _TARGET_PLATFORM or CCApplication:sharedApplication():getTargetPlatform()
	return _TARGET_PLATFORM == kTargetIphone or _TARGET_PLATFORM == kTargetIpad
end

-- 版本号(数值)
function GetAppVersionValue()
	_APP_VER_STR = _APP_VER_STR or CCGetAppVersionName()

	local ver_str = string.gsub(_APP_VER_STR, "%.", "")
	return tonumber(ver_str) or 0
end

