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
- XP set to `Config.FullGrownXp` on purchase and load so all abilities unlock immediately
- Server rewritten to VORP-only (redem blocks removed)
- Uses `oxmysql` via `exports.ghmattimysql` (matches server standard)

## ⚠️ IMPORTANT: Client files needed from upstream
The two client files are stubs. Before testing you must copy:
- `client/warmenu.lua` from https://github.com/HALALsnackbar/rdn_companions/blob/main/client/warmenu.lua
- `client/client.lua` from https://github.com/HALALsnackbar/rdn_companions/blob/main/client/client.lua

These are framework-agnostic and can be dropped in as-is.

## Database
**.sql files are gitignored** — run this manually against `gothmommy_db`:

```sql
CREATE TABLE IF NOT EXISTS `companions` (
  `identifier`     varchar(40)  NOT NULL,
  `charidentifier` int          NOT NULL DEFAULT '0',
  `dog`            varchar(255) NOT NULL,
  `skin`           int          NOT NULL DEFAULT '0',
  `xp`             int                   DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
```

Connect and run:
```bash
mysql -h amp.pacsarcade.net -P 3307 -u pacbot -p gothmommy_db
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
