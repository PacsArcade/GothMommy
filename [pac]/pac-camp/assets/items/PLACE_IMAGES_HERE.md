# pac-camp Item Images

This folder holds the inventory icon PNGs for all pac-camp placeable items.
These are binary files and cannot be stored via the GitHub API — they must be
copied manually.

## Source
All 19 PNGs live in the upstream fork:
```
https://github.com/PacsArcade/pac-camp/tree/main/rs_camp/img/
```

## Files needed (19 total)
```
campfire_01.png
campfire_02.png
chair_wood.png
chest_big.png
chest_little.png
chest_medium.png
door_01.png
door_02.png
door_03.png
door_04.png
hitchingpost_iron.png
hitchingpost_wood.png
hitchingpost_wood_double.png
table_wood01.png
tent_bounty02.png
tent_bounty06.png
tent_bounty07.png
tent_collector04.png
tent_trader.png
```

## Deploy to inventory
Copy all PNGs to your vorp_inventory images folder:
```bash
INVENTORY_IMG="/home/amp/.ampdata/instances/RedM01/txadmin/server/txData/GothMommy.base/resources/[vorp]/vorp_inventory/html/img"
SRC="https://raw.githubusercontent.com/PacsArcade/pac-camp/main/rs_camp/img"

for img in campfire_01 campfire_02 chair_wood chest_big chest_little chest_medium \
           door_01 door_02 door_03 door_04 hitchingpost_iron hitchingpost_wood \
           hitchingpost_wood_double table_wood01 tent_bounty02 tent_bounty06 \
           tent_bounty07 tent_collector04 tent_trader; do
  wget -q "$SRC/${img}.png" -O "$INVENTORY_IMG/${img}.png"
done
echo "Done - $(ls $INVENTORY_IMG/*.png | grep -c '') PNGs in place"
```
