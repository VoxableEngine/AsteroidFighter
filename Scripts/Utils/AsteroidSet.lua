
local Class = require("CoreLib.SimpleLuaClasses.Class")

local AsteroidSet = Class()

function AsteroidSet:init(asteroidConfig)
    self.config = asteroidConfig or {
        numPoints = 8,
        numInSet = 50
    }
    self.asteroids = {}
end

function AsteroidSet:Generate()

end

function AsteroidSet:GetRandomIndex()
    return RandomInt(1, #self.asteroids)
end

function AsteroidSet:GetAsteroidModel(asteroidIndex)

end

function AsteroidSet:GetShardModel(asteroidIndex, shardIndex)

end

function AsteroidSet:GetCrumbleModel(asteroidIndex, shardIndex, crumbleIndex)

end

return AsteroidSet
