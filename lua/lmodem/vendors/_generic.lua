local types = require("lmodem.types")
local AT = require("lmodem.AT")

---@class GenericDevice:Object
---@field device       string # default: /dev/ttyUSB2
---@field manufacturer string
---@field model        string
---@field revision     string
---@field imei         string
---@field modes        string[]
---@field host_mode    boolean
---@field supported_interface ModemInterface[]
---@field supported_bands integer[]
---@field available_bands integer[]
---@operator call:GenericDevice
local _GenericDevice = require("lmodem.class"):extend()

function _GenericDevice:new(opts)
    local device = opts.at_dev or "/dev/ttyUSB2"
    local baudrate = opts.baudrate or 115200
    self.AT = AT:new(device, baudrate)
    self.logger = require("lmodem.log"):new()

    self.sim1 = {}
    self.sim2 = {}
    self.sim_slot = 0
end

function _GenericDevice:GetManufacturer()
    local ok, response = self.AT:Send("AT+CGMI")
    if ok then
        self.manufacturer = response
        return self.manufacturer
    end
end

function _GenericDevice:GetModel()
    local ok, response = self.AT:Send("AT+CGSN")
    if ok then
        self.model = response:match("%d+")
        return self.model
    end
end

function _GenericDevice:GetRevision()
    local ok, response = self.AT:Send("AT+CGMR")
    if ok then
        self.revision = response
        return self.revision
    end
end

function _GenericDevice:GetIemi()
    local ok, response = self.AT:Send("AT+CGMR")
    if ok then
        self.revision = response
        return self.revision
    end
end

function _GenericDevice:GetModelInfo()
    return {
        manufacturer = self:GetManufacturer(),
        model = self:GetModel(),
        revision = self:GetRevision(),
        imei = self:GetIemi(),
    }
end

---------------------------- SIM Card -----------------------------------------

function _GenericDevice:GetImsi()
    local ok, response = self.AT:Send("AT+CIMI")
    if ok then
        self.imsi = response:match("%d+")
        return self.imsi
    end
end

function _GenericDevice:GetIccid()
    local ok, response = self.AT:Send("AT+ICCID")
    if ok then
        self.iccid = response:match("%d+")
        return self.iccid
    end
end

function _GenericDevice:GetSimInfo()
    return {
        imsi = self:GetImsi(),
        iccid = self:GetIccid(),
    }
end

function _GenericDevice:SwitchSimSlot()
    error("not implemented!")
end

function _GenericDevice:SimStatus()
    error("not implemented!")
end

---------------------------- Network -----------------------------------------

---example +CSQ: 5,99
---<0-31>,99
---@return integer signal_dbm >= -113
---@return integer err_rate
function _GenericDevice:GetSignalQuality()
    local ok, response = self.AT:Send("AT+CSQ")
    local ret = {}
    for num in response:gmatch("%d+") do
        table.insert(ret, tonumber(num, 10))
    end
    assert(#ret == 2)
    local quality, err_rate = ret[1], ret[2]
    if quality == 99 then
        -- TODO signal unknown or unavailable
    end
    local dbm = -113 + quality * 2
    return dbm, err_rate
end

function _GenericDevice:Connect()
    error("not implemented!")
end

function _GenericDevice:Disconnect()
    error("not implemented!")
end

function _GenericDevice:NetworkStatus()
    error("not implemented!")
end

function _GenericDevice:NetworkScan()
    error("not implemented!")
end

function _GenericDevice:LockBand(bands)
    error("not implemented!")
end

function _GenericDevice:ScanCell()
    error("not implemented!")
end

function _GenericDevice:LockCell()
    error("not implemented!")
end

---------------------------- Private -----------------------------------------
-- vendors private apis

---------------------------- Product -----------------------------------------

return _GenericDevice
