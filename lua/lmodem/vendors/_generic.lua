local types = require("lmodem.types")
local Serial = require("periphery").Serial

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
    opts = opts or {}
    self.logger = require("lmodem.log"):new("/tmp/lmodem/lmodem.log")

    self.device = opts.device or "/dev/ttyUSB2"
    self.baudrate = opts.baudrate or 115200
    self.at_echo_enabled = opts.at_echo_enabled or false -- default disabled

    -- test AT
    local ok, _ = self:SendAT("AT")
    if ok then
        self.logger:info("Module setup sucessfully!")
    else
        self.logger:error("Module setup failed!")
    end

    if self.at_echo_enabled then
        self:SendAT("ATE1") -- enable AT cmd echo
    else
        self:SendAT("ATE0") -- enable AT cmd echo
    end
    return self
end
--------------------- Setup AT ------------------------------------------------
---@param cmd string AT cmd
---@param timeout_ms integer? default 500ms
---@return boolean
---@return string
function _GenericDevice:SendAT(cmd, timeout_ms)
    local serial = Serial(self.device, self.baudrate)

    -- clear serial buffer
    repeat
        serial:read(128, 50)
    until serial:input_waiting() == 0

    self.logger:info("Send AT: " .. cmd)
    serial:write(cmd .. "\r\n") -- real cmd ends with "\r\n"
    serial:flush()

    serial:poll(timeout_ms or 500) -- wait for data available

    local response = ""
    repeat
        response = response .. serial:read(128, 50)
    until serial:input_waiting() == 0
    serial:close()

    local ok = response:match("OK") and true or false

    if self.at_echo_enabled then
        response = response:gsub(#cmd + 1)
    end

    if ok then
        response = response:gsub("%s*OK%s*$", ""):gsub("^%s*", "")
        response = response == "" and "OK" or response
        self.logger:info(response)
        return ok, response
    else
        --- return raw response
        response = response:gsub("^%s*", "")
        self.logger:error(response)
        return ok, response
    end
end

---------------------------- Module Info---------------------------------------

function _GenericDevice:GetManufacturer()
    local ok, response = self:SendAT("AT+CGMI")
    if ok then
        self.manufacturer = response
        return self.manufacturer
    end
end

function _GenericDevice:GetModel()
    local ok, response = self:SendAT("AT+CGMM")
    if ok then
        self.model = response
        return self.model
    end
end

function _GenericDevice:GetRevision()
    local ok, response = self:SendAT("AT+CGMR")
    if ok then
        self.revision = response
        return self.revision
    end
end

function _GenericDevice:GetIemi()
    local ok, response = self:SendAT("AT+CGSN")
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
    local ok, response = self:SendAT("AT+CIMI")
    if ok then
        self.imsi = response:match("%d+")
        return self.imsi
    end
end

function _GenericDevice:GetIccid()
    local ok, response = self:SendAT("AT+ICCID")
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
    local ok, response = self:SendAT("AT+CSQ")
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
