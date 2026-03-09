# pac-idcard

ID Card system for Goth Mommy RP — built on VORP Core.

## SQL
Run `sql/install.sql` before starting the resource.

## server.cfg
Add after vorp_inventory:
```
ensure pac-idcard
```

## Items needed in DB
See `vorp-items.sql` in the pac-idcard repo.

## Photo Portal
Players upload their photo at: https://pacsarcade.org/idphotos/

## Commands
| Command | Who | What |
|---|---|---|
| `/idcard` | Everyone | Show your ID card |
| `/checkid [id]` | Law / Admin | Verify documents, detect forgeries |
| `/deleteidcard [id]` | Law / Admin | Revoke ID card |

## Keybinds (Camera Mode)
| Key | Action |
|---|---|
| G | Take photo |
| Backspace | Exit |
| W / S | Move camera forward / back |
| Page Up / Down | Zoom in / out |
| Arrow Left / Right | Cycle filters |
| Enter | Print photo |
