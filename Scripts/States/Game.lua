local StateManager = require("CoreLib.State.StateManager")
local Arena = require("Objects.Arena")
local Player = require("Objects.Player")
local Laser = require("Objects.Laser")

local Game = StateManager:CreateState("Game")

local lightNode_ = nil
local playerNode_ = nil
local arenaNode_ = nil

local function HandlePostRenderUpdate(eventType, eventData)
    local debug = scene_:GetComponent("DebugRenderer")

    --debug:AddLine(Vector3(-1, 0, -5), Vector3(-0.5, 0, -5), Color(1,0,0))
    --debug:AddLine(Vector3(-1, 0, -5), Vector3(-1, 0.5, -5), Color(0,1,0))

    -- If draw debug mode is enabled, draw physics debug geometry. Use depth test to make the result easier to interpret
    -- Note the convenience accessor to the physics world component
    --if drawDebug then
        if playerNode_ ~= nil then
            --print("here")
            --debug:AddBoundingBox(playerNode_:GetComponent("StaticModel").worldBoundingBox, Color(0,1,0))
        end
        --renderer:DrawDebugGeometry(false)
    --end
end

function Game:Start()

    -- local lightNode = scene_:CreateChild("MainLight")
    -- lightNode.direction = Vector3.FORWARD -- Vector3(-0.8, 0.0, -0.8) -- The direction vector does not need to be normalized
    -- --lightNode_.position = Vector3(0.0, 0.0, -10.0)
    -- local light = lightNode:CreateComponent("Light")
    -- light.position = Vector3(-1.0, -1.0, -5.0)
    -- light.lightType = LIGHT_DIRECTIONAL
    -- light.color = Color(1.0, 1.0, 1.0)
    -- light.specularIntensity = 1.25

    -- local lightNode = scene_:CreateChild("MainLight")
    -- local light = lightNode:CreateComponent("Light")
    -- light.lightType = LIGHT_POINT
    -- light.range = 20.0
    -- light.color = Color(1.0, 1.0, 1.0)
    -- light.position = Vector3(0.0, 0.0, 0.0)

    local lightNode = scene_:CreateChild("MainLight")
    local light = lightNode:CreateComponent("Light")
    light.lightType = LIGHT_DIRECTIONAL
    light.range = 10.0
    light.color = Color(1.0, 1.0, 1.0)
    light.rotation = Quaternion(21, 59, 2)
    light.lightMask = 1

    --light.position = Vector3(0.0, 0.0, 0.0)

    arenaNode_ = scene_:CreateChild("Arena")
    arenaNode_.position = Vector3(0, 0, 0.2)
    arenaNode_.scale = Vector3(20, 1, 20)
    arenaNode_:CreateScriptObject("Arena")
    arenaNode_.rotation = Quaternion(270, 0, 0)


    playerNode_ = scene_:CreateChild("Player")
    playerNode_.position = Vector3(0, 0, 0)
    playerNode_.scale = Vector3(0.2, 0.2, 0.2)
    playerNode_:CreateScriptObject("Player")
    --playerNode_.lightMask = 1
    SubscribeToEvent("PostRenderUpdate", HandlePostRenderUpdate)
end

function Game:Stop()
    playerNode_:Remove()
    playerNode_ = nil

    arenaNode_:Remove()
    arenaNode_ = nil
end

return Game