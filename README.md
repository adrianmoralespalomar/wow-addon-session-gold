# Session Gold

World of Warcraft add-on (made for **WoW Forever**, interface `16001`) that counts the gold you make and spend since you log in, split by source, with gold per hour and a total for the day.

## Features

- Session balance (`+12g 30s`) in the bags, on the row of the gold. Works with the game's bags and with Baganator (through its `RegisterRegion` API).
- Hover over your gold (or the balance) for income and expenses by source: loot, quests, vendor, repairs, Auction House, mail, trade, flights, training and other. Also today's balance and the last session's.
- `/reload` keeps the session going; logging out and in starts a new one. The last session summary is printed in the chat when you log in.
- Per character. Days older than 30 are forgotten.

### How the source is guessed

The game does not say where money comes from, so the add-on looks at the window open when it changes (vendor, mailbox, Auction House, trade, flight master, trainer, quest reward, loot), or closed less than two seconds before. Repairs are told apart from vendor purchases by the repair calls. Anything else (bank slots, gossip options...) counts as *other*. Auction House sales arrive by mail, so they count as *mail*.

## Usage

- `/sgold`: options (also in *Options → AddOns*).
- `/sgold show`: session summary in the chat.
- `/sgold reset`: starts a new session (the current one becomes the last one).
- `/sgold test`: shows the balance and a summary with made-up numbers for 20 seconds, without touching the real ones.

## Development

- `npm install`, then `npm run logo` renders `assets/logo.svg` to `assets/logo.png`, the CurseForge project avatar (`tools/render-logo.ts`).
- `npm run package` builds `dist/SessionGold-<version>.zip` to upload to CurseForge (`tools/package-addon.ps1`).
- `npm run link` links `SessionGold` into the game's AddOns folder (`tools/link-addon.ps1`, change the path with `-AddOnsPath`). After editing, `/reload` in the game.

## License

MIT, see `LICENSE`.
