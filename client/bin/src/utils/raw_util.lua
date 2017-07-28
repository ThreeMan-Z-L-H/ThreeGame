--[[
	此文件放置加载main.lua前就开始使用的函数
	用于控件中使用 [Number] 形式来表示文字或颜色
--]]

function GetRandomTips()
	math.randomseed(math.floor(os.clock() * 1000))
	local index = math.random(1, #Config.Tips)
	Config.RandomTips = Config.Tips[index]
end

-- 从配置表中获取字符
function GetKeyWordsByIndex(index)
    if KeyWords[index] then
        Config.TTFWord = KeyWords[index]
    else
        Config.TTFWord = ""
    end
end

-- 从配置表中获取颜色
function GetColorByName(name)
	name = string.upper(name)
    if Config.Color[name] then
        Config.TTFColor = Config.Color16[name]
    else
        Config.TTFColor = "" 
    end
end

-- 从配置表中获取字体
function GetFontPathByName(name)
    if Config.Fonts[name] then
        Config.TTFFontName = Config.Fonts[name]
    else
        Config.TTFFontName = "" 
    end
end
