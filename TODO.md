# Goth Mommy RP — Server TODO

This file tracks pending work across all scripts. Ordered by priority.

---

<<<<<<< HEAD
=======
## pac-camp

### Bedroll — PENDING IN-GAME TEST
- [ ] **Bedroll sleep animation** — bedroll is now a placeable prop (like chest/tent).
      Proximity prompt "Sleep" appears when within 2m. Press E → sleep anim → respawn set.
      Sleep uses `TaskStartScenarioInPlaceHash(ped, GetHashKey("WORLD_HUMAN_SLEEP_GROUND"), ...)`
      wrapped in pcall. **Needs in-game test** to confirm scenario hash works in RedM.
      If scenario fails silently, try anim dict fallback:
      `amb_camp@world_human_sleep_ground@male@back@idle_a` / `base`.
      Client log: watch F8 for `[pac-camp] sleep scenario started` vs fallback messages.
- [ ] **Bedroll item in DB** — `bedroll` item still exists in `items` table with `usable=1`.
      Once bedroll prop approach is confirmed working, the item row can stay (it places
      the prop when used from inventory) or be removed. No action needed right now.
- [ ] **campinvite / campkick / chest access via membership** — needs 2-player test session.

### Completed ✅
- [x] Mouse-driven ghost prop placement UI (smooth, tested working)
- [x] Town blocking (AllowedTowns all false, tested working)
- [x] Chest open/close + inventory persistence across restarts
- [x] Camp membership system (pac_camp_members table)
- [x] /campinvite, /campkick, /campwho commands (logic complete, single-player verified)
- [x] Bedroll proximity prompt infrastructure (mirrors chest exactly)
- [x] Bedroll respawn DB write (pac_camp_respawn, confirmed working)
- [x] Respawn teleport on character spawn (vorp_character:spawnAChar)
- [x] 19 camp item inventory images deployed to vorp_inventory

---

>>>>>>> main
## pac-idcard

### In-World Placement
- [ ] **Blackwater Identity Process NPC** — currently on boardwalk outside building
      (`-802.5, -1187.8, 44.0`). Need to resolve the locked building door.
      Research: `SetStateOfClosestDoorOfType` or find correct door hash for the
      Blackwater government building interior to keep NPC inside properly.
- [ ] **Illegal Forger NPCs** — placeholder coords near photographer studio.
      Need to find real accessible locations: back alleys, bayou shacks, abandoned
      buildings. Update `Config.IDCardNPC["IllegalCard"]` coords.
- [ ] **Additional towns** — add Photographer + IDCard NPCs for Valentine and
      Rhodes once player base grows.

### Features (Premium / Future)
- [ ] **Pixelated filter** — removed from free tier. CEF can't sample game framebuffer
<<<<<<< HEAD
      so true pixelation isn't possible; current canvas approach renders as a tinted
      mosaic. Revisit when/if a screenshot-basic resource is added (could capture
      game frame and display as pixelated canvas).
- [ ] **Demon Eyes filter** — overlay with red eye glow. Saved for premium.
- [ ] **Admin web panel** — web UI for admins to view/revoke/issue ID cards.
      Back-end endpoints already exist (`/deleteidcard`, `/checkid`).
- [ ] **screenshot-basic resource** — would allow true in-game screenshot-to-URL
      workflow instead of the current Steam F12 / manual upload process.

### Cleanup (after merge)
- [ ] Run `git rm` on 6 dead asset files (see `[pac]/pac-idcard/CLEANUP.md`)
      to recover ~4.75 MB. Must be done via CLI on VPS after pull.

---

## pac-camp

### Setup
- [ ] **Branch created**: `feat/pac-camp` in GothMommy repo
- [ ] **Script placed**: `[pac]/pac-camp/` (rename from `rs_camp`)
- [ ] **SQL**: Run `pac-camp-inject.sql` on `gothmommy_db` (table + items)
- [ ] **Inventory images**: Copy all 18 PNGs from `rs_camp/img/` into
      `[vorp]/vorp_inventory/html/img/` on the VPS
- [ ] **server.cfg**: Add `ensure pac-camp` after `ensure pac-idcard`
- [ ] **Dependencies**: Confirm `oxmysql` and `uiprompt` are ensured before pac-camp
- [ ] **feather-menu**: Not required by rs_camp — was a different script concern.
      pac-camp uses its own HTML UI.
- [ ] **Test**: Give yourself `campfire_01` via `/vorp item add [id] campfire_01 1`
      and verify placement, storage, pickup all work.
=======
      so true pixelation isn't possible. Revisit with screenshot-basic resource.
- [ ] **Demon Eyes filter** — overlay with red eye glow. Saved for premium.
- [ ] **Admin web panel** — web UI for admins to view/revoke/issue ID cards.
- [ ] **screenshot-basic resource** — proper in-game screenshot-to-URL workflow.

### Cleanup (VPS CLI)
- [ ] Run `git rm` on 6 dead asset files (see `[pac]/pac-idcard/CLEANUP.md`)
      to recover ~4.75 MB.
>>>>>>> main

---

## Infrastructure
<<<<<<< HEAD
- [ ] Merge `idcards` → `main` (ready after asset cleanup git rm)
- [ ] Set up `feat/pac-camp` branch from updated main
- [ ] Long-term: investigate building interior access for RP immersion
      (Blackwater government building, Saloon interiors etc.)
=======
- [ ] Long-term: building interior access (Blackwater gov building, saloons)
- [ ] feat/bcc-companions (SQL: companions table)
- [ ] feat/bcc-vampires (SQL: ricx_vampire needs recreating)
- [ ] feat/grave-robbery (ricx_grave_robbery, Config.framework="vorp")
>>>>>>> main
