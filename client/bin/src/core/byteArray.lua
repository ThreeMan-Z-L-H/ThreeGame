ByteArray = {chars="",position=0,cls="ByteArray"}
ByteArray.__index = ByteArray
ByteArray = class("ByteArray")

function ByteArray:ctor()
	self.position = 0
	self.chars = ""
	self.cls = self.__cname
end

function ByteArray:getLen()
    return #self.chars
end

function ByteArray:writeInt(i)
    local temp = string.format("%08x",i)
    self.chars=self.chars..string.char(tonumber(string.sub(temp,1,2),16),tonumber(string.sub(temp,3,4),16),tonumber(string.sub(temp,5,6),16),tonumber(string.sub(temp,7,8),16))
end

function ByteArray:writeByte(i)
    self.chars = self.chars..string.char(i)
end

function ByteArray:writeUTF(i)
    local len = #i
    self:writeShort(len)
    self.chars = self.chars..i
end

function ByteArray:writeShort(i)
    temp = string.format("%04x",i)
    self.chars=self.chars..string.char(tonumber(string.sub(temp,1,2),16),tonumber(string.sub(temp,3,4),16))
end

function ByteArray:writeLong(i)
    local upper = math.floor(i/math.pow(2,32))
    local lower = math.floor(i%math.pow(2,32))

    self:writeInt(upper)
    self:writeInt(lower)
end

function ByteArray:writeBoolean(i)
    if i then
        self:writeByte(1)
    else
        self:writeByte(0)
    end
end

function ByteArray:readByte()
    local p = self.position;
    local v = string.byte(string.sub(self.chars,p,p))
    self.position=p+1
    return v
end

function ByteArray:readInt()
    local p = self.position
    local s = string.sub(self.chars,p,p+3)
    self.position = p+4
    local t1 = string.sub(s,1,1)
    local t2 = string.sub(s,2,2)
    local t3 = string.sub(s,3,3)
    local t4 = string.sub(s,4,4)
    local v = tonumber(string.format("%02x",string.byte(t1))..string.format("%02x",string.byte(t2))..string.format("%02x",string.byte(t3))..string.format("%02x",string.byte(t4)),16)
    return v
end

function ByteArray:readLong()
    local upper = self:readInt(upper)
    local lower = self:readInt(lower)
    return upper*math.pow(2,32)+lower
end

function ByteArray:readUTF()
    local len = self:readShort()
	if len==0 then
		return ""
	end
    local p = self.position
    local s = string.sub(self.chars,p,p+len-1)
    self.position = p+len
    return s
end

function ByteArray:readBoolean()
    local i = self:readByte()
    return i~=0
end

function ByteArray:readShort()
    p = self.position
    s = string.sub(self.chars,p,p+1)
    self.position = p+2
    t1 = string.sub(s,1,1)
    t2 = string.sub(s,2,2)
    
    v = tonumber(string.format("%02x",string.byte(t1))..string.format("%02x",string.byte(t2)),16)
    return v
end

function ByteArray:setStr(i)
    self.chars = i
    self.position = 1
end
function ByteArray:getLeft()
    return string.sub(self.chars,self.position,#self.chars)
end
function ByteArray:getStr()
    return self.chars;
end