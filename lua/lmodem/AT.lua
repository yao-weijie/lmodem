---@type Serial
local Serial = require("periphery").Serial

---@class AT:Object
local AT = require("lmodem.class"):extend()

---@param sec number|string
local function sleep(sec)
    os.execute("sleep " .. sec)
end

---@param dev string?       default: /dev/ttyUSB2
---@param baudrate integer? default: 115200
function AT:new(dev, baudrate)
    self.dev = dev or "/dev/ttyUSB2"
    self.baudrate = baudrate or 115200
    self.serial = Serial(self.dev, self.baudrate)
    return self
end

---get trimed response
---@param cmd string AT cmd
---@param timeout_ms integer? default 500ms
---@return boolean
---@return string
function AT:Send(cmd, timeout_ms)
    self.serial:write(cmd)
    local ret = ""
    local response

    self.serial:poll(timeout_ms or 500) -- wait for data available

    repeat
        response = self.serial:read(128, timeout_ms or 500)
        ret = ret .. response
    until ret:match("OK") or ret:match("ERROR")

    local ok = response:match("OK") and true or false

    response = response:gsub("%s*OK%s*$", ""):gsub("%s*ERROR%s*$", ""):gsub("^%s*", "")

    self.serial:close()

    return ok, response
end

---debug mode, return raw response
---@param cmd string AT cmd
---@param timeout_ms integer? default 500ms
---@return string
function AT:DebugSend(cmd, timeout_ms)
    self.serial:write(cmd)
    local ret = ""
    local response

    self.serial:poll(timeout_ms or 500) -- wait for data available

    repeat
        response = self.serial:read(128, timeout_ms or 500)
        ret = ret .. response
    until ret:match("OK") or ret:match("ERROR")

    self.serial:close()

    sleep("0.05")

    return response
end

return AT
