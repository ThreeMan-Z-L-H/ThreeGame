local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"
local STATUS_ERROR_OPTION = "Operation not supported on socket"

local socket = require("socket.core")
local bytesRecieve = ""
local conected = false
local receiveLen = false
local currMsgLen = 0
local tcpClient = socket.tcp()
local lastRecieveTime = 0

function requestHTTP(url, callback)
   local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)
    print("GET",url)
	local function onReadyStateChange()
		local statusString = "Http Status Code:"..xhr.statusText
		print("status",statusString)
		print("response",xhr.response)
		callback(xhr.response)
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send() 
end

function extendRecieveTime()
    lastRecieveTime = lastRecieveTime + 120
end

ccount = 1
local byteReceived = 0
local byteSended = 0
local receiveTime
function checkReceive()
    local currTime = socket.gettime()
    local currReceivedByte,currSendedByte,currReceiveTime = tcpClient:getstats()

    if currReceivedByte - byteReceived > 1000000 and currReceiveTime - receiveTime > 10 then
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
            local className="org/cocos2dx/lua/AppActivity"
            local args = {}
            local sig = "()V"
            local luaj = require "luaj"
            local ok, result = luaj.callStaticMethod(className,"reset", args, sig)
        end
        return
    end
    byteReceived, byteSended, receiveTime = currReceivedByte, currSendedByte, currReceiveTime
    lastRecieveTime = currTime
    local body, status, partial = tcpClient:receive("*a")
    ccount = ccount + 1
    if body and partial then body = body .. partial end
    if status == STATUS_CLOSED or status == STATUS_NOT_CONNECTED then
        print("socket已关闭",status)
        resetTcp(false)
--        Fecade:sendMsg(IO_Type.SOCKET_CLOSED)
        return
    elseif partial ~= nil and #partial then
        bytesRecieve = bytesRecieve..partial
    elseif body ~= nil and #body > 0 then
        bytesRecieve = bytesRecieve..body
    end
    repeat
        local msg = nil
        local bytesAvailable = #bytesRecieve
        if receiveLen then
            if bytesAvailable>=currMsgLen then
                msg = string.sub(bytesRecieve, 1, currMsgLen)
                bytesRecieve = string.sub(bytesRecieve, currMsgLen + 1, bytesAvailable)
            end
            if msg~=nill then
                receiveLen = false
                local ba = ByteArray:new()
                ba:setStr(msg)
                local status = {}
                status.flag = ba:readByte()
				status.serverTime = ba:readLong()
                id = ba:readInt()
                status.state = ba:readByte()
                
                if status.state == 0 then
                    body = ByteArray:new()
                    body:setStr(ba:getLeft())
                    mo = {id = id, body = body}
--                    ModelManager:decode(id,status,ba)
					PortocalManager:recivePortocal(id, status, ba)
                else
				-- error
                    local errorTip = ba:readUTF()
                    local errorCode = ba:readShort()
                    print("数据异常id=", id, errorTip, errorCode)
					
--                    ModelManager:hook(id, errorCode)
--                    TipController:addTip(errorTip)
                end

            end
        else
            if bytesAvailable>=4 then
                msg = string.sub(bytesRecieve,1,4)
                bytesRecieve = string.sub(bytesRecieve,5,bytesAvailable)
            end
            if msg ~=nil then
                receiveLen = true
                local ba = ByteArray:new()
                ba:setStr(msg)
                currMsgLen = ba:readInt()
            end
        end
    until msg == nil
    sendToServer()
end
function resetTcp(withClose)
    if tcpConnectReceiveKey~=nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(tcpConnectReceiveKey)
        tcpConnectReceiveKey = nil
    end
    if withClose then
        tcpClient:close()
    end
    tcpClient = socket.tcp()
end
function onSocketConnect()
    print("网络已连接")
--    Fecade:sendMsg(IO_Type.SOCKET_CONNECT)
    conect = true
    receiveLen = false
    bytesRecieve = ""
    if tcpConnectReceiveKey==nil then
        lastRecieveTime = socket.gettime()
        tcpConnectReceiveKey=cc.Director:getInstance():getScheduler():scheduleScriptFunc(checkReceive, 0, false)
    end
end

local _host
local _port
function connect(host, port)
    _host = host or _host
    _port = port or _port
    tcpClient:settimeout(0)
    print("正在连接网络", _host, _port)
    if tcpConnectTestKey~=nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(tcpConnectTestKey)
        tcpConnectTestKey = nil
    end
    local result,msg = tcpClient:connect(_host,_port)
    if result==1 then
        onSocketConnect()
    else
        if msg==STATUS_TIMEOUT then
            tcpConnectTestKey=cc.Director:getInstance():getScheduler():scheduleScriptFunc(checkSocketConnect, 0, false)
            tcpConnectTime = socket.gettime()
        elseif msg==STATUS_ALREADY_CONNECTED then
            resetTcp(true)
            connect()
        elseif msg==STATUS_ERROR_OPTION then
            print(msg)
        else
            print("socket连接失败type="..msg)
--            Fecade:sendMsg(IO_Type.SOCKET_CONNECT_TIMEOUT,msg)
        end
    end
end

function checkSocketConnect()
    local result,status = tcpClient:connect(_host,_port)
    print("连接检测",result,status)
    if result == 1 or status == STATUS_ALREADY_CONNECTED then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(tcpConnectTestKey)
        tcpConnectTestKey = nil
        
        onSocketConnect()
    else
        print("checkConnect",socket.gettime()-tcpConnectTime)
        if socket.gettime() - tcpConnectTime > 5 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(tcpConnectTestKey)
            tcpConnectTestKey = nil
            resetTcp(true)
--            Fecade:sendMsg(IO_Type.SOCKET_CONNECT_TIMEOUT,"timeout")
        end
    end
end
function getTime()
    return socket.gettime()
end
local sendBuffer = ""
function postBytes(id, body)
    body = body or ByteArray:new()
    head = ByteArray:new()
    head:writeInt(body:getLen() + 13)
    head:writeByte(110)
    head:writeInt(id)
    head:writeLong(socket.gettime() * 1000)
    buffer = head:getStr()..body:getStr()
    sendBuffer = sendBuffer..buffer
end

function sendToServer()
    local bufferLen = #sendBuffer
    if bufferLen > 0 then
        if bufferLen > 1024 then
            local result,msg,sta = tcpClient:send(string.sub(sendBuffer, 1, 1024))
            sendBuffer=string.sub(sendBuffer, 1025, bufferLen)
        else
            local result,msg,sta = tcpClient:send(sendBuffer)
            sendBuffer = ""
        end
    end
end

