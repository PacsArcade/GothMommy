-- pac-camp  s/s.lua  (server)  v2
-- New in v2:
--   * Camp membership: /campinvite, /campkick, /campwho
--   * Chest + door access uses camp membership (not per-object shared_with)
--   * Bedroll item: sets character respawn point, sleep anim triggered client-side
local VORPcore = exports.vorp_core:GetCore()
local VorpInv  = exports.vorp_inventory:vorp_inventoryApi()
local Inv      = exports.vorp_inventory
local loadedCamps = {}

-- -----------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------
local function registerStorage(prefix, name, limit)
    if not Inv:isCustomInventoryRegistered(prefix) then
        Inv:registerInventory({
            id=prefix, name=name, limit=limit,
            acceptWeapons=true, shared=true, ignoreItemStackLimit=true,
            whitelistItems=false, UsePermissions=false, UseBlackList=false, whitelistWeapons=false,
        })
    end
end

local function isAdmin(group)
    for _, ag in ipairs(Config.AdminGroups) do
        if group == ag then return true end
    end
    return false
end

local function isChestModel(model)
    for _, c in ipairs(Config.Chests) do
        if c.object == model then return true end
    end
    return false
end

-- Returns true if charId/identifier is a member of owner's camp
local function isCampMember(ownerIdentifier, ownerCharid, memberIdentifier, memberCharid, cb)
    exports.oxmysql:execute(
        'SELECT id FROM pac_camp_members WHERE owner_identifier=@oi AND owner_charid=@oc AND member_identifier=@mi AND member_charid=@mc',
        {['@oi']=ownerIdentifier, ['@oc']=ownerCharid, ['@mi']=memberIdentifier, ['@mc']=memberCharid},
        function(rows) cb(rows and #rows > 0) end
    )
end

-- -----------------------------------------------------------------------
-- Startup: load all saved camps
-- -----------------------------------------------------------------------
AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    exports.oxmysql:execute('SELECT * FROM pac_camp', {}, function(rows)
        if rows then
            loadedCamps = {}
            for _, r in pairs(rows) do
                table.insert(loadedCamps, {
                    id=r.id, x=r.x, y=r.y, z=r.z,
                    rotation={x=r.rot_x, y=r.rot_y, z=r.rot_z},
                    item={name=r.item_name, model=r.item_model},
                    owner_identifier=r.owner_identifier,
                    owner_charid=r.owner_charid
                })
            end
        end
    end)
end)

-- -----------------------------------------------------------------------
-- Send camps to connecting player
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:server:requestCamps')
AddEventHandler('pac_camp:server:requestCamps', function()
    TriggerClientEvent('pac_camp:client:receiveCamps', source, loadedCamps)
end)

-- -----------------------------------------------------------------------
-- Place prop
-- -----------------------------------------------------------------------
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
        ['@id']=Char.identifier, ['@cid']=Char.charIdentifier,
        ['@x']=coords.x, ['@y']=coords.y, ['@z']=coords.z,
        ['@rx']=rotation.x, ['@ry']=rotation.y, ['@rz']=rotation.z,
        ['@iname']=itemName, ['@imodel']=model
    }, function(result)
        if result and result.insertId then
            local data = {
                id=result.insertId, x=coords.x, y=coords.y, z=coords.z,
                rotation={x=rotation.x, y=rotation.y, z=rotation.z},
                item={name=itemName, model=model},
                owner_identifier=Char.identifier,
                owner_charid=Char.charIdentifier
            }
            table.insert(loadedCamps, data)
            TriggerClientEvent('pac_camp:client:spawnCamps', -1, data)
        end
    end)
end)

-- -----------------------------------------------------------------------
-- Pick up prop (owner or admin only)
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:server:pickUpByOwner')
AddEventHandler('pac_camp:server:pickUpByOwner', function(uid)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    local group = Char.group

    local function doRemove(row)
        TriggerClientEvent('pac_camp:client:removeCamp', -1, uid)
        for i, c in ipairs(loadedCamps) do
            if c.id == uid then table.remove(loadedCamps, i); break end
        end
        exports.oxmysql:execute('DELETE FROM pac_camp WHERE id = ?', {uid}, function(res)
            local aff = res and (res.affectedRows or res.affected_rows or res.changes)
            if aff and aff > 0 then
                if row.item_name then VorpInv.addItem(src, row.item_name, 1) end
                VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Picked, "generic_textures", "tick", 4000, "COLOR_GREEN")
            end
        end)
    end

    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {uid}, function(rows)
        if not rows or #rows == 0 then
            VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Dont, "menu_textures", "cross", 3000, "COLOR_RED"); return
        end
        local row = rows[1]
        local isOwner = (row.owner_identifier == Char.identifier and row.owner_charid == Char.charIdentifier)
        if not (isOwner or isAdmin(group)) then
            VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.Dont, "menu_textures", "cross", 3000, "COLOR_RED"); return
        end
        if not isChestModel(row.item_model) then doRemove(row); return end
        -- Chest must be empty before pickup
        local invID = "camp_storage_"..uid
        if exports.vorp_inventory:isCustomInventoryRegistered(invID) then
            exports.vorp_inventory:getCustomInventoryItems(invID, function(items)
                exports.vorp_inventory:getCustomInventoryWeapons(invID, function(weapons)
                    items = items or {}; weapons = weapons or {}
                    if #items > 0 or #weapons > 0 then
                        VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.chestfull, "menu_textures", "cross", 3000, "COLOR_RED")
                    else doRemove(row) end
                end)
            end)
        else doRemove(row) end
    end)
end)

-- -----------------------------------------------------------------------
-- Open chest  (owner OR camp member)
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:server:openChest')
AddEventHandler('pac_camp:server:openChest', function(campId)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end

    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {campId}, function(rows)
        if not rows or #rows == 0 then return end
        local row = rows[1]
        local isOwner = (row.owner_identifier == Char.identifier and row.owner_charid == Char.charIdentifier)
        if isOwner then
            -- Owner: open immediately
            local prefix = "camp_storage_"..campId
            local cap = 1000
            for _, v in pairs(Config.Chests) do
                if v.object == row.item_model then cap = v.capacity; break end
            end
            registerStorage(prefix, Config.Text.StorageName, cap)
            Inv:openInventory(src, prefix)
        else
            -- Check camp membership
            isCampMember(row.owner_identifier, row.owner_charid, Char.identifier, Char.charIdentifier, function(member)
                if not member then
                    VORPcore.NotifyLeft(src, Config.Text.Chest, Config.Text.Dontchest, "menu_textures", "cross", 2000, "COLOR_RED"); return
                end
                local prefix = "camp_storage_"..campId
                local cap = 1000
                for _, v in pairs(Config.Chests) do
                    if v.object == row.item_model then cap = v.capacity; break end
                end
                registerStorage(prefix, Config.Text.StorageName, cap)
                Inv:openInventory(src, prefix)
            end)
        end
    end)
end)

-- -----------------------------------------------------------------------
-- Toggle door  (owner OR camp member)
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:server:toggleDoor')
AddEventHandler('pac_camp:server:toggleDoor', function(campId)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end

    exports.oxmysql:execute('SELECT * FROM pac_camp WHERE id = ?', {campId}, function(rows)
        if not rows or #rows == 0 then return end
        local row = rows[1]
        local isOwner = (row.owner_identifier == Char.identifier and row.owner_charid == Char.charIdentifier)
        if isOwner then
            TriggerClientEvent('pac_camp:client:toggleDoor', -1, campId); return
        end
        isCampMember(row.owner_identifier, row.owner_charid, Char.identifier, Char.charIdentifier, function(member)
            if not member then
                VORPcore.NotifyLeft(src, Config.Text.Door, Config.Text.Dontdoor, "menu_textures", "cross", 2000, "COLOR_RED"); return
            end
            TriggerClientEvent('pac_camp:client:toggleDoor', -1, campId)
        end)
    end)
end)

-- -----------------------------------------------------------------------
-- /campinvite [serverId]  -  invite a player into your camp
-- -----------------------------------------------------------------------
RegisterCommand(Config.Commands.CampInvite, function(source, args)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end

    local tPid = tonumber(args[1])
    if not tPid then
        VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.InviteUsage, "menu_textures", "cross", 3000, "COLOR_RED"); return
    end
    local tUser = VORPcore.getUser(tPid)
    if not tUser then
        VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return
    end
    local tChar = tUser.getUsedCharacter
    if not tChar then
        VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return
    end
    if tChar.charIdentifier == Char.charIdentifier then
        VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.InviteSelf, "menu_textures", "cross", 3000, "COLOR_RED"); return
    end

    exports.oxmysql:execute(
        'INSERT IGNORE INTO pac_camp_members (owner_identifier,owner_charid,member_identifier,member_charid) VALUES (@oi,@oc,@mi,@mc)',
        {['@oi']=Char.identifier, ['@oc']=Char.charIdentifier, ['@mi']=tChar.identifier, ['@mc']=tChar.charIdentifier},
        function(result)
            local aff = result and (result.affectedRows or result.affected_rows or result.changes or 0)
            if aff and aff > 0 then
                local tName = tChar.firstname.." "..tChar.lastname
                VORPcore.NotifyLeft(src, Config.Text.Camp,
                    Config.Text.InviteSuccess:gsub("{name}", tName),
                    "generic_textures", "tick", 3000, "COLOR_GREEN")
                VORPcore.NotifyLeft(tPid, Config.Text.Camp,
                    Config.Text.InviteReceived:gsub("{name}", Char.firstname.." "..Char.lastname),
                    "generic_textures", "tick", 4000, "COLOR_GREEN")
            else
                VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.AlreadyMember, "menu_textures", "cross", 3000, "COLOR_RED")
            end
        end
    )
end, false)

-- -----------------------------------------------------------------------
-- /campkick [serverId]  -  remove a player from your camp
-- -----------------------------------------------------------------------
RegisterCommand(Config.Commands.CampKick, function(source, args)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end

    local tPid = tonumber(args[1])
    if not tPid then
        VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.KickUsage, "menu_textures", "cross", 3000, "COLOR_RED"); return
    end
    local tUser = VORPcore.getUser(tPid)
    if not tUser then
        VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return
    end
    local tChar = tUser.getUsedCharacter
    if not tChar then
        VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return
    end

    exports.oxmysql:execute(
        'DELETE FROM pac_camp_members WHERE owner_identifier=@oi AND owner_charid=@oc AND member_identifier=@mi AND member_charid=@mc',
        {['@oi']=Char.identifier, ['@oc']=Char.charIdentifier, ['@mi']=tChar.identifier, ['@mc']=tChar.charIdentifier},
        function(result)
            local aff = result and (result.affectedRows or result.affected_rows or result.changes or 0)
            if aff and aff > 0 then
                local tName = tChar.firstname.." "..tChar.lastname
                VORPcore.NotifyLeft(src, Config.Text.Camp,
                    Config.Text.KickSuccess:gsub("{name}", tName),
                    "generic_textures", "tick", 3000, "COLOR_GREEN")
                VORPcore.NotifyLeft(tPid, Config.Text.Camp,
                    Config.Text.KickReceived:gsub("{name}", Char.firstname.." "..Char.lastname),
                    "menu_textures", "cross", 4000, "COLOR_RED")
            else
                VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.NotMember, "menu_textures", "cross", 3000, "COLOR_RED")
            end
        end
    )
end, false)

-- -----------------------------------------------------------------------
-- /campwho  -  list your current camp members
-- -----------------------------------------------------------------------
RegisterCommand(Config.Commands.CampWho, function(source, args)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end

    exports.oxmysql:execute(
        'SELECT member_identifier, member_charid FROM pac_camp_members WHERE owner_identifier=@oi AND owner_charid=@oc',
        {['@oi']=Char.identifier, ['@oc']=Char.charIdentifier},
        function(rows)
            if not rows or #rows == 0 then
                VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.NoMembers, "generic_textures", "tick", 3000, "COLOR_WHITE"); return
            end
            -- Build a name list by cross-referencing online players
            local names = {}
            for _, row in ipairs(rows) do
                local found = false
                for pid = 0, GetNumPlayerIndices()-1 do
                    local p = GetPlayerFromIndex(pid)
                    local pUser = VORPcore.getUser(p)
                    if pUser then
                        local pChar = pUser.getUsedCharacter
                        if pChar and pChar.identifier == row.member_identifier and pChar.charIdentifier == row.member_charid then
                            table.insert(names, pChar.firstname.." "..pChar.lastname.." (online)")
                            found = true; break
                        end
                    end
                end
                if not found then
                    table.insert(names, "Char #"..row.member_charid.." (offline)")
                end
            end
            local msg = Config.Text.MemberList.." "..table.concat(names, ", ")
            VORPcore.NotifyLeft(src, Config.Text.Camp, msg, "generic_textures", "tick", 6000, "COLOR_WHITE")
        end
    )
end, false)

-- -----------------------------------------------------------------------
-- Bedroll: set respawn point
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:server:setBedrollRespawn')
AddEventHandler('pac_camp:server:setBedrollRespawn', function(coords)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    exports.oxmysql:execute(
        'INSERT INTO pac_camp_respawn (identifier,charid,x,y,z,heading) VALUES (@id,@cid,@x,@y,@z,@h) ON DUPLICATE KEY UPDATE x=@x, y=@y, z=@z, heading=@h',
        {['@id']=Char.identifier, ['@cid']=Char.charIdentifier, ['@x']=coords.x, ['@y']=coords.y, ['@z']=coords.z, ['@h']=coords.w or 0.0},
        function()
            VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.BedrollSet, "generic_textures", "tick", 3000, "COLOR_GREEN")
        end
    )
end)

-- Apply bedroll respawn on character spawn (hook into vorp_character spawn event)
AddEventHandler('vorp_character:spawnAChar', function(source, data)
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    exports.oxmysql:execute(
        'SELECT x,y,z,heading FROM pac_camp_respawn WHERE identifier=@id AND charid=@cid',
        {['@id']=Char.identifier, ['@cid']=Char.charIdentifier},
        function(rows)
            if rows and #rows > 0 then
                local r = rows[1]
                TriggerClientEvent('pac_camp:client:applyRespawn', src, {x=r.x, y=r.y, z=r.z, w=r.heading})
            end
        end
    )
end)

-- -----------------------------------------------------------------------
-- Town check + max object check before placing
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:server:checkTownAndPlace')
AddEventHandler('pac_camp:server:checkTownAndPlace', function(itemName, town)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    if town ~= nil then
        if Config.AllowedTowns[town] == false then
            VorpInv.CloseInv(src)
            VORPcore.NotifySimpleTop(src, Config.Text.Camp, Config.Text.NotInTown, 4000); return
        end
    end
    exports.oxmysql:execute(
        'SELECT COUNT(*) as count FROM pac_camp WHERE owner_identifier=@id AND owner_charid=@cid',
        {['@id']=Char.identifier, ['@cid']=Char.charIdentifier},
        function(result)
            local count = result[1] and result[1].count or 0
            if count >= Config.MaxObject then
                VorpInv.CloseInv(src)
                VORPcore.NotifySimpleTop(src, Config.Text.Camp, Config.Text.MaxItems, 4000); return
            end
            VorpInv.CloseInv(src)
            TriggerClientEvent('pac_camp:client:placePropCamp', src, itemName)
        end
    )
end)

-- -----------------------------------------------------------------------
-- Remove item from inventory after placement
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:removeItem')
AddEventHandler('pac_camp:removeItem', function(itemName)
    if Config.Items[itemName] then VorpInv.subItem(source, itemName, 1) end
end)

-- -----------------------------------------------------------------------
-- Register all usable items  (runs last so Config.Items is populated)
-- -----------------------------------------------------------------------
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

-- Bedroll registered separately (no town/placement check - it sets respawn)
VorpInv.RegisterUsableItem('bedroll', function(data)
    local src  = data.source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    TriggerClientEvent('pac_camp:client:useBedroll', src)
end)
