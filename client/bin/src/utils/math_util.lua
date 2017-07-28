--[[
	有关数学或计算的工具函数
--]]

-- 四舍五入
function math.round(num)
	return num >= 0 and math.floor(num + 0.5) or math.ceil(num - 0.5)
end

-- 限定数值范围
function LIMIT_NUM(num, min_num, max_num)
	if num < min_num then
		return min_num
	elseif num > max_num then
		return max_num
	else
		return num
	end
end

--[[ 合成/分解ComID]]
function CompressComID(obj_type, obj_id, srv_id)
     obj_type = obj_type or 0 
     obj_id = obj_id or 0
     srv_id = srv_id or 0
    
    local str_type = tostring(obj_type)
    local str_id = tostring(obj_id)
    local str_sev = tostring(srv_id)

    local type_len = string.len(str_type)
    local id_len = string.len(str_id)
    local sev_len = string.len(str_sev)

    local format_type = string.format("%d%d%s", string.len(tostring(type_len)), type_len, str_type)
    local format_id = string.format("%d%d%s", string.len(tostring(id_len)), id_len, str_id)
    local format_sev = string.format("%d%d%s", string.len(tostring(sev_len)), sev_len, str_sev)
    
    local com_id = string.format("%s%s%s", format_type, format_id, format_sev)
    return com_id
end

function DecompressComID(com_id)
    local function read_string_by_index(str, index)
        local start_num = tonumber(string.sub(str, index, index))
        index = index + 1
        assert(start_num ~= nil, "DecompressComID( Error com_id:" .. tostring(com_id))
        local format_len = tonumber(string.sub(str,index,index+start_num-1))
        index = index + start_num
        local format_info = string.sub(str, index, index + format_len - 1)
        index = index + format_len
        return format_info, index
    end
    local com_str = com_id
    local index = 1
    local obj_type, index = read_string_by_index(com_str, index)
    local obj_id, index = read_string_by_index(com_str, index)
    local srv_id, index = read_string_by_index(com_str, index)
    
    if string.len(obj_type) < 11 then
        obj_type = tonumber(obj_type)
    end

    if string.len(obj_id) < 11 then
        obj_id = tonumber(obj_id)
    end
    
    if string.len(srv_id) < 11 then
        srv_id = tonumber(srv_id)
    end

    return obj_type,obj_id,srv_id
end

--[[ 合成/分解int32]]
function CompressInt32(high, low)
	return high * 65536 + low
end

function DecompressInt32(num)
	return math.floor(num / 65536),  math.floor(num % 65536)
end

--[[ 合成int64 ]]
function CompressInt64(high, low)
	return high * 4294967296 + low
end

function AddUpSum(n)
	return (1 + n) * n / 2
end

