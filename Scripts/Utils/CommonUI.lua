
local CommonUI = {}

function CommonUI.ButtonEvents(state, element, buttonName, clickMethod, hoverMethod)
    local button = element:GetChild(buttonName, true)
    if button ~= nil then
        state:SubscribeToEvent(button, "Released", clickMethod)
        state:SubscribeToEvent(button, "HoverBegin", hoverMethod)
    end
end

return CommonUI
