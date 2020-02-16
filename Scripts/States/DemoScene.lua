
local StateManager = require("CoreLib.State.StateManager")

local Arena = require("Objects.Arena")
local AsteroidGenerator = require("Objects.AsteroidGenerator")

local DemoScene = StateManager:CreateAsyncState("DemoScene")

function DemoScene:Start()

    local localCam = cameraNode_:GetScriptObject()
    localCam:NoFollow()
    localCam:DefaultPosition()

    local lightNode = scene_:CreateChild("MainLight")
    self:AddObject("MainLight", lightNode)
    local light = lightNode:CreateComponent("Light")
    light.lightType = LIGHT_DIRECTIONAL
    light.range = 10.0
    light.color = Color(1.0, 1.0, 1.0)
    light.rotation = Quaternion(21, 59, 2)
    light.lightMask = 1

    local arenaNode = scene_:CreateChild("Arena")
    self:AddObject("Arena", arenaNode)
    arenaNode:CreateScriptObject("Arena")

    local asteroidRoot = scene_:CreateChild("AsteroidRoot")
    self:AddObject("AsteroidRoot", asteroidRoot)
    local generator = asteroidRoot:CreateScriptObject("AsteroidGenerator")
    generator:GenerateSets()

    local titleNode = scene_:CreateChild("TitleNode")
    self:AddObject("TitleNode", titleNode)

    titleNode.position = Vector3(0, 1.5, -2)
    titleNode.rotation = Quaternion(0, 180, 0)
    local titleModel = titleNode:CreateComponent("StaticModel")
    titleModel.model = cache:GetResource("Model", "Models/Title.mdl")
    titleModel.material = cache:GetResource("Material", "Materials/Green.xml")
end

function DemoScene:Stop()

    self:ReleaseObjects()
end

return DemoScene
