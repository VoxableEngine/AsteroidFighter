
local Class = require("CoreLib.SimpleLuaClasses.Class")
local Delaunay = require("Utils.Delaunay")

local AsteroidSet = Class()

function AsteroidSet:init(asteroidConfig)
    self.config = asteroidConfig or {
        numPoints = 6,
        numInSet = 5,
        minVariance = -0.25,
        maxVariance = 0.25,
        arrangements = {
            radius = 1
        }
    }
    self.asteroids = {}
end

function AsteroidSet:Generate()

    local config = self.config
    local arrangement = config.arrangements

    self.asteroids = {}

    --generate set of random asteroids to generate models from
    for aIndex=1, self.config.numInSet, 1 do

        local asteroid = {}
        local points = {}

        --generate random points for an asteroid starting in a circle arrangement
        local radius = arrangement.radius
        local angleInc = 360 / self.config.numPoints

        for pIndex=1, self.config.numPoints, 1 do

            local vec = Vector3()
            vec.x = Cos(pIndex*(angleInc))*radius+Random(config.minVariance, config.maxVariance)
            vec.y = Sin(pIndex*(angleInc))*radius+Random(config.minVariance, config.maxVariance)

            table.insert(points, vec)
        end
        asteroid.data = Delaunay(points, config.minVariance-radius, config.maxVariance+radius)

        table.insert(self.asteroids, asteroid)
    end

    local vertexData = {}
    local lastVertex = 1
    local indexData = {}
    local lastIndex = 1

    local currentIndex = 0

    for aIndex, asteroid in ipairs(self.asteroids) do

        local data = asteroid.data
        local boundingBox = BoundingBox()
        local firstIndex = currentIndex

        --print("firstIndex: "..firstIndex)

        for vIndex, vertex in ipairs(data.vertices) do

            boundingBox:Merge(vertex)

            -- position
            vertexData[lastVertex] = vertex.x
            vertexData[lastVertex+1] = vertex.y
            vertexData[lastVertex+2] = vertex.z

            -- normal
            vertexData[lastVertex+3] = Random(-0.5, 0)
            vertexData[lastVertex+4] = Random(-0.5, 0)
            vertexData[lastVertex+5] = -1

            -- texcoord
            vertexData[lastVertex+6] = vertex.x
            vertexData[lastVertex+7] = vertex.y

            lastVertex = lastVertex + 8
            currentIndex = currentIndex + 1
        end

        asteroid.boundingBox = boundingBox
        asteroid.startIndex = lastIndex-1 --firstIndex

        asteroid.shards = {}


        for tIndex, tri in ipairs(data.triangles) do

            local shardBounds = BoundingBox()
            local crumbs = {}

            shardBounds:Merge(tri.a)
            shardBounds:Merge(tri.b)
            shardBounds:Merge(tri.c)

            table.insert(asteroid.shards, {
                startIndex = lastIndex-1,
                boundingBox = shardBounds,
                a = tri.a,
                b = tri.b,
                c = tri.c,
                crumbs = crumbs
            })

            indexData[lastIndex] = firstIndex+tri.ai-1
            indexData[lastIndex+1] = firstIndex+tri.bi-1
            indexData[lastIndex+2] = firstIndex+tri.ci-1

            lastIndex = lastIndex + 3
        end

        asteroid.indexCount = lastIndex-asteroid.startIndex
        print("startIndex: "..asteroid.startIndex..", indexCount: "..asteroid.indexCount)
    end

    local numVertices = lastVertex --#meshData.vertices
    local numIndexes = lastIndex -- #indexData

    --print("numVertices: "..numVertices)
    --print("numIndexes: "..numIndexes)


    --print("lastVertex: "..lastVertex)

    self.vBuffer = VertexBuffer:new()
    self.iBuffer = IndexBuffer:new()

    -- Shadowed buffer needed for raycasts to work, and so that data can be automatically restored on device loss
    self.vBuffer.shadowed = true
    -- We could use the "legacy" element bitmask to define elements for more compact code, but let's demonstrate
    -- defining the vertex elements explicitly to allow any element types and order
    local elements = {
        VertexElement(TYPE_VECTOR3, SEM_POSITION),
        VertexElement(TYPE_VECTOR3, SEM_NORMAL),
        VertexElement(TYPE_VECTOR2, SEM_TEXCOORD)
    }
    self.vBuffer:SetSize(numVertices, elements)

    local temp = VectorBuffer()
    for i = 1, numVertices * 8 do
        temp:WriteFloat(vertexData[i])
    end
    self.vBuffer:SetData(temp)

    self.iBuffer.shadowed = true
    self.iBuffer:SetSize(numIndexes, false)
    temp:Clear()
    for i = 1, numIndexes do
        temp:WriteUShort(indexData[i])
    end
    self.iBuffer:SetData(temp)
end

function AsteroidSet:GetAsteroidData(asteroidIndex)
    return self.asteroids[asteroidIndex]
end

function AsteroidSet:GetShardData(asteroidIndex, shardIndex)
    return self.asteroids[asteroidIndex].shards[shardIndex]
end

function AsteroidSet:GetCrumbData(asteroidIndex, shardIndex, crumbIndex)
    return self.asteroids[asteroidIndex].shards[shardIndex].crumbs[crumbIndex]
end

function AsteroidSet:GetRandomIndex()
    return RandomInt(1, #self.asteroids)
end

function AsteroidSet:GetWholeModel(asteroidIndex)

    local asteroid = self.asteroids[asteroidIndex]

    --if asteroid.model == nil then
        -- Create model, buffers and geometry without garbage collection, as they will be managed
        -- by the StaticModel component once assigned to it
        asteroid.model = Model:new()
        local geom = Geometry:new()

        geom:SetVertexBuffer(0, self.vBuffer)
        geom:SetIndexBuffer(self.iBuffer)
        geom:SetDrawRange(TRIANGLE_LIST, asteroid.startIndex, asteroid.indexCount)

        asteroid.model.numGeometries = 1
        asteroid.model:SetGeometry(0, 0, geom)
        asteroid.model.boundingBox = asteroid.boundingBox

        -- Though not necessary to render, the vertex & index buffers must be listed in the model so that it can be saved properly
        local vertexBuffers = {}
        local indexBuffers = {}
        table.insert(vertexBuffers, self.vBuffer)
        table.insert(indexBuffers, self.iBuffer)
        -- Morph ranges could also be not defined. Here we simply define a zero range (no morphing) for the vertex buffer
        local morphRangeStarts = {}
        local morphRangeCounts = {}
        table.insert(morphRangeStarts, 0)
        table.insert(morphRangeCounts, 0)
        asteroid.model:SetVertexBuffers(vertexBuffers, morphRangeStarts, morphRangeCounts)
        asteroid.model:SetIndexBuffers(indexBuffers)
    --end
    return asteroid.model
end

function AsteroidSet:GetShardModel(asteroidIndex, shardIndex)

    local asteroid = self.asteroids[asteroidIndex]
    local shard = asteroid.shards[shardIndex]

    --if shard.model == nil then

        -- Create model, buffers and geometry without garbage collection, as they will be managed
        -- by the StaticModel component once assigned to it
        shard.model = Model:new()
        local geom = Geometry:new()

        geom:SetVertexBuffer(0, self.vBuffer)
        geom:SetIndexBuffer(self.iBuffer)
        geom:SetDrawRange(TRIANGLE_LIST, shard.startIndex, 3)

        shard.model.numGeometries = 1
        shard.model:SetGeometry(0, 0, geom)
        shard.model.boundingBox = shard.boundingBox

        -- Though not necessary to render, the vertex & index buffers must be listed in the model so that it can be saved properly
        local vertexBuffers = {}
        local indexBuffers = {}
        table.insert(vertexBuffers, self.vBuffer)
        table.insert(indexBuffers, self.iBuffer)
        -- Morph ranges could also be not defined. Here we simply define a zero range (no morphing) for the vertex buffer
        local morphRangeStarts = {}
        local morphRangeCounts = {}
        table.insert(morphRangeStarts, 0)
        table.insert(morphRangeCounts, 0)
        shard.model:SetVertexBuffers(vertexBuffers, morphRangeStarts, morphRangeCounts)
        shard.model:SetIndexBuffers(indexBuffers)
    --end
    return shard.model
end

function AsteroidSet:GetCrumbModel(asteroidIndex, shardIndex, crumbIndex)

    local asteroid = self.asteroids[asteroidIndex]
    local shard = asteroid.shards[shardIndex]
    local crumb = shard.crumbs[crumbIndex]

    if crumb.model == nil then

        -- Create model, buffers and geometry without garbage collection, as they will be managed
        -- by the StaticModel component once assigned to it
        crumb.model = Model:new()
        local geom = Geometry:new()

        geom:SetVertexBuffer(0, self.vBuffer)
        geom:SetIndexBuffer(self.iBuffer)
        geom:SetDrawRange(TRIANGLE_LIST, crumb.startIndex, 3)

        crumb.model.numGeometries = 1
        crumb.model:SetGeometry(0, 0, geom)
        crumb.model.boundingBox = crumb.boundingBox

        -- Though not necessary to render, the vertex & index buffers must be listed in the model so that it can be saved properly
        local vertexBuffers = {}
        local indexBuffers = {}
        table.insert(vertexBuffers, self.vBuffer)
        table.insert(indexBuffers, self.iBuffer)
        -- Morph ranges could also be not defined. Here we simply define a zero range (no morphing) for the vertex buffer
        local morphRangeStarts = {}
        local morphRangeCounts = {}
        table.insert(morphRangeStarts, 0)
        table.insert(morphRangeCounts, 0)
        crumb.model:SetVertexBuffers(vertexBuffers, morphRangeStarts, morphRangeCounts)
        crumb.model:SetIndexBuffers(indexBuffers)
    end
    return crumb.model
end

return AsteroidSet
