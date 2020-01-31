Laser = ScriptObject()

local LASER_SPEED = 5

function Laser:Start()
    local node = self.node
    local laserModel = node:CreateComponent("StaticModel")
    laserModel.model = cache:GetResource("Model", "Models/Laser.mdl")
    laserModel.material = cache:GetResource("Material", "Materials/Green.xml")

    local laserEffect = node:CreateComponent("ParticleEmitter")
    laserEffect.effect = cache:GetResource("ParticleEffect", "Particle/LaserTrail.xml")

    local laserSoundSource = node:CreateComponent("SoundSource3D")
    laserSoundSource:SetDistanceAttenuation(1, 5, 1)
    laserSoundSource.soundType = SOUND_EFFECT
    laserSoundSource.gain = 0.05125
    local laserPass = cache:GetResource("Sound", "Sounds/LaserPass.wav")
    laserSoundSource:Play(laserPass)
end

function Laser:Update(timeStep)
    local node = self.node
    node:Translate(Vector3(0.0, 0.0, 1.0) * LASER_SPEED * timeStep, TS_LOCAL)

    if node.position.x > 20 or node.position.x < -20 or node.position.y > 20 or node.position.y < -20 then
        node:Remove();
    end
end

return Laser
