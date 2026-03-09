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
      so true pixelation isn't possible. Revisit with screenshot-basic resource.
- [ ] **Demon Eyes filter** — overlay with red eye glow. Saved for premium.
- [ ] **Admin web panel** — web UI for admins to view/revoke/issue ID cards.
- [ ] **screenshot-basic resource** — proper in-game screenshot-to-URL workflow.

### Cleanup (VPS CLI)
- [ ] Run `git rm` on 6 dead asset files (see `[pac]/pac-idcard/CLEANUP.md`)
      to recover ~4.75 MB.

---

## pac-camp

### Setup
- [ ] Pull `feat/pac-camp` branch on VPS
- [ ] Run `pac-camp-inject.sql` on `gothmommy_db`
- [ ] Copy 18 PNGs from `[pac]/pac-camp/img/` → `[vorp]/vorp_inventory/html/img/`
- [ ] Add `ensure uiprompt` and `ensure pac-camp` to server.cfg
- [ ] Test: give yourself `campfire_01` via inventory and verify placement works

### Known Issues / In Progress
- [ ] Placement ground-snap was broken in original — fixed in pac-camp v1
      (auto-snap on spawn + continuous snap + flatness check)
- [ ] AllowedTowns blocks placement inside city limits — working as intended

---

## Infrastructure
- [ ] Long-term: building interior access (Blackwater gov building, saloons)
- [ ] feat/bcc-companions (SQL: companions table)
- [ ] feat/bcc-vampires (SQL: ricx_vampire needs recreating)
- [ ] feat/grave-robbery (ricx_grave_robbery, Config.framework="vorp")
