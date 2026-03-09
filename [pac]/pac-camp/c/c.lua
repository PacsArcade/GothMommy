-- pac-camp  c/c.lua  (client)
-- Based on rs_camp by riversafe. Goth Mommy RP fixes:
--   * Auto ground-snap on placement start
--   * Continuous ground-snap while moving (F re-enables after manual override)
--   * Flatness check on confirm (Config.MaxSlopeAngle)
--   * All net events renamed pac_camp:

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

-- Downward ray to find ground Z and surface normal at (x,y)
local function GetGroundInfo(x, y, z)
    local ray = StartShapeTestRay(x, y, z+3.0, x, y, z-3.0, 1, -1, 0)
    local _, hit, hitCoords, hitNormal = GetShapeTestResultIncludingMaterial(ray)
    if hit == 1 then return hitCoords.z, hitNormal end
    local found, gz = GetGroundZFor_3dCoord(x, y, z+1.0, false)
    return gz, vector3(0,0,1)
end

-- Degrees off vertical (0=flat, 90=wall)
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

RegisterNetEvent('pac_camp:client:spawnCamps')
AddEventHandler('pac_camp:client:spawnCamps', function(data)
    campsData[data.id] = data
end)

CreateThread(function()
    while true do
        local ped   = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local activeCamps = {}
        for id, data in pairs(campsData) do
            local pos  = vector3(data.x, data.y, data.z)
            local dist = #(pCoords - pos)
            if dist < renderDistance and not campsEntities[id] then
                local mHash   = GetHashKey(data.item.model)
                local isDyn   = false
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

    -- Auto snap to ground on spawn
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

    local snapped   = GetEntityCoords(tempObj, true)
    local posX, posY, posZ = snapped.x, snapped.y, snapped.z
    local rotX, rotY, rotZ = 0.0, 0.0, 0.0
    local posStep   = 0.1
    local rotStep   = posStep * 10
    local snapToGround = true
    local isPlacing = true
    local dynRadius = GetModelRadius(modelHash)
    local vegSphere = AddVeg(posX, posY, posZ, dynRadius)

    SendNUIMessage({
        action   = "showcamp",
        title    = Config.ControlsPanel.title,
        controls = Config.ControlsPanel.controls,
        speed    = Config.Text.SpeedLabel..": "..string.format("%.2f", posStep)
    })

    local function refreshUI()
        SendNUIMessage({
            action   = "showcamp",
            title    = Config.ControlsPanel.title,
            controls = Config.ControlsPanel.controls,
            speed    = Config.Text.SpeedLabel..": "..string.format("%.2f", posStep)
        })
    end

    CreateThread(function()
        while isPlacing do
            Wait(0)
            for _, k in pairs(Config.Keys) do DisableControlAction(0, k, true) end

            local moved = false

            if IsDisabledControlJustPressed(0, Config.Keys.moveForward)  then posY=posY+posStep; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.moveBackward) then posY=posY-posStep; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.moveLeft)     then posX=posX-posStep; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.moveRight)    then posX=posX+posStep; moved=true end
            -- 7/8 override snap so player can raise/lower off ground
            if IsDisabledControlJustPressed(0, Config.Keys.moveUp)   then posZ=posZ+posStep; snapToGround=false; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.moveDown) then posZ=posZ-posStep; snapToGround=false; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateRightZ) then rotZ=rotZ+rotStep; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateLeftZ)  then rotZ=rotZ-rotStep; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateUpX)    then rotX=rotX+rotStep; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateDownX)  then rotX=rotX-rotStep; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateRightY) then rotY=rotY+rotStep; moved=true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateLeftY)  then rotY=rotY-rotStep; moved=true end
            -- F = manual snap + re-enable continuous
            if IsDisabledControlJustPressed(0, Config.Keys.placeOnGround) then snapToGround=true; moved=true end

            if IsDisabledControlJustPressed(0, Config.Keys.increaseSpeed) then
                posStep=math.min(posStep+0.01, 5.0); rotStep=posStep*10; refreshUI()
            end
            if IsDisabledControlJustPressed(0, Config.Keys.decreaseSpeed) then
                posStep=math.max(posStep-0.01, 0.01); rotStep=posStep*10; refreshUI()
            end

            -- Continuous ground snap
            if snapToGround then
                local gz = GetGroundInfo(posX, posY, posZ)
                if gz then posZ = gz end
            end

            if moved then
                SetEntityCoords(tempObj, posX, posY, posZ, true, true, true, false)
                SetEntityRotation(tempObj, rotX, rotY, rotZ, 2, true)
                if vegSphere then RemVeg(vegSphere) end
                vegSphere = AddVeg(posX, posY, posZ, dynRadius)
            end

            -- CONFIRM
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
                    TriggerServerEvent('pac_camp:server:savecampOwner', vector3(posX,posY,posZ), vector3(rotX,rotY,rotZ), itemName)
                    TriggerServerEvent("pac_camp:removeItem", itemName)
                    TriggerEvent("vorp:NotifyLeft", Config.Text.Camp, Config.Text.Place, "generic_textures", "tick", 2000, "COLOR_GREEN")
                end
            end

            -- CANCEL
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

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/'..Config.Commands.Shareperms, Config.Text.Shared, {
        {name=Config.Text.Corret, help=Config.Text.Corret},
        {name=Config.Text.Sharecorret, help=Config.Text.Playerpermi}
    })
    TriggerEvent('chat:addSuggestion', '/'..Config.Commands.Unshareperms, Config.Text.Remove, {
        {name=Config.Text.Corret, help=Config.Text.Corret}
    })
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

RegisterNetEvent('pac_camp:client:sendTownToServer')
AddEventHandler('pac_camp:client:sendTownToServer', function(itemName)
    TriggerServerEvent('pac_camp:server:checkTownAndPlace', itemName, GetCurrentTownName())
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for uid, _ in pairs(campsEntities) do
        if ActiveVegZones[uid] then RemVeg(ActiveVegZones[uid]); ActiveVegZones[uid]=nil end
        local e = campsEntities[uid]
        if e and DoesEntityExist(e) then DeleteEntity(e) end
        campsEntities[uid]=nil; campsData[uid]=nil; dynamicDoors[uid]=nil
    end
end)
