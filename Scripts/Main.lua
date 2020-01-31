
local StateManager = require("CoreLib.State.StateManager")

scene_ = nil
cameraNode_ = nil
camera_ = nil

function Start()

    scene_ = Scene()

    scene_:CreateComponent("Octree")

    -- -- Create the camera. Set far clip to match the fog. Note: now we actually create the camera node outside
    -- -- the scene, because we want it to be unaffected by scene load / save
    cameraNode_ = Node()
    cameraNode_.position = Vector3(0.0, 0.0, -10.0)
    cameraNode_:LookAt(Vector3(0.0, 0.0, 0.0))
    camera_ = cameraNode_:CreateComponent("Camera")
    --camera_.orthographic = true
    --camera_.orthoSize = graphics.height * PIXEL_SIZE
    camera_.zoom = 1.2 * Min(graphics.width / 1280, graphics.height / 800) -- Set zoom according to user's resolution to ensure full visibility (initial zoom (1.2) is set for full visibility at 1280x800 resolution)
    --camera.farClip = 750.0

    -- Set an initial position for the camera scene node above the floor
    --cameraNode_.position = Vector3(0.0, 0.0, 0.0)

    -- Create a Zone for ambient light & fog control
    local zoneNode = scene_:CreateChild("Zone")
    local zone = zoneNode:CreateComponent("Zone")
    zone.boundingBox = BoundingBox(-250.0, 250.0)
    zone.ambientColor = Color(0.001, 0.001, 0.001)
    zone.fogColor = Color(0.01, 0.01, 0.01)
    zone.fogStart = 5.0
    zone.fogEnd = 40.0

    local viewport = Viewport:new(scene_, cameraNode_:GetComponent("Camera"))
    renderer:SetViewport(0, viewport)

    StateManager:Init()
    StateManager:ShowState("MainMenu")

    --engine:CreateDebugHud()
    --local uiStyle = cache:GetResource("XMLFile", "UI/Styles.xml")
    --debugHud.defaultStyle = uiStyle
    scene_:CreateComponent("DebugRenderer")

    -- local effectRenderPath = viewport:GetRenderPath():Clone()
    -- effectRenderPath:Append(cache:GetResource("XMLFile", "PostProcess/VolumeScatter.xml"))
    -- -- Make the bloom mixing parameter more pronounced
    -- --effectRenderPath:SetShaderParameter("BloomMix", Variant(Vector2(0.9, 0.6)))
    -- effectRenderPath:SetEnabled("VolumeScatter", true)
    -- viewport:SetRenderPath(effectRenderPath)
end
