local _, addon = ...
local L = addon.L

local INCOME_COLOR = { 0.25, 1, 0.25 }
local EXPENSES_COLOR = { 1, 0.25, 0.25 }
local HEADER_COLOR = { 1, 0.82, 0 }
local SOURCE_COLOR = { 0.8, 0.8, 0.8 }
local VALUE_COLOR = { 1, 1, 1 }
local SOURCE_INDENT = "   "

-- Session balance in the bag, on the row of the gold
local bagButton
local bagText
local isAttachedToBaganator = false
-- Baganator money buttons that already add the session to their tooltip
local hookedMoneyButtons = {}

local function AddTooltipLine(label, value, labelColor)
  local lr, lg, lb = unpack(labelColor)
  local vr, vg, vb = unpack(VALUE_COLOR)
  GameTooltip:AddDoubleLine(label, value, lr, lg, lb, vr, vg, vb)
end

local function AddSourceLines(column)
  for _, sourceAmount in ipairs(addon.GetSourceAmounts(column)) do
    AddTooltipLine(SOURCE_INDENT .. sourceAmount.label, addon.FormatMoney(sourceAmount.amount), SOURCE_COLOR)
  end
end

-- Appends the session details to whatever GameTooltip already shows
local function AddSessionLines()
  local session = addon.GetDisplayedSession()
  if not session then return end
  local income, expenses, net = addon.GetLedgerTotals(session)
  local moneyPerHour = addon.GetMoneyPerHour(session)
  AddTooltipLine("Session Gold", addon.FormatDuration(addon.GetSessionDuration(session)), HEADER_COLOR)
  AddTooltipLine(L["Income"], addon.FormatMoney(income), INCOME_COLOR)
  AddSourceLines(session.income)
  AddTooltipLine(L["Expenses"], addon.FormatMoney(expenses), EXPENSES_COLOR)
  AddSourceLines(session.expenses)
  AddTooltipLine(L["Net"], addon.FormatSignedMoney(net), HEADER_COLOR)
  AddTooltipLine(L["Per hour"], moneyPerHour and addon.FormatSignedMoney(moneyPerHour) or "-", HEADER_COLOR)

  GameTooltip:AddLine(" ")
  local _, _, todayNet = addon.GetLedgerTotals(addon.GetTodayLedger())
  AddTooltipLine(L["Today"], addon.FormatSignedMoney(todayNet), HEADER_COLOR)
  local lastSession = addon.data.lastSession
  if not lastSession then return end
  local _, _, lastNet = addon.GetLedgerTotals(lastSession)
  AddTooltipLine(format(L["Last session (%s)"], addon.FormatDuration(addon.GetSessionDuration(lastSession))), addon.FormatSignedMoney(lastNet), HEADER_COLOR)
end

local function ShowBagButtonTooltip()
  GameTooltip:SetOwner(bagButton, "ANCHOR_TOP")
  AddSessionLines()
  GameTooltip:Show()
end

-- Baganator shows the gold of every character when hovering over the money: the session goes below
local function AddSessionToMoneyTooltip()
  if not addon.GetDisplayedSession() then return end
  GameTooltip:AddLine(" ")
  AddSessionLines()
  GameTooltip:Show()
end

local function HookBaganatorMoneyButton(backpackFrame)
  local moneyButton = backpackFrame and backpackFrame.CurrencyWidget and backpackFrame.CurrencyWidget.MoneyButton
  if not moneyButton or hookedMoneyButtons[moneyButton] then return end
  moneyButton:HookScript("OnEnter", AddSessionToMoneyTooltip)
  hookedMoneyButtons[moneyButton] = true
end

-- Its bag frames are named after the current skin and created when the skin loads, so they are looked up every refresh
local function HookBaganatorMoneyButtons()
  local skin = Baganator.API.Skins.GetCurrentSkin()
  for _, framePrefix in ipairs(addon.BAGANATOR_BACKPACK_FRAME_PREFIXES) do HookBaganatorMoneyButton(_G[framePrefix .. skin]) end
end

-- Baganator has an API to add regions to the bottom row of the bag, the row of the gold.
-- It moves the region into the bag frame when laying it out: that bag's money is hooked right then.
local function AttachToBaganator()
  Baganator.API.RegisterRegion("Session Gold", "SessionGold", "backpack", "bottom_left", bagButton)
  hooksecurefunc(bagButton, "SetParent", function(_, backpackFrame) HookBaganatorMoneyButton(backpackFrame) end)
  isAttachedToBaganator = true
end

-- Game's bags: above the gold of the backpack, separate or combined
local function AttachToBlizzardBag(bagFrame)
  local moneyFrame = bagFrame.MoneyFrame or _G[bagFrame:GetName() .. "MoneyFrame"]
  if not moneyFrame then return end
  bagFrame:HookScript("OnShow", function()
    bagButton:SetParent(bagFrame)
    bagButton:ClearAllPoints()
    bagButton:SetPoint("BOTTOMRIGHT", moneyFrame, "TOPRIGHT", 0, addon.BLIZZARD_BAG_OFFSET_Y)
    addon.RefreshDisplay()
  end)
end

function addon.CreateDisplay()
  bagButton = CreateFrame("Button", "SessionGoldBagButton", UIParent)
  bagButton:SetHeight(addon.BAG_BUTTON_HEIGHT)
  bagText = bagButton:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  bagText:SetPoint("LEFT")
  bagButton:RegisterForClicks("RightButtonUp")
  bagButton:SetScript("OnClick", function() addon.OpenOptionsPanel() end)
  bagButton:SetScript("OnEnter", ShowBagButtonTooltip)
  bagButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
  bagButton:Hide()
  C_Timer.NewTicker(addon.DISPLAY_REFRESH_SECONDS, addon.RefreshDisplay)
  if Baganator and Baganator.API and Baganator.API.RegisterRegion then return AttachToBaganator() end
  for _, bagFrameName in ipairs(addon.BLIZZARD_BAG_FRAME_NAMES) do
    if _G[bagFrameName] then AttachToBlizzardBag(_G[bagFrameName]) end
  end
end

function addon.RefreshDisplay()
  if not bagButton then return end
  if isAttachedToBaganator then HookBaganatorMoneyButtons() end
  local session = addon.GetDisplayedSession()
  local wasShown, oldWidth = bagButton:IsShown(), bagButton:GetWidth()
  bagButton:SetShown(session ~= nil and addon.settings.isBagBalanceShown)
  if session then
    local _, _, net = addon.GetLedgerTotals(session)
    bagText:SetText(format(L["Session: %s"], addon.FormatSignedMoney(net)))
    bagButton:SetWidth(bagText:GetStringWidth())
  end
  if GameTooltip:IsOwned(bagButton) then ShowBagButtonTooltip() end
  -- Baganator places its regions only when it lays the bag out
  local hasLayoutChanged = wasShown ~= bagButton:IsShown() or oldWidth ~= bagButton:GetWidth()
  if isAttachedToBaganator and hasLayoutChanged then Baganator.API.RequestLayoutUpdate() end
end
