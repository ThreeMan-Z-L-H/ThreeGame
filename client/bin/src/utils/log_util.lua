--[[  log相关工具函数 ]]

Log = Log or {}

Log.Level = {
	ALL    = 0,	 -- 所有
	TEMP   = 1,  -- 临时测试 (用完就扔)
	DEBUG  = 2,	 -- 调试信息
	INFO   = 3,	 -- 一般信息
	NOTICE = 4,  -- 重要信息 （关键模块/关键流程点）
	WARN   = 5,	 -- 警告信息
	ERR    = 6,	 -- 错误信息
}

Log._cur_level = Log._cur_level or (_DEBUG and Log.Level.DEBUG or Log.Level.INFO)

function Log.SetLogLevel(level)
	Log._cur_level = level
end

function Log.print(...)
	print(...)
end

function Log.temp(...)
	if Log._cur_level <= Log.Level.TEMP then
		print("~/", ...)
	end
end

function Log.debug(...)
	if Log._cur_level <= Log.Level.DEBUG then
		print("D/", ...)
	end
end

function Log.info(...)
	if Log._cur_level <= Log.Level.INFO then
		print("I/", ...)
	end
end

function Log.notice(...)
	if Log._cur_level <= Log.Level.NOTICE then
		print("*/", ...)
	end
end

function Log.warn(...)
	if Log._cur_level <= Log.Level.WARN then
		print("?/", ...)
	end
end

function Log.err(...)
	if Log._cur_level <= Log.Level.ERR then
		print("!/", ...)
	end
end

