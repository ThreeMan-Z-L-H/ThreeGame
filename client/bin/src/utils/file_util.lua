--[[ 文件相关工具函数 ]]

FileUtil = FileUtil or {}

function FileUtil.IsAbsolutePath(path)
	return string.sub(path, 1, 1) == "/" or string.sub(path, 2, 2) == ":"
end

function FileUtil.CombinePath(path1, path2)
	local c = string.sub(path1, -1)
	if c ~= "/" and c ~= "\\" then
		path1 = path1 .. "/"
	end

	c = string.sub(path2, 1, 1)
	if c == "/" or c == "\\" then
		path2 = string.sub(path2, 2)
	end

	return path1 .. path2
end

function FileUtil.BaseFileName(fullname, exclude_ext)
	local basename = fullname
	local n = string.len(fullname)
	for i = n, 1, -1 do
		local ch = string.sub(fullname, i, i)
		if ch == "\\" or ch == "/" then
			basename = string.sub(fullname, i + 1)
			break
		end
	end

	if exclude_ext then
		local start, _ = string.find(basename, ".", 1, true)
		if start then
			basename = string.sub(basename, 1, start - 1)
		end
	end

	return basename
end

function FileUtil.GetFileNameList(path, pattern, lua_pattern, exclude_ext)
	-- only for WINDOWS
	if string.find(path, ":") == nil then
		path = "..\\Resources\\" .. string.gsub(path, "/", "\\")
	end
	pattern = pattern or "*.*"

	local name_list = {}
	for file in io.popen("dir /a:-d /b /w " .. path .. "\\" .. pattern):lines() do
		local name = exclude_ext and FileUtil.BaseFileName(file, true) or file
		if not lua_pattern or string.find(name, lua_pattern) ~= nil then
			name_list[#name_list + 1] = name
		end
	end

	return name_list
end

function FileUtil.GetChildDirList(path, pattern, lua_pattern)
	-- only for WINDOWS
	if string.find(path, ":") == nil then
		path = "..\\Resources\\" .. string.gsub(path, "/", "\\")
	end
	pattern = pattern or "*.*"

	local name_list = {}
	for file in io.popen("dir /a:d /b /w " .. path .. "\\" .. pattern):lines() do
		local name = file
		if name ~= "." and name ~= ".." then
			if not lua_pattern or string.find(name, lua_pattern) ~= nil then
				name_list[#name_list + 1] = name
			end
		end
	end

	return name_list
end

function FileUtil.GetRecursiveFileNameList(path, pattern, lua_pattern)
	-- only for WINDOWS
	if string.find(path, ":") == nil then
		path = "..\\Resources\\" .. string.gsub(path, "/", "\\")
	end
	pattern = pattern or "*.*"

	local name_list = {}
	for file in io.popen("dir /a:-d /b /w /s " .. path .. "\\" .. pattern):lines() do
		local name = FileUtil.BaseFileName(file, exclude_ext)
		if not lua_pattern or string.find(name, lua_pattern) ~= nil then
			name_list[#name_list + 1] = file
		end
	end

	return name_list
end

function FileUtil.IsFileExists(path)
	-- only for WINDOWSS
	if string.find(path, ":") == nil then
		path = "..\\Resources\\" .. string.gsub(path, "/", "\\")
	end

	local rfile = io.open(path, "rb")
	if rfile then
		rfile:close()
		return true
	end

	return false
end

function FileUtil.GetFileContent(path)
	-- only for WINDOWSS
	if string.find(path, ":") == nil then
		path = "..\\Resources\\" .. string.gsub(path, "/", "\\")
	end

	local rfile = io.open(path, "rb")
	if rfile then
		local text = rfile:read("*all")
		rfile:close()
		return true, text
	end

	return false, ""
end

