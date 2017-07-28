--[[ 日期时间相关工具函数 ]]

TimeUtil = TimeUtil or {}

local function get_limit_time(list, skip_lead0, min, max)
	skip_lead0 = NVL(skip_lead0, true)

	local sub_list = {}
	for i, v in ipairs(list) do
		if not skip_lead0 or #sub_list > 0 or v[1] ~= 0 then
			sub_list[#sub_list + 1] = v
		end
	end

	if min and min > 0 then
		local index = #list - #sub_list
		while #sub_list < min and index > 0 do
			table.insert(sub_list, 1, list[index])
			index = index - 1
		end
	end

	if max and max > 0 then
		while #sub_list > max do
			table.remove(sub_list, #sub_list)
		end
	end

	local str = ""
	for i, v in ipairs(sub_list) do
		str = str .. v[1] .. v[2]
	end

	return str
end

--[[
	格式化计时秒数
	min 最少显示多少个时间单位
	max 最多显示多少个时间单位
--]]
function TimeUtil.FormatSeconds(seconds, format, min, max)
	local prefix = seconds >= 0 and "" or "-"
	seconds = math.abs(seconds)
	format = format or (seconds >= 3600 and "HH:MM:SS" or "MM:SS")

	if format == "HMS_AUTO_MIN2" then
		format = "HMS_AUTO"
		min = 2
	elseif format == "HMS_AUTO_FIX2" then
		format = "HMS_AUTO"
		min = 2
		max = 2
	elseif format == "DHMS_AUTO_MIN2" then
		format = "DHMS_AUTO"
		min = 2
	elseif format == "DHMS_AUTO_FIX2" then
		format = "DHMS_AUTO"
		min = 2
		max = 2
	elseif format == "DHMS_AUTO_2TO3" then
		format = "DHMS_AUTO"
		min = 2
		max = 3
	elseif format == "DHM_AUTO_FIX2" then
		format = "DHM_AUTO"
		min = 2
		max = 2
	end

	local day_str, hour_str, minute_str, sec_str = FuncSwithUtil.GetTimeStr()
	local hour = math.floor(seconds / 3600)
	local minute = math.floor(seconds % 3600 / 60)
	local sec = math.floor(seconds % 60)

	if format == "MM:SS" then
		return prefix .. string.format("%02d:%02d", minute, sec)
	elseif format == "HH:MM" then
		return prefix .. string.format("%02d:%02d", hour, minute)
	elseif format == "HH:MM:SS" then
		return prefix .. string.format("%02d:%02d:%02d", hour, minute, sec)
	elseif format == "(SS)" then
		return "(" .. prefix .. tostring(seconds) .. ")"
	elseif format == "HMS" then
		return prefix .. hour .. hour_str ..  minute .. minute_str .. sec .. sec_str
	elseif format == "DHMS_AUTO" then
		local day = math.floor(hour / 24)
		hour = hour - day * 24
		return prefix .. get_limit_time({{day, day_str}, {hour, hour_str}, {minute, minute_str}, {sec, sec_str}}, true, min, max)
	elseif format == "HMS_AUTO" then
		return prefix .. get_limit_time({{hour, hour_str}, {minute, minute_str}, {sec, sec_str}}, true, min, max)
	elseif format == "DHM_AUTO" then
		local day = math.floor(hour / 24)
		hour = hour - day * 24
		return prefix .. get_limit_time({{day, day_str}, {hour, hour_str}, {minute, minute_str}}, true, min, max)
	else
		return prefix .. tostring(seconds)
	end
end

--[[
	格式化截止时间戳为计时秒数 默认用服务器时间
--]]
function TimeUtil.FormatToTime(to_time, format, is_srv)
	local seconds = to_time - IF(NVL(is_srv, true), os.srv_time(), os.time())
	if seconds < 0 then seconds = 0 end

	return TimeUtil.FormatSeconds(seconds, format)
end

--[[
	格式化时间戳 默认用服务器时间
--]]
function TimeUtil.FormatTime(timestamp, format)
	timestamp = NVL(timestamp, os.srv_time())
	format = NVL(format, "HH:MM:SS")

	local time = os.date("*t", timestamp)

	if format == "MM:SS" then
		return string.format("%02d:%02d", time.min, time.sec)
	elseif format == "HH:MM" then
		return string.format("%02d:%02d", time.hour, time.min)
	elseif format == "HH:MM:SS" then
		return string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	elseif format == "YYYYMMDD" then
		return string.format("%04d%02d%02d", time.year, time.month, time.day)
	elseif format == "YYYY-MM-DD" then
		return string.format("%04d-%02d-%02d", time.year, time.month, time.day)
	elseif format == "MM-DD" then
		return string.format("%02d-%02d", time.month, time.day)
	elseif format == "ALL" then
		return string.format("%04d-%02d-%02d %02d:%02d:%02d", time.year, time.month, time.day, time.hour, time.min, time.sec)
	elseif format == "ALL_NO_YEAR" then
		return string.format("%02d-%02d %02d:%02d:%02d", time.month, time.day, time.hour, time.min, time.sec)
	elseif format == "YYYY\\MM\\DD" then
		return string.format("%04d\\%02d\\%02d", time.year, time.month, time.day)
	else
		return tostring(timestamp)
	end
end

--[[
	获取周几 (1-7)  默认用服务器时间
--]]
function TimeUtil.GetWeekDay(timestamp, is_srv)
	timestamp = timestamp or IF(NVL(is_srv, true), os.srv_time(), os.time())
	local t = os.date("*t", timestamp)
	local wday = t.wday - 1
	return (wday == 0 and 7 or wday)
end

--[[ 获取所在月的天数  默认用服务器时间 ]]
function TimeUtil.GetMonthDays(timestamp, is_srv)
	timestamp = timestamp or IF(NVL(is_srv, true), os.srv_time(), os.time())
	local t = os.date("*t", timestamp)
	if t.month == 2 then
		return IF(t.year % 400 == 0 or t.year % 4 == 0 and t.year % 100 ~= 0, 29, 28)
	elseif table.exists({1, 3, 5, 7, 8, 10, 12}, t.month) then
		return 31
	else
		return 30
	end
end

--[[ 获取相对于当天0点的秒数 ]]
function TimeUtil.GetDaySeconds(timestamp, is_srv)
	timestamp = timestamp or IF(NVL(is_srv, true), os.srv_time(), os.time())
	local t = os.date("*t", timestamp)
	return t.hour * 3600 + t.min * 60 + t.sec
end
