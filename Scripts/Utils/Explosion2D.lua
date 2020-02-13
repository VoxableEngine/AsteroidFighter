
--local Class = require("CoreLib.SimpleLuaClasses.Class")

local Explosion2D = {}

function Explosion2D.Impulse(world, hitTag, startPoint, blastRadius, blastPower, numRays, singleResult)

    -- local numRays = 30
    -- local startPoint = contacts[1].position
    -- local blastRadius = 8
    -- local blastPower = 20

    if singleResult == nil then
        singleResult = false
    end

    local rayPower = blastPower / numRays

    for i = 1, numRays, 1 do
        local angle = (i / numRays) * 360
        local rayDir = Vector2( Sin(angle), Cos(angle) )
        local endPoint = startPoint + rayDir * blastRadius

        --check what this ray hits
        --RayCastClosestCallback callback;//basic callback to record body and hit point
        --local world = scene_:GetComponent("PhysicsWorld2D")

        if singleResult then
            local result = world:RaycastSingle(startPoint, endPoint)
            local impulse = result.position - startPoint
            impulse:Normalize()
            if result.body ~= nil and result.body.node:HasTag(hitTag) then
                result.body:ApplyLinearImpulse(impulse*rayPower, startPoint, true)
            end
        else
            local results = world:Raycast(startPoint, endPoint)
            for rIndex, result in ipairs(results) do
                local impulse = result.position - startPoint
                impulse:Normalize()
                if result.body ~= nil and result.body.node:HasTag(hitTag) then
                    result.body:ApplyLinearImpulse(impulse*rayPower, startPoint, true)
                end
            end
        end
    end
end

return Explosion2D
