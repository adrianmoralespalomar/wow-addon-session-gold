local addonName, addon = ...
local L = addon.L

local eventFrame = CreateFrame("Frame")

local function LoadSavedVariables()
  SessionGoldDB = SessionGoldDB or {}
  for key, value in pairs(addon.DEFAULT_SETTINGS) do
    if SessionGoldDB[key] == nil then SessionGoldDB[key] = value end
  end
  addon.settings = SessionGoldDB
  SessionGoldCharDB = SessionGoldCharDB or {}
  SessionGoldCharDB.days = SessionGoldCharDB.days or {}
  addon.data = SessionGoldCharDB
end

-- An event the client does not have would raise an error: that source then simply counts as other
local function RegisterEventIfExists(event) return pcall(eventFrame.RegisterEvent, eventFrame, event) end

-- A window is only followed if its closing can be seen too: otherwise its source would stay active forever
local function RegisterContextWindowEvents()
  local closeEventsBySource = {}
  for event, source in pairs(addon.CONTEXT_CLOSE_EVENTS) do closeEventsBySource[source] = event end
  for openEvent, source in pairs(addon.CONTEXT_OPEN_EVENTS) do
    if RegisterEventIfExists(closeEventsBySource[source]) then RegisterEventIfExists(openEvent) end
  end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_MONEY")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
RegisterContextWindowEvents()
for event in pairs(addon.CONTEXT_PULSE_EVENTS) do RegisterEventIfExists(event) end
eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" then
    if ... ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    LoadSavedVariables()
    addon.HookRepairs()
    addon.CreateOptionsPanel()
    addon.CreateDisplay()
  elseif event == "PLAYER_ENTERING_WORLD" then
    addon.OnPlayerEnteringWorld(...)
    addon.RefreshDisplay()
  elseif event == "PLAYER_MONEY" then
    addon.OnPlayerMoneyChanged()
    addon.RefreshDisplay()
  elseif event == "PLAYER_LOGOUT" then
    addon.OnPlayerLogout()
  elseif addon.CONTEXT_OPEN_EVENTS[event] then
    addon.OpenContext(addon.CONTEXT_OPEN_EVENTS[event])
  else
    addon.MarkContextRecent(addon.CONTEXT_CLOSE_EVENTS[event] or addon.CONTEXT_PULSE_EVENTS[event])
  end
end)

local SLASH_COMMAND_HANDLERS = {
  [""] = function() addon.OpenOptionsPanel() end,
  show = function() addon.PrintSessionSummary(addon.GetDisplayedSession(), L["This session"]) end,
  reset = addon.ResetSession,
  test = addon.StartTest,
}

SLASH_SESSIONGOLD1 = "/sgold"
SLASH_SESSIONGOLD2 = "/sessiongold"
SlashCmdList.SESSIONGOLD = function(message)
  local handler = SLASH_COMMAND_HANDLERS[strlower(strtrim(message or ""))]
  if handler then return handler() end
  print(addon.CHAT_PREFIX .. L["Commands: /sgold (options), /sgold show, /sgold reset, /sgold test"])
end
