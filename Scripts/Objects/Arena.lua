
local Boundary = require("Objects.Boundary")

Arena = ScriptObject()

function Arena:Start()
    local node = self.node
    self.bgNode = node:CreateChild("ArenaBackground")
    self.bgNode.position = Vector3(0, 0, 0.2)
    self.bgNode.scale = Vector3(ARENA_SIZE, 1, ARENA_SIZE)
    self.bgNode.rotation = Quaternion(270, 0, 0)

    local bgModel = self.bgNode:CreateComponent("StaticModel")

    bgModel.lightMask = 2
    bgModel.model = cache:GetResource("Model", "Models/Plane.mdl")
    bgModel.material = cache:GetResource("Material", "Materials/StarField.xml")
    --bgModel.material = cache:GetResource("Material", "Materials/Green.xml")

    local sideDist = ARENA_SIZE*0.5-0.25

    local topNode = node:CreateChild("TopBoundary")
    topNode.position = Vector3(0, -sideDist, 0)
    topNode.barrierSize = Vector2(ARENA_SIZE, 0.5)
    topNode:CreateScriptObject("Boundary")

    local bottomNode = node:CreateChild("BottomBoundary")
    bottomNode.position = Vector3(0, sideDist, 0)
    bottomNode.barrierSize = Vector2(ARENA_SIZE, 0.5)
    bottomNode:CreateScriptObject("Boundary")

    local leftNode = node:CreateChild("LeftBoundary")
    leftNode.position = Vector3(-sideDist, 0, 0)
    leftNode.barrierSize = Vector2(0.5, ARENA_SIZE)
    leftNode:CreateScriptObject("Boundary")

    local rightNode = node:CreateChild("RightBoundary")
    rightNode.position = Vector3(sideDist, 0, 0)
    rightNode.barrierSize = Vector2(0.5, ARENA_SIZE)
    rightNode:CreateScriptObject("Boundary")
end

function Arena:Update(timeStep)
    local camPos = cameraNode_.position
    local arenaPos = self.bgNode.position
    self.bgNode.position = Vector3(camPos.x, camPos.y, arenaPos.z)
end

return Arena
