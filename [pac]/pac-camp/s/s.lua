-- pac-camp  s/s.lua  (server)
local VORPcore = exports.vorp_core:GetCore()
local VorpInv  = exports.vorp_inventory:vorp_inventoryApi()
local Inv      = exports.vorp_inventory
local loadedCamps = {}

local function registerStorage(prefix, name, limit)
    if not Inv:isCustomInventoryRegistered(prefix) then
        Inv:registerInventory({
            id=prefix, name=name, limit=limit,
            acceptWeapons=true, shared=true, ignoreItemStackLimit=true,
            whitelistItems=false, UsePermissions=false, UseBlackList=false, whitelistWeapons=false,
        })
    end
end

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    exports.oxmysql:execute('SELECT * FROM pac_camp', {}, function(rows)
        if rows then
            loadedCamps = {}
            for _, r in pairs(rows) do
                table.insert(loadedCamps, {
                    id=r.id, x=r.x, y=r.y, z=r.z,
                    rotation={x=r.rot_x, y=r.rot_y, z=r.rot_z},
                    item={name=r.item_name, model=r.item_model}
                })
            end
        end
    end)
end)

RegisterNetEvent('pac_camp:server:requestCamps')
AddEventHandler('pac_camp:server:requestCamps', function()
    TriggerClientEvent('pac_camp:client:receiveCamps', source, loadedCamps)
end)

RegisterNetEvent('pac_camp:server:savecampOwner')
AddEventHandler('pac_camp:server:savecampOwner', function(coords, rotation, itemName)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    if not Config.Items[itemName] then return end
    local model = Config.Items[itemName].model
    exports.oxmysql:execute([[
        INSERT INTO pac_camp (owner_identifier,owner_charid,x,y,z,rot_x,rot_y,rot_z,item_name,item_model)
        VALUES (@id,@cid,@x,@y,@z,@rx,@ry,@rz,@iname,@imodel)
    ]], {
        ['@id']=Char.identifier,['@cid']=Char.charIdentifier,
        ['@x']=coords.x,['@y']=coords.y,['@z']=coords.z,
        ['@rx']=rotation.x,['@ry']=rotation.y,['@rz']=rotation.z,
        ['@iname']=itemName,['@imodel']=model
    }, function(result)
        if result and result.insertId then
            local data = {
                id=result.insertId, x=coords.x, y=coords.y, z=coords.z,
                rotation={x=rotation.x,y=rotation.y,z=rotation.z},
                item={name=itemName, model=model}
            }
            table.insert(loadedCamps, data)
            TriggerClientEvent('pac_camp:client:spawnCamps', -1, data)
        end
    end)
end)

RegisterNetEvent('pac_camp:server:pickUpByOwner')
AddEventHandler('pac_camp:server:pickUpByOwner', function(uid)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    local group = Char.group

    local function isAdmin(g)
        for _, ag in ipairs(Config.AdminGroups) do if g==ag then return true end end
        return false
    end
    local function isChest(model)
        for _, c in ipairs(Config.Chests) do if c.object==model then return true end end
        return false
    end
    local function doRemove(row)
        TriggerClientEvent('pac_camp:client:removeCamp', -1, uid)
        for i, c in ipairs(loadedCamps) do
            if c.id==uid then table.remove(loadedCamps,i); break end
        end
        exports.oxmysql:execute('DELETE FROM pac_camp WHERE id = ?', {uid}, function(res)
            local aff = res and (res.affectedRows or res.affected_rows or res.changes)
            if aff and aff>0 then
                if row.item_name then VorpInv.addItem(src, row.item_name, 1) end
                VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Picked, "generic_textures", "tick", 4000, "COLOR_GREEN")
            end
        end)
    end

    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {uid}, function(rows)
        if not rows or #rows==0 then
            VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Dont, "menu_textures", "cross", 3000, "COLOR_RED"); return
        end
        local row = rows[1]
        if not ((row.owner_identifier==Char.identifier and row.owner_charid==Char.charIdentifier) or isAdmin(group)) then
            VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Dont, "menu_textures", "cross", 3000, "COLOR_RED"); return
        end
        if not isChest(row.item_model) then doRemove(row); return end
        local invID = "camp_storage_"..uid
        if exports.vorp_inventory:isCustomInventoryRegistered(invID) then
            exports.vorp_inventory:getCustomInventoryItems(invID, function(items)
                exports.vorp_inventory:getCustomInventoryWeapons(invID, function(weapons)
                    items=items or {}; weapons=weapons or {}
                    if #items>0 or #weapons>0 then
                        VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.chestfull, "menu_textures", "cross", 3000, "COLOR_RED")
                    else doRemove(row) end
                end)
            end)
        else doRemove(row) end
    end)
end)

RegisterNetEvent('pac_camp:server:openChest')
AddEventHandler('pac_camp:server:openChest', function(campId)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {campId}, function(rows)
        if rows and #rows>0 then
            local row = rows[1]
            local ok  = (row.owner_identifier==Char.identifier and row.owner_charid==Char.charIdentifier)
            if not ok then
                for _, d in ipairs(json.decode(row.shared_with or '[]')) do
                    if d and d.charIdentifier==Char.charIdentifier then ok=true; break end
                end
            end
            if not ok then
                VORPcore.NotifyLeft(src, Config.Text.Chest, Config.Text.Dontchest, "menu_textures", "cross", 2000, "COLOR_RED"); return
            end
            local prefix = "camp_storage_"..campId
            local cap    = 1000
            for _, v in pairs(Config.Chests) do
                if v.object==row.item_model then cap=v.capacity; break end
            end
            registerStorage(prefix, Config.Text.StorageName, cap)
            Inv:openInventory(src, prefix)
        end
    end)
end)

RegisterNetEvent('pac_camp:server:toggleDoor')
AddEventHandler('pac_camp:server:toggleDoor', function(campId)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {campId}, function(rows)
        if rows and #rows>0 then
            local row = rows[1]
            local ok  = (row.owner_identifier==Char.identifier and row.owner_charid==Char.charIdentifier)
            if not ok then
                for _, d in ipairs(json.decode(row.shared_with) or {}) do
                    if d and d.charIdentifier==Char.charIdentifier then ok=true; break end
                end
            end
            if not ok then
                VORPcore.NotifyLeft(src, Config.Text.Door, Config.Text.Dontdoor, "menu_textures", "cross", 2000, "COLOR_RED"); return
            end
            TriggerClientEvent('pac_camp:client:toggleDoor', -1, campId)
        end
    end)
end)

RegisterCommand(Config.Commands.Shareperms, function(source, args)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    local campId = tonumber(args[1]); local tPid = tonumber(args[2])
    if not campId or not tPid then return end
    exports.oxmysql:execute('SELECT shared_with,owner_identifier,owner_charid FROM pac_camp WHERE id = ?', {campId}, function(rows)
        if rows and #rows>0 then
            local row = rows[1]
            if row.owner_identifier~=Char.identifier or row.owner_charid~=Char.charIdentifier then
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Dontowner, "menu_textures", "cross", 3000, "COLOR_RED"); return
            end
            local tUser = VORPcore.getUser(tPid)
            if not tUser then
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return
            end
            local tCid = tUser.getUsedCharacter.charIdentifier
            local tId  = tUser.getUsedCharacter.identifier
            local sw   = json.decode(row.shared_with) or {}
            local clean = {}; local exists = false
            for _, v in ipairs(sw) do
                if v then
                    if v.charIdentifier==tCid then exists=true end
                    table.insert(clean, v)
                end
            end
            if exists then
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Already, "menu_textures", "cross", 3000, "COLOR_RED"); return
            end
            table.insert(clean, {identifier=tId, charIdentifier=tCid})
            exports.oxmysql:execute('UPDATE pac_camp SET shared_with = ? WHERE id = ?', {json.encode(clean), campId}, function()
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Permsyes, "generic_textures", "tick", 3000, "COLOR_GREEN")
            end)
        else
            VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Permsdont, "menu_textures", "cross", 3000, "COLOR_RED")
        end
    end)
end, false)

RegisterCommand(Config.Commands.Unshareperms, function(source, args)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    local campId = tonumber(args[1])
    if not campId then return end
    exports.oxmysql:execute('SELECT shared_with,owner_identifier,owner_charid FROM pac_camp WHERE id = ?', {campId}, function(rows)
        if rows and #rows>0 then
            local row = rows[1]
            if row.owner_identifier~=Char.identifier or row.owner_charid~=Char.charIdentifier then
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Dontowner, "menu_textures", "cross", 3000, "COLOR_RED"); return
            end
            exports.oxmysql:execute('UPDATE pac_camp SET shared_with = ? WHERE id = ?', {json.encode({}), campId}, function()
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Allpermission, "generic_textures", "tick", 3000, "COLOR_GREEN")
            end)
        else
            VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Permsdont, "menu_textures", "cross", 3000, "COLOR_RED")
        end
    end)
end, false)

for itemName, _ in pairs(Config.Items) do
    VorpInv.RegisterUsableItem(itemName, function(data)
        local src  = data.source
        local User = VORPcore.getUser(src)
        if not User then return end
        local Char = User.getUsedCharacter
        if not Char then return end
        TriggerClientEvent('pac_camp:client:sendTownToServer', src, itemName)
    end)
end

RegisterNetEvent('pac_camp:server:checkTownAndPlace')
AddEventHandler('pac_camp:server:checkTownAndPlace', function(itemName, town)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    -- nil town = wilderness = always allowed
    if town ~= nil then
        if Config.AllowedTowns[town] == false then
            VorpInv.CloseInv(src)
            VORPcore.NotifySimpleTop(src, Config.Text.Camp, Config.Text.NotInTown, 4000)
            return
        end
    end
    exports.oxmysql:execute(
        'SELECT COUNT(*) as count FROM pac_camp WHERE owner_identifier=@id AND owner_charid=@cid',
        {['@id']=Char.identifier, ['@cid']=Char.charIdentifier},
        function(result)
            local count = result[1] and result[1].count or 0
            if count >= Config.MaxObject then
                VorpInv.CloseInv(src)
                VORPcore.NotifySimpleTop(src, Config.Text.Camp, Config.Text.MaxItems, 4000)
                return
            end
            VorpInv.CloseInv(src)
            TriggerClientEvent('pac_camp:client:placePropCamp', src, itemName)
        end
    )
end)

RegisterNetEvent('pac_camp:removeItem')
AddEventHandler('pac_camp:removeItem', function(itemName)
    if Config.Items[itemName] then VorpInv.subItem(source, itemName, 1) end
end)
