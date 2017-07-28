
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")


require "config"
require "cocos.init"
require "utils.init"

cclog = function(...)
    print(string.format(...))
end

local function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
	
	math.randomseed(os.time() + os.clock() * 10000)
	
	cclog("mmmmmmmmmmmmmmmmmmmm")
	
	require "loading"
	Loading.run()
end

function setupMain()
--[[
    require "src/config"
    Config:init()
    require "src/platform"
    setupMVC()
    require "src/audio"
    AE.setMusicEnable(not Config:getValue(Config.MUSIC_OFF))
    AE.setEffectsEnable(not Config:getValue(Config.EFFECT_OFF))
    AE.setMusicVolume(Config:getValue(Config.MUSIC_VOLUME))
    AE.setEffectsVolume(Config:getValue(Config.EFFECT_VALUME))
    require "src/pay"
--]]
	
	require "core.init"
	require "mvcInit"
	
	ViewManager.new()
	PortocalManager.new()
	GlobalEventManager.new()

	registerControls()
	
	runMain()
end

function runMain()
--[[
    Container:init()
    ServerController:selectServer()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_ANDROID == targetPlatform then
        local _className="org/cocos2dx/lua/AppActivity"
        local _args = {}
        local _sig = "()Ljava/lang/String;"
        local luaj = require "luaj"
        local _ok,_result =luaj.callStaticMethod(_className,"getImei",_args,_sig)
        if _ok then
            g_imeiNumber = _result
        end
    else
        g_imeiNumber = "this is not android plat"
    end
    --ServerProxy:setHost("182.254.228.69",9503)
--]]
	
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
--    cclog(msg)
end

