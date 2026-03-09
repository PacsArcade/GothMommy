# pac-grave-robbery — Install Guide

## 1. SQL (run once against gothmommy_db)

```sql
-- From sql/items.sql
INSERT IGNORE INTO items (item, label, limit_count, can_remove, type, usable, desc)
VALUES
  ('shovel',        'Shovel',          1,  1, 'item_standard', 0, 'A sturdy digging shovel.'),
  ('grave_trinket', 'Old Trinket',      5,  1, 'item_standard', 0, 'Something dug from a grave.'),
  ('old_coin',      'Old Coin',        10,  1, 'item_standard', 0, 'A worn coin of uncertain origin.'),
  ('grave_ring',    'Tarnished Ring',   5,  1, 'item_standard', 0, 'A ring taken from the earth.');
```

## 2. Item PNGs
Copy to `[vorp]/vorp_inventory/html/img/`:
- `shovel.png`
- `grave_trinket.png`
- `old_coin.png`
- `grave_ring.png`

## 3. server.cfg
```
ensure pac-grave-robbery
```

## 4. VPS Deploy
```bash
cd "/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources"
git pull origin feat/v2-features
```
Then in F8: `ensure pac-grave-robbery`

## 5. Test Checklist
- [ ] Resource starts with no script errors
- [ ] Walk to Rhodes cemetery — ground circle appears at each grave
- [ ] Stand on grave — Dig / Pay Respects prompts appear
- [ ] Without shovel: hold Dig — get "You'll need a shovel" notification
- [ ] With shovel: hold Dig — 20s animation plays, loot notification on completion
- [ ] Hold Pay Respects — prayer animation plays, toggle off works
- [ ] Dig same grave twice — "already robbed" message
- [ ] Check Blackwater, Armadillo, Tumbleweed grave coords in-game (TODO: verify new grave coords are accurate)

## 6. Return to Main After Testing
```bash
git checkout main && git pull origin main
```
