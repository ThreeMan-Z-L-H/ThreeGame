--[[
	字符串工具函数
	侧重于字符串的基本操作
--]]


-- 以某个分隔符为标准，分割字符串
function string.Split(split_string, splitter, ignore_empty, is_plain)
	-- @param split_string 需要分割的字符串
	-- @param splitter 分隔符
	-- @param ignore_empty 是否忽略空字符串 默认false
	-- @param is_plain splitter是否是纯文本 默认true
	-- @return 用分隔符分隔好的table

	ignore_empty = NVL(ignore_empty, false)
	is_plain = NVL(is_plain, true)

	local split_result = {}
	local search_pos_begin = 1

	while true do
		local find_pos_begin, find_pos_end = string.find(split_string, splitter, search_pos_begin, is_plain)
		if not find_pos_begin then
			break
		end

		split_result[#split_result + 1] = string.sub(split_string, search_pos_begin, find_pos_begin - 1)
		search_pos_begin = find_pos_end + 1
	end

	if search_pos_begin <= string.len(split_string) then
		split_result[#split_result + 1] = string.sub(split_string, search_pos_begin)
	end

	if ignore_empty then
		local filter_result = {}
		for i = 1, #split_result do
			if split_result[i] ~= "" then
				table.insert(filter_result, split_result[i])
			end
		end

		return filter_result
	else
		return split_result
	end
end

-- 以某个连接符为标准，返回一个table所有字段连接结果
function string.Join(join_table, joiner, ignore_empty)
	-- @param join_table 连接table
	-- @param joiner 连接符
	-- @param ignore_empty 是否忽略空字符串 默认false
	-- @return 用连接符连接后的字符串

	ignore_empty = NVL(ignore_empty, false)

	if #join_table == 0 then
		return ""
	end

	if ignore_empty then
		local result = ""
		for i = 1, #join_table do
			if join_table[i] ~= "" then
				if result ~= "" then result = result .. joiner end
				result = result .. join_table[i]
			end
		end

		return result
	else
		local fmt = "%s"
		for i = 2, #join_table do
			fmt = fmt .. joiner .. "%s"
		end

		return string.format(fmt, unpack(join_table))
	end
end

-- 纯文本替换
function string.Replace(str, sub, newsub)
	local t = {}

	local last_end = 0
	local b, e = string.find(str, sub, last_end + 1, true)
	while b and e do
		t[#t + 1] = string.sub(str, last_end + 1, b - 1)
		t[#t + 1] = newsub
		last_end = e
		b, e = string.find(str, sub, last_end + 1, true)
	end
	t[#t + 1] = string.sub(str, last_end + 1)

	return table.concat(t)
end

-- 去首尾空白
function string.TrimLeft(str)
	return (string.gsub(str, "^%s+", ""))
end

function string.TrimRight(str)
	return (string.gsub(str, "%s+$", ""))
end

function string.Trim(str)
	return string.TrimRight(string.TrimLeft(str))
end

function string.TrimAllSpace(str)
	return (string.gsub(str, "%s+", ""))
end

function string.TrimAllNewline(str)
	return (string.gsub(str, "[\r\n]", ""))
end

--获得字符列表
function string.GetCharsList(str)
	local chars_list = {}
	for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
		chars_list[#chars_list + 1] = uchar 
	end
	
	return chars_list
end

--获得码点列表
function string.GetCodePointsList(utf8str)
	local res = {}

	local seq = 0
	local val = nil
	for i = 1, #utf8str do
		local c = string.byte(utf8str, i)
		if seq == 0 then
			table.insert(res, val)
			seq = c < 0x80 and 1
				or c < 0xE0 and 2
				or c < 0xF0 and 3 
				or c < 0xF8 and 4
				or c < 0xFC and 5
				or c < 0xFE and 6
				or 0
			val = bit.band(c, 2^(8-seq) - 1)
		else
			val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
		end
		seq = seq - 1
	end
	table.insert(res, val)

	return res
end

--获得字符数
function string.GetCharsNum(str)
	local _, count = string.gsub(str, "[^\128-\193]", "")
	return count
end

--把多个字符串连接成一个字符串
function string.Contact(str_table, seprator)
	return table.concat(str_table, seprator)
end

-- utf8 转 码点
function string.Utf8ToCodePoint(utf8str)
	local cp_list = string.GetCodePointsList(utf8str)
	return #cp_list > 0 and cp_list[1] or -1
end

