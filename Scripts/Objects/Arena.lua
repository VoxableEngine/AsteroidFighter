
Arena = ScriptObject()

function Arena:Start()
    local node = self.node
    local arenaModel = node:CreateComponent("StaticModel")

    arenaModel.lightMask = 2

    arenaModel.model = cache:GetResource("Model", "Models/Plane.mdl")
    arenaModel.material = cache:GetResource("Material", "Materials/DefaultGrey.xml")
    --arenaModel.material = cache:GetResource("Material", "Materials/Green.xml")
end


return Arena
