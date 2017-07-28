BaseView = class("BaseView")

function BaseView:ctor()
	self.node = nil
	self.cls = self.__cname
	self.showing = false
	self.widgetMap = {}
end

function BaseView:addView()
	print("抽象发法View:addView需重写:"..self.cls)
end


function BaseView:removeView()
    print("抽象发法View:removeView需重写:"..self.cls)
end

function BaseView:regist()
    ViewManager:registView(self)
end

function BaseView:removeTexture(path)
    local fullPath = cc.FileUtils:sharedFileUtils():fullPathForFilename("path")
    cc.Director:getInstance():getTextureCache():removeTextureForKey(fullPath)
end

function BaseView:removeSpriteFrame(path)
    cc.SpriteFrameCache:getInstance():removeSpriteFramesWithFile(path)
end

function BaseView:loadWidget(path)
	print(self.cls, "loadWidget", path)
    local plist = BaseView.jsonPlistMap[path]
    if plist==nil then
        local jstr = cc.FileUtils:getInstance():getStringFromFile(path)
        local p1,p2 = string.find(jstr, '"textures"')
        local p3 = string.find(jstr, "%[", p2)
        local p4 = string.find(jstr, "%]", p3)
        local dir =nil
        local index = 1
        local lastIndex = 1
        repeat
            index = string.find(path, "/", index + 1)
            if index==nil then
                dir=string.sub(path, 1, lastIndex)
            end
            lastIndex = index
        until dir~=nil
        plist = json.decode(string.sub(jstr, p3, p4))
        for i,v in pairs(plist) do
            plist[i]=dir .. v
        end
        BaseView.jsonPlistMap[path] = plist
    end
    for i,v in pairs(plist) do
        if BaseView.plistCountMap[v]~=nil then
            BaseView.plistCountMap[v].count = BaseView.plistCountMap[v].count+1
            BaseView.plistCountMap[v].timeout = 0
        else
            BaseView.plistCountMap[v]={count=1,timeout=0}
        end
    end
    if self~=BaseView then
        if self.widgetMap[path] then
            self.widgetMap[path]=self.widgetMap[path]+1
        else
            self.widgetMap[path] = 1
        end
    end
    return ccs.GUIReader:getInstance():widgetFromJsonFile(path)
end

function BaseView:clearWidget(path,decount)
    decount = decount or 1
    local plist = BaseView.jsonPlistMap[path]
	if plist then
		for i,v in pairs(plist) do
			if BaseView.plistCountMap[v] then
				BaseView.plistCountMap[v].count = BaseView.plistCountMap[v].count-decount
			end
		end
	else
		print("未调用View:loadWidget，path="..path)
	end
end

function BaseView:unregist(removeNow)
    ViewManager:unregistView(self,removeNow)
    for i, v in pairs(self.widgetMap) do
        BaseView:clearWidget(i,v)
    end
end

function BaseView:callLater(fun,delay,params)
    if self.schedulerId~=nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
    end
	self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
	function()
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId=nil 
		fun(params) 
	end, delay, false)
end

function BaseView:autoClear()
    for i,v in pairs(BaseView.plistCountMap) do
        if v.count <= 0 then
            if v.timeout > 30 then
                local withTexture = string.sub(i, 1, -6).."png"
                print("移除纹理集", i, withTexture)
                cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(i)
                cc.Director:getInstance():getTextureCache():removeTextureForKey(withTexture)
                BaseView.plistCountMap[i]=nil
            else
                v.timeout = v.timeout + 5
            end
        end
    end
end

