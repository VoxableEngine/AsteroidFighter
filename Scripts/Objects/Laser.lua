
local Explosion2D = require("Utils.Explosion2D")

Laser = ScriptObject()

local LASER_SPEED = 5
local LASER_RANGE = 25 -- laser travel distance squared

local collisionCategory_ = categories_.FRIENDLY_PROJECTILE

local collisionMask_ = bit.bor(
    categories_.BOUNDARY,
    categories_.ASTEROID,
    categories_.ENEMY_SHIP
)

function Laser:Start()
    local node = self.node

    local modelNode = node:CreateChild("ModelNode")
    modelNode.rotation = Quaternion(0, 90, 270)

    local laserModel = modelNode:CreateComponent("StaticModel")
    laserModel.model = cache:GetResource("Model", "Models/Laser.mdl")
    laserModel.material = cache:GetResource("Material", "Materials/Green.xml")

    node:AddTag("Laser")

    local body = node:CreateComponent("RigidBody2D")
    body.bodyType = BT_DYNAMIC
    body.allowSleep = false

    local shape = node:CreateComponent("CollisionPolygon2D")
    shape:SetVertexCount(4)
    shape:SetVertex(0, Vector2(0.35, 0))
    shape:SetVertex(1, Vector2(0, 0.2))
    shape:SetVertex(2, Vector2(-1.2, 0))
    shape:SetVertex(3, Vector2(0, -0.2))
    shape:SetCategoryBits(collisionCategory_)
    shape:SetMaskBits(collisionMask_)

    shape.density = 1.0
    shape.friction = 0
    shape.restitution = 0.3


    local laserEffect = node:CreateComponent("ParticleEmitter")
    laserEffect.effect = cache:GetResource("ParticleEffect", "Particle/LaserTrail.xml")

    local laserSoundSource = node:CreateComponent("SoundSource3D")
    laserSoundSource:SetDistanceAttenuation(1, 5, 1)
    laserSoundSource.soundType = SOUND_EFFECT
    laserSoundSource.gain = 0.05125
    local laserPass = cache:GetResource("Sound", "Sounds/LaserPass.wav")
    laserSoundSource:Play(laserPass)

    --self.launchTime = time:GetSystemTime()
    self.startPosition = Vector3(node.position)
    self.burstTime = nil
    body:SetLinearVelocity((node.rotation*Vector3(1.0, 0.0, 0.0)) * LASER_SPEED)

    self:SubscribeToEvent(self.node, "NodeBeginContact2D", "Laser:HandleCollisionBegin")
end

function Laser:Update(timeStep)
    local node = self.node
    local body = node:GetComponent("RigidBody2D")

    --body.angularVelocity = 0
    --node:Translate(Vector3(0.0, 0.0, 1.0) * LASER_SPEED * timeStep, TS_LOCAL)
    if self.burstTime and time:GetSystemTime() - self.burstTime > 150 then
        node:Remove()
    --elseif time:GetSystemTime() - self.launchTime > 1250 then
    elseif Vector3(node.position-self.startPosition):LengthSquared() > LASER_RANGE then

        node:Remove()
    end
end

function Laser:HandleCollisionBegin(eventType, eventData)

    local hitNode = eventData["OtherNode"]:GetPtr("Node")
    --if laserNode:HasTag("Laser") == false then return end

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
    local body = node:GetComponent("RigidBody2D")

    body.linearVelocity = Vector2(0, 0)
    body.angularVelocity = 0

    local world = scene_:GetComponent("PhysicsWorld2D")
    Explosion2D.Impulse(world, "Asteroid", contacts[1].position, 1.25, 5, 30, false)

    local modelNode = node:GetChild("ModelNode")
    if modelNode ~= nil then
        modelNode:Remove()

        local laserEffect = node:GetComponent("ParticleEmitter")
        laserEffect.effect = cache:GetResource("ParticleEffect", "Particle/LaserBurst.xml")
        self.burstTime = time:GetSystemTime()

        local laserSoundSource = node:GetComponent("SoundSource3D")
        local laserHit = cache:GetResource("Sound", "Sounds/LaserHit_"..RandomInt(1,4)..".wav")
        laserSoundSource:Play(laserHit)
    end
end

return Laser
