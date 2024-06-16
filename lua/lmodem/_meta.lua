---@meta

error("This is a meta file, DO NOT require!")

---@class Serial
---@field baudrate integer
---@field databits integer
---@field parity   string
---@field stopbits integer
---@field xonxoff  boolean
---@field rtscts   boolean
---@field vmin     integer
---@field vtime    integer
---@field fd       integer
---@operator call():Serial
local serial = {}

---@param length integer
---@param timeout_ms integer|nil
---@return string
function serial:read(length, timeout_ms) end

---@param data string
function serial:write(data) end

---0 for non-blocking, else blocking
---@param timeout_ms integer?
function serial:poll(timeout_ms) end

---@return integer
function serial:input_waiting() end

---@return integer
function serial:output_waiting() end

function serial:close() end
