Boundary = ScriptObject()

function Boundary:Start()
    local node = self.node
    local boundaryModel = node:CreateComponent("StaticModel")

    boundaryModel.lightMask = 2

    boundaryModel.model = cache:GetResource("Model", "Models/Plane.mdl")
    boundaryModel.material = cache:GetResource("Material", "Materials/Green.xml")
    --arenaModel.material = cache:GetResource("Material", "Materials/Green.xml")
end

-- function Arena:Update(timeStep)
--     local camPos = cameraNode_.position
--     local arenaPos = self.node.position
--     self.node.position = Vector3(camPos.x, camPos.y, arenaPos.z)
-- end

return Arena
