
local Class = require("CoreLib.SimpleLuaClasses.Class")
--local Numeric = require("Utils.Numeric")

local Edge = Class()

function Edge:init(v1, i1, v2, i2)
    self.v = Vector3(v1.x, v1.y, v1.z)
    self.vi = i1
    self.w = Vector3(v2.x, v2.y, v2.z)
    self.wi = i2
    self.isBad = false
end

-- function Edge:__eq(rhs)
--     return (self.v:Equals(rhs.v) and self.w:Equals(rhs.w)) or
--         (self.v:Equals(rhs.w) and self.w:Equals(rhs.v))
-- end

function Edge:Equals(rhs)
    return (self.v:Equals(rhs.v) and self.w:Equals(rhs.w)) or
        (self.v:Equals(rhs.w) and self.w:Equals(rhs.v))
end

return Edge
