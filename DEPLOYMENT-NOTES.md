# GothMommy Deployment Notes

## VPS Resources Path
```
/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources
```

## Git Pull (always use fetch first)
```bash
cd "/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources"
git fetch origin && git pull origin main
```

## Branch Per Script Rule
- `main` = stable, tested, ensured in server.cfg
- Each new script gets `feat/<scriptname>` branch
- Merge to main only after in-game test passes
- All custom scripts go in `[pac]/` folder

## Scripts Ensured (server.cfg order matters)
```
ensure vorp_core
ensure vorp_inventory
ensure oxmysql
ensure uiprompt
ensure pac-idcard
ensure pac-camp
ensure pac-companions
```

## Database
- Host: amp.pacsarcade.net:3307
- User: pacbot
- DB: gothmommy_db
- Connect: `mysql -h amp.pacsarcade.net -P 3307 -u pacbot -p gothmommy_db`

## Inventory Images
After adding any new script with items, copy PNGs to:
```
[vorp]/vorp_inventory/html/img/
```

## Web Portal
- ID photo upload: https://pacsarcade.org/idphotos/
- File: `/var/www/vhosts/pacsarcade.org/httpdocs/idphotos/index.html`

---

## Script Import Checklist

When adding any new FiveM/RedM resource to the server, run through this checklist:

### 1. Inventory Images
- [ ] Look in the script's source for an `items/` folder (this is the standard location for item images)
- [ ] Common alternate locations: `html/img/items/`, `stream/`, `images/`
- [ ] Copy the `.png` files from that `items/` folder directly into `[vorp]/vorp_inventory/html/img/`
- [ ] Do NOT copy the whole script's `html/` or `assets/` folder — only the item images
- [ ] File names must match exactly what is registered in the items SQL (without extension)

### 2. Items Registration
- [ ] Check the script's SQL file for `INSERT INTO items` statements
- [ ] Run those inserts against `gothmommy_db` (backup first!)
- [ ] Verify item names match the image filenames (without extension)

### 3. Database Tables
- [ ] Back up DB before any migration
- [ ] Run the script's `CREATE TABLE IF NOT EXISTS` statements
- [ ] Check for conflicts with existing table names

### 4. Framework Shim
- [ ] Confirm script targets VORP Core — strip any RSG/QBCore references
- [ ] Check `fxmanifest.lua` for correct `game 'rdr3'` and `fx_version 'cerulean'`
- [ ] Remove version checker if present

### 5. Config
- [ ] Set `Config.LicensePrefix` to `GMRP`
- [ ] Verify authorized jobs match GMRP job names
- [ ] Check NPC coordinates are in a valid in-world location

### 6. Branch & Deploy
- [ ] Create feature branch: `feat/<scriptname>`
- [ ] Push all files
- [ ] `git pull origin <branch>` on VPS (not just `git fetch`!)
- [ ] `restart <resource>` in txAdmin
- [ ] Run in-game checklist
- [ ] Merge to `main` only after checklist passes

---

## pac-idcard Specific Notes

**Items needed in vorp_inventory:**
- `printphoto` → image: `printphoto.png`
- `man_idcard` → image: `man_idcard.png`
- `woman_idcard` → image: `woman_idcard.png`

Source images come from the **original script's `items/` folder** — copy them to `[vorp]/vorp_inventory/html/img/`

**SQL to register items** (run once):
```sql
INSERT IGNORE INTO items (item, label, limit_count, can_remove, type, usable, desc)
VALUES 
  ('printphoto',   'Passport Photo',  1, 1, 'item_standard', 1, 'A photograph for identity documents.'),
  ('man_idcard',   'ID Card (Male)',   1, 1, 'item_standard', 1, 'Official Goth Mommy RP identity card.'),
  ('woman_idcard', 'ID Card (Female)', 1, 1, 'item_standard', 1, 'Official Goth Mommy RP identity card.');
```
