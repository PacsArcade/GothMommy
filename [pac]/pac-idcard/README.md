# pac-idcard — Goth Mommy RP Edition

VORP Core ID card system with photographer NPC, camera filters, and ID card issuance.

## Version
`2026-03-09-v17`

## Features
- Photographer NPC with scripted camera session
- 3-2-1 countdown + flash shutter
- 7 camera filters: None, Sepia, Thunderstorm, Blood Moon, Acid Trip, Foggy Lens, Pixelated
- ID card form with religion, hair, eye, city dropdowns
- Legal + illegal ID card NPCs
- Law enforcement `/checkid` command
- Admin `/deleteidcard` command
- GMRP-XXXXXX license number format

## Camera Controls (Numpad)
| Key | Action |
|-----|--------|
| NUM 8 | Camera Up |
| NUM 2 | Camera Down |
| NUM 4 | Camera Left |
| NUM 6 | Camera Right |
| NUM 7 | Zoom In |
| NUM 9 | Zoom Out |
| NUM 5 | Reset Camera |
| NUM 1 | Previous Filter |
| NUM 3 | Next Filter |
| ENTER | Take Photo (3-2-1 countdown) |
| NUM 0 / Backspace / Escape | Exit |

## Screenshot Note
The shutter fires `Citizen.InvokeNative(0x3B96D87CB7DA1245)` (RDR native screenshot export)
and also injects `INPUT_SCREENSHOT` (166). Screenshots save to the RDR gallery folder.
If screenshots are not saving, ensure the player has their in-game screenshot key enabled.

## Installation
1. Copy `pac-idcard/` into your `[pac]/` folder
2. Run the SQL migration in `sql/pac_idcard.sql`
3. Copy item images from `items/` to `[vorp]/vorp_inventory/html/img/`
4. Add `ensure pac-idcard` to `server.cfg`
5. Restart server

## Dependencies
- VORP Core
- vorp_inventory
- vorp_character

## SQL Tables
See `sql/pac_idcard.sql`

## Config
All settings in `config.lua`. Prices, NPC locations, filter list, keybinds all configurable.
