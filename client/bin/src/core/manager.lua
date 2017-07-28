--[[
	管理类， 单例模式，生成后不会销毁
--]]

ViewManager = class("ViewManager")
function ViewManager:ctor()
    if ViewManager.Instance then 
        error("[ViewManager] Attempt to create singleton twice!")
    end
    ViewManager.Instance = self
	
	self.removeViews = {}
end

function ViewManager:registView(view)
    if view.cls=="View" then
        print("View.cls未重定义")
    end
    if view.showing then
        print(view.cls.."已经注册")
        return
    end

    view:addView()
    view.showing = true
end

function ViewManager:unregistView(view, now)
	now = not not now
	
    if now then
		print("unregistView->", view.__cname)
		GlobalEventManager.Instance:unBindEvent(view.__cname)
		
		view:removeView()
		view.showing = false
--		view = nil
		cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    else
        view.showing = false
        if self.removeKey == nil then
            self.removeKey = cc.Director:getInstance():getScheduler():scheduleScriptFunc(self.removeUnregistViews, 0.1, false)
            self.removeViews = {view}
        else
            self.removeViews[#self.removeViews + 1] = view
        end
    end
end

function ViewManager:removeUnregistViews()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ViewManager.removeKey)
    ViewManager.removeKey = nil
    for i,v in pairs(ViewManager.removeViews) do
        ViewManager:unregistView(v, true)
    end
    ViewManager.removeViews = {}
end

PortocalManager = class("PortocalManager")
function PortocalManager:ctor()
	if PortocalManager.Instance then 
        error("[PortocalManager] Attempt to create singleton twice!")
    end
    PortocalManager.Instance = self
	self._portocal_func = {}
end

function PortocalManager:registerPortocal(id, call_func)
	self._portocal_func[id] = call_func
end

function PortocalManager:recivePortocal(id, status, data_list)
	local call_func = self._portocal_func[id]
	if not call_func then
		print("Portocal have not register please check id="..id)
		return
	else
		call_func(id, status, data_list)
	end
end

function PortocalManager:SendPortocal(id, data)
    local data = data or ByteArray:new()
    postBytes(id, data)
end

GlobalEventManager = class("GlobalEventManager")
function GlobalEventManager:ctor()
    if GlobalEventManager.Instance then 
        error("[GlobalEventManager] Attempt to create singleton twice!")
    end
    GlobalEventManager.Instance = self
	
	self._global_event_func = {}
end

function GlobalEventManager:bindEvent(owner_name, event_id, call_func)
	if not self._global_event_func[owner_name] then
		self._global_event_func[owner_name] = {}
	end
	self._global_event_func[owner_name][event_id] = call_func
end

function GlobalEventManager:unBindEvent(owner_name, event_id)
	if not self._global_event_func[owner_name] then return end
	if not event_id then
		self._global_event_func[owner_name] = {}
		return
	end
	
	self._global_event_func[owner_name][event_id] = nil
end

function GlobalEventManager:triggerEvent(event_id, data)
	for owner_name, list in pairs(self._global_event_func) do
		for id, call_func in pairs(list) do
			call_func(data)
		end
	end
end

