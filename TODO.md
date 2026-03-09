# Goth Mommy RP — Server TODO

This file tracks pending work across all scripts. Ordered by priority.

---

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

---

## Infrastructure
- [ ] Merge `idcards` → `main` (ready after asset cleanup git rm)
- [ ] Set up `feat/pac-camp` branch from updated main
- [ ] Long-term: investigate building interior access for RP immersion
      (Blackwater government building, Saloon interiors etc.)
