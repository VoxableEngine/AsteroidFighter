
local StateManager = require("CoreLib.State.StateManager")
local MainMenu = StateManager:CreateState("MainMenu")

local musicSource_ = nil
local fxSource_ = nil
local mainMenu_ = nil

local function HandleClickSound(eventType, eventData)
    local fx = cache:GetResource("Sound", "Sounds/click1.ogg")
    fxSource_:Play(fx)
end

local function HandleStartReleased(eventType, eventData)
    HandleClickSound(eventType, eventData)
    StateManager:ShowState("Game")
end

local function HandleNetworkReleased(eventType, eventData)
    HandleClickSound(eventType, eventData)
end

local function HandleOptionsReleased(eventType, eventData)
    HandleClickSound(eventType, eventData)
end

local function HandleExitReleased(eventType, eventData)
    HandleClickSound(eventType, eventData)
    engine:Exit()
end

local function HandleHoverSound(eventType, eventData)
    local fx = cache:GetResource("Sound", "Sounds/rollover1.ogg")
    fxSource_:Play(fx)
  end

local function HandleExit(eventType, eventData)
    scene_:RemoveAllChildren()
end

function MainMenu:Start()

    musicSource_ = scene_:CreateComponent("SoundSource")
    musicSource_.soundType = SOUND_MUSIC

    fxSource_ = scene_:CreateComponent("SoundSource")
    fxSource_.soundType = SOUND_EFFECT

    local music = cache:GetResource("Sound", "Music/Crush.ogg")
    music.looped = true
    musicSource_:Play(music)

    local uiStyle = cache:GetResource("XMLFile", "UI/Styles.xml")
    -- Set style to the UI root so that elements will inherit it
    ui.root.defaultStyle = uiStyle

    -- Create the Window and add it to the UI's root node
    mainMenu_ = ui:LoadLayout(cache:GetResource("XMLFile", "UI/MainMenu.xml"))
    mainMenu_:SetName("MainMenu")

    local startButton = mainMenu_:GetChild("StartButton", true);
    if startButton ~= nil then
        SubscribeToEvent(startButton, "Released", HandleStartReleased)
        SubscribeToEvent(startButton, "HoverBegin", HandleHoverSound)
    end
    local networkButton = mainMenu_:GetChild("NetworkButton", true);
    if networkButton ~= nil then
        SubscribeToEvent(networkButton, "Released", HandleNetworkReleased)
        SubscribeToEvent(networkButton, "HoverBegin", HandleHoverSound)
    end
    local optionsButton = mainMenu_:GetChild("OptionsButton", true);
    if optionsButton ~= nil then
        SubscribeToEvent(optionsButton, "Released", HandleOptionsReleased)
        SubscribeToEvent(optionsButton, "HoverBegin", HandleHoverSound)
    end
    local exitButton = mainMenu_:GetChild("ExitButton", true);
    if exitButton ~= nil then
        SubscribeToEvent(exitButton, "Released", HandleExitReleased)
        SubscribeToEvent(exitButton, "HoverBegin", HandleHoverSound)
    end

    ui.root:AddChild(mainMenu_)
end

function MainMenu:Stop()
    musicSource_:Remove()
    musicSource_ = nil
    fxSource_:Remove()
    fxSource_ = nil
    mainMenu_:Remove()
    mainMenu_ = nil
end

return MainMenu
