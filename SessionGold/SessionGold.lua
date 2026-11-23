local _, addon = ...
local L = addon.L

local SECONDS_PER_HOUR = 3600
local SECONDS_PER_DAY = 86400
local POSITIVE_COLOR_CODE = "|cff40ff40"
local NEGATIVE_COLOR_CODE = "|cffff4040"
local ZERO_MONEY_TEXT = "0|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"

-- Until when each source explains a money change: math.huge while its window is open
local contextActiveUntil = {}
-- A money change with no source yet, in case the event that explains it comes right after
local lastUnexplainedChange
-- False until PLAYER_ENTERING_WORLD: money events before it do not count
local isSessionActive = false
local testTimer

-- A ledger holds copper per source, income and expenses apart (both positive): the session and each day are one
local function CreateEmptyLedger() return { income = {}, expenses = {} } end

local function GetTodayKey() return date("%Y-%m-%d") end

local function SumValues(values)
  local total = 0
  for _, value in pairs(values) do total = total + value end
  return total
end

function addon.GetLedgerTotals(ledger)
  local income, expenses = SumValues(ledger.income), SumValues(ledger.expenses)
  return income, expenses, income - expenses
end

function addon.GetSessionDuration(session) return (session.endTime or time()) - session.startTime end

function addon.GetMoneyPerHour(session)
  local duration = addon.GetSessionDuration(session)
  if duration < addon.MIN_SECONDS_FOR_RATE then return nil end
  local _, _, net = addon.GetLedgerTotals(session)
  return math.floor(net * SECONDS_PER_HOUR / duration)
end

-- { label, amount } of a ledger column in display order, without the empty sources
function addon.GetSourceAmounts(column)
  local sourceAmounts = {}
  for _, source in ipairs(addon.SOURCE_KEYS) do
    if (column[source] or 0) > 0 then sourceAmounts[#sourceAmounts + 1] = { label = addon.SOURCE_LABELS[source], amount = column[source] } end
  end
  return sourceAmounts
end

-- GetCoinTextureString does not exist in this client; GetMoneyString does (Baganator uses it)
function addon.FormatMoney(copper)
  if copper == 0 then return ZERO_MONEY_TEXT end
  return GetMoneyString(math.abs(copper), true)
end

function addon.FormatSignedMoney(copper)
  if copper > 0 then return POSITIVE_COLOR_CODE .. "+|r" .. addon.FormatMoney(copper) end
  if copper < 0 then return NEGATIVE_COLOR_CODE .. "-|r" .. addon.FormatMoney(copper) end
  return addon.FormatMoney(copper)
end

function addon.FormatDuration(seconds)
  local hours, minutes = math.floor(seconds / SECONDS_PER_HOUR), math.floor(seconds % SECONDS_PER_HOUR / 60)
  if hours > 0 then return format(L["%dh %dm"], hours, minutes) end
  return format(L["%dm"], minutes)
end

local function GetLedgerColumn(ledger, amount) return amount > 0 and ledger.income or ledger.expenses end

local function AddToLedger(ledger, source, amount)
  local column = GetLedgerColumn(ledger, amount)
  column[source] = (column[source] or 0) + math.abs(amount)
end

local function MoveBetweenSources(ledger, amount, fromSource, toSource)
  local column = GetLedgerColumn(ledger, amount)
  local remaining = (column[fromSource] or 0) - math.abs(amount)
  column[fromSource] = remaining > 0 and remaining or nil
  column[toSource] = (column[toSource] or 0) + math.abs(amount)
end

local function RecordMoneyChange(amount, source)
  if amount == 0 then return end
  local days, today = addon.data.days, GetTodayKey()
  days[today] = days[today] or CreateEmptyLedger()
  AddToLedger(addon.data.session, source, amount)
  AddToLedger(days[today], source, amount)
  addon.data.session.lastChangeTime = time()
  lastUnexplainedChange = source == "other" and { amount = amount, day = today, at = GetTime() } or nil
end

local function DetectSource(amount)
  local now = GetTime()
  for _, source in ipairs(addon.SOURCE_PRIORITY) do
    local isPossible = source ~= "repair" or amount < 0
    if isPossible and (contextActiveUntil[source] or 0) >= now then return source end
  end
  return "other"
end

function addon.OpenContext(source) contextActiveUntil[source] = math.huge end

-- On a window closing or an event with no window. The money may have come just before: it is moved to this source.
function addon.MarkContextRecent(source)
  contextActiveUntil[source] = GetTime() + addon.CONTEXT_GRACE_SECONDS
  local change = lastUnexplainedChange
  if not change or GetTime() - change.at > addon.CONTEXT_GRACE_SECONDS then return end
  if source == "repair" and change.amount > 0 then return end
  lastUnexplainedChange = nil
  MoveBetweenSources(addon.data.session, change.amount, "other", source)
  if addon.data.days[change.day] then MoveBetweenSources(addon.data.days[change.day], change.amount, "other", source) end
  addon.RefreshDisplay()
end

local function MarkRepairIfInRepairMode()
  if InRepairMode and InRepairMode() then addon.MarkContextRecent("repair") end
end

-- Repairs happen with the vendor open: these calls tell them apart from purchases
function addon.HookRepairs()
  if RepairAllItems then hooksecurefunc("RepairAllItems", function() addon.MarkContextRecent("repair") end) end
  if PickupInventoryItem then hooksecurefunc("PickupInventoryItem", MarkRepairIfInRepairMode) end
  if C_Container and C_Container.PickupContainerItem then return hooksecurefunc(C_Container, "PickupContainerItem", MarkRepairIfInRepairMode) end
  if PickupContainerItem then hooksecurefunc("PickupContainerItem", MarkRepairIfInRepairMode) end
end

local function PruneOldDays()
  local oldestKeptDay = date("%Y-%m-%d", time() - addon.DAYS_KEPT * SECONDS_PER_DAY)
  for day in pairs(addon.data.days) do
    if day < oldestKeptDay then addon.data.days[day] = nil end
  end
end

-- The current session becomes the last one, ending at previousEndTime
local function StartNewSession(previousEndTime)
  local previousSession = addon.data.session
  if previousSession then
    previousSession.endTime = previousEndTime
    addon.data.lastSession = previousSession
  end
  local session = CreateEmptyLedger()
  session.startTime = time()
  session.lastMoney = GetMoney()
  addon.data.session = session
  lastUnexplainedChange = nil
end

local function IsNewLogin(isInitialLogin)
  local session = addon.data.session
  if not session then return true end
  if isInitialLogin ~= nil then return isInitialLogin end
  return not session.endTime or time() - session.endTime > addon.RELOAD_MAX_SECONDS
end

-- After a /reload the saved session goes on. Money that changed without being seen (it should not) counts as other.
local function ContinueSavedSession()
  local session = addon.data.session
  session.endTime = nil
  RecordMoneyChange(GetMoney() - session.lastMoney, "other")
  session.lastMoney = GetMoney()
end

-- Also fires on every loading screen: only the first one after loading the add-on matters
function addon.OnPlayerEnteringWorld(isInitialLogin)
  if isSessionActive then return end
  isSessionActive = true
  PruneOldDays()
  if not IsNewLogin(isInitialLogin) then return ContinueSavedSession() end
  -- If the game closed without PLAYER_LOGOUT (a crash), the last money change is the best guess of when it ended
  local previousSession = addon.data.session
  StartNewSession(previousSession and (previousSession.endTime or previousSession.lastChangeTime or previousSession.startTime))
  if addon.settings.isLoginSummaryShown then addon.PrintLastSessionSummary() end
end

function addon.OnPlayerMoneyChanged()
  if not isSessionActive then return end
  local session = addon.data.session
  local change = GetMoney() - session.lastMoney
  RecordMoneyChange(change, DetectSource(change))
  session.lastMoney = GetMoney()
end

-- Also fires on /reload, which ContinueSavedSession undoes
function addon.OnPlayerLogout()
  if isSessionActive then addon.data.session.endTime = time() end
end

function addon.ResetSession()
  if not isSessionActive then return end
  StartNewSession(time())
  print(addon.CHAT_PREFIX .. L["New session started."])
  addon.RefreshDisplay()
end

function addon.GetDisplayedSession()
  if addon.testSession then return addon.testSession end
  return isSessionActive and addon.data.session or nil
end

function addon.GetTodayLedger()
  if addon.testSession then return addon.testSession end
  return addon.data.days[GetTodayKey()] or CreateEmptyLedger()
end

function addon.PrintLastSessionSummary()
  local session = addon.data.lastSession
  if not session then return end
  local _, _, net = addon.GetLedgerTotals(session)
  print(addon.CHAT_PREFIX .. format(L["Last session: %s in %s"], addon.FormatSignedMoney(net), addon.FormatDuration(addon.GetSessionDuration(session))))
end

local function JoinSourceAmounts(column, formatAmount)
  local parts = {}
  for _, sourceAmount in ipairs(addon.GetSourceAmounts(column)) do parts[#parts + 1] = sourceAmount.label .. " " .. formatAmount(sourceAmount.amount) end
  return table.concat(parts, ", ")
end

function addon.PrintSessionSummary(session, title)
  if not session then return print(addon.CHAT_PREFIX .. L["The session starts when you enter the world."]) end
  local income, expenses, net = addon.GetLedgerTotals(session)
  local moneyPerHour = addon.GetMoneyPerHour(session)
  print(addon.CHAT_PREFIX .. format(L["%s (%s): %s, %s per hour"], title, addon.FormatDuration(addon.GetSessionDuration(session)),
    addon.FormatSignedMoney(net), moneyPerHour and addon.FormatSignedMoney(moneyPerHour) or "-"))
  if income > 0 then print(format(L["  Income %s: %s"], addon.FormatMoney(income), JoinSourceAmounts(session.income, addon.FormatMoney))) end
  if expenses > 0 then print(format(L["  Expenses %s: %s"], addon.FormatMoney(expenses), JoinSourceAmounts(session.expenses, addon.FormatMoney))) end
end

local function CreateTestSession()
  local session = CreateEmptyLedger()
  session.startTime = time() - 5400
  session.income = { loot = 245000, quest = 182500, vendor = 96000, mail = 500000 }
  session.expenses = { repair = 31250, flight = 4400, training = 18000, auction = 12000 }
  return session
end

-- Shows the window and the chat summary with made-up numbers for a while, without touching the real ones
function addon.StartTest()
  if testTimer then testTimer:Cancel() end
  addon.testSession = CreateTestSession()
  addon.PrintSessionSummary(addon.testSession, L["Test session"])
  addon.RefreshDisplay()
  testTimer = C_Timer.NewTimer(addon.TEST_DURATION_SECONDS, function()
    addon.testSession = nil
    addon.RefreshDisplay()
  end)
end
