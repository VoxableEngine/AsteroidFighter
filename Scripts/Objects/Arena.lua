
Arena = ScriptObject()

function Arena:Start()
    local node = self.node
    local arenaModel = node:CreateComponent("StaticModel")

    arenaModel.lightMask = 2

    arenaModel.model = cache:GetResource("Model", "Models/Plane.mdl")
    arenaModel.material = cache:GetResource("Material", "Materials/StarField.xml")
    --arenaModel.material = cache:GetResource("Material", "Materials/Green.xml")
end

function Arena:Update(timeStep)
    local camPos = cameraNode_.position
    local arenaPos = self.node.position
    self.node.position = Vector3(camPos.x, camPos.y, arenaPos.z)
end

return Arena
