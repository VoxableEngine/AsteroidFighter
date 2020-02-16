
Boundary = ScriptObject()

local collisionCategory_ = categories_.BOUNDARY

local collisionMask_ = bit.bor(
    categories_.ASTEROID,
    categories_.FRIENDLY_SHIP,
    categories_.FRIENDLY_PROJECTILE,
    categories_.ENEMY_SHIP,
    categories_.ENEMY_PROJECTILE
)

function Boundary:Start()
    local node = self.node

    local modelNode = node:CreateChild("ModelNode")
    modelNode.scale = Vector3(node.barrierSize.x, 1, node.barrierSize.y)
    modelNode.rotation = Quaternion(270, 0, 0)
    local boundaryModel = modelNode:CreateComponent("StaticModel")

    boundaryModel.lightMask = 2

    boundaryModel.model = cache:GetResource("Model", "Models/Plane.mdl")
    boundaryModel.material = cache:GetResource("Material", "Materials/Green.xml")
    --arenaModel.material = cache:GetResource("Material", "Materials/Green.xml")

    --node.scale = Vector3(node.barrierSize.x, node.barrierSize.y, 1)

    local body = node:CreateComponent("RigidBody2D")
    body.bodyType = BT_STATIC


    local shape = node:CreateComponent("CollisionBox2D")
    shape.size = Vector2(node.barrierSize.x, node.barrierSize.y)
    shape.density = 2.0
    shape.friction = 0.5
    shape.restitution = 1.0
    shape:SetCategoryBits(collisionCategory_)
    shape:SetMaskBits(collisionMask_)

end

-- function Boundary:Update(timeStep)
-- end

return Arena
