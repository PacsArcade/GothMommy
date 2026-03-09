# pac-companions Install Notes

## Source
Forked from: https://github.com/HALALsnackbar/rdn_companions  
Modified for: Goth Mommy RP (PacsArcade) — VORP framework

## Changes from upstream
- `Config.Framework` = `"vorp"`
- `ConvarFramework` = `"vorp"` in fxmanifest
- `Config.RaiseAnimal` = `false` — pets spawn fully grown
- `Config.NotifyWhenHungry` = `false` — no hunger notifications
- `Config.FeedInterval` = `99999` — feeding effectively disabled
- XP set to `Config.FullGrownXp` on purchase and load so pets have all abilities immediately
- Server rewritten to VORP-only (redem blocks removed)
- Uses `oxmysql` via `exports.ghmattimysql` (matches server standard)

## ⚠️ IMPORTANT: Client files needed from upstream
The two client files are stubs. Before testing you must copy:
- `client/warmenu.lua` from https://github.com/HALALsnackbar/rdn_companions/blob/main/client/warmenu.lua
- `client/client.lua` from https://github.com/HALALsnackbar/rdn_companions/blob/main/client/client.lua

These are framework-agnostic and can be dropped in as-is.

## Database
Run `sql/companions.sql` against `gothmommy_db`:
```bash
mysql -h amp.pacsarcade.net -P 3307 -u pacbot -p gothmommy_db < sql/companions.sql
```

## server.cfg
Add after `ensure uiprompt`:
```
ensure pac-companions
```

## Dependencies
- vorp_core
- vorp_inventory
- oxmysql (ghmattimysql)
- uiprompt
