# Proyecto en CurseForge

Todo lo que se rellena en el proyecto de CurseForge, para copiarlo y pegarlo si hay que crearlo de nuevo. Si cambia lo que hace el add-on, actualizarlo aquí y allí.

## Ficha

| Campo | Valor |
|---|---|
| Project name | `Session Gold` |
| Logo | `assets/logo.png` |
| Class | Addons |
| Main category | Auction & Economy o, si no existe, Miscellaneous |
| Additional categories | Data Export, si existe |
| Allow Comments | Sí (para que avisen de fallos) |
| Unlisted project | No |
| Project License | MIT License |
| Project distribution | Permitir la distribución fuera de CurseForge (WowUp y otros gestores); esas descargas no cuentan para las recompensas |
| Fichero | `dist/SessionGold-<versión>.zip` (`npm run package`) |
| Display name | `Session Gold <versión>` |
| Release Options | Publicar automáticamente al aprobarse |
| Game Version | WoW Forever (la versión `1.60.x` actual) |
| Release Type | Release |
| Changelog | La sección de la versión en `CHANGELOG.md`, en Markdown |
| Formato de la descripción | Markdown |

## Summary

How much gold you made since you logged in, where it came from and how much per hour.

## Description

**Know exactly how much gold this session was worth.**

Session Gold counts every copper you make and spend from the moment you log in, and shows it in your bags, right by your gold.

### Features

- **Session balance** in your bags, next to your gold. Works with the default bags and with Baganator.
- **By source:** hover over your gold to see income and expenses split into loot, quests, vendor, repairs, Auction House, mail, trade, flights, training and other.
- **Today and last session:** the day's balance for the character, and a summary of your last session in the chat when you log in.
- **Survives `/reload`:** the session only restarts when you log out and back in, or when you ask for it.
- Per character, English and Spanish.

### Usage

- `/sgold`: open the options (also in *Options → AddOns → Session Gold*).
- `/sgold show`: session summary in the chat.
- `/sgold reset`: start a new session.
- `/sgold test`: preview the balance with made-up numbers.

The game does not tell where money comes from, so the source is guessed from the window you have open (vendor, mailbox, Auction House...). Auction House sales arrive by mail and count as mail.
