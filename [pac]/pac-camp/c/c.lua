-- pac-camp  c/c.lua  (client)  v2
local campsEntities  = {}
local dynamicDoors   = {}
local campsData      = {}
local doorStates     = {}
local renderDistance = Config.RenderDistance
local closestDoorEntity,  closestDoorId  = nil, nil
local closestCampEntity,  closestCampId  = nil, nil
local closestChestEntity, closestChestId = nil, nil
local targetEnabled = false

local campPromptGroup  = UipromptGroup:new(Config.Promp.Controls)
local campPickUpPrompt = Uiprompt:new(Config.Promp.Key.Pickut, Config.Promp.Collect, campPromptGroup)
campPickUpPrompt:setHoldMode(true)

local chestPromptGroup = UipromptGroup:new(Config.Promp.Chest)
local chestPrompt      = Uiprompt:new(Config.Promp.Key.Chest, Config.Promp.Chestopen, chestPromptGroup)
chestPrompt:setStandardMode(true)

local doorPromptGroup = UipromptGroup:new(Config.Promp.Door)
local doorPrompt      = Uiprompt:new(Config.Promp.Key.Door, Config.Promp.Dooropen, doorPromptGroup)
doorPrompt:setStandardMode(true)

local function RotationToDirection(rot)
    local radX = math.rad(rot.x)
    local radZ = math.rad(rot.z)
    local cosX = math.cos(radX)
    return vector3(-math.sin(radZ)*cosX, math.cos(radZ)*cosX, math.sin(radX))
end

local function RaycastFromCamera(distance)
    local ped  = PlayerPedId()
    local co   = GetGameplayCamCoord()
    local rot  = GetGameplayCamRot(2)
    local fwd  = RotationToDirection(rot)
    local dest = co + (fwd * distance)
    local ray  = StartShapeTestRay(co.x,co.y,co.z, dest.x,dest.y,dest.z, 1572865+16+32, ped, 0)
    local _, hit, _, _, eHit = GetShapeTestResult(ray)
    if hit == 1 and DoesEntityExist(eHit) then return eHit end
    return nil
end

local function RaycastToGround()
    local co  = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(2)
    local fwd = RotationToDirection(rot)
    local far = co + fwd * 40.0
    local ray = StartShapeTestRay(co.x,co.y,co.z, far.x,far.y,far.z, 1, PlayerPedId(), 0)
    local _, hit, hitCoords, hitNormal = GetShapeTestResultIncludingMaterial(ray)
    if hit == 1 then
        return hitCoords.x, hitCoords.y, hitCoords.z, hitNormal
    end
    local mx, my = (co.x+far.x)/2, (co.y+far.y)/2
    local found, gz = GetGroundZFor_3dCoord(mx, my, co.z, false)
    return mx, my, gz or co.z, vector3(0,0,1)
end

local function GetGroundInfo(x, y, z)
    local ray = StartShapeTestRay(x, y, z+3.0, x, y, z-3.0, 1, -1, 0)
    local _, hit, hitCoords, hitNormal = GetShapeTestResultIncludingMaterial(ray)
    if hit == 1 then return hitCoords.z, hitNormal end
    local found, gz = GetGroundZFor_3dCoord(x, y, z+1.0, false)
    return gz, vector3(0,0,1)
end

local function GetSlopeAngle(normal)
    if not normal then return 0.0 end
    return math.deg(math.acos(math.max(-1.0, math.min(1.0, normal.z))))
end

local function hideCampPrompt()
    campPromptGroup:setActive(false)
    campPickUpPrompt:setVisible(false)
    campPickUpPrompt:setEnabled(false)
    closestCampEntity, closestCampId = nil, nil
end

local function DrawCrosshair(isTarget)
    local dict = "blips"
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict)
        while not HasStreamedTextureDictLoaded(dict) do Wait(0) end
    end
    local r,g,b = 255,255,255
    if isTarget then r,g,b = 0,255,0 end
    DrawSprite(dict, "blip_ambient_eyewitness", 0.5, 0.5, 0.02, 0.03, 0.0, r, g, b, 255)
end

local function isChestObject(model)
    for _, v in pairs(Config.Chests) do
        if GetHashKey(v.object) == model then return true end
    end
    return false
end

local AllVeg      = 1+2+4+8+16+32+64+128+256
local VMT_Cull    = 1+2+4+8+16+32
local ActiveVegZones = {}

local function AddVeg(x,y,z,r)
    return Citizen.InvokeNative(0xFA50F79257745E74, x, y, z, r, VMT_Cull, AllVeg, 0)
end
local function RemVeg(sphere)
    Citizen.InvokeNative(0x9CF1836C03FB67A2, Citizen.PointerValueIntInitialized(sphere), 0)
end

-- -----------------------------------------------------------------------
-- Camp spawn / despawn
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:client:spawnCamps')
AddEventHandler('pac_camp:client:spawnCamps', function(data)
    campsData[data.id] = data
end)

CreateThread(function()
    while true do
        local ped     = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local activeCamps = {}
        for id, data in pairs(campsData) do
            local pos  = vector3(data.x, data.y, data.z)
            local dist = #(pCoords - pos)
            if dist < renderDistance and not campsEntities[id] then
                local mHash = GetHashKey(data.item.model)
                local isDyn = false
                for _, door in pairs(Config.Doors or {}) do
                    if door.modelDoor == data.item.model then isDyn=true; dynamicDoors[id]=GetHashKey(data.item.model); break end
                end
                local obj = CreateObjectNoOffset(mHash, data.x, data.y, data.z, false, false, isDyn)
                SetEntityRotation(obj,
                    tonumber(data.rotation.x or 0)%360,
                    tonumber(data.rotation.y or 0)%360,
                    tonumber(data.rotation.z or 0)%360
                )
                FreezeEntityPosition(obj, true)
                SetEntityAsMissionEntity(obj, true)
                campsEntities[id] = obj
                for _, item in pairs(Config.Items or {}) do
                    if item.model == data.item.model and item.veg then
                        ActiveVegZones[id] = AddVeg(data.x, data.y, data.z, item.veg); break
                    end
                end
            end
            local isDoor = false
            for _, door in pairs(Config.Doors or {}) do
                if door.modelDoor == data.item.model then isDoor=true; break end
            end
            if dist > renderDistance and campsEntities[id] and not isDoor then
                DeleteEntity(campsEntities[id]); campsEntities[id]=nil
                if ActiveVegZones[id] then RemVeg(ActiveVegZones[id]); ActiveVegZones[id]=nil end
                dynamicDoors[id]=nil
            end
            if dist < renderDistance then activeCamps[id]=true end
        end
        for id, sphere in pairs(ActiveVegZones) do
            if not activeCamps[id] then RemVeg(sphere); ActiveVegZones[id]=nil end
        end
        Wait(1000)
    end
end)

RegisterNetEvent('pac_camp:client:removeCamp')
AddEventHandler('pac_camp:client:removeCamp', function(uniqueId)
    if ActiveVegZones[uniqueId] then RemVeg(ActiveVegZones[uniqueId]); ActiveVegZones[uniqueId]=nil end
    local e = campsEntities[uniqueId]
    if e and DoesEntityExist(e) then DeleteEntity(e) end
    campsEntities[uniqueId]=nil; campsData[uniqueId]=nil; dynamicDoors[uniqueId]=nil
end)

Citizen.CreateThread(function()
    TriggerServerEvent('pac_camp:server:requestCamps')
end)

RegisterNetEvent('pac_camp:client:receiveCamps')
AddEventHandler('pac_camp:client:receiveCamps', function(camps)
    if camps then
        for _, data in pairs(camps) do TriggerEvent('pac_camp:client:spawnCamps', data) end
    end
end)

-- -----------------------------------------------------------------------
-- /camp command  (pickup target mode toggle)
-- -----------------------------------------------------------------------
RegisterCommand(Config.Commands.Camp, function()
    targetEnabled = not targetEnabled
    if targetEnabled then
        TriggerEvent("vorp:NotifyLeft", Config.Text.Target, Config.Text.Targeton, "generic_textures", "tick", 2000, "COLOR_GREEN")
        SendNUIMessage({action="showtarget", text=Config.Text.TargetActiveText..Config.Commands.Camp..Config.Text.TargetActiveText1})
    else
        TriggerEvent("vorp:NotifyLeft", Config.Text.Target, Config.Text.Targetoff, "menu_textures", "cross", 2000, "COLOR_RED")
        hideCampPrompt(); SendNUIMessage({action="hidetarget"})
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if targetEnabled then
            local eHit = RaycastFromCamera(10.0)
            local found = false
            closestCampEntity, closestCampId = nil, nil
            if eHit then
                for uid, ent in pairs(campsEntities) do
                    if eHit == ent then closestCampEntity=ent; closestCampId=uid; found=true; break end
                end
            end
            DrawCrosshair(found)
            if found then
                campPromptGroup:setActive(true); campPickUpPrompt:setVisible(true); campPickUpPrompt:setEnabled(true)
            else hideCampPrompt() end
        else hideCampPrompt() end
    end
end)

-- -----------------------------------------------------------------------
-- Chest + door proximity prompts
-- -----------------------------------------------------------------------
local function updateChestPrompts()
    local pCoords = GetEntityCoords(PlayerPedId())
    closestChestEntity, closestChestId = nil, nil
    local cd = 2.0
    for uid, ent in pairs(campsEntities or {}) do
        if DoesEntityExist(ent) and isChestObject(GetEntityModel(ent)) then
            local d = #(pCoords - GetEntityCoords(ent))
            if d <= cd then cd=d; closestChestEntity=ent; closestChestId=uid end
        end
    end
    local found = closestChestEntity ~= nil
    chestPromptGroup:setActive(found)
    if found then chestPrompt:setText(Config.Promp.Chestopen.." ID - "..tostring(closestChestId).." ") end
    chestPrompt:setVisible(found); chestPrompt:setEnabled(found)
end

local function updateDoorPrompts()
    local pCoords = GetEntityCoords(PlayerPedId())
    closestDoorEntity, closestDoorId = nil, nil
    local cd = 2.0
    for uid, ent in pairs(campsEntities or {}) do
        if DoesEntityExist(ent) and dynamicDoors[uid] then
            local d = #(pCoords - GetEntityCoords(ent))
            if d <= cd then cd=d; closestDoorEntity=ent; closestDoorId=uid end
        end
    end
    local found = closestDoorEntity ~= nil
    doorPromptGroup:setActive(found)
    if found then doorPrompt:setText(Config.Promp.Dooropen.." ID - "..tostring(closestDoorId)) end
    doorPrompt:setVisible(found); doorPrompt:setEnabled(found)
end

CreateThread(function() while true do Wait(500); updateDoorPrompts()  end end)
CreateThread(function() while true do Wait(500); updateChestPrompts() end end)

campPromptGroup:setOnHoldModeJustCompleted(function(group, prompt)
    if closestCampEntity and DoesEntityExist(closestCampEntity) and prompt==campPickUpPrompt and closestCampId then
        TriggerServerEvent('pac_camp:server:pickUpByOwner', closestCampId)
        hideCampPrompt()
    end
end)

chestPromptGroup:setOnStandardModeJustCompleted(function(group, prompt)
    if closestChestEntity and DoesEntityExist(closestChestEntity) and prompt==chestPrompt and closestChestId then
        TriggerServerEvent('pac_camp:server:openChest', closestChestId)
    end
end)

doorPromptGroup:setOnStandardModeJustCompleted(function(group, prompt)
    if closestDoorEntity and DoesEntityExist(closestDoorEntity) and closestDoorId then
        TriggerServerEvent('pac_camp:server:toggleDoor', closestDoorId)
    end
end)

UipromptManager:startEventThread()

RegisterNetEvent('pac_camp:client:toggleDoor')
AddEventHandler('pac_camp:client:toggleDoor', function(campId)
    local door = campsEntities[campId]
    if door and DoesEntityExist(door) then
        local rot  = GetEntityRotation(door, 2)
        local open = doorStates[campId] or false
        if not open then
            SetEntityRotation(door, rot.x, rot.y, rot.z+90.0, 2, true); doorStates[campId]=true
        else
            SetEntityRotation(door, rot.x, rot.y, rot.z-90.0, 2, true); doorStates[campId]=false
        end
    end
end)

-- -----------------------------------------------------------------------
-- Placement mode  (mouse-driven: ghost prop follows camera crosshair)
-- -----------------------------------------------------------------------
local function GetModelRadius(mHash)
    local mn, mx = GetModelDimensions(mHash)
    if mn and mx then
        return math.max(math.abs(mx.x-mn.x), math.abs(mx.y-mn.y), math.abs(mx.z-mn.z))
    end
    return 5.0
end

RegisterNetEvent('pac_camp:client:placePropCamp')
AddEventHandler('pac_camp:client:placePropCamp', function(itemName)
    if not Config.Items[itemName] then return end
    local modelName = Config.Items[itemName].model
    local modelHash = GetHashKey(modelName)
    if not modelHash then return end

    local ped = PlayerPedId()
    local ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.0))
    local groundZ = GetGroundInfo(ox, oy, oz)
    if groundZ then oz = groundZ end

    local tempObj = CreateObject(modelHash, ox, oy, oz, true, true, true)
    if not tempObj then return end

    FreezeEntityPosition(tempObj, true)
    SetEntityCollision(tempObj, false, false)
    SetEntityAlpha(tempObj, 180, false)
    SetEntityVisible(tempObj, true)
    SetModelAsNoLongerNeeded(modelHash)
    PlaceObjectOnGroundProperly(tempObj)

    local posX, posY, posZ = ox, oy, oz
    local rotZ      = 0.0
    local snapToGround = true
    local isPlacing    = true
    local dynRadius    = GetModelRadius(modelHash)
    local vegSphere    = AddVeg(posX, posY, posZ, dynRadius)

    SendNUIMessage({
        action   = "showcamp",
        title    = Config.ControlsPanel.title,
        controls = Config.ControlsPanel.controls,
        speed    = ""
    })

    CreateThread(function()
        while isPlacing do
            Wait(0)
            DisableControlAction(0, Config.Keys.cancelPlace,   true)
            DisableControlAction(0, Config.Keys.confirmPlace,  true)
            DisableControlAction(0, Config.Keys.placeOnGround, true)
            DisableControlAction(0, Config.Keys.increaseSpeed, true)
            DisableControlAction(0, Config.Keys.decreaseSpeed, true)

            local nx, ny, nz, norm = RaycastToGround()
            if nx then
                posX, posY = nx, ny
                if snapToGround then posZ = nz end
            end

            if IsDisabledControlJustPressed(0, Config.Keys.increaseSpeed) then rotZ = rotZ + 15.0 end
            if IsDisabledControlJustPressed(0, Config.Keys.decreaseSpeed) then rotZ = rotZ - 15.0 end
            if IsDisabledControlJustPressed(0, Config.Keys.placeOnGround) then snapToGround = true end

            SetEntityCoords(tempObj, posX, posY, posZ, true, true, true, false)
            SetEntityRotation(tempObj, 0.0, 0.0, rotZ, 2, true)
            if vegSphere then RemVeg(vegSphere) end
            vegSphere = AddVeg(posX, posY, posZ, dynRadius)

            if IsDisabledControlJustPressed(0, Config.Keys.confirmPlace) then
                local _, surfNormal = GetGroundInfo(posX, posY, posZ)
                local slope = GetSlopeAngle(surfNormal)
                if slope > Config.MaxSlopeAngle then
                    TriggerEvent("vorp:NotifyLeft", Config.Text.Camp, Config.Text.NotFlat, "menu_textures", "cross", 3000, "COLOR_RED")
                else
                    isPlacing = false
                    SendNUIMessage({action="hidecamp"})
                    if DoesEntityExist(tempObj) then DeleteObject(tempObj) end
                    if vegSphere then RemVeg(vegSphere); vegSphere=nil end
                    TriggerServerEvent('pac_camp:server:savecampOwner', vector3(posX,posY,posZ), vector3(0.0,0.0,rotZ), itemName)
                    TriggerServerEvent("pac_camp:removeItem", itemName)
                    TriggerEvent("vorp:NotifyLeft", Config.Text.Camp, Config.Text.Place, "generic_textures", "tick", 2000, "COLOR_GREEN")
                end
            end

            if IsDisabledControlJustPressed(0, Config.Keys.cancelPlace) then
                isPlacing = false
                SendNUIMessage({action="hidecamp"})
                if DoesEntityExist(tempObj) then DeleteObject(tempObj) end
                if vegSphere then RemVeg(vegSphere); vegSphere=nil end
                TriggerEvent("vorp:NotifyLeft", Config.Text.Camp, Config.Text.Cancel, "menu_textures", "cross", 2000, "COLOR_RED")
            end
        end
    end)
end)

-- -----------------------------------------------------------------------
-- Bedroll: sleep animation + set respawn
--
-- Strategy 1: TaskStartScenarioInPlaceHash with WORLD_HUMAN_SLEEP_GROUND
-- Strategy 2: anim dict (amb_camp@...) if scenario hash not available
-- Strategy 3: plain Wait (no visual, but respawn still sets correctly)
--
-- NOTE: IsTaskActive is a GTA5/FiveM native - NOT available in RedM.
--       We always attempt Strategy 1 directly.
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:client:useBedroll')
AddEventHandler('pac_camp:client:useBedroll', function()
    local ped     = PlayerPedId()
    local coords  = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    print('[pac-camp] useBedroll: starting sleep sequence')

    -- Strategy 1: scenario hash (built-in RDR3 sleep behaviour)
    local scenarioHash = GetHashKey("WORLD_HUMAN_SLEEP_GROUND")
    print('[pac-camp] useBedroll: trying scenario hash ' .. tostring(scenarioHash))
    local ok, err = pcall(function()
        TaskStartScenarioInPlaceHash(ped, scenarioHash, 5000, true, 0, 0, false)
    end)
    if ok then
        print('[pac-camp] useBedroll: scenario started OK, waiting 5.5s')
        Wait(5500)
        ClearPedTasksImmediately(ped)
        print('[pac-camp] useBedroll: scenario done')
    else
        -- Strategy 2: anim dict fallback
        print('[pac-camp] useBedroll: scenario failed (' .. tostring(err) .. '), trying anim dict')
        local dict = "amb_camp@world_human_sleep_ground@male@back@idle_a"
        print('[pac-camp] useBedroll: DoesAnimDictExist=' .. tostring(DoesAnimDictExist(dict)))
        if DoesAnimDictExist(dict) then
            RequestAnimDict(dict)
            local t = 0
            while not HasAnimDictLoaded(dict) and t < 60 do Wait(50); t = t + 1 end
            if HasAnimDictLoaded(dict) then
                print('[pac-camp] useBedroll: playing anim dict')
                TaskPlayAnim(ped, dict, "idle_a", 2.0, -2.0, 5000, 1, 0, false, false, false)
                Wait(5000)
                StopAnimTask(ped, dict, "idle_a", 2.0)
                RemoveAnimDict(dict)
            else
                print('[pac-camp] useBedroll: anim dict load timed out, plain wait')
                Wait(3000)
            end
        else
            -- Strategy 3: plain wait - no visual but respawn still saves
            print('[pac-camp] useBedroll: anim dict not in this build, plain wait')
            Wait(3000)
        end
    end

    print('[pac-camp] useBedroll: sending setBedrollRespawn')
    TriggerServerEvent('pac_camp:server:setBedrollRespawn', {x=coords.x, y=coords.y, z=coords.z, w=heading})
end)

RegisterNetEvent('pac_camp:client:applyRespawn')
AddEventHandler('pac_camp:client:applyRespawn', function(coords)
    Wait(1000)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w or 0.0)
end)

-- -----------------------------------------------------------------------
-- Town check
-- -----------------------------------------------------------------------
RegisterNetEvent('pac_camp:client:sendTownToServer')
AddEventHandler('pac_camp:client:sendTownToServer', function(itemName)
    TriggerServerEvent('pac_camp:server:checkTownAndPlace', itemName, GetCurrentTownName())
end)

function GetCurrentTownName()
    local h = Citizen.InvokeNative(0x43AD8FC02B429D33, GetEntityCoords(PlayerPedId()), 1)
    local map = {
        [GetHashKey("Annesburg")]  = "Annesburg",
        [GetHashKey("Armadillo")]  = "Armadillo",
        [GetHashKey("Blackwater")] = "Blackwater",
        [GetHashKey("Rhodes")]     = "Rhodes",
        [GetHashKey("StDenis")]    = "StDenis",
        [GetHashKey("Strawberry")] = "Strawberry",
        [GetHashKey("Tumbleweed")] = "Tumbleweed",
        [GetHashKey("Valentine")]  = "Valentine",
    }
    return map[h]
end

-- -----------------------------------------------------------------------
-- Chat suggestions
-- -----------------------------------------------------------------------
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/'..Config.Commands.Camp,        Config.Text.CampCmdDesc, {})
    TriggerEvent('chat:addSuggestion', '/'..Config.Commands.CampInvite,  Config.Text.InviteDesc,  {{name="serverID", help="Server ID of the player to invite"}})
    TriggerEvent('chat:addSuggestion', '/'..Config.Commands.CampKick,    Config.Text.KickDesc,    {{name="serverID", help="Server ID of the player to remove"}})
    TriggerEvent('chat:addSuggestion', '/'..Config.Commands.CampWho,     Config.Text.WhoDesc,     {})
end)

-- -----------------------------------------------------------------------
-- Cleanup
-- -----------------------------------------------------------------------
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for uid, _ in pairs(campsEntities) do
        if ActiveVegZones[uid] then RemVeg(ActiveVegZones[uid]); ActiveVegZones[uid]=nil end
        local e = campsEntities[uid]
        if e and DoesEntityExist(e) then DeleteEntity(e) end
        campsEntities[uid]=nil; campsData[uid]=nil; dynamicDoors[uid]=nil
    end
end)
