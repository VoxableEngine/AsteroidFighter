
LocalCamera = ScriptObject()

--local camera_ = nil
--local followNode_ = nil

local DEFAULT_FOLLOW_FACTOR = 0.01

function LocalCamera:Start()
    --cameraNode_ = self.node
    self.camera = self.node:CreateComponent("Camera")
    --camera_.orthographic = true
    --camera_.orthoSize = graphics.height * PIXEL_SIZE
    self.camera.zoom = 1 * Min(graphics.width / 1280, graphics.height / 800) -- Set zoom according to user's resolution to ensure full visibility (initial zoom (1.2) is set for full visibility at 1280x800 resolution)
    self.camera.farClip = 750.0

    self.followNode = nil
    self.followFactor = DEFAULT_FOLLOW_FACTOR
end

function LocalCamera:GetCrosshairRotation(mouseX, mouseY)

    if self.followNode == nil then return Quaternion() end

    local camPos = self.node.position
    local playerPos = self.followNode.position

    local x = mouseX / graphics.width
    local y = mouseY / graphics.height
    local cameraRay = self.camera:GetScreenRay(x, y);
    local dist = cameraRay:HitDistance(Plane(Vector3.FORWARD, Vector3.ZERO));
    local worldPos = cameraRay.origin + cameraRay.direction * dist;

    worldPos.x = (playerPos.x-worldPos.x)
    worldPos.y = (playerPos.y-worldPos.y)

    return Quaternion(0, 0, -Atan2(worldPos.x, worldPos.y))
end

function LocalCamera:DefaultPosition()
    self.node.position = Vector3(0.0, 0.0, -10.0)
    self.node:LookAt(Vector3(0.0, 0.0, 0.0))
end

function LocalCamera:FollowNode(node, factor)
    if tolua.type(node) == "Node" then
        self.followNode = node
        self.followFactor = factor or DEFAULT_FOLLOW_FACTOR
    else
        error("Invalid node to follow")
    end
end

function LocalCamera:NoFollow()
    self.followNode = nil
end

function LocalCamera:Update(timeStep)
    if self.followNode ~= nil then
        local camPos = self.node.position
        local playerPos = self.followNode.position
        local followFactor = self.followFactor
        cameraNode_:Translate(Vector3((playerPos.x-camPos.x)*followFactor, (playerPos.y-camPos.y)*followFactor, 0), TS_WORLD)
    end
end

return LocalCamera
