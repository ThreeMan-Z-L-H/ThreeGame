--[[
	文本处理辅助工具函数
	侧重于应用级别的针对具体功能的文本处理
--]]

TextUtil = TextUtil or {}

--[[ 数字加颜色标签 忽略html标签 ]]
function TextUtil.ColorDigits(str, color)
	color = color or Config.Color16.BLUE

	local color_plain_func = function(s)
		return string.gsub(s, "[\\.0-9]+%%*", function(w) return HtmlTool.ColorWord(w, color) end)
	end

	str = string.gsub(str, "([^<>]+)(<.->)", 
		function(w1, w2)
			return color_plain_func(w1) .. w2
		end
	)
	str = string.gsub(str, "[^<>]+$", 
		function(w)
			return color_plain_func(w)
		end
	)

	return str
end

--[[数值转为带正负号的字符串]]
function TextUtil.SignedNumberStr(number)
	return number > 0 and "+" .. tostring(number) or (number == 0 and "0" or tostring(number))
end

--[[如超过一定值 返回以'万'为单位的数值字符串, is_care_last去掉小数点最后位的0]]
function TextUtil.UnitNumberStr(number, dot_num, prefix_min, is_care_last)
	dot_num = dot_num or 2 				-- 默认小数点后2位
	prefix_min = prefix_min or 10000	-- 默认1W起开始加后缀
    is_care_last = NVL(is_care_last, false)
	if number >= prefix_min then
		local fmt = string.format("%%.%df", dot_num)
		local str = string.format(fmt, number / 10000)
		if is_care_last then
			str = string.gsub(str, "(%.)([0-9]-)(0*)$", function(w1, w2,w3) return w2 ~= "" and w1 .. w2 or ""  end)
		end
		return str .. "W"
	else
		return tostring(number)
	end
end

--[[
	按数值范围进行格式化, 返回 数字 + 单位(空/K/M/G),  数字部分除小数点不超过3位
	opt_list选项：
	min    : >=此值才显示单位
	min_k  : >=此值才显示K
	min_m  : >=此值才显示M
	min_g  : >=此值才显示G
--]]
function TextUtil.AutoUnitNumberStr(number, opt_list)
	opt_list = opt_list or {}

	local sign = ""
	if number < 0 then
		number = -number
		sign = "-"
	end

	if opt_list.min and number < opt_list.min then
		return sign .. tostring(number)
	end

	local min_k = opt_list.min_k or 1000
	local min_m = opt_list.min_m or 999500
	local min_g = opt_list.min_g or 999500000

	if TextUtil._special_banshu_flag == nil then
		TextUtil._special_banshu_flag = CCGetAppMetaValue("game.specialBanshuFlag") == "true"
	end

	local unit_number = 1
	local unit_str = ""
	if number >= min_g then
		unit_number = 1000000000
		unit_str = TextUtil._special_banshu_flag and _L(35) or "G"
	elseif number >= min_m then
		unit_number = 1000000
		unit_str = TextUtil._special_banshu_flag and _L(34) or "M"
	elseif number >= min_k then
		unit_number = 1000
		unit_str = TextUtil._special_banshu_flag and _L(33) or "K"
	end

	if unit_number > 1 then
		local str = ""
		for dot_num = 2, 0, - 1 do
			local fmt = string.format("%%.%df", dot_num)
			str = string.format(fmt, number / unit_number)
			str = string.gsub(str, "(%.)([0-9]-)(0*)$", function(w1, w2,w3) return w2 ~= "" and w1 .. w2 or ""  end)
			if dot_num == 0 or  string.len(str) <= 4 then
				break
			end
		end
		
		return sign .. str .. unit_str
	else
		return sign .. tostring(number)
	end
end

--[[
	解析简单的帮助信息
	@@头标题		HEAD
	@小标题			SUBTITLE
	-				SEPERATOR
	!列表			LIST
	~正文			TEXT
	其它都是正文	TEXT
	每种样式格式前可用 ##数字 指定更细的样式
	单词标绿[xxx] 单词标红{xxx}
--]]
function TextUtil.ParseHelpText(text, opt_list)
	opt_list = opt_list or {}

	text = string.gsub(text, "<br>", "\n")
	text = string.gsub(text, "\r", "\n")

	local lines = string.Split(text, "\n", false, true)

	-- 单词颜色
	local function color_words(line)
		line = string.gsub(line, "%[(.-)%]", function(w)
			if opt_list.color_word_size then
				w = HtmlTool.SizeWord(w, opt_list.color_word_size)
			end
			return HtmlTool.ColorWord(w, Config.Color.GREEN)
		end)
		line = string.gsub(line, "%{(.-)%}", function(w)
			if opt_list.color_word_size then
				w = HtmlTool.SizeWord(w, opt_list.color_word_size)
			end
			return HtmlTool.ColorWord(w, Config.Color.ORANGE)
		end)
		return line
	end

	for index, line in ipairs(lines) do
		lines[index] = color_words(line)
	end

	-- 分段解析
	local sect_list = {}
	local last_sect = nil
	for index, line in ipairs(lines) do
		local subid = 0
		if string.sub(line, 1, 2) == "##" then
			local b, e, idstr = string.find(line, "^##(%d+)")
			if idstr then
				subid = tonumber(idstr) or 0
				line = string.sub(line, e + 1)
			end
		end

		if string.sub(line, 1, 2) == "@@" then
			-- 主标题
			last_sect = {type = "HEAD", subid = subid, content = { string.sub(line, 3) } }
			table.insert(sect_list, last_sect)
		elseif string.sub(line, 1, 1) == "@" then
			-- 小标题
			last_sect = {type = "SUBTITLE", subid = subid, content = { string.sub(line, 2) } }
			table.insert(sect_list, last_sect)
		elseif string.sub(line, 1, 1) == "!" then
			-- 列表
			last_sect = {type = "LIST", subid = subid, content = {}}
			table.insert(last_sect.content, string.sub(line, 2))
			table.insert(sect_list, last_sect)
		elseif line == "-" then
			-- 分隔线
			last_sect = {type = "SEPERATOR", subid = subid, content = {}}
			table.insert(sect_list, last_sect)
		elseif string.sub(line, 1, 1) == "~" then
			-- 正文
			last_sect = {type = "TEXT", subid = subid, content = {}}
			table.insert(last_sect.content, string.sub(line, 2))
			table.insert(sect_list, last_sect)
		else
			-- 继续正文或列表
			if not last_sect or (last_sect.type ~= "TEXT" and last_sect.type ~= "LIST") then
				last_sect = {type = "TEXT", subid = subid, content = {}}
				table.insert(sect_list, last_sect)
			end
			table.insert(last_sect.content, line)
		end
	end

	for index, sect in ipairs(sect_list) do
		if sect.type == "LIST" then
			local index = 0
			for i, item in ipairs(sect.content) do
				if item ~= "" then
					index = index + 1
					sect.content[i] = index .. ". " .. item
				end
			end
		end
	end

	return sect_list
end

--[[ 生成随机帐号]]
function GetRandomPlatUserName()
    local char_src = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
    "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w",
    "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}

    local range = #char_src 
    local name_len = math.random(4, 6)
    
    local random_name = {}
    for i = 1, name_len do
        random_name[#random_name + 1] = char_src[math.random(1, 100000) % range + 1]
    end

    return table.concat(random_name)
end

--[[ 生成随机密码]]
function GetRandomPlatUserPassword()
    -- 密码使用纯数字字符表示
    local password_len = 6
    
    local random_password = {}
    for i = 1, password_len do
        random_password[#random_password + 1] = math.random(1, 100000) % 10 
    end

    return table.concat(random_password)
end

--[[判断字符串的有效性,纯数字字符]]
function IsValidPlatSTR(chars, minimum_len, max_len)
    -- 判断非法字符（非数字和字符）
    local start, len, match = string.find(chars, "%W*(%w*)%W*")
    return match == chars and len >= minimum_len and len <= max_len
end

-- 缩写
_N = TextUtil.AutoUnitNumberStr

