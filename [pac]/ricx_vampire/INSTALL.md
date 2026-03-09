# ricx_vampire — Install Guide

> ⚠️ Tebex paid script. `client.lua` and `server.lua` are FXAP encrypted — do not modify.
> Only `config.lua`, `fw_func.lua`, and `events.lua` are editable.

## 1. SQL (run once against gothmommy_db)

```sql
-- Table
CREATE TABLE IF NOT EXISTS `ricx_vampire` (
  `id`         int(11)      NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60)  NOT NULL,
  `charid`     int(11)      NOT NULL,
  `data`       longtext     DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Items (from sql/vorp_items.sql)
INSERT IGNORE INTO items (item, label, limit_count, can_remove, type, usable, desc)
VALUES
  ('ricx_vampire_transform_drink', 'Strange Elixir',    1, 1, 'item_standard', 1, 'A dark vial that smells of iron and nightshade.'),
  ('ricx_human_blood',             'Human Blood',       5, 1, 'item_standard', 0, 'Warm. Still warm.'),
  ('ricx_empty_jar',               'Empty Jar',        10, 1, 'item_standard', 0, 'An empty glass jar.');
```

## 2. Item PNGs
Copy to `[vorp]/vorp_inventory/html/img/`:
- `ricx_vampire_transform_drink.png`
- `ricx_human_blood.png`
- `ricx_empty_jar.png`

## 3. server.cfg
```
ensure ricx_vampire
```

## 4. VPS Deploy
```bash
cd "/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources"
git pull origin feat/v2-features
```
Then in F8: `ensure ricx_vampire`

## 5. Test Checklist
- [ ] Resource starts with no script errors
- [ ] Give self `ricx_vampire_transform_drink` via inventory admin
- [ ] Use item — transformation success notification appears
- [ ] Type `/vampire` — HUD toggles on showing mana bar
- [ ] Wait until 6am in-game — sun damage ticks apply
- [ ] Type `/bat_t` — bat transformation triggers
- [ ] Approach human NPC, bloodsuck — mana deducted, police alert fires (80% chance)
- [ ] Check `ricx_vampire` table in DB — row created for character

## 6. GMRP Notes
- `fw_func.lua` uses `exports.oxmysql` — **ghmattimysql has been removed**
- `Config.Debug = false` — no spam logs
- `Config.BloodsuckAlert.police_jobs` is set to `{"police", "police2"}` — update when law enforcement jobs are added
- Encrypted files (`client.lua`, `server.lua`) must stay untouched

## 7. Return to Main After Testing
```bash
git checkout main && git pull origin main
```
