
local AsteroidSet = require("Utils.AsteroidSet")
local Asteroid = require("Objects.Asteroid")

AsteroidGenerator = ScriptObject()

function AsteroidGenerator:Start()

end

function AsteroidGenerator:GenerateSets()
    self.asteroidSet = AsteroidSet()
    self.asteroidSet:Generate()
end

--function AsteroidGenerator:Generate()

    -- local points = {}
    -- local numPoints = 6
    -- local min = -0.25
    -- local max = 0.25

    -- --generate set of random points
    -- local angleInc = 360 / numPoints
    -- for i=1, numPoints, 1 do
    --     --local vec = Vector3(Random(min, max), Random(min, max), 0)
    --     local vec = Vector3()
    --     vec.x = Cos(i*(angleInc))*1+Random(min, max)
    --     vec.y = Sin(i*(angleInc))*1+Random(min, max)

    --     table.insert(points, vec)
    -- end

    -- return Delaunay(points, min-1, max+1)
--end


function AsteroidGenerator:Update(timeStep)

    local asteroidRoot = self.node
    local asteroids = asteroidRoot:GetChildrenWithTag("Asteroid", true)

    if #asteroids < MIN_ASTEROIDS-1 then

        local numToCreate = (MIN_ASTEROIDS-1) - #asteroids

        for aIndex=1, numToCreate, 1 do

            local asteroidNode = asteroidRoot:CreateChild("Asteroid")
            asteroidNode:CreateScriptObject("Asteroid")
        end
    end
end

return AsteroidGenerator
