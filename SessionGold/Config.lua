local _, addon = ...
local L = addon.L

addon.CHAT_PREFIX = "|cffffd100Session Gold|r: "

-- The API does not say where money comes from: it is guessed from the window open (or just closed) when it changes.
-- A source counts for this long after its window closes or its event fires, because the money may arrive a bit later.
addon.CONTEXT_GRACE_SECONDS = 2
-- Without the PLAYER_ENTERING_WORLD arguments, a /reload is told from a new login by how soon it comes back
addon.RELOAD_MAX_SECONDS = 60
-- Gold per hour is not shown for very short sessions, where it would be meaningless
addon.MIN_SECONDS_FOR_RATE = 300
addon.DAYS_KEPT = 30
addon.TEST_DURATION_SECONDS = 20
-- The gold per hour in an open tooltip changes with time even without money changes
addon.DISPLAY_REFRESH_SECONDS = 30

-- Balance next to the gold of the bag
addon.BAG_BUTTON_HEIGHT = 20
addon.BLIZZARD_BAG_OFFSET_Y = 2
addon.BLIZZARD_BAG_FRAME_NAMES = { "ContainerFrameCombinedBags", "ContainerFrame1" }
-- Baganator bag frames, followed by the name of the current skin
addon.BAGANATOR_BACKPACK_FRAME_PREFIXES = { "Baganator_SingleViewBackpackViewFrame", "Baganator_CategoryViewBackpackViewFrame" }

-- Display order
addon.SOURCE_KEYS = { "loot", "quest", "vendor", "repair", "auction", "mail", "trade", "flight", "training", "other" }
addon.SOURCE_LABELS = {
  loot = L["Loot"],
  quest = L["Quests"],
  vendor = L["Vendor"],
  repair = L["Repairs"],
  auction = L["Auction House"],
  mail = L["Mail"],
  trade = L["Trade"],
  flight = L["Flights"],
  training = L["Training"],
  other = L["Other"],
}
-- When several windows are open at once, the most specific one wins (repairing happens with the vendor open)
addon.SOURCE_PRIORITY = { "repair", "trade", "auction", "mail", "quest", "flight", "training", "vendor", "loot" }

addon.CONTEXT_OPEN_EVENTS = {
  MERCHANT_SHOW = "vendor",
  AUCTION_HOUSE_SHOW = "auction",
  MAIL_SHOW = "mail",
  TRADE_SHOW = "trade",
  TAXIMAP_OPENED = "flight",
  TRAINER_SHOW = "training",
  QUEST_COMPLETE = "quest",
  LOOT_OPENED = "loot",
}
addon.CONTEXT_CLOSE_EVENTS = {
  MERCHANT_CLOSED = "vendor",
  AUCTION_HOUSE_CLOSED = "auction",
  MAIL_CLOSED = "mail",
  TRADE_CLOSED = "trade",
  TAXIMAP_CLOSED = "flight",
  TRAINER_CLOSED = "training",
  QUEST_FINISHED = "quest",
  LOOT_CLOSED = "loot",
}
-- Events with no window: the money of a shared loot or a quest reward comes right before or after them
addon.CONTEXT_PULSE_EVENTS = {
  CHAT_MSG_MONEY = "loot",
  QUEST_TURNED_IN = "quest",
}

addon.DEFAULT_SETTINGS = {
  isBagBalanceShown = true,
  isLoginSummaryShown = true,
}
