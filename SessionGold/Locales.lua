local _, addon = ...

-- English is the key itself: a missing translation falls back to it
local translations = {}
addon.L = setmetatable(translations, { __index = function(_, key) return key end })

local locale = GetLocale()
if locale ~= "esES" and locale ~= "esMX" then return end

-- Sources
translations["Loot"] = "Botín"
translations["Quests"] = "Misiones"
translations["Vendor"] = "Vendedor"
translations["Repairs"] = "Reparaciones"
translations["Auction House"] = "Casa de subastas"
translations["Mail"] = "Correo"
translations["Trade"] = "Comercio"
translations["Flights"] = "Vuelos"
translations["Training"] = "Instructores"
translations["Other"] = "Otros"

-- Bag and tooltip
translations["Session: %s"] = "Sesión: %s"
translations["Income"] = "Ingresos"
translations["Expenses"] = "Gastos"
translations["Net"] = "Balance"
translations["Per hour"] = "Por hora"
translations["Today"] = "Hoy"
translations["Last session (%s)"] = "Última sesión (%s)"

-- Chat
translations["%dh %dm"] = "%d h %d min"
translations["%dm"] = "%d min"
translations["This session"] = "Esta sesión"
translations["Test session"] = "Sesión de prueba"
translations["%s (%s): %s, %s per hour"] = "%s (%s): %s, %s por hora"
translations["  Income %s: %s"] = "  Ingresos %s: %s"
translations["  Expenses %s: %s"] = "  Gastos %s: %s"
translations["Last session: %s in %s"] = "Última sesión: %s en %s"
translations["New session started."] = "Sesión nueva empezada."
translations["The session starts when you enter the world."] = "La sesión empieza al entrar en el mundo."
translations["Commands: /sgold (options), /sgold show, /sgold reset, /sgold test"] = "Comandos: /sgold (opciones), /sgold show (resumen), /sgold reset (sesión nueva), /sgold test"

-- Options panel
translations["Counts the gold you make and spend since you log in, by source. Hover over your gold in the bags for the details."] = "Cuenta el oro que ganas y gastas desde que entras, por origen. Pasa el ratón por tu oro en la bolsa para ver el detalle."
translations["Show the session balance in the bags, next to the gold"] = "Mostrar el balance de la sesión en la bolsa, junto al oro"
translations["Print the last session summary in the chat when logging in"] = "Escribir en el chat el resumen de la última sesión al entrar"
translations["Test"] = "Probar"
translations["Start a new session"] = "Empezar sesión nueva"
