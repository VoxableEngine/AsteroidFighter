
Player = ScriptObject()

local MOVE_SPEED = 2
local MOVE_DAMP = 3
local MAX_SPEED = 4
local MAX_ENGINE_GAIN = 0.03125

local hudText_ = nil
local playerSoundSource_ = nil

function Player:HandleMouseButtonDown(eventType, eventData)
    local node = self.node
    self.direction = node.rotation:RollAngle()+270
    --print(self == nil)
    local laserNode = scene_:CreateChild("Bullet1")
    laserNode.position = node.position
    laserNode.rotation = Quaternion(self.direction, 90, 0)
    laserNode.scale = Vector3(0.15, 0.15, 0.15)
    laserNode:CreateScriptObject("Laser")

    local sound = cache:GetResource("Sound", "Sounds/Laser.wav")
    self.fxSoundSource:Play(sound)
end

function Player:Start()

    local node = self.node

    self.velocity = Vector3(0, 0, 0)

    local playerModel = node:CreateComponent("StaticModel")
    playerModel.model = cache:GetResource("Model", "Models/Ship.mdl")
    --playerModel.material = cache:GetResource("Material", "Materials/DefaultGrey.xml")
    playerModel.material = cache:GetResource("Material", "Materials/Green.xml")
    playerModel.lightMask = 1

    local playerLight = node:CreateComponent("Light")
    playerLight.lightType = LIGHT_POINT
    playerLight.range = 2.0
    playerLight.color = Color(0.0, 0.45, 0.0)
    playerLight.specularIntensity = 1.25
    playerLight.lightMask = 2

    local listener = node:CreateComponent("SoundListener")
    audio.listener = listener

    self.fxSoundSource = node:CreateComponent("SoundSource3D")
    self.fxSoundSource:SetDistanceAttenuation(10, 40, 1)
    self.fxSoundSource.soundType = SOUND_EFFECT

    self.engineSoundSource = node:CreateComponent("SoundSource3D")
    self.engineSoundSource:SetDistanceAttenuation(5, 20, 1)
    self.engineSoundSource.soundType = SOUND_EFFECT
    self.engineSoundSource.gain = 0.03125

    hudText_ = Text:new()
    hudText_.text = "hey hey"
    hudText_:SetStyleAuto()
    hudText_.position = IntVector2(5,5)
    hudText_.color = Color(0, 1, 0)

    ui.root:AddChild(hudText_)

    self:SubscribeToEvent("MouseButtonDown", "Player:HandleMouseButtonDown")
end

function Player:Update(timeStep)
    local node = self.node
    local mpos = input:GetMousePosition()
    local np = node.position
    local wp = camera_:ScreenToWorldPoint(Vector3(mpos.x/graphics.width, mpos.y/graphics.height, 0))

    --hudText_.text = "x = " .. wp.x .. ", y = " .. wp.y .. ", z = " .. wp.z .. "\nx = " .. np.x .. ", y = " .. np.y .. ", z = " .. np.z

    wp.x = np.x-(wp.x*100)
    wp.y = np.y-(wp.y*100)
    node.rotation = Quaternion(180, 0, Atan2(wp.x, wp.y))

    local isThrust = false
    local isEngineSounding = false
    if input:GetKeyDown(KEY_W) then
        self.velocity.y = self.velocity.y + (1.0 * MOVE_SPEED * timeStep)
        self.velocity.y = Clamp(self.velocity.y, -MAX_SPEED, MAX_SPEED)
        --node:Translate(Vector3(0, 1.0, 0) * MOVE_SPEED * timeStep, TS_WORLD)
        isThrust = true
    end
    if input:GetKeyDown(KEY_S) then
        self.velocity.y = self.velocity.y + (-1.0 * MOVE_SPEED * timeStep)
        self.velocity.y = Clamp(self.velocity.y, -MAX_SPEED, MAX_SPEED)
        --node:Translate(Vector3(0, -1.0, 0) * MOVE_SPEED * timeStep, TS_WORLD)
        isThrust = true
    end
    if input:GetKeyDown(KEY_A) then
        self.velocity.x = self.velocity.x + (-1.0 * MOVE_SPEED * timeStep)
        self.velocity.x = Clamp(self.velocity.x, -MAX_SPEED, MAX_SPEED)
        --node:Translate(Vector3(-1, 0, 0) * MOVE_SPEED * timeStep, TS_WORLD)
        isThrust = true
    end
    if input:GetKeyDown(KEY_D) then
        self.velocity.x = self.velocity.x + (1.0 * MOVE_SPEED * timeStep)
        self.velocity.x = Clamp(self.velocity.x, -MAX_SPEED, MAX_SPEED)
        --node:Translate(Vector3(1, 0, 0) * MOVE_SPEED * timeStep, TS_WORLD)
        isThrust = true
    end

    if isThrust then
        if self.engineSoundSource:IsPlaying() == false then
            local engineSound = cache:GetResource("Sound", "Sounds/Engine.wav")
            engineSound.looped = true
            self.engineSoundSource:Play(engineSound)
        end
        isEngineSounding = true
    else
        local damp = MOVE_DAMP * timeStep
        if self.velocity.x < -M_EPSILON then
            self.velocity.x = self.velocity.x + damp
        elseif self.velocity.x > M_EPSILON then
            self.velocity.x = self.velocity.x - damp
        end
        if self.velocity.y < -M_EPSILON then
            self.velocity.y = self.velocity.y + damp
        elseif self.velocity.y > M_EPSILON then
            self.velocity.y = self.velocity.y - damp
        end

        if Abs(self.velocity.x) > damp or Abs(self.velocity.y) > damp then
            isEngineSounding = true
        end
    end

    if isEngineSounding then
        local ratio = self.velocity:Length()/MAX_SPEED
        self.engineSoundSource.frequency = 40000 + ratio*60000
        self.engineSoundSource.gain = ratio*MAX_ENGINE_GAIN
    else
        self.engineSoundSource:Stop()
    end
    --apply velocity to current position

    node:Translate(self.velocity * timeStep, TS_WORLD)
end

return Player
