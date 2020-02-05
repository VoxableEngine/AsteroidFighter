
--local Bit = require("Utils.Bitwise")

Player = ScriptObject()

local MOVE_SPEED = 0.35
local MOVE_DAMP = 0.5
local MAX_SPEED = 5
local MAX_ENGINE_GAIN = 0.05125

local hudText_ = nil
local playerSoundSource_ = nil

local collisionMask_ = bit.bor(
    categories_.BOUNDARY,
    categories_.ASTEROID,
    categories_.FRIENDLY_SHIP,
    categories_.ENEMY_SHIP,
    categories_.ENEMY_PROJECTILE)

function Player:HandleMouseButtonDown(eventType, eventData)
    local node = self.node
    self.direction = node.rotation:RollAngle()+270
    --print(self == nil)
    local laserNode = scene_:CreateChild("Laser")

    laserNode.position = node.position
    laserNode.rotation = Quaternion(0, 0, self.direction)
    laserNode.scale = Vector3(0.15, 0.15, 0.15)

    --laserNode:Translate(Vector3(0.0, 0.0, 1.0) * 0.30, TS_LOCAL)
    laserNode:Translate( (node.rotation*Vector3(0.0, -1.0, 0.0)) * 0.3, TS_WORLD)

    laserNode:CreateScriptObject("Laser")

    local sound = cache:GetResource("Sound", "Sounds/Laser.wav")
    self.fxSoundSource:Play(sound)
end

function Player:Start()

    local node = self.node
    node.scale = Vector3(0.2, 0.2, 0.2)

    local modelNode = node:CreateChild("ModelNode")
    modelNode.rotation = Quaternion(180, 0, 0)

    self.velocity = Vector3(0, 0, 0)

    local playerModel = modelNode:CreateComponent("StaticModel")
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
    self.engineSoundSource.gain = MAX_ENGINE_GAIN

    hudText_ = Text:new()
    hudText_.text = ""
    hudText_:SetStyleAuto()
    hudText_.position = IntVector2(5,5)
    hudText_.color = Color(0, 1, 0)

    ui.root:AddChild(hudText_)

    local body = node:CreateComponent("RigidBody2D")
    body.bodyType = BT_DYNAMIC
    body.allowSleep = false
    body:SetLinearDamping(MOVE_DAMP)

    local shape = node:CreateComponent("CollisionPolygon2D")
    shape:SetVertexCount(3)
    shape:SetVertex(0, Vector2(0, -1))
    shape:SetVertex(1, Vector2(0.8, 0.8))
    shape:SetVertex(2, Vector2(-0.8, 0.8))

    shape.density = 1.0
    shape.friction = 0.5
    shape.restitution = 0.1
    shape:SetCategoryBits(categories_.FRIENDLY_SHIP)
    shape:SetMaskBits(collisionMask_)

    self:SubscribeToEvent("MouseButtonDown", "Player:HandleMouseButtonDown")
end

function Player:Update(timeStep)
    local node = self.node
    local body = node:GetComponent("RigidBody2D")

    self.velocity = Vector3(0,0,0)

    local isThrust = false
    local isEngineSounding = false
    if input:GetKeyDown(KEY_W) then
        self.velocity.y = self.velocity.y + (1.0 * MOVE_SPEED)
        isThrust = true
    end
    if input:GetKeyDown(KEY_S) then
        self.velocity.y = self.velocity.y + (-1.0 * MOVE_SPEED)
        isThrust = true
    end
    if input:GetKeyDown(KEY_A) then
        self.velocity.x = self.velocity.x + (-1.0 * MOVE_SPEED)
        isThrust = true
    end
    if input:GetKeyDown(KEY_D) then
        self.velocity.x = self.velocity.x + (1.0 * MOVE_SPEED)
        isThrust = true
    end

    --apply engine thrust
    body:ApplyForceToCenter(self.velocity)
    body.linearVelocity = Vector2(Clamp(body.linearVelocity.x, -MAX_SPEED, MAX_SPEED), Clamp(body.linearVelocity.y, -MAX_SPEED, MAX_SPEED))
    body.angularVelocity = 0

    if isThrust then
        if self.engineSoundSource:IsPlaying() == false then
            local engineSound = cache:GetResource("Sound", "Sounds/Engine.wav")
            engineSound.looped = true
            self.engineSoundSource:Play(engineSound)
        end
        isEngineSounding = true
    else
        if Abs(body.linearVelocity.x) > M_EPSILON or Abs(body.linearVelocity.y) > M_EPSILON then
            isEngineSounding = true
        end
    end

    if isEngineSounding then
        local ratio = body.linearVelocity:Length()/MAX_SPEED
        self.engineSoundSource.frequency = 40000 + ratio*60000
        self.engineSoundSource.gain = ratio*MAX_ENGINE_GAIN
    else
        self.engineSoundSource:Stop()
    end

    local camPos = cameraNode_.position
    local playerPos = node.position

    cameraNode_:Translate(Vector3((playerPos.x-camPos.x)*0.01, (playerPos.y-camPos.y)*0.01, 0), TS_WORLD)

    local mpos = input:GetMousePosition()
    local np = node.position

    local x = mpos.x / graphics.width
    local y = mpos.y / graphics.height
    local cameraRay = camera_:GetScreenRay(x, y);
    local dist = cameraRay:HitDistance(Plane(Vector3.FORWARD, Vector3.ZERO));
    local wp = cameraRay.origin + cameraRay.direction * dist;

    wp.x = (np.x-wp.x)
    wp.y = (np.y-wp.y)

    --hudText_.text = "\ngw = " .. graphics.width .. ", gh = " .. graphics.height ..
    --    "\nmp: x = " .. mpos.x .. ", y = " .. mpos.y ..
    --    "\nwp: x = " .. wp.x .. ", y = " .. wp.y .. ", z = " .. wp.z ..
    --    "\nnp: x = " .. np.x .. ", y = " .. np.y .. ", z = " .. np.z

    node.rotation = Quaternion(0, 0, -Atan2(wp.x, wp.y))
end

return Player
