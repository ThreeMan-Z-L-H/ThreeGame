BaseProxy = class("baseProxy")

function BaseProxy:ctor()
	self.cls = self.__cname
end

function BaseProxy:readJson(path)
    local str = cc.FileUtils:getInstance():getStringFromFile(path)
    local json = require "json"
    return json.decode(str)
end

function BaseProxy:getTable(table)
    local result = {}
    local index=1
    for c in db:nrows('SELECT * FROM '..table) do
        result[index]=c
        index = index+1
    end
    return result
end

function BaseProxy:getRow(table, id)
    for c in db:nrows('SELECT * FROM '..table..' WHERE id='..id) do
        return c
    end
    return nil
end

function BaseProxy:getValue(table,id,key)
    local sql="SELECT "..key.." FROM "..table.." WHERE id="..id
    local result
    function showrow(udata,cols,values,names)
        result = values[1]
        return 1
    end
    db:exec(sql,showrow,'admin')
    return result
end

