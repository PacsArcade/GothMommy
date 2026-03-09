# pac-camp Item Images

This folder is where item PNG icons live.
Binary files can't be stored via the GitHub API, so they must be copied manually.

## Source
All 19 PNGs are in the upstream fork:
```
https://github.com/PacsArcade/pac-camp/tree/main/rs_camp/img/
```

## Files needed (19 total)
```
campfire_01.png           campfire_02.png
chair_wood.png            table_wood01.png
chest_big.png             chest_little.png          chest_medium.png
door_01.png               door_02.png               door_03.png               door_04.png
hitchingpost_iron.png     hitchingpost_wood.png     hitchingpost_wood_double.png
tent_bounty02.png         tent_bounty06.png         tent_bounty07.png
tent_collector04.png      tent_trader.png
```

## Deploy to inventory

> ⚠️  Path is `[VORP]` (uppercase) and subfolder is `img/items/` — not `img/`

```bash
INVIMG="/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources/[VORP]/vorp_inventory/html/img/items"
SRC="https://raw.githubusercontent.com/PacsArcade/pac-camp/main/rs_camp/img"

for img in campfire_01 campfire_02 chair_wood chest_big chest_little chest_medium \
           door_01 door_02 door_03 door_04 hitchingpost_iron hitchingpost_wood \
           hitchingpost_wood_double table_wood01 tent_bounty02 tent_bounty06 \
           tent_bounty07 tent_collector04 tent_trader; do
  wget -q "$SRC/${img}.png" -O "$INVIMG/${img}.png" && echo "OK: ${img}" || echo "FAIL: ${img}"
done
```
