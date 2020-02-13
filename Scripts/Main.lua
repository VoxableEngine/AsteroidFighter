
scene_ = nil
cameraNode_ = nil
drawDebug_ = false
gamePaused_ = false

categories_ = {
    BOUNDARY            = 1,
    ASTEROID            = 2,
    FRIENDLY_SHIP       = 4,
    ENEMY_SHIP          = 8,
    FRIENDLY_PROJECTILE = 16,
    ENEMY_PROJECTILE    = 32
}

MIN_ASTEROIDS = 8
ARENA_SIZE = 20

--local SceneManager = require("CoreLib.Scene.SceneManager")
local StateManager = require("CoreLib.State.StateManager")

--local AsteroidGenerator = require("Utils.AsteroidGenerator")
local LocalCamera = require("Objects.LocalCamera")

function Start()

    scene_ = Scene()
    scene_:CreateComponent("Octree")

    -- -- Create the camera. Set far clip to match the fog.
    cameraNode_ = scene_:CreateChild("LocalCamera") --Node()

    -- Create LocalCamera script object to manage the player's local camera
    local localCam = cameraNode_:CreateScriptObject("LocalCamera")
    localCam:DefaultPosition()

    -- Create a Zone for ambient light & fog control
    local zoneNode = scene_:CreateChild("Zone")
    local zone = zoneNode:CreateComponent("Zone")
    zone.boundingBox = BoundingBox(-250.0, 250.0)
    zone.ambientColor = Color(0.001, 0.001, 0.001)
    zone.fogColor = Color(0.01, 0.01, 0.01)
    zone.fogStart = 1.0
    zone.fogEnd = 80.0

    --renderer.numViewports = 2

    local viewport = Viewport:new(scene_, cameraNode_:GetComponent("Camera"))
    renderer:SetViewport(0, viewport)

    -- Set up the rear camera viewport on top of the front view ("rear view mirror")
    -- The viewport index must be greater in that case, otherwise the view would be left behind
    --local radarViewport = Viewport:new(scene_, radar_,
    --    IntRect(graphics.width * 2 / 3, graphics.height-graphics.height/3, graphics.width - 32, graphics.height))
    --renderer:SetViewport(1, radarViewport)

    local world = scene_:CreateComponent("PhysicsWorld2D")
    world:SetGravity(Vector2(0, 0))
    world:SetDrawShape(true)
    scene_:CreateComponent("DebugRenderer")

    -- Set style to the UI root so that elements will inherit it
    local uiStyle = cache:GetResource("XMLFile", "UI/BaseStyle.xml")
    ui.root.defaultStyle = uiStyle

    StateManager:Init()
    StateManager:ShowState("MainMenu")

    --engine:CreateDebugHud()
    --local uiStyle = cache:GetResource("XMLFile", "UI/Styles.xml")
    --debugHud.defaultStyle = uiStyle

    -- local effectRenderPath = viewport:GetRenderPath():Clone()
    -- effectRenderPath:Append(cache:GetResource("XMLFile", "PostProcess/VolumeScatter.xml"))
    -- -- Make the bloom mixing parameter more pronounced
    -- --effectRenderPath:SetShaderParameter("BloomMix", Variant(Vector2(0.9, 0.6)))
    -- effectRenderPath:SetEnabled("VolumeScatter", true)
    -- viewport:SetRenderPath(effectRenderPath)
end
