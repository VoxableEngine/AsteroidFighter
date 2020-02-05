Laser = ScriptObject()

local LASER_SPEED = 5

local collisionMask_ = bit.bor(
    categories_.BOUNDARY,
    categories_.ASTEROID,
    categories_.ENEMY_SHIP)

function Laser:Start()
    local node = self.node

    local modelNode = node:CreateChild("ModelNode")
    modelNode.rotation = Quaternion(0, 90, 270)

    local laserModel = modelNode:CreateComponent("StaticModel")
    laserModel.model = cache:GetResource("Model", "Models/Laser.mdl")
    laserModel.material = cache:GetResource("Material", "Materials/Green.xml")

    local body = node:CreateComponent("RigidBody2D")
    body.bodyType = BT_DYNAMIC
    body.allowSleep = false

    local shape = node:CreateComponent("CollisionPolygon2D")
    shape:SetVertexCount(4)
    shape:SetVertex(0, Vector2(0.35, 0))
    shape:SetVertex(1, Vector2(0, 0.2))
    shape:SetVertex(2, Vector2(-1.2, 0))
    shape:SetVertex(3, Vector2(0, -0.2))
    shape:SetCategoryBits(categories_.FRIENDLY_PROJECTILE)
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

    self.launchTime = time:GetSystemTime()
    self.burstTime = nil
    body:SetLinearVelocity((node.rotation*Vector3(1.0, 0.0, 0.0)) * LASER_SPEED)
end

function Laser:Update(timeStep)
    local node = self.node
    local body = node:GetComponent("RigidBody2D")

    --body.angularVelocity = 0
    --node:Translate(Vector3(0.0, 0.0, 1.0) * LASER_SPEED * timeStep, TS_LOCAL)
    if self.burstTime and time:GetSystemTime() - self.burstTime > 150 then
        node:Remove()
    elseif time:GetSystemTime() - self.launchTime > 1250 then
        node:Remove()
    end
end

function Laser:Burst()
    local node = self.node
    local body = node:GetComponent("RigidBody2D")

    body.linearVelocity = Vector2(0, 0)
    body.angularVelocity = 0

    local modelNode = node:GetChild("ModelNode")
    modelNode:Remove()

    local laserEffect = node:GetComponent("ParticleEmitter")
    laserEffect.effect = cache:GetResource("ParticleEffect", "Particle/LaserBurst.xml")
    self.burstTime = time:GetSystemTime()
end

return Laser
