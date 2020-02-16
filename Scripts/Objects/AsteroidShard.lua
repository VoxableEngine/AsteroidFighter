
local AsteroidModel = require("Utils.AsteroidModel")
--local Explosion2D = require("Utils.Explosion2D")

AsteroidShard = ScriptObject()

local collisionCategory_ = categories_.ASTEROID

local collisionMask_ = bit.bor(
    categories_.BOUNDARY,
    categories_.ASTEROID,
    categories_.FRIENDLY_SHIP,
    categories_.FRIENDLY_PROJECTILE,
    categories_.ENEMY_SHIP,
    categories_.ENEMY_PROJECTILE
)

function AsteroidShard:HandlePostRenderUpdate(eventType, eventData)
    --local debug = scene_:GetComponent("DebugRenderer")
end

function AsteroidShard:Start()

    local node = self.node
    local asteroidRoot = scene_:GetChild("AsteroidRoot", true)
    local generator = asteroidRoot:GetScriptObject()
    local asteroidSet = generator.asteroidSet

    self.asteroidIndex = node.asteroidIndex
    self.shardIndex = node.shardIndex

    --local model = asteroidSet:GetShardModel(self.asteroidIndex, self.shardIndex)

    local modelNode = node:CreateChild("ModelNode")
    local staticModel = modelNode:CreateComponent("StaticModel")
    staticModel.model = asteroidSet:GetShardModel(self.asteroidIndex, self.shardIndex)
    staticModel.material = cache:GetResource("Material", "Materials/Stone.xml")

    node:AddTag("Asteroid")

    local body = node:CreateComponent("RigidBody2D")
    body.bodyType = BT_DYNAMIC

    local shard = asteroidSet:GetShardData(self.asteroidIndex, self.shardIndex)
    local shape = node:CreateComponent("CollisionPolygon2D")
    shape:SetVertexCount(3)
    shape:SetVertex(0, Vector2(shard.a.x, shard.a.y))
    shape:SetVertex(1, Vector2(shard.b.x, shard.b.y))
    shape:SetVertex(2, Vector2(shard.c.x, shard.c.y))
    shape.density = 2.0
    shape.friction = 0.5
    shape.restitution = 0.1
    shape:SetCategoryBits(collisionCategory_)
    shape:SetMaskBits(collisionMask_)

    --self:SubscribeToEvent("PostRenderUpdate", "AsteroidShard:HandlePostRenderUpdate")
    self:SubscribeToEvent(node, "NodeBeginContact2D", "AsteroidShard:HandleCollisionBegin")
end

function AsteroidShard:HandleCollisionBegin(eventType, eventData)


    local laserNode = eventData["OtherNode"]:GetPtr("Node")

    if laserNode:HasTag("Laser") == false then return end

    local node = self.node
    -- local contacts = {}
    -- local contactBuffer = eventData["Contacts"]:GetBuffer()

    -- while not contactBuffer.eof do
    --     local contact = {}
    --     contact.position = contactBuffer:ReadVector2() -- position
    --     contact.normal = contactBuffer:ReadVector2() -- normal
    --     contact.seperation = contactBuffer:ReadFloat() -- seperation (negative overlap distance)
    --     table.insert(contacts, contact)
    -- end
    node:Remove()
end

function AsteroidShard:Update(timeStep)
    local node = self.node
    if (node.position.x > ARENA_SIZE*0.5 or node.position.x < -ARENA_SIZE*0.5) or
        (node.position.y > ARENA_SIZE*0.5 or node.position.y < -ARENA_SIZE*0.5) then

        node:Remove()
    end
end

return AsteroidShard
