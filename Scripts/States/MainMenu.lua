
local StateManager = require("CoreLib.State.StateManager")
local Common = require("CoreLib.UI.Common")

local MainMenu = StateManager:CreateState("MainMenu")

function MainMenu:Start()

    local musicSource = scene_:CreateComponent("SoundSource")
    musicSource.soundType = SOUND_MUSIC
    self:AddObject("MusicSource", musicSource)

    local fxSource = scene_:CreateComponent("SoundSource")
    fxSource.soundType = SOUND_EFFECT
    self:AddObject("FXSource", fxSource)

    local music = cache:GetResource("Sound", "Music/Crush.ogg")
    music.looped = true
    musicSource:Play(music)

    -- Create the Window and add it to the UI's root node
    local mainMenu = ui:LoadLayout(cache:GetResource("XMLFile", "UI/MainMenu.xml"))
    mainMenu:SetName("MainMenu")

    self.HandleClickSound = Common.MakeSoundHandler(self, "FXSource", "Sounds/click1.ogg")
    self.HandleHoverSound = Common.MakeSoundHandler(self, "FXSource", "Sounds/rollover1.ogg")

    Common.ButtonEvents(self, mainMenu, "StartButton", "HandleStartReleased", "HandleHoverSound")
    Common.ButtonEvents(self, mainMenu, "JoinButton", "HandleJoinReleased", "HandleHoverSound")
    Common.ButtonEvents(self, mainMenu, "OptionsButton", "HandleOptionsReleased", "HandleHoverSound")
    Common.ButtonEvents(self, mainMenu, "ExitButton", "HandleExitReleased", "HandleHoverSound")

    ui.root:AddChild(mainMenu)
    self:AddObject("MainMenu", mainMenu)

    StateManager:StartAsync("DemoScene")
end

function MainMenu:HandleStartReleased(eventType, eventData)
    self:HandleClickSound(eventType, eventData)
    StateManager:ShowState("Game")
end

function MainMenu:HandleJoinReleased(eventType, eventData)
    self:HandleClickSound(eventType, eventData)
    StateManager:ShowState("Join")
end

function MainMenu:HandleOptionsReleased(eventType, eventData)
    self:HandleClickSound(eventType, eventData)
    StateManager:ShowState("Options")
end

function MainMenu:HandleExitReleased(eventType, eventData)
    self:HandleClickSound(eventType, eventData)
    engine:Exit()
end

function MainMenu:Stop()

    self:ReleaseObjects()
    StateManager:StopAsync("DemoScene")
end

return MainMenu
