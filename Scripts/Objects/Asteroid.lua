
local Delaunay = require("Utils.Delaunay")
--local Triangle = require("Utils.Triangle")
--local Edge = require("Utils.Edge")

Asteroid = ScriptObject()

local collisionMask_ = bit.bor(
    categories_.BOUNDARY,
    categories_.ASTEROID,
    categories_.FRIENDLY_SHIP,
    categories_.FRIENDLY_PROJECTILE,
    categories_.ENEMY_SHIP,
    categories_.ENEMY_PROJECTILE)

function Asteroid:HandlePostRenderUpdate(eventType, eventData)
    --print("here")
    local debug = scene_:GetComponent("DebugRenderer")

    --AddSphere (const Sphere &sphere, const Color &color, bool depthTest=true)

    -- for index,vertex in ipairs(self.delaunay.vertices) do
    --     debug:AddSphere(Sphere(self.node.position+vertex, 0.03125), Color(1, 0, 0), false)
    -- end

    -- for index,tri in ipairs(self.delaunay.triangles) do
    --     debug:AddLine(self.node.position+tri.a, self.node.position+tri.b, Color(1, 1, 0), false)
    --     debug:AddLine(self.node.position+tri.b, self.node.position+tri.c, Color(1, 1, 0), false)
    --     debug:AddLine(self.node.position+tri.c, self.node.position+tri.a, Color(1, 1, 0), false)
    -- end
end

function Asteroid:Start()

    self.points = {}
    self.rot = 0 --Random(-10, 10)

    local numPoints = 10
    local min = -0.25
    local max = 0.25



    --generate set of random points
    local angleInc = 360 / numPoints
    for i=1, numPoints, 1 do
        --local vec = Vector3(Random(min, max), Random(min, max), 0)
        local vec = Vector3()
        vec.x = Cos(i*(angleInc))*1+Random(min, max)
        vec.y = Sin(i*(angleInc))*1+Random(min, max)

        table.insert(self.points, vec)
    end

    self.delaunay = Delaunay(self.points, -2, 2)

    local vertexData = {}
    local lastVertex = 1
    for vIndex, vertex in ipairs(self.delaunay.vertices) do
        -- position
        vertexData[lastVertex] = vertex.x
        vertexData[lastVertex+1] = vertex.y
        vertexData[lastVertex+2] = vertex.z

        -- normal
        vertexData[lastVertex+3] = Random(-0.5, 0)
        vertexData[lastVertex+4] = Random(-0.5, 0)
        vertexData[lastVertex+5] = -1

        lastVertex = lastVertex + 6
    end

    local indexData = {}
    local lastIndex = 1
    for tIndex, tri in ipairs(self.delaunay.triangles) do
        indexData[lastIndex] = tri.ai-1
        indexData[lastIndex+1] = tri.bi-1
        indexData[lastIndex+2] = tri.ci-1

        lastIndex = lastIndex + 3
    end

    local numVertices = #self.delaunay.vertices
    local numIndexes = #indexData

    -- Create model, buffers and geometry without garbage collection, as they will be managed
    -- by the StaticModel component once assigned to it
    local fromScratchModel = Model:new()
    local vb = VertexBuffer:new()
    local ib = IndexBuffer:new()
    local geom = Geometry:new()

    -- Shadowed buffer needed for raycasts to work, and so that data can be automatically restored on device loss
    vb.shadowed = true
    -- We could use the "legacy" element bitmask to define elements for more compact code, but let's demonstrate
    -- defining the vertex elements explicitly to allow any element types and order
    local elements = {
        VertexElement(TYPE_VECTOR3, SEM_POSITION),
        VertexElement(TYPE_VECTOR3, SEM_NORMAL)
    }
    vb:SetSize(numVertices, elements)

    local temp = VectorBuffer()
    for i = 1, numVertices * 6 do
        temp:WriteFloat(vertexData[i])
    end
    vb:SetData(temp)

    ib.shadowed = true
    ib:SetSize(numIndexes, false)
    temp:Clear()
    for i = 1, numIndexes do
        temp:WriteUShort(indexData[i])
    end
    ib:SetData(temp)

    geom:SetVertexBuffer(0, vb)
    geom:SetIndexBuffer(ib)
    geom:SetDrawRange(TRIANGLE_LIST, 0, numIndexes)

    fromScratchModel.numGeometries = 1
    fromScratchModel:SetGeometry(0, 0, geom)
    fromScratchModel.boundingBox = BoundingBox(Vector3(-1.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))

    -- Though not necessary to render, the vertex & index buffers must be listed in the model so that it can be saved properly
    local vertexBuffers = {}
    local indexBuffers = {}
    table.insert(vertexBuffers, vb)
    table.insert(indexBuffers, ib)
    -- Morph ranges could also be not defined. Here we simply define a zero range (no morphing) for the vertex buffer
    local morphRangeStarts = {}
    local morphRangeCounts = {}
    table.insert(morphRangeStarts, 0)
    table.insert(morphRangeCounts, 0)
    fromScratchModel:SetVertexBuffers(vertexBuffers, morphRangeStarts, morphRangeCounts)
    fromScratchModel:SetIndexBuffers(indexBuffers)

    local node = self.node
    local modelNode = node:CreateChild("ModelNode")

    local asteroidModel = modelNode:CreateComponent("StaticModel")
    asteroidModel.model = fromScratchModel
    asteroidModel.material = cache:GetResource("Material", "Materials/Asteroid.xml")

    local body = node:CreateComponent("RigidBody2D")
    body.bodyType = BT_DYNAMIC

    for tIndex, tri in ipairs(self.delaunay.triangles) do
        local shape = node:CreateComponent("CollisionPolygon2D")
        shape:SetVertexCount(3)
        shape:SetVertex(0, Vector2(tri.a.x, tri.a.y))
        shape:SetVertex(1, Vector2(tri.b.x, tri.b.y))
        shape:SetVertex(2, Vector2(tri.c.x, tri.c.y))
        shape.density = 2.0
        shape.friction = 0.5
        shape.restitution = 0.1
        shape:SetCategoryBits(categories_.ASTEROID)
        shape:SetMaskBits(collisionMask_)
    end


    --self:SubscribeToEvent("PostRenderUpdate", "Asteroid:HandlePostRenderUpdate")
    self:SubscribeToEvent("PhysicsBeginContact2D", "Asteroid:HandleCollisionBegin")
end

function Asteroid:HandleCollisionBegin(eventType, eventData)
    local hitNodeA = eventData["NodeA"]:GetPtr("Node")
    local hitNodeB = eventData["NodeB"]:GetPtr("Node")
    local hitNode = nil

    if hitNodeA.name == "Laser" then
        hitNode = hitNodeA
    elseif hitNodeB.name == "Laser" then
        hitNode = hitNodeB
    else
        return
    end
    print(hitNode.name)
    hitNode:GetScriptObject():Burst()
end

function Asteroid:Update(timeStep)
    local node = self.node

    node:Rotate(Quaternion(0, 0, self.rot*timeStep), TS_LOCAL)
end

return Asteroid
