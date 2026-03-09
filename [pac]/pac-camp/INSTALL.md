# pac-camp Installation Guide
## Goth Mommy RP — VORP Core / RedM

---

## Folder Structure
```
[pac]/
  uiprompt/              ← standalone dependency (bundled)
    fxmanifest.lua
    uiprompt.lua
  pac-camp/
    fxmanifest.lua
    config.lua           ← edit this to configure
    c/
      c.lua              ← client script
    s/
      s.lua              ← server script
    sql/
      pac-camp-inject.sql ← run once on DB
    assets/
      items/             ← place inventory PNGs here (see below)
    html/
      index.html         ← placement UI (from upstream)
```

---

## Step 1 — Pull the branch on VPS
```bash
cd "/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources"
git fetch origin && git pull origin feat/pac-camp
```

## Step 2 — Database
The `pac_camp` table and all 19 items are already injected on `gothmommy_db`.
For a fresh install, run:
```bash
mysql -h amp.pacsarcade.net -P 3307 -u goth_admin -p gothmommy_db \
  < "[pac]/pac-camp/sql/pac-camp-inject.sql"
```
> **Schema note:** VORP uses column `limit` (not `limit_count`). The SQL file
> uses the correct column name.

## Step 3 — Inventory images
Run this one-liner on the VPS to pull all 19 PNGs from the upstream fork:
```bash
INVENTORY_IMG="/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources/[vorp]/vorp_inventory/html/img"
SRC="https://raw.githubusercontent.com/PacsArcade/pac-camp/main/rs_camp/img"
for img in campfire_01 campfire_02 chair_wood chest_big chest_little chest_medium \
           door_01 door_02 door_03 door_04 hitchingpost_iron hitchingpost_wood \
           hitchingpost_wood_double table_wood01 tent_bounty02 tent_bounty06 \
           tent_bounty07 tent_collector04 tent_trader; do
  wget -q "$SRC/${img}.png" -O "$INVENTORY_IMG/${img}.png"
done
```

## Step 4 — server.cfg
Add these lines **in this order**, before any VORP gameplay scripts:
```
ensure uiprompt
ensure pac-camp
```
`uiprompt` must be ensured first — pac-camp's fxmanifest references `@uiprompt/uiprompt.lua`.

## Step 5 — Restart & test
1. Restart the server (or `refresh` + `start uiprompt` + `start pac-camp` in txAdmin console)
2. Give yourself a test item:
   ```
   /vorp item add [your_server_id] campfire_01 1
   ```
3. Open inventory, double-click the item
4. Prop should appear in front of you, already snapped to ground
5. Move with arrow keys, confirm with ENTER
6. Use `/camp` to enter pickup mode, look at placed object, hold R to pick up

---

## Adding new placeable items
1. Add entry to `Config.Items` in `config.lua`
2. Add matching `INSERT IGNORE` to `sql/pac-camp-inject.sql`
3. Add PNG to `assets/items/` and copy to `vorp_inventory/html/img/`
4. Run the INSERT on the live DB
5. `refresh` + `restart pac-camp` in txAdmin

---

## Placement controls
| Key           | Action              |
|---------------|---------------------|
| Arrow keys    | Move object         |
| 1 / 2         | Rotate Z axis       |
| 3 / 4         | Rotate X axis       |
| 5 / 6         | Rotate Y axis       |
| 7 / 8         | Move up / down      |
| F             | Snap to ground      |
| Scroll Up/Dn  | Adjust move speed   |
| ENTER         | Confirm placement   |
| G             | Cancel placement    |

**Placement is blocked inside towns** (see `Config.AllowedTowns`).
**Placement is blocked on steep slopes** (see `Config.MaxSlopeAngle`, default 15°).

---

## Chest sharing
```
/shareperm [chestId] [targetPlayerId]   — give another player access
/unshareperm [chestId]                  — revoke all shared access
```
Chest ID is shown in the prompt when you approach a chest you own.
