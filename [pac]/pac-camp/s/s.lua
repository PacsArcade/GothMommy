-- pac-camp  s/s.lua  (server)  v2
local VORPcore = exports.vorp_core:GetCore()
local VorpInv  = exports.vorp_inventory:vorp_inventoryApi()
local Inv      = exports.vorp_inventory
local loadedCamps = {}

local function getAllUsableItemNames()
    local names = {}
    for itemName, _ in pairs(Config.Items) do
        table.insert(names, itemName)
    end
    table.insert(names, 'bedroll')
    return names
end

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

local function isCampMember(ownerIdentifier, ownerCharid, memberIdentifier, memberCharid, cb)
    exports.oxmysql:execute(
        'SELECT id FROM pac_camp_members WHERE owner_identifier=@oi AND owner_charid=@oc AND member_identifier=@mi AND member_charid=@mc',
        {['@oi']=ownerIdentifier, ['@oc']=ownerCharid, ['@mi']=memberIdentifier, ['@mc']=memberCharid},
        function(rows) cb(rows and #rows > 0) end
    )
end

local function unregisterAllUsableItems()
    for _, name in ipairs(getAllUsableItemNames()) do
        exports.vorp_inventory:unRegisterUsableItem(name)
    end
end

local function registerAllUsableItems()
    unregisterAllUsableItems()

    for itemName, _ in pairs(Config.Items) do
        exports.vorp_inventory:registerUsableItem(itemName, function(data)
            local src  = data.source
            local User = VORPcore.getUser(src)
            if not User then return end
            local Char = User.getUsedCharacter
            if not Char then return end
            TriggerClientEvent('pac_camp:client:sendTownToServer', src, itemName)
        end)
    end

    -- Bedroll with full trace logging
    exports.vorp_inventory:registerUsableItem('bedroll', function(data)
        print('[pac-camp] BEDROLL USE CALLBACK FIRED - source: ' .. tostring(data and data.source))
        local src  = data.source
        local User = VORPcore.getUser(src)
        if not User then
            print('[pac-camp] BEDROLL ERROR: getUser returned nil for source ' .. tostring(src))
            return
        end
        local Char = User.getUsedCharacter
        if not Char then
            print('[pac-camp] BEDROLL ERROR: getUsedCharacter returned nil')
            return
        end
        print('[pac-camp] BEDROLL: triggering client event useBedroll for src ' .. tostring(src))
        TriggerClientEvent('pac_camp:client:useBedroll', src)
    end)

    local count = 0
    for _ in pairs(Config.Items) do count = count + 1 end
    print('[pac-camp] Registered ' .. count + 1 .. ' usable items (including bedroll)')
end

-- -----------------------------------------------------------------------
-- Startup
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
    Citizen.CreateThread(function()
        Wait(500)
        registerAllUsableItems()
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    unregisterAllUsableItems()
    print('[pac-camp] Unregistered all usable items')
end)

-- -----------------------------------------------------------------------
-- DEBUG COMMAND: /bedrolldebug
-- Run this while holding a bedroll to diagnose the Use button issue.
-- Dumps: item in DB, item in VORP ServerItems cache, item in your inventory,
--        UsableItemsFunctions registration status.
-- -----------------------------------------------------------------------
RegisterCommand('bedrolldebug', function(source, args)
    local src = source
    local User = VORPcore.getUser(src)
    if not User then print('[bedrolldebug] no user'); return end
    local Char = User.getUsedCharacter
    if not Char then print('[bedrolldebug] no char'); return end

    print('[bedrolldebug] ========== BEDROLL DEBUG ==========')
    print('[bedrolldebug] player src=' .. tostring(src) .. ' identifier=' .. tostring(Char.identifier))

    -- 1. Check DB
    exports.oxmysql:execute("SELECT item, label, usable, type FROM items WHERE item = 'bedroll'", {}, function(rows)
        if rows and #rows > 0 then
            local r = rows[1]
            print('[bedrolldebug] DB: item=' .. r.item .. ' label=' .. r.label .. ' usable=' .. tostring(r.usable) .. ' type=' .. r.type)
        else
            print('[bedrolldebug] DB: bedroll NOT FOUND in items table!')
        end
    end)

    -- 2. Check player's inventory for bedroll
    exports.oxmysql:execute(
        "SELECT id, item, count FROM user_items WHERE identifier = ? AND item = 'bedroll'",
        { Char.identifier },
        function(rows)
            if rows and #rows > 0 then
                for _, r in ipairs(rows) do
                    print('[bedrolldebug] user_items: id=' .. tostring(r.id) .. ' item=' .. r.item .. ' count=' .. tostring(r.count))
                end
            else
                print('[bedrolldebug] user_items: no bedroll rows found for identifier=' .. tostring(Char.identifier))
            end
        end
    )

    -- 3. Check VORP in-memory registration
    -- We can probe this indirectly by attempting to call GetResourceExports
    -- The real check is whether vorp_inventory's UsableItemsFunctions has 'bedroll'
    -- We can't read that table directly, but we can see if the 20000ms warning fires
    print('[bedrolldebug] Sending test use event to vorp_inventory...')
    TriggerEvent('vorp_inventory:Server:OnItemUse', { source = src, item = { item = 'bedroll', name = 'bedroll' } })

    -- 4. Try firing the bedroll callback directly as a test
    -- This tells us if OUR callback works even if VORP isn't calling it
    print('[bedrolldebug] Firing useBedroll client event directly (bypass VORP)...')
    TriggerClientEvent('pac_camp:client:useBedroll', src)

    print('[bedrolldebug] ========== END DEBUG ==========')
    print('[bedrolldebug] Check above for DB/inventory results.')
    print('[bedrolldebug] If sleep anim plays NOW -> VORP is not calling our callback.')
    print('[bedrolldebug] If sleep anim does NOT play -> client event is broken.')
    VORPcore.NotifyLeft(src, 'Debug', 'Bedroll debug fired - check server console', 'generic_textures', 'tick', 4000, 'COLOR_WHITE')
end, false)

-- Net event to confirm client received useBedroll
RegisterNetEvent('pac_camp:debug:clientConfirm')
AddEventHandler('pac_camp:debug:clientConfirm', function(msg)
    print('[pac-camp] CLIENT CONFIRM from src=' .. tostring(source) .. ': ' .. tostring(msg))
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
-- Pick up prop
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
-- Open chest (owner OR camp member)
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
            local prefix = "camp_storage_"..campId
            local cap = 1000
            for _, v in pairs(Config.Chests) do if v.object == row.item_model then cap = v.capacity; break end end
            registerStorage(prefix, Config.Text.StorageName, cap)
            Inv:openInventory(src, prefix)
        else
            isCampMember(row.owner_identifier, row.owner_charid, Char.identifier, Char.charIdentifier, function(member)
                if not member then
                    VORPcore.NotifyLeft(src, Config.Text.Chest, Config.Text.Dontchest, "menu_textures", "cross", 2000, "COLOR_RED"); return
                end
                local prefix = "camp_storage_"..campId
                local cap = 1000
                for _, v in pairs(Config.Chests) do if v.object == row.item_model then cap = v.capacity; break end end
                registerStorage(prefix, Config.Text.StorageName, cap)
                Inv:openInventory(src, prefix)
            end)
        end
    end)
end)

-- -----------------------------------------------------------------------
-- Toggle door (owner OR camp member)
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
        if isOwner then TriggerClientEvent('pac_camp:client:toggleDoor', -1, campId); return end
        isCampMember(row.owner_identifier, row.owner_charid, Char.identifier, Char.charIdentifier, function(member)
            if not member then
                VORPcore.NotifyLeft(src, Config.Text.Door, Config.Text.Dontdoor, "menu_textures", "cross", 2000, "COLOR_RED"); return
            end
            TriggerClientEvent('pac_camp:client:toggleDoor', -1, campId)
        end)
    end)
end)

-- -----------------------------------------------------------------------
-- /campinvite
-- -----------------------------------------------------------------------
RegisterCommand(Config.Commands.CampInvite, function(source, args)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    local tPid = tonumber(args[1])
    if not tPid then VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.InviteUsage, "menu_textures", "cross", 3000, "COLOR_RED"); return end
    local tUser = VORPcore.getUser(tPid)
    if not tUser then VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return end
    local tChar = tUser.getUsedCharacter
    if not tChar then VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return end
    if tChar.charIdentifier == Char.charIdentifier then VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.InviteSelf, "menu_textures", "cross", 3000, "COLOR_RED"); return end
    exports.oxmysql:execute(
        'INSERT IGNORE INTO pac_camp_members (owner_identifier,owner_charid,member_identifier,member_charid) VALUES (@oi,@oc,@mi,@mc)',
        {['@oi']=Char.identifier, ['@oc']=Char.charIdentifier, ['@mi']=tChar.identifier, ['@mc']=tChar.charIdentifier},
        function(result)
            local aff = result and (result.affectedRows or result.affected_rows or result.changes or 0)
            if aff and aff > 0 then
                VORPcore.NotifyLeft(src,  Config.Text.Camp, Config.Text.InviteSuccess:gsub("{name}", tChar.firstname.." "..tChar.lastname), "generic_textures", "tick", 3000, "COLOR_GREEN")
                VORPcore.NotifyLeft(tPid, Config.Text.Camp, Config.Text.InviteReceived:gsub("{name}", Char.firstname.." "..Char.lastname),  "generic_textures", "tick", 4000, "COLOR_GREEN")
            else
                VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.AlreadyMember, "menu_textures", "cross", 3000, "COLOR_RED")
            end
        end
    )
end, false)

-- -----------------------------------------------------------------------
-- /campkick
-- -----------------------------------------------------------------------
RegisterCommand(Config.Commands.CampKick, function(source, args)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    local tPid = tonumber(args[1])
    if not tPid then VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.KickUsage, "menu_textures", "cross", 3000, "COLOR_RED"); return end
    local tUser = VORPcore.getUser(tPid)
    if not tUser then VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return end
    local tChar = tUser.getUsedCharacter
    if not tChar then VORPcore.NotifyLeft(src, Config.Text.Perms, Config.Text.Playerno, "menu_textures", "cross", 3000, "COLOR_RED"); return end
    exports.oxmysql:execute(
        'DELETE FROM pac_camp_members WHERE owner_identifier=@oi AND owner_charid=@oc AND member_identifier=@mi AND member_charid=@mc',
        {['@oi']=Char.identifier, ['@oc']=Char.charIdentifier, ['@mi']=tChar.identifier, ['@mc']=tChar.charIdentifier},
        function(result)
            local aff = result and (result.affectedRows or result.affected_rows or result.changes or 0)
            if aff and aff > 0 then
                VORPcore.NotifyLeft(src,  Config.Text.Camp, Config.Text.KickSuccess:gsub("{name}", tChar.firstname.." "..tChar.lastname), "generic_textures", "tick", 3000, "COLOR_GREEN")
                VORPcore.NotifyLeft(tPid, Config.Text.Camp, Config.Text.KickReceived:gsub("{name}", Char.firstname.." "..Char.lastname),  "menu_textures", "cross", 4000, "COLOR_RED")
            else
                VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.NotMember, "menu_textures", "cross", 3000, "COLOR_RED")
            end
        end
    )
end, false)

-- -----------------------------------------------------------------------
-- /campwho
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
            local ownerLine = Config.Text.YouAreOwner
            if not rows or #rows == 0 then
                VORPcore.NotifyLeft(src, Config.Text.Camp, ownerLine.."\n"..Config.Text.NoMembers, "generic_textures", "tick", 4000, "COLOR_WHITE"); return
            end
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
                if not found then table.insert(names, "Char #"..row.member_charid.." (offline)") end
            end
            VORPcore.NotifyLeft(src, Config.Text.Camp, ownerLine.."\n"..Config.Text.MemberList.." "..table.concat(names, ", "), "generic_textures", "tick", 6000, "COLOR_WHITE")
        end
    )
end, false)

-- -----------------------------------------------------------------------
-- Bedroll respawn
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
        function() VORPcore.NotifyLeft(src, Config.Text.Camp, Config.Text.BedrollSet, "generic_textures", "tick", 3000, "COLOR_GREEN") end
    )
end)

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
-- Town check + place
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:server:checkTownAndPlace')
AddEventHandler('pac_camp:server:checkTownAndPlace', function(itemName, town)
    local src  = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Char = User.getUsedCharacter
    if not Char then return end
    if town ~= nil and Config.AllowedTowns[town] == false then
        VorpInv.CloseInv(src)
        VORPcore.NotifySimpleTop(src, Config.Text.Camp, Config.Text.NotInTown, 4000); return
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

RegisterNetEvent('pac_camp:removeItem')
AddEventHandler('pac_camp:removeItem', function(itemName)
    if Config.Items[itemName] then VorpInv.subItem(source, itemName, 1) end
end)
