local _, addon = ...
local L = addon.L

-- Widgets are built by hand (no option templates) so they keep working across Classic client versions
local PANEL_MARGIN = 16
local ROW_HEIGHT = 30
local BUTTON_GAP = 8

local panel
local settingsCategory
-- Functions that copy the saved settings into the widgets
local widgetRefreshers = {}

local function CreateLabel(parent, text, fontObject)
  local label = parent:CreateFontString(nil, "ARTWORK", fontObject or "GameFontHighlight")
  label:SetText(text)
  label:SetJustifyH("LEFT")
  return label
end

local function CreateCheckbox(parent, settingKey, text, y)
  local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  checkbox:SetPoint("TOPLEFT", PANEL_MARGIN, y)
  local label = CreateLabel(checkbox, text)
  label:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
  checkbox:SetScript("OnClick", function(self)
    addon.settings[settingKey] = self:GetChecked()
    addon.RefreshDisplay()
  end)
  widgetRefreshers[#widgetRefreshers + 1] = function() checkbox:SetChecked(addon.settings[settingKey]) end
  return checkbox
end

local function CreateButton(parent, text, onClick)
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetText(text)
  button:SetSize(math.max(90, button:GetFontString():GetStringWidth() + 24), 22)
  button:SetScript("OnClick", onClick)
  return button
end

function addon.CreateOptionsPanel()
  panel = CreateFrame("Frame")
  panel.name = "Session Gold"
  local title = CreateLabel(panel, "Session Gold", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", PANEL_MARGIN, -PANEL_MARGIN)
  local description = CreateLabel(panel, L["Counts the gold you make and spend since you log in, by source. Hover over your gold in the bags for the details."])
  description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

  local y = -70
  CreateCheckbox(panel, "isBagBalanceShown", L["Show the session balance in the bags, next to the gold"], y)
  CreateCheckbox(panel, "isLoginSummaryShown", L["Print the last session summary in the chat when logging in"], y - ROW_HEIGHT)

  local testButton = CreateButton(panel, L["Test"], addon.StartTest)
  testButton:SetPoint("TOPLEFT", PANEL_MARGIN, y - ROW_HEIGHT * 3)
  local resetSessionButton = CreateButton(panel, L["Start a new session"], addon.ResetSession)
  resetSessionButton:SetPoint("LEFT", testButton, "RIGHT", BUTTON_GAP, 0)

  panel:SetScript("OnShow", addon.RefreshOptionsPanel)
  if Settings and Settings.RegisterCanvasLayoutCategory then
    settingsCategory = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(settingsCategory)
  elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
  end
end

function addon.RefreshOptionsPanel()
  if not panel then return end
  for _, refreshWidget in ipairs(widgetRefreshers) do refreshWidget() end
end

function addon.OpenOptionsPanel()
  if settingsCategory then return Settings.OpenToCategory(settingsCategory:GetID()) end
  InterfaceOptionsFrame_OpenToCategory(panel)
end
