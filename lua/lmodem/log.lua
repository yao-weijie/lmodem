---@class Logger:Object
local _Logger = require("lmodem.class"):extend()

---@enum LogLevel
local LOG_LEVEL = {
    INFO = "INFO",
    WARN = "WARN",
    ERROR = "ERROR",
}

---@private
function _Logger:_write_file(msg)
    local f = io.open(self.path, "a+")
    if f then
        f:write(msg .. "\n")
        f:close()
    end
end

function _Logger:info(msg)
    self:log(msg, LOG_LEVEL.INFO)
end

function _Logger:warn(msg)
    self:log(msg, LOG_LEVEL.WARN)
end

function _Logger:error(msg)
    self:log(msg, LOG_LEVEL.ERROR)
end

function _Logger:log(msg, level)
    msg = msg or ""
    level = level or LOG_LEVEL.INFO

    msg = ("[%s] %s: %s"):format(os.date("%Y-%m-%d_%X"), level, msg)

    self:_write_file(msg)
end

---@param path string?
function _Logger:new(path)
    self.path = path or "/tmp/lmodem/lmodem.log"
    local dir = self.path:gsub("%/([%.%-_%w]*)$", "")
    os.execute("mkdir -p " .. dir)
    return self
end

return _Logger
