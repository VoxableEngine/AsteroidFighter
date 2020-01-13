
scene_ = nil

local musicSource_ = nil
local fxSource_ = nil
local mainMenu_ = nil

local rot_ = 0.0

function Start()

    scene_ = Scene()
    
    scene_:CreateComponent("Octree")

    -- Create the camera. Set far clip to match the fog. Note: now we actually create the camera node outside
    -- the scene, because we want it to be unaffected by scene load / save
    cameraNode_ = Node()
    local camera = cameraNode_:CreateComponent("Camera")
    
    cameraNode_.position = Vector3(0.0, 0.0, -10.0)
    cameraNode_:LookAt(Vector3(0.0, 0.0, 0.0))
    local camera = cameraNode_:CreateComponent("Camera")
    camera.orthographic = true
    camera.orthoSize = graphics.height * PIXEL_SIZE
    camera.zoom = 1.2 * Min(graphics.width / 1280, graphics.height / 800) -- Set zoom according to user's resolution to ensure full visibility (initial zoom (1.2) is set for full visibility at 1280x800 resolution)
    --camera.farClip = 750.0

    -- Set an initial position for the camera scene node above the floor
    --cameraNode_.position = Vector3(0.0, 0.0, 0.0)

    -- Create a Zone for ambient light & fog control
    local zoneNode = scene_:CreateChild("Zone")
    local zone = zoneNode:CreateComponent("Zone")
    zone.boundingBox = BoundingBox(-1000.0, 1000.0)
    zone.ambientColor = Color(0.15, 0.15, 0.15)
    zone.fogColor = Color(0.2, 0.2, 0.2)
    zone.fogStart = 500.0
    zone.fogEnd = 750.0
    --zone.fogColor = Color(0.151, 0.151, 0.151)
    --zone.fogStart = 5.0
    --zone.fogEnd = 500.0

    -- Create a directional light
    local lightNode = scene_:CreateChild("DirectionalLight")
    lightNode.direction = Vector3(0.0, 0.0, -0.8) -- The direction vector does not need to be normalized
    local light = lightNode:CreateComponent("Light")
    light.lightType = LIGHT_DIRECTIONAL
    light.color = Color(1.0, 1.0, 1.0)
    light.specularIntensity = 0.25



    local viewport = Viewport:new(scene_, cameraNode_:GetComponent("Camera"))
    renderer:SetViewport(0, viewport)


    musicSource_ = scene_:CreateComponent("SoundSource")
    musicSource_.soundType = SOUND_MUSIC
    
    fxSource_ = scene_:CreateComponent("SoundSource")
    fxSource_.soundType = SOUND_EFFECT

    local music = cache:GetResource("Sound", "AsteroidFighter/Music/technogeek.ogg")
    music.looped = true
    musicSource_:Play(music)

    local uiStyle = cache:GetResource("XMLFile", "AsteroidFighter/UI/Styles.xml")
    -- Set style to the UI root so that elements will inherit it
    ui.root.defaultStyle = uiStyle

    -- Create the Window and add it to the UI's root node
    mainMenu_ = ui:LoadLayout(cache:GetResource("XMLFile", "AsteroidFighter/UI/MainMenu.xml"))
    mainMenu_:SetName("MainMenu")

    local startButton = mainMenu_:GetChild("StartButton", true);
    if startButton ~= nil then
        SubscribeToEvent(startButton, "Released", "HandleStartReleased")
        SubscribeToEvent(startButton, "HoverBegin", "HandleHoverSound")
    end
    local networkButton = mainMenu_:GetChild("NetworkButton", true);
    if networkButton ~= nil then
        SubscribeToEvent(networkButton, "Released", "HandleNetworkReleased")
        SubscribeToEvent(networkButton, "HoverBegin", "HandleHoverSound")
    end
    local optionsButton = mainMenu_:GetChild("OptionsButton", true);
    if optionsButton ~= nil then
        SubscribeToEvent(optionsButton, "Released", "HandleOptionsReleased")
        SubscribeToEvent(optionsButton, "HoverBegin", "HandleHoverSound")
    end
    local exitButton = mainMenu_:GetChild("ExitButton", true);
    if exitButton ~= nil then
        SubscribeToEvent(exitButton, "Released", "HandleExitReleased")
        SubscribeToEvent(exitButton, "HoverBegin", "HandleHoverSound")
    end

    ui.root:AddChild(mainMenu_)
    
    CreatePlayer()
    
    SubscribeToEvent("Update", "HandleUpdate")
    SubscribeToEvent("Exit", "HandleExit")
end

function CreatePlayer()

    local numVertices = 3
    local numIndexes = 3
    local vertexData = {
        -- Position          Normal
        0.0, -1.5, 0.0,   0.0, 0.0, 1.0,
        -1.0, 0.5, 0.0,   0.0, 0.0, 1.0,
        1.0, 0.5, 0.0,   0.0, 0.0, 1.0
    }

    local indexData = {
        0, 1, 2
    }

    -- Create model, buffers and geometry without garbage collection, as they will be managed
    -- by the StaticModel component once assigned to it
    local fromScratchModel = Model:new()
    local vb = VertexBuffer:new()
    local ib = IndexBuffer:new()
    local geom = Geometry:new()

    -- Shadowed buffer needed for raycasts to work, and so that data can be automatically restored on device loss
    vb.shadowed = true
    -- We could use the "legacy" element bitmask to define elements for more compact code, but let's demonstrate
    -- defining the vertex elements explicitly to allow any element types and order
    local elements = {
        VertexElement(TYPE_VECTOR3, SEM_POSITION),
        VertexElement(TYPE_VECTOR3, SEM_NORMAL)
    }
    vb:SetSize(numVertices, elements)
    local temp = VectorBuffer()
    for i = 1, numVertices * 6 do
        temp:WriteFloat(vertexData[i])
    end
    vb:SetData(temp)

    ib.shadowed = true
    ib:SetSize(numVertices, false)
    temp:Clear()
    for i = 1, numVertices do
        temp:WriteUShort(indexData[i])
    end
    ib:SetData(temp)

    geom:SetVertexBuffer(0, vb)
    geom:SetIndexBuffer(ib)
    geom:SetDrawRange(TRIANGLE_LIST, 0, numVertices)

    fromScratchModel.numGeometries = 1
    fromScratchModel:SetGeometry(0, 0, geom)
    fromScratchModel.boundingBox = BoundingBox(Vector3(-1.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))

    -- Though not necessary to render, the vertex & index buffers must be listed in the model so that it can be saved properly
    local vertexBuffers = {}
    local indexBuffers = {}
    table.insert(vertexBuffers, vb)
    table.insert(indexBuffers, ib)
    -- Morph ranges could also be not defined. Here we simply define a zero range (no morphing) for the vertex buffer
    local morphRangeStarts = {}
    local morphRangeCounts = {}
    table.insert(morphRangeStarts, 0)
    table.insert(morphRangeCounts, 0)
    fromScratchModel:SetVertexBuffers(vertexBuffers, morphRangeStarts, morphRangeCounts)
    fromScratchModel:SetIndexBuffers(indexBuffers)

    local playerNode = scene_:CreateChild("Player")
    playerNode.position = Vector3(-2.5, 0.0, 0.0)
    playerNode.scale = Vector3(0.3, 0.3, 0.3)
    local playerModel = playerNode:CreateComponent("StaticModel")
    playerModel.model = fromScratchModel
    playerModel.material = cache:GetResource("Material", "AsteroidFighter/Materials/Green.xml")
    
    local enemyNode = scene_:CreateChild("Enemy")
    enemyNode.position = Vector3(2.5, 0.0, 0.0)
    enemyNode.scale = Vector3(0.3, 0.3, 0.3)
    local enemyModel = enemyNode:CreateComponent("StaticModel")
    enemyModel.model = fromScratchModel
    enemyModel.material = cache:GetResource("Material", "AsteroidFighter/Materials/Red.xml")
end

function HandleUpdate(eventType, eventData)
    local timeStep = eventData["TimeStep"]:GetFloat()
    local playerNode = scene_:GetChild("Player")
    local enemyNode = scene_:GetChild("Enemy")
    rot_ = rot_ + timeStep * 125.0
    playerNode:SetRotation(Quaternion(0.0, 0.0, rot_))
    enemyNode:SetRotation(Quaternion(0.0, 0.0, rot_))
end

function HandleStartReleased(eventType, eventData)
  HandleClickSound(eventType, eventData)
end

function HandleNetworkReleased(eventType, eventData)
  HandleClickSound(eventType, eventData)
end

function HandleOptionsReleased(eventType, eventData)
  HandleClickSound(eventType, eventData)
end

function HandleExitReleased(eventType, eventData)
  HandleClickSound(eventType, eventData)
  engine:Exit()
end

function HandleClickSound(eventType, eventData)
    local fx = cache:GetResource("Sound", "Sounds/click1.ogg")
    fxSource_:Play(fx)
end

function HandleHoverSound(eventType, eventData)
    local fx = cache:GetResource("Sound", "Sounds/rollover1.ogg")
    fxSource_:Play(fx)
end

function HandleExit(eventType, eventData)
    log.Write(1, "here")
    scene_:RemoveAllChildren()
end
--function HandlePostRenderUpdate(eventType, eventData)

--end