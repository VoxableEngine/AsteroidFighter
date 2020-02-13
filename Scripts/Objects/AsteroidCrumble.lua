
local AsteroidModel = require("Utils.AsteroidModel")
local Explosion2D = require("Utils.Explosion2D")

AsteroidCrumble = ScriptObject()

local collisionCategory_ = categories_.ASTEROID

local collisionMask_ = bit.bor(
    categories_.BOUNDARY,
    categories_.ASTEROID,
    categories_.FRIENDLY_SHIP,
    categories_.FRIENDLY_PROJECTILE,
    categories_.ENEMY_SHIP,
    categories_.ENEMY_PROJECTILE
)

function AsteroidCrumble:HandlePostRenderUpdate(eventType, eventData)
    local debug = scene_:GetComponent("DebugRenderer")

    -- for index,vertex in ipairs(self.node.vertices) do
    --     debug:AddSphere(Sphere(self.node.rotation*(self.node.position+vertex), 0.03125), Color(1, 0, 0), false)
    -- end

    -- for index,tri in ipairs(self.node.triangles) do
    --     debug:AddLine(self.node.position+tri.a, self.node.position+tri.b, Color(1, 1, 0), false)
    --     debug:AddLine(self.node.position+tri.b, self.node.position+tri.c, Color(1, 1, 0), false)
    --     debug:AddLine(self.node.position+tri.c, self.node.position+tri.a, Color(1, 1, 0), false)
    -- end
end

function AsteroidCrumble:Start()
    local node = self.node
    local model = AsteroidModel.Create({ vertices=node.vertices, triangles=node.triangles })
    local modelNode = node:CreateChild("ModelNode")
    local staticModel = modelNode:CreateComponent("StaticModel")
    staticModel.model = model
    staticModel.material = cache:GetResource("Material", "Materials/Asteroid.xml")

    node:AddTag("Asteroid")

    local body = node:CreateComponent("RigidBody2D")
    body.bodyType = BT_DYNAMIC

    local triangle = node.triangles[1]
    local shape = node:CreateComponent("CollisionPolygon2D")
    shape:SetVertexCount(3)
    shape:SetVertex(0, Vector2(triangle.a.x, triangle.a.y))
    shape:SetVertex(1, Vector2(triangle.b.x, triangle.b.y))
    shape:SetVertex(2, Vector2(triangle.c.x, triangle.c.y))
    shape.density = 2.0
    shape.friction = 0.5
    shape.restitution = 0.1
    shape:SetCategoryBits(collisionCategory_)
    shape:SetMaskBits(collisionMask_)

    self:SubscribeToEvent("PostRenderUpdate", "AsteroidCrumble:HandlePostRenderUpdate")
    self:SubscribeToEvent(self.node, "NodeBeginContact2D", "AsteroidCrumble:HandleCollisionBegin")
end

function AsteroidCrumble:HandleCollisionBegin(eventType, eventData)
    local laserNode = eventData["OtherNode"]:GetPtr("Node")

    if laserNode.name ~= "Laser" then
        return
    end

    local contactBuffer = eventData["Contacts"]:GetBuffer()

    local contacts = {}
    while not contactBuffer.eof do
        local contact = {}
        contact.position = contactBuffer:ReadVector2() -- position
        contact.normal = contactBuffer:ReadVector2() -- normal
        contact.seperation = contactBuffer:ReadFloat() -- seperation (negative overlap distance)
        table.insert(contacts, contact)
    end

    local node = self.node
    node:RemoveComponents("CollisionPolygon2D")

    -- local world = scene_:GetComponent("PhysicsWorld2D")
    -- Explosion2D.Impulse(world, "Asteroid", contacts[1].position, 1.25, 5, 30, false)

    --remove crumble node
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
