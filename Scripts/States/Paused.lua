
local StateManager = require("CoreLib.State.StateManager")
local Common = require("CoreLib.UI.Common")

local Paused = StateManager:CreateAsyncState("Paused")

function Paused:HandleResumeReleased(eventType, eventData)
    --HandleClickSound(eventType, eventData)
    StateManager:StopAsync("Paused")
end

function Paused:HandleExitReleased(eventType, eventData)
    --HandleClickSound(eventType, eventData)
    engine:Exit()
end

function Paused:Start()

    scene_.updateEnabled = false
    scene_:GetComponent("PhysicsWorld2D"):SetUpdateEnabled(false)
    gamePaused_ = true

    local fxSource = scene_:CreateComponent("SoundSource")
    fxSource.soundType = SOUND_EFFECT
    self:AddObject("FXSource", fxSource)

    local window = ui.root:CreateChild("Window", "PauseWindow")
    window:SetStyleAuto()
    window:SetMinSize(graphics.width/3, graphics.height/3)
    window:SetMaxSize(graphics.width/3, graphics.height/3)
    window:SetAlignment(HA_CENTER, VA_CENTER)
    window.layoutMode = LM_VERTICAL
    self:AddObject("PauseWindow", window)

    self.HandleClickSound = Common.MakeSoundHandler(self, "FXSource", "Sounds/click1.ogg")
    self.HandleHoverSound = Common.MakeSoundHandler(self, "FXSource", "Sounds/rollover1.ogg")

    local resumeButton = window:CreateChild("Button", "ResumeButton")
    resumeButton:SetStyleAuto()
    resumeButton:SetMinSize(250, 80)
    resumeButton:SetMaxSize(250, 80)
    resumeButton:SetAlignment(HA_CENTER, VA_TOP)
    local resumeText = resumeButton:CreateChild("Text", "ResumeText")
    resumeText:SetStyleAuto()
    resumeText.minAnchor = Vector2(0.5, 0.5)
    resumeText.maxAnchor = Vector2(0.5, 0.5)
    resumeText.pivot = Vector2(0.5, 0.5)
    resumeText:SetEnableAnchor(true)
    resumeText.text = "Resume"
    Common.ButtonEvents(self, window, "ResumeButton", "HandleResumeReleased", "HandleHoverSound")

    local exitButton = window:CreateChild("Button", "ExitButton")
    exitButton:SetStyleAuto()
    exitButton:SetMinSize(250, 80)
    exitButton:SetMaxSize(250, 80)
    exitButton:SetAlignment(HA_CENTER, VA_TOP)
    local exitText = exitButton:CreateChild("Text", "ExitText")
    exitText:SetStyleAuto()
    exitText.minAnchor = Vector2(0.5, 0.5)
    exitText.maxAnchor = Vector2(0.5, 0.5)
    exitText.pivot = Vector2(0.5, 0.5)
    exitText:SetEnableAnchor(true)
    exitText.text = "Exit"
    Common.ButtonEvents(self, window, "ExitButton", "HandleExitReleased", "HandleHoverSound")

end

-- function Paused:HandleClickSound(eventType, eventData)

--     local fx = cache:GetResource("Sound", "Sounds/click1.ogg")
--     self:GetObject("FXSource"):Play(fx)
-- end

function Paused:HandleResumeReleased(eventType, eventData)

    self:HandleClickSound(eventType, eventData)
    StateManager:StopAsync("Paused")
end

function Paused:HandleExitReleased(eventType, eventData)

    self:HandleClickSound(eventType, eventData)
    engine:Exit()
end

-- function Paused:HandleHoverSound(eventType, eventData)

--     local fx = cache:GetResource("Sound", "Sounds/rollover1.ogg")
--     self:GetObject("FXSource"):Play(fx)
-- end

function Paused:Stop()

    self:ReleaseObjects()
    scene_.updateEnabled = true
    scene_:GetComponent("PhysicsWorld2D"):SetUpdateEnabled(true)
    gamePaused_ = false
end

return Paused
