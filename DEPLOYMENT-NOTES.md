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
# ensure pac-camp   ← add after feat/pac-camp merges
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
