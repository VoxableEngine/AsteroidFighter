
local StateManager = require("CoreLib.State.StateManager")

local Arena = require("Objects.Arena")
local AsteroidGenerator = require("Objects.AsteroidGenerator")

local DemoScene = StateManager:CreateAsyncState("DemoScene")

function DemoScene:Start()

    local localCam = cameraNode_:GetScriptObject()
    localCam:NoFollow()
    localCam:DefaultPosition()

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

    local asteroidRoot = scene_:CreateChild("AsteroidRoot")
    asteroidRoot.isDemoScene = true
    asteroidRoot:CreateScriptObject("AsteroidGenerator")
    self:AddObject("AsteroidRoot", asteroidRoot)

    local titleNode = scene_:CreateChild("TitleNode")
    titleNode.position = Vector3(0, 1.5, -2)
    titleNode.rotation = Quaternion(0, 180, 0)
    local titleModel = titleNode:CreateComponent("StaticModel")
    titleModel.model = cache:GetResource("Model", "Models/Title.mdl")
    titleModel.material = cache:GetResource("Material", "Materials/Green.xml")
    self:AddObject("TitleNode", titleNode)
end

function DemoScene:Stop()

    self:ReleaseObjects()
end

return DemoScene
