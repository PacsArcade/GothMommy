# pac-hooker — Install Guide

## 1. SQL (run once against gothmommy_db)

```sql
CREATE TABLE IF NOT EXISTS `pac_player_status` (
  `id`                int(11)      NOT NULL AUTO_INCREMENT,
  `identifier`        varchar(60)  NOT NULL,
  `charid`            int(11)      NOT NULL,
  `last_bath`         int(11)      DEFAULT NULL,
  `well_rested_until` int(11)      DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_char` (`identifier`, `charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 2. No Item PNGs Required
This script is currency-only. No inventory items.

## 3. server.cfg
```
ensure pac-hooker
```

## 4. TODO Before Go-Live
- [ ] Verify all `pos` teleport coordinates in-game (marked with `-- TODO` in config.lua)
- [ ] Swap placeholder `mp_m_freemode_01` gentleman NPC models for period-appropriate dressed male peds
- [ ] Confirm bath system works end-to-end with a bathhouse script (pac-bath, future feature)

## 5. VPS Deploy
```bash
cd "/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources"
git pull origin feat/v2-features
```
Then in F8: `ensure pac-hooker`

## 6. Test Checklist
- [ ] Resource starts with no script errors
- [ ] NPCs spawn at Valentine, Blackwater, Rhodes after character select
- [ ] Blips appear on map for each location
- [ ] Approach female NPC as male character — G prompt appears
- [ ] Without bath: G — "You smell like a mule" rejection fires
- [ ] After bath (manually SET last_bath in DB): G — screen fades, noir toast appears, sounds play, fade back in
- [ ] $15 deducted from character after session
- [ ] Health restored to full after session
- [ ] Well-rested toast appears
- [ ] Approach female NPC as female character — rejection fires, direct to gentleman NPC
- [ ] Gentleman NPC accepts female character

## 7. Return to Main After Testing
```bash
git checkout main && git pull origin main
```
