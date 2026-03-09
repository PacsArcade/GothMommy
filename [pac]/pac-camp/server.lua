-- pac-camp server.lua
-- Renamed from rs_camp. All events prefixed pac_camp:
local VORPcore = exports.vorp_core:GetCore()
local VorpInv  = exports.vorp_inventory:vorp_inventoryApi()
local Inv      = exports.vorp_inventory
local loadedCamps = {}

local function registerStorage(prefix, name, limit)
    local isInvRegistered = Inv:isCustomInventoryRegistered(prefix)
    if not isInvRegistered then
        local data = {
            id=prefix, name=name, limit=limit,
            acceptWeapons=true, shared=true, ignoreItemStackLimit=true,
            whitelistItems=false, UsePermissions=false, UseBlackList=false, whitelistWeapons=false,
        }
        Inv:registerInventory(data)
    end
end

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    exports.oxmysql:execute('SELECT * FROM pac_camp', {}, function(results)
        if results then
            loadedCamps = {}
            for _, row in pairs(results) do
                table.insert(loadedCamps, {
                    id=row.id, x=row.x, y=row.y, z=row.z,
                    rotation={x=row.rot_x, y=row.rot_y, z=row.rot_z},
                    item={name=row.item_name, model=row.item_model}
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
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end
    if not Config.Items[itemName] then return end

    local itemModel = Config.Items[itemName].model
    exports.oxmysql:execute([[
        INSERT INTO pac_camp (owner_identifier, owner_charid, x, y, z, rot_x, rot_y, rot_z, item_name, item_model)
        VALUES (@identifier, @charid, @x, @y, @z, @rot_x, @rot_y, @rot_z, @item_name, @item_model)
    ]], {
        ['@identifier']=Character.identifier,['@charid']=Character.charIdentifier,
        ['@x']=coords.x,['@y']=coords.y,['@z']=coords.z,
        ['@rot_x']=rotation.x,['@rot_y']=rotation.y,['@rot_z']=rotation.z,
        ['@item_name']=itemName,['@item_model']=itemModel
    }, function(result)
        if result and result.insertId then
            local data = {
                id=result.insertId, x=coords.x, y=coords.y, z=coords.z,
                rotation={x=rotation.x,y=rotation.y,z=rotation.z},
                item={name=itemName, model=itemModel}
            }
            table.insert(loadedCamps, data)
            TriggerClientEvent('pac_camp:client:spawnCamps', -1, data)
        end
    end)
end)

RegisterNetEvent('pac_camp:server:pickUpByOwner')
AddEventHandler('pac_camp:server:pickUpByOwner', function(uniqueId)
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end
    local u_identifier = Character.identifier
    local u_charid     = Character.charIdentifier
    local characterGroup = Character.group

    local function IsAdmin(group)
        for _, g in ipairs(Config.AdminGroups) do if group==g then return true end end
        return false
    end
    local function IsChest(model)
        for _, c in ipairs(Config.Chests) do if c.object==model then return true end end
        return false
    end
    local function RemoveCamp(row)
        TriggerClientEvent('pac_camp:client:removeCamp', -1, uniqueId)
        for i, camp in ipairs(loadedCamps) do
            if camp.id==uniqueId then table.remove(loadedCamps,i); break end
        end
        exports.oxmysql:execute('DELETE FROM pac_camp WHERE id = ?', {uniqueId}, function(result)
            local affected = result and (result.affectedRows or result.affected_rows or result.changes)
            if affected and affected > 0 then
                if row.item_name then VorpInv.addItem(src, row.item_name, 1) end
                VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Picked, "generic_textures", "tick", 4000, "COLOR_GREEN")
            end
        end)
    end

    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {uniqueId}, function(results)
        if not results or #results==0 then
            VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Dont, "menu_textures", "cross", 3000, "COLOR_RED"); return
        end
        local row = results[1]
        if not ((row.owner_identifier==u_identifier and row.owner_charid==u_charid) or IsAdmin(characterGroup)) then
            VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Dont, "menu_textures", "cross", 3000, "COLOR_RED"); return
        end
        if not IsChest(row.item_model) then RemoveCamp(row); return end
        local invID = "camp_storage_"..uniqueId
        if exports.vorp_inventory:isCustomInventoryRegistered(invID) then
            exports.vorp_inventory:getCustomInventoryItems(invID, function(items)
                exports.vorp_inventory:getCustomInventoryWeapons(invID, function(weapons)
                    items=items or {}; weapons=weapons or {}
                    if #items>0 or #weapons>0 then
                        VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.chestfull, "menu_textures", "cross", 3000, "COLOR_RED")
                    else RemoveCamp(row) end
                end)
            end)
        else RemoveCamp(row) end
    end)
end)

RegisterNetEvent('pac_camp:server:openChest')
AddEventHandler('pac_camp:server:openChest', function(campId)
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {campId}, function(results)
        if results and #results>0 then
            local row = results[1]
            local hasAccess = (row.owner_identifier==Character.identifier and row.owner_charid==Character.charIdentifier)
            if not hasAccess then
                local sharedWith = json.decode(row.shared_with or "[]")
                for _, data in ipairs(sharedWith) do
                    if data and data.charIdentifier==Character.charIdentifier then hasAccess=true; break end
                end
            end
            if not hasAccess then
                VORPcore.NotifyLeft(src, Config.Text.Chest, Config.Text.Dontchest, "menu_textures", "cross", 2000, "COLOR_RED"); return
            end
            local prefix   = "camp_storage_"..campId
            local capacity = 1000
            for _, v in pairs(Config.Chests) do
                if v.object==row.item_model then capacity=v.capacity; break end
            end
            registerStorage(prefix, Config.Text.StorageName, capacity)
            Inv:openInventory(src, prefix)
        end
    end)
end)

RegisterNetEvent('pac_camp:server:toggleDoor')
AddEventHandler('pac_camp:server:toggleDoor', function(campId)
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end
    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {campId}, function(results)
        if results and #results>0 then
            local row = results[1]
            local hasAccess = (row.owner_identifier==Character.identifier and row.owner_charid==Character.charIdentifier)
            if not hasAccess then
                local sharedWith = json.decode(row.shared_with) or {}
                for _, data in ipairs(sharedWith) do
                    if data and data.charIdentifier==Character.charIdentifier then hasAccess=true; break end
                end
            end
            if not hasAccess then
                VORPcore.NotifyLeft(src, Config.Text.Door, Config.Text.Dontdoor, "menu_textures", "cross", 2000, "COLOR_RED"); return
            end
            TriggerClientEvent('pac_camp:client:toggleDoor', -1, campId)
        end
    end)
end)

RegisterCommand(Config.Commands.Shareperms, function(source, args)
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    local campId = tonumber(args[1])
    local targetPlayerId = tonumber(args[2])
    if not campId or not targetPlayerId then return end
    exports.oxmysql:execute('SELECT shared_with, owner_identifier, owner_charid FROM pac_camp WHERE id = ?', {campId}, function(results)
        if results and #results>0 then
            local row = results[1]
            if row.owner_identifier~=Character.identifier or row.owner_charid~=Character.charIdentifier then
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Dontowner, "menu_textures", "cross", 3000, "COLOR_RED"); return
            end
            local targetUser = VORPcore.getUser(targetPlayerId)
            if not targetUser then
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return
            end
            local targetCharId    = targetUser.getUsedCharacter.charIdentifier
            local targetIdentifier = targetUser.getUsedCharacter.identifier
            local sharedWith = json.decode(row.shared_with) or {}
            local cleanArray = {}; local alreadyExists = false
            for _, v in ipairs(sharedWith) do
                if v~=nil then
                    if v.charIdentifier==targetCharId then alreadyExists=true end
                    table.insert(cleanArray, v)
                end
            end
            if alreadyExists then
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Already, "menu_textures", "cross", 3000, "COLOR_RED"); return
            end
            table.insert(cleanArray, {identifier=targetIdentifier, charIdentifier=targetCharId})
            exports.oxmysql:execute('UPDATE pac_camp SET shared_with = ? WHERE id = ?', {json.encode(cleanArray), campId}, function()
                VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Permsyes, "generic_textures", "tick", 3000, "COLOR_GREEN")
            end)
        else
            VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Permsdont, "menu_textures", "cross", 3000, "COLOR_RED")
        end
    end)
end, false)

RegisterCommand(Config.Commands.Unshareperms, function(source, args)
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    local campId = tonumber(args[1])
    if not campId then return end
    exports.oxmysql:execute('SELECT shared_with, owner_identifier, owner_charid FROM pac_camp WHERE id = ?', {campId}, function(results)
        if results and #results>0 then
            local row = results[1]
            if row.owner_identifier~=Character.identifier or row.owner_charid~=Character.charIdentifier then
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
        local src = data.source
        local User = VORPcore.getUser(src)
        if not User then return end
        local Character = User.getUsedCharacter
        if not Character then return end
        TriggerClientEvent('pac_camp:client:sendTownToServer', src, itemName)
    end)
end

RegisterNetEvent('pac_camp:server:checkTownAndPlace')
AddEventHandler('pac_camp:server:checkTownAndPlace', function(itemName, town)
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end

    -- town == nil means wilderness (no town hash) = always allowed
    if town ~= nil then
        local allowed = Config.AllowedTowns[town]
        if allowed == false then
            VorpInv.CloseInv(src)
            VORPcore.NotifySimpleTop(src, Config.Text.Camp, Config.Text.NotInTown, 4000)
            return
        end
    end

    exports.oxmysql:execute(
        'SELECT COUNT(*) as count FROM pac_camp WHERE owner_identifier = @identifier AND owner_charid = @charid',
        {['@identifier']=Character.identifier,['@charid']=Character.charIdentifier},
        function(result)
            local count = result[1] and result[1].count or 0
            if count >= Config.MaxObject then
                VorpInv.CloseInv(src)
                VORPcore.NotifySimpleTop(src, Config.Text.Camp, Config.Text.MaxItems, 4000)
                return
            end
            VorpInv.CloseInv(src)
            TriggerClientEvent("pac_camp:client:placePropCamp", src, itemName)
        end
    )
end)

RegisterNetEvent("pac_camp:removeItem")
AddEventHandler("pac_camp:removeItem", function(itemName)
    local src = source
    if Config.Items[itemName] then VorpInv.subItem(src, itemName, 1) end
end)
