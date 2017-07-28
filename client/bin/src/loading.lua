Loading = {}


URL = "ws://47.88.84.202:9001/echo"

webSocket = nil

cnt = 0


function Loading.run()
	local scene = cc.Scene:create()

	local visibleSize = cc.Director:getInstance():getVisibleSize()
	
	
	local labelShow = ccui.Text:create()
    labelShow:setString("")
	labelShow:setAnchorPoint(cc.p(0, 0.5))
    labelShow:setFontSize(20)
    labelShow:setTouchScaleChangeEnabled(true)
    labelShow:setPosition(cc.p(200,100))
    labelShow:setTouchEnabled(true)
	scene:addChild(labelShow)
	
   local editUrl = cc.EditBox:create({width = 200, height = 30}, "res/slider_bg4.png")
    editUrl:setPosition(cc.p(visibleSize.width/2, visibleSize.height - 200))
    editUrl:setFontSize(20)
    editUrl:setFontColor(cc.c3b(255,0,0))
    editUrl:setPlaceHolder("url")
    editUrl:setPlaceholderFontColor(cc.c3b(255,0,0))
    editUrl:setMaxLength(80)
    editUrl:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
	--Handler
--	editUrl:registerScriptEditBoxHandler(editBoxTextEventHandle)

	scene:addChild(editUrl)
	
	
	
	local function onOpen(strData)
        labelShow:setString("OPEN：" .. URL)
    end

    local function onMessage(strData)
		cnt = cnt + 1
		labelShow:setString("REVIVE(".. cnt ..")：" .. strData)
    end

    local function onClose(strData)
        labelShow:setString("CLOSE")
        webSocket = nil
		cnt = 0
    end

    local function onError(strData)
        labelShow:setString("ERROR：" .. strData)
    end
	
	
	local function onConnect(sender,eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			labelShow:setString("URL:"..editUrl:getText())
			if not webSocket then
				webSocket = cc.WebSocket:create(URL)
				cnt = 0
				
				webSocket:registerScriptHandler(onOpen,cc.WEBSOCKET_OPEN)
				webSocket:registerScriptHandler(onMessage,cc.WEBSOCKET_MESSAGE)
				webSocket:registerScriptHandler(onClose,cc.WEBSOCKET_CLOSE)
				webSocket:registerScriptHandler(onError,cc.WEBSOCKET_ERROR)	
			end
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	local buttonConnect = ccui.Button:create()
	buttonConnect:setTouchEnabled(true)
	buttonConnect:loadTextures("res/Button_Normal.png", "res/Button_Press.png", "res/Button_Disable.png")
	buttonConnect:setPosition(cc.p(visibleSize.width/2 + 200, visibleSize.height - 200))
	buttonConnect:addTouchEventListener(onConnect)
	buttonConnect:setTitleText("连接")
	buttonConnect:setTitleColor(cc.c3b(0,0,0))
	scene:addChild(buttonConnect)
	
	
	local editSend = cc.EditBox:create({width = 200, height = 30}, "res/slider_bg4.png")
    editSend:setPosition(cc.p(visibleSize.width/2, visibleSize.height - 300))
    editSend:setFontSize(20)
    editSend:setFontColor(cc.c3b(0, 255,0))
    editSend:setPlaceHolder("send_str")
    editSend:setPlaceholderFontColor(cc.c3b(0,0,255))
    editSend:setMaxLength(80)
    editSend:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
	--Handler
--	editUrl:registerScriptEditBoxHandler(editBoxTextEventHandle)

	scene:addChild(editSend)
	
	
	local function onSend(sender,eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			if webSocket then
				if cc.WEBSOCKET_STATE_OPEN == webSocket:getReadyState() then
				   labelShow:setString("SEND_STR:"..editSend:getText())
				   webSocket:sendString(editSend:getText())
				else
					local warningStr = "webSocket instance wasn't ready..."
					sendTextStatus:setString(warningStr)
					labelShow:setString("WARRNING：" .. warningStr)
				end
			end
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	local buttonSend = ccui.Button:create()
	buttonSend:setTouchEnabled(true)
	buttonSend:loadTextures("res/Button_Normal.png", "res/Button_Press.png", "res/Button_Disable.png")
	buttonSend:setPosition(cc.p(visibleSize.width/2 + 200, visibleSize.height - 300))
	buttonSend:addTouchEventListener(onSend)
	buttonSend:setTitleText("发送")
	buttonSend:setTitleColor(cc.c3b(0,0,0))
	scene:addChild(buttonSend)
	
	
	local function onClose(sender,eventType)
		if eventType == ccui.TouchEventType.began then
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			if webSocket then
                webSocket:close()
			end
		elseif eventType == ccui.TouchEventType.canceled then
		end
	end
	local buttonClose = ccui.Button:create()
	buttonClose:setTouchEnabled(true)
	buttonClose:loadTextures("res/Button_Normal.png", "res/Button_Press.png", "res/Button_Disable.png")
	buttonClose:setPosition(cc.p(visibleSize.width/2 + 250, visibleSize.height - 200))
	buttonClose:addTouchEventListener(onClose)
	buttonClose:setTitleText("断开")
	buttonClose:setTitleColor(cc.c3b(0,0,0))
	scene:addChild(buttonClose)

    cc.Director:getInstance():runWithScene(scene)
end

