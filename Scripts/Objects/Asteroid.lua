
local Triangle = require("Utils.Triangle")
local AsteroidModel = require("Utils.AsteroidModel")
local Explosion2D = require("Utils.Explosion2D")
local AsteroidShard = require("Objects.AsteroidShard")

Asteroid = ScriptObject()

local collisionCategory_ = categories_.ASTEROID

local collisionMask_ = bit.bor(
    categories_.BOUNDARY,
    categories_.ASTEROID,
    categories_.FRIENDLY_SHIP,
    categories_.FRIENDLY_PROJECTILE,
    categories_.ENEMY_SHIP,
    categories_.ENEMY_PROJECTILE
)

function Asteroid:HandlePostRenderUpdate(eventType, eventData)
    local debug = scene_:GetComponent("DebugRenderer")

    --for index,vertex in ipairs(self.mesh.vertices) do
    --   debug:AddSphere(Sphere(self.node.rotation*(self.node.position+vertex), 0.03125), Color(1, 0, 0), false)
    --end

    -- for index,tri in ipairs(self.mesh.triangles) do
    --     debug:AddLine(self.node.position+tri.a, self.node.position+tri.b, Color(1, 1, 0), false)
    --     debug:AddLine(self.node.position+tri.b, self.node.position+tri.c, Color(1, 1, 0), false)
    --     debug:AddLine(self.node.position+tri.c, self.node.position+tri.a, Color(1, 1, 0), false)
    -- end
end

function Asteroid:Start()

    local asteroidRoot = scene_:GetChild("AsteroidRoot", true)
    local generator = asteroidRoot:GetScriptObject()
    self.mesh = generator:Generate()

    local model = AsteroidModel.Create(self.mesh)

    local node = self.node
    local modelNode = node:CreateChild("ModelNode")

    local staticModel = modelNode:CreateComponent("StaticModel")
    staticModel.model = model
    staticModel.material = cache:GetResource("Material", "Materials/Asteroid.xml")

    node:AddTag("Asteroid")

    local body = node:CreateComponent("RigidBody2D")
    body.bodyType = BT_DYNAMIC

    for tIndex, tri in ipairs(self.mesh.triangles) do
        local shape = node:CreateComponent("CollisionPolygon2D")
        shape:SetVertexCount(3)
        shape:SetVertex(0, Vector2(tri.a.x, tri.a.y))
        shape:SetVertex(1, Vector2(tri.b.x, tri.b.y))
        shape:SetVertex(2, Vector2(tri.c.x, tri.c.y))
        shape.density = 2.0
        shape.friction = 0.5
        shape.restitution = 0.1
        shape:SetCategoryBits(collisionCategory_)
        shape:SetMaskBits(collisionMask_)
    end

    body:ApplyLinearImpulseToCenter(self.node.impulse, true)
    body:ApplyAngularImpulse(self.node.angularImpulse, true)

    self:SubscribeToEvent("PostRenderUpdate", "Asteroid:HandlePostRenderUpdate")
    self:SubscribeToEvent(self.node, "NodeBeginContact2D", "Asteroid:HandleCollisionBegin")
end

function Asteroid:DoLaserCollision(laserNode, contacts)

end

function Asteroid:DoAsteroidCollision(otherNode, contacts)

end

function Asteroid:HandleCollisionBegin(eventType, eventData)
    local otherNode = eventData["OtherNode"]:GetPtr("Node")
    local contactBuffer = eventData["Contacts"]:GetBuffer()

    if otherNode.name ~= "Laser" then
        return
    end

    local contacts = {}
    while not contactBuffer.eof do
        local contact = {}
        contact.position = contactBuffer:ReadVector2() -- position
        contact.normal = contactBuffer:ReadVector2() -- normal
        contact.seperation = contactBuffer:ReadFloat() -- seperation (negative overlap distance)
        table.insert(contacts, contact)
    end

    local node = self.node
    local modelNode = node:GetChild("ModelNode")
    if modelNode ~= nil then
        modelNode:Remove()
    end

    --remove existing collision polygons
    node:RemoveComponents("CollisionPolygon2D")

    local asteroidRoot = scene_:GetChild("AsteroidRoot", true)

    -- Create free floating asteroid shards
    for tIndex, tri in ipairs(self.mesh.triangles) do
        local shardNode = asteroidRoot:CreateChild("AsteroidShard")

        local newTri = Triangle(tri.a, 1, tri.b, 2, tri.c, 3)
        shardNode.position = node.position
        shardNode.rotation = node.rotation
        shardNode.vertices = { newTri.a, newTri.b, newTri.c }
        shardNode.triangles = { newTri }
        shardNode:CreateScriptObject("AsteroidShard")
    end

    node:Remove()
end

function Asteroid:Update(timeStep)
    local node = self.node
    if (node.position.x > ARENA_SIZE*0.5 or node.position.x < -ARENA_SIZE*0.5) or
        (node.position.y > ARENA_SIZE*0.5 or node.position.y < -ARENA_SIZE*0.5) then

        node:Remove()
    end
end

return Asteroid
