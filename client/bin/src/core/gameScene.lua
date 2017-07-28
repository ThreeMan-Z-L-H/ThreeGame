GameScene = class("GameScene", function()
	return cc.Scene:create()
end)

function GameScene:ctor()
	self.sceneLayer = cc.Layer:create()
	self.uiLayer = cc.Layer:create()
	self.windowLayer = cc.Layer:create()
	self.popLayer = cc.Layer:create()
	self.visibleSize = cc.Director:getInstance():getVisibleSize()
	self.windowScaleFactor = math.min(self.visibleSize.width / 800, self.visibleSize.height / 480)
	
	self:addChild(self.sceneLayer, 0)
    self:addChild(self.uiLayer, 1)
    self:addChild(self.windowLayer, 2)
    self:addChild(self.popLayer, 3)
    
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self)
    else
        cc.Director:getInstance():runWithScene(self)
    end
	
	self.windowNum = 0
end

function GameScene:addScene(node)
    self.sceneLayer:addChild(node)
end

function GameScene:removeScene(node)
    self.sceneLayer:removeChild(node)
end

function GameScene:addWindow(node, autoLayout)
    autoLayout = autoLayout==nil or autoLayout
    if autoLayout then
        self:centerLayout(node)
    end
	self.windowNum = self.windowNum + 1
    self.windowLayer:addChild(node, self.windowNum)
end

function GameScene:removeWindow(node)
    self.windowLayer:removeChild(node)
end

function GameScene:addUI(node)
    self.uiLayer:addChild(node)
end

function GameScene:removeUI(node)
    self.uiLayer:removeChild(node)
end

function GameScene:addPop(node, autoLayout)
    autoLayout = autoLayout==nil or autoLayout
    if autoLayout then
        self:centerLayout(node)
    end
    self.popLayer:addChild(node)
end

function GameScene:removePop(node)
    self.popLayer:removeChild(node)
end

function GameScene:centerLayout(node)
    local size
    local anchor = node:getAnchorPoint()
    node:setScale(self.windowScaleFactor)
    local cx, cy = self.visibleSize.width /2 , self.visibleSize.height / 2

    if node.getSize ~= nil then
        size = node:getSize()
    else
        size = node:getContentSize()
    end
    cx = cx + (anchor.x - 0.5) * size.width * self.windowScaleFactor
    cy = cy + (anchor.y - 0.5) * size.height * self.windowScaleFactor
    node:setPosition(cx,cy)
end

