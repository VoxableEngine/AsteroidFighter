
local Class = require("CoreLib.SimpleLuaClasses.Class")

local Triangle = Class()

function Triangle:init(v1, i1, v2, i2, v3, i3)
    self.a = Vector3(v1.x, v1.y, v1.z)
    self.ai = i1
    self.b = Vector3(v2.x, v2.y, v2.z)
    self.bi = i2
    self.c = Vector3(v3.x, v3.y, v3.z)
    self.ci = i3
    self.isBad = false
end

function Triangle:__eq(rhs)
    return	(self.a:Equals(rhs.a) or self.a:Equals(rhs.b) or self.a:Equals(rhs.c)) or
			(self.b:Equals(rhs.a) or self.b:Equals(rhs.b) or self.b:Equals(rhs.c)) or
			(self.c:Equals(rhs.a) or self.c:Equals(rhs.b) or self.c:Equals(rhs.c))
end

function Triangle:ContainsVertex(v)
    return self.a:Equals(v) or self.b:Equals(v) or self.c:Equals(v)
end

function Triangle:CircumCircleContains(v)
    local ab = self.a:LengthSquared()
    local cd = self.b:LengthSquared()
    local ef = self.c:LengthSquared()

    local ax = self.a.x
    local ay = self.a.y
    local bx = self.b.x
    local by = self.b.y
    local cx = self.c.x
    local cy = self.c.y

    local circumX = (ab * (cy - by) + cd * (ay - cy) + ef * (by - ay)) / (ax * (cy - by) + bx * (ay - cy) + cx * (by - ay))
    local circumY = (ab * (cx - bx) + cd * (ax - cx) + ef * (bx - ax)) / (ay * (cx - bx) + by * (ax - cx) + cy * (bx - ax))

    local circum = Vector3(circumX*0.5, circumY*0.5, 0)
    local circumRadius = Vector3(self.a - circum):LengthSquared()
    local dist = Vector3(v - circum):LengthSquared()

    return dist < circumRadius or Equals(dist, circumRadius)
end

return Triangle
