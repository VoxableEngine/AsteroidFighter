
local StateManager = require("CoreLib.State.StateManager")

local Arena = require("Objects.Arena")
local Player = require("Objects.Player")
local Laser = require("Objects.Laser")
local AsteroidGenerator = require("Objects.AsteroidGenerator")

local Game = StateManager:CreateState("Game")

local function HandlePostRenderUpdate(eventType, eventData)
    local debug = scene_:GetComponent("DebugRenderer")

    --debug:AddLine(Vector3(-1, 0, -5), Vector3(-0.5, 0, -5), Color(1,0,0))
    --debug:AddLine(Vector3(-1, 0, -5), Vector3(-1, 0.5, -5), Color(0,1,0))

    -- If draw debug mode is enabled, draw physics debug geometry. Use depth test to make the result easier to interpret
    -- Note the convenience accessor to the physics world component
    if drawDebug_ then
        --if playerNode_ ~= nil then
            --print("here")
            --debug:AddBoundingBox(playerNode_:GetComponent("StaticModel").worldBoundingBox, Color(0,1,0))
        --end
        --renderer:DrawDebugGeometry(false)
        scene_:GetComponent("PhysicsWorld2D"):DrawDebugGeometry(true)
    end

    --
    --renderer:DrawDebugGeometry(true)
end

local function HandleKeyDown(eventType, eventData)
    local key = eventData["Key"]:GetInt()
    if key == KEY_ESCAPE then
        StateManager:ToggleAsync("Paused")
    elseif key == KEY_F11 then
        debugHud:ToggleAll()
    elseif key == KEY_F10 then
        drawDebug_ = not drawDebug_
    end
end

function Game:Start()

    SetRandomSeed(time:GetSystemTime())

    local lightNode = scene_:CreateChild("MainLight")
    local light = lightNode:CreateComponent("Light")
    light.lightType = LIGHT_DIRECTIONAL
    light.range = 10.0
    light.color = Color(1.0, 1.0, 1.0)
    light.rotation = Quaternion(21, 59, 2)
    light.lightMask = 1
    self:AddObject("MainLight", lightNode)

    local arenaNode = scene_:CreateChild("Arena")
    arenaNode.position = Vector3(0, 0, 0.2)
    arenaNode.scale = Vector3(20, 1, 20)
    arenaNode:CreateScriptObject("Arena")
    arenaNode.rotation = Quaternion(270, 0, 0)
    self:AddObject("Arena", arenaNode)

    local playerNode = scene_:CreateChild("Player")
    playerNode.position = Vector3(0, 0, 0)
    playerNode:CreateScriptObject("Player")
    self:AddObject("Player", playerNode)

    local musicSource = scene_:CreateComponent("SoundSource")
    musicSource.soundType = SOUND_MUSIC
    self:AddObject("MusicSource", musicSource)

    local music = cache:GetResource("Sound", "Music/Backbeat.ogg")
    music.looped = true
    musicSource:Play(music)

    local asteroidRoot = scene_:CreateChild("AsteroidRoot")
    asteroidRoot:CreateScriptObject("AsteroidGenerator")
    self:AddObject("AsteroidRoot", asteroidRoot)

    local localCam = cameraNode_:GetScriptObject()
    localCam:FollowNode(playerNode)

    SubscribeToEvent("PostRenderUpdate", HandlePostRenderUpdate)
    SubscribeToEvent("KeyDown", HandleKeyDown)
end

function Game:Stop()

    self:ReleaseObjects()
end

return Game
