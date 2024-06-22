---@class HuaweiDevice:GenericDevice
local _HuaweiDevice = require("lmodem.vendors._generic"):extend()

-- override
function _HuaweiDevice:GetIccid()
    local ok, response = self:SendAT("AT^ICCID")
    if ok then
        self.iccid = response:match("%d+")
        return self.iccid
    end
end
