-- pac-camp client.lua
-- Based on rs_camp by riversafe. Fixed for Goth Mommy RP:
--   - Auto ground-snap on placement start
--   - Continuous ground-snap during placement (no need to press F manually)
--   - Flatness check: rejects placement on slopes > Config.MaxSlopeAngle
--   - uiprompt bundled as standalone resource in [pac]/uiprompt

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
    local playerPed    = PlayerPedId()
    local coords       = GetGameplayCamCoord()
    local rotation     = GetGameplayCamRot(2)
    local forwardVec   = RotationToDirection(rotation)
    local dest         = coords + (forwardVec * distance)
    local rayHandle    = StartShapeTestRay(coords.x,coords.y,coords.z, dest.x,dest.y,dest.z, 1572865+16+32, playerPed, 0)
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
    if hit == 1 and DoesEntityExist(entityHit) then return entityHit end
    return nil
end

-- Returns the Z height of the ground directly below (x,y,z+2) using a downward ray.
-- Also returns the surface normal so we can check flatness.
local function GetGroundInfo(x, y, z)
    local rayHandle = StartShapeTestRay(
        x, y, z + 3.0,
        x, y, z - 3.0,
        1, -1, 0
    )
    local _, hit, hitCoords, hitNormal = GetShapeTestResultIncludingMaterial(rayHandle)
    if hit == 1 then
        return hitCoords.z, hitNormal
    end
    -- Fallback: use game's ground Z
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 1.0, false)
    return groundZ, vector3(0,0,1)
end

-- Returns slope angle in degrees from the surface normal (0 = flat, 90 = vertical wall)
local function GetSlopeAngle(normal)
    if not normal then return 0.0 end
    -- angle between normal and straight-up vector3(0,0,1)
    local dot = math.max(-1.0, math.min(1.0, normal.z))
    return math.deg(math.acos(dot))
end

local function hideCampPrompt()
    campPromptGroup:setActive(false)
    campPickUpPrompt:setVisible(false)
    campPickUpPrompt:setEnabled(false)
    closestCampEntity, closestCampId = nil, nil
end

local function DrawCrosshair(isTarget)
    local dict = "blips"
    local name = "blip_ambient_eyewitness"
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict)
        while not HasStreamedTextureDictLoaded(dict) do Wait(0) end
    end
    local r,g,b = 255,255,255
    if isTarget then r,g,b = 0,255,0 end
    DrawSprite(dict, name, 0.5, 0.5, 0.02, 0.03, 0.0, r, g, b, 255)
end

local function isChestObject(model)
    for _, v in pairs(Config.Chests) do
        if GetHashKey(v.object) == model then return true end
    end
    return false
end

local AllVegetation = 1+2+4+8+16+32+64+128+256
local VMT_Cull      = 1+2+4+8+16+32
local ActiveVegZones = {}

local function AddVegModifierSphere(x,y,z,r)
    return Citizen.InvokeNative(0xFA50F79257745E74, x, y, z, r, VMT_Cull, AllVegetation, 0)
end
local function RemoveVegModifierSphere(sphere, p1)
    return Citizen.InvokeNative(0x9CF1836C03FB67A2, Citizen.PointerValueIntInitialized(sphere), p1)
end

RegisterNetEvent('pac_camp:client:spawnCamps')
AddEventHandler('pac_camp:client:spawnCamps', function(data)
    campsData[data.id] = data
end)

CreateThread(function()
    while true do
        local playerPed    = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local activeCamps  = {}

        for id, data in pairs(campsData) do
            local pos  = vector3(data.x, data.y, data.z)
            local dist = #(playerCoords - pos)

            if dist < renderDistance and not campsEntities[id] then
                local modelHash = GetHashKey(data.item.model)
                local isDynamic = false
                for _, door in pairs(Config.Doors or {}) do
                    if door.modelDoor == data.item.model then
                        isDynamic = true
                        dynamicDoors[id] = GetHashKey(data.item.model)
                        break
                    end
                end
                local object = CreateObjectNoOffset(modelHash, data.x, data.y, data.z, false, false, isDynamic)
                SetEntityRotation(object,
                    tonumber(data.rotation.x or 0.0) % 360.0,
                    tonumber(data.rotation.y or 0.0) % 360.0,
                    tonumber(data.rotation.z or 0.0) % 360.0
                )
                FreezeEntityPosition(object, true)
                SetEntityAsMissionEntity(object, true)
                campsEntities[id] = object
                for _, item in pairs(Config.Items or {}) do
                    if item.model == data.item.model and item.veg then
                        ActiveVegZones[id] = AddVegModifierSphere(data.x, data.y, data.z, item.veg)
                        break
                    end
                end
            end

            local isDoor = false
            for _, door in pairs(Config.Doors or {}) do
                if door.modelDoor == data.item.model then isDoor = true; break end
            end

            if dist > renderDistance and campsEntities[id] and not isDoor then
                DeleteEntity(campsEntities[id])
                campsEntities[id] = nil
                if ActiveVegZones[id] then
                    RemoveVegModifierSphere(ActiveVegZones[id], 0)
                    ActiveVegZones[id] = nil
                end
                dynamicDoors[id] = nil
            end

            if dist < renderDistance then activeCamps[id] = true end
        end

        for id, sphere in pairs(ActiveVegZones) do
            if not activeCamps[id] then
                RemoveVegModifierSphere(sphere, 0)
                ActiveVegZones[id] = nil
            end
        end

        Wait(1000)
    end
end)

RegisterNetEvent('pac_camp:client:removeCamp')
AddEventHandler('pac_camp:client:removeCamp', function(uniqueId)
    if ActiveVegZones[uniqueId] then
        RemoveVegModifierSphere(ActiveVegZones[uniqueId], 0)
        ActiveVegZones[uniqueId] = nil
    end
    local entity = campsEntities[uniqueId]
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    campsEntities[uniqueId] = nil
    campsData[uniqueId]     = nil
    dynamicDoors[uniqueId]  = nil
end)

Citizen.CreateThread(function()
    TriggerServerEvent('pac_camp:server:requestCamps')
end)

RegisterNetEvent('pac_camp:client:receiveCamps')
AddEventHandler('pac_camp:client:receiveCamps', function(camps)
    if camps then
        for _, data in pairs(camps) do
            TriggerEvent('pac_camp:client:spawnCamps', data)
        end
    end
end)

RegisterCommand(Config.Commands.Camp, function()
    targetEnabled = not targetEnabled
    if targetEnabled then
        TriggerEvent("vorp:NotifyLeft", Config.Text.Target, Config.Text.Targeton, "generic_textures", "tick", 2000, "COLOR_GREEN")
        SendNUIMessage({ action="showtarget", text=Config.Text.TargetActiveText..Config.Commands.Camp..Config.Text.TargetActiveText1 })
    else
        TriggerEvent("vorp:NotifyLeft", Config.Text.Target, Config.Text.Targetoff, "menu_textures", "cross", 2000, "COLOR_RED")
        hideCampPrompt()
        SendNUIMessage({ action="hidetarget" })
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if targetEnabled then
            local entityHit = RaycastFromCamera(10.0)
            local found = false
            closestCampEntity, closestCampId = nil, nil
            if entityHit then
                for uniqueId, entity in pairs(campsEntities) do
                    if entityHit == entity then
                        closestCampEntity = entity
                        closestCampId = uniqueId
                        found = true
                        break
                    end
                end
            end
            DrawCrosshair(found)
            if found then
                campPromptGroup:setActive(true)
                campPickUpPrompt:setVisible(true)
                campPickUpPrompt:setEnabled(true)
            else
                hideCampPrompt()
            end
        else
            hideCampPrompt()
        end
    end
end)

local function updateChestPrompts()
    local playerPed    = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    closestChestEntity, closestChestId = nil, nil
    local closestDist = 2.0
    for uniqueId, entity in pairs(campsEntities or {}) do
        if DoesEntityExist(entity) and isChestObject(GetEntityModel(entity)) then
            local dist = #(playerCoords - GetEntityCoords(entity))
            if dist <= closestDist then
                closestDist = dist
                closestChestEntity = entity
                closestChestId = uniqueId
            end
        end
    end
    local found = closestChestEntity ~= nil
    chestPromptGroup:setActive(found)
    if found then chestPrompt:setText(Config.Promp.Chestopen.." ID - "..tostring(closestChestId).." ") end
    chestPrompt:setVisible(found)
    chestPrompt:setEnabled(found)
end

local function updateDoorPrompts()
    local playerPed    = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    closestDoorEntity, closestDoorId = nil, nil
    local closestDist = 2.0
    for uniqueId, entity in pairs(campsEntities or {}) do
        if DoesEntityExist(entity) and dynamicDoors[uniqueId] then
            local dist = #(playerCoords - GetEntityCoords(entity))
            if dist <= closestDist then
                closestDist = dist
                closestDoorEntity = entity
                closestDoorId = uniqueId
            end
        end
    end
    local found = closestDoorEntity ~= nil
    doorPromptGroup:setActive(found)
    if found then doorPrompt:setText(Config.Promp.Dooropen.." ID - "..tostring(closestDoorId)) end
    doorPrompt:setVisible(found)
    doorPrompt:setEnabled(found)
end

CreateThread(function() while true do Wait(500); updateDoorPrompts()  end end)
CreateThread(function() while true do Wait(500); updateChestPrompts() end end)

campPromptGroup:setOnHoldModeJustCompleted(function(group, prompt)
    if closestCampEntity and DoesEntityExist(closestCampEntity) then
        if prompt == campPickUpPrompt and closestCampId then
            TriggerServerEvent('pac_camp:server:pickUpByOwner', closestCampId)
            hideCampPrompt()
        end
    end
end)

chestPromptGroup:setOnStandardModeJustCompleted(function(group, prompt)
    if closestChestEntity and DoesEntityExist(closestChestEntity) then
        if prompt == chestPrompt and closestChestId then
            TriggerServerEvent('pac_camp:server:openChest', closestChestId)
        end
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
            SetEntityRotation(door, rot.x, rot.y, rot.z + 90.0, 2, true)
            doorStates[campId] = true
        else
            SetEntityRotation(door, rot.x, rot.y, rot.z - 90.0, 2, true)
            doorStates[campId] = false
        end
    end
end)

local function GetModelRadius(modelHash)
    local minDim, maxDim = GetModelDimensions(modelHash)
    if minDim and maxDim then
        return math.max(
            math.abs(maxDim.x - minDim.x),
            math.abs(maxDim.y - minDim.y),
            math.abs(maxDim.z - minDim.z)
        ) * 1.0
    end
    return 5.0
end

RegisterNetEvent('pac_camp:client:placePropCamp')
AddEventHandler('pac_camp:client:placePropCamp', function(itemName)
    if not Config.Items[itemName] then return end

    local modelName = Config.Items[itemName].model
    local modelHash = GetHashKey(modelName)
    if not modelHash then return end

    local playerPed = PlayerPedId()
    -- Start 4 units in front of the player
    local ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 4.0, 0.0))

    -- Snap to ground immediately on spawn
    local groundZ, normal = GetGroundInfo(ox, oy, oz)
    oz = groundZ

    local tempObj = CreateObject(modelHash, ox, oy, oz, true, true, true)
    if not tempObj then return end

    local dynamicRadius = GetModelRadius(modelHash)
    local posStep = 0.1
    local rotStep = posStep * 10
    local tempVegSphere = nil

    FreezeEntityPosition(tempObj, true)
    SetEntityCollision(tempObj, false, false)
    SetEntityAlpha(tempObj, 180, false)
    SetEntityVisible(tempObj, true)
    SetModelAsNoLongerNeeded(modelHash)

    -- Initial snap to ground properly
    PlaceObjectOnGroundProperly(tempObj)
    local snappedPos = GetEntityCoords(tempObj, true)
    local posX, posY, posZ = snappedPos.x, snappedPos.y, snappedPos.z
    local rotX, rotY, rotZ = 0.0, 0.0, 0.0

    tempVegSphere = AddVegModifierSphere(posX, posY, posZ, dynamicRadius)

    SendNUIMessage({
        action   = "showcamp",
        title    = Config.ControlsPanel.title,
        controls = Config.ControlsPanel.controls,
        speed    = Config.Text.SpeedLabel..": "..string.format("%.2f", posStep)
    })

    local isPlacing      = true
    local snapToGround   = true  -- continuous ground snap enabled by default

    CreateThread(function()
        while isPlacing do
            Wait(0)
            for _, keyCode in pairs(Config.Keys) do
                DisableControlAction(0, keyCode, true)
            end

            local moved = false

            if IsDisabledControlJustPressed(0, Config.Keys.moveForward)  then posY = posY + posStep; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.moveBackward) then posY = posY - posStep; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.moveLeft)     then posX = posX - posStep; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.moveRight)    then posX = posX + posStep; moved = true end

            -- moveUp/moveDown manually override snap temporarily
            if IsDisabledControlJustPressed(0, Config.Keys.moveUp)   then posZ = posZ + posStep; snapToGround = false; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.moveDown) then posZ = posZ - posStep; snapToGround = false; moved = true end

            if IsDisabledControlJustPressed(0, Config.Keys.rotateRightZ) then rotZ = rotZ + rotStep; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateLeftZ)  then rotZ = rotZ - rotStep; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateUpX)    then rotX = rotX + rotStep; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateDownX)  then rotX = rotX - rotStep; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateRightY) then rotY = rotY + rotStep; moved = true end
            if IsDisabledControlJustPressed(0, Config.Keys.rotateLeftY)  then rotY = rotY - rotStep; moved = true end

            -- F = manual snap + re-enable continuous snap
            if IsDisabledControlJustPressed(0, Config.Keys.placeOnGround) then
                snapToGround = true
                moved = true
            end

            if IsDisabledControlJustPressed(0, Config.Keys.increaseSpeed) then
                posStep = math.min(posStep + 0.01, 5.0)
                rotStep = posStep * 10
                SendNUIMessage({ action="showcamp", title=Config.ControlsPanel.title, controls=Config.ControlsPanel.controls, speed=Config.Text.SpeedLabel..": "..string.format("%.2f", posStep) })
            end
            if IsDisabledControlJustPressed(0, Config.Keys.decreaseSpeed) then
                posStep = math.max(posStep - 0.01, 0.01)
                rotStep = posStep * 10
                SendNUIMessage({ action="showcamp", title=Config.ControlsPanel.title, controls=Config.ControlsPanel.controls, speed=Config.Text.SpeedLabel..": "..string.format("%.2f", posStep) })
            end

            -- Continuously snap Z to ground when snap is enabled
            if snapToGround then
                local gZ, gNormal = GetGroundInfo(posX, posY, posZ)
                if gZ then posZ = gZ end
            end

            if moved then
                SetEntityCoords(tempObj, posX, posY, posZ, true, true, true, false)
                SetEntityRotation(tempObj, rotX, rotY, rotZ, 2, true)
                if tempVegSphere then RemoveVegModifierSphere(tempVegSphere, 0) end
                tempVegSphere = AddVegModifierSphere(posX, posY, posZ, dynamicRadius)
            end

            -- CONFIRM placement
            if IsDisabledControlJustPressed(0, Config.Keys.confirmPlace) then
                -- Flatness check
                local _, surfaceNormal = GetGroundInfo(posX, posY, posZ)
                local slopeAngle = GetSlopeAngle(surfaceNormal)
                if slopeAngle > Config.MaxSlopeAngle then
                    TriggerEvent("vorp:NotifyLeft", Config.Text.Camp, Config.Text.NotFlat, "menu_textures", "cross", 3000, "COLOR_RED")
                    -- Don't cancel, let player find a flatter spot
                else
                    isPlacing = false
                    SendNUIMessage({ action="hidecamp" })
                    if DoesEntityExist(tempObj) then DeleteObject(tempObj) end
                    if tempVegSphere then RemoveVegModifierSphere(tempVegSphere, 0); tempVegSphere = nil end
                    TriggerServerEvent('pac_camp:server:savecampOwner', vector3(posX,posY,posZ), vector3(rotX,rotY,rotZ), itemName)
                    TriggerServerEvent("pac_camp:removeItem", itemName)
                    TriggerEvent("vorp:NotifyLeft", Config.Text.Camp, Config.Text.Place, "generic_textures", "tick", 2000, "COLOR_GREEN")
                end
            end

            -- CANCEL placement
            if IsDisabledControlJustPressed(0, Config.Keys.cancelPlace) then
                isPlacing = false
                SendNUIMessage({ action="hidecamp" })
                if DoesEntityExist(tempObj) then DeleteObject(tempObj) end
                if tempVegSphere then RemoveVegModifierSphere(tempVegSphere, 0); tempVegSphere = nil end
                TriggerEvent("vorp:NotifyLeft", Config.Text.Camp, Config.Text.Cancel, "menu_textures", "cross", 2000, "COLOR_RED")
            end
        end
    end)
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/'..Config.Commands.Shareperms, Config.Text.Shared, {
        { name=Config.Text.Corret,    help=Config.Text.Corret },
        { name=Config.Text.Sharecorret, help=Config.Text.Playerpermi }
    })
    TriggerEvent('chat:addSuggestion', '/'..Config.Commands.Unshareperms, Config.Text.Remove, {
        { name=Config.Text.Corret, help=Config.Text.Corret }
    })
end)

function GetCurrentTownName()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local town_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, pedCoords, 1)
    local townNames = {
        [GetHashKey("Annesburg")]  = "Annesburg",
        [GetHashKey("Armadillo")]  = "Armadillo",
        [GetHashKey("Blackwater")] = "Blackwater",
        [GetHashKey("Rhodes")]     = "Rhodes",
        [GetHashKey("StDenis")]    = "StDenis",
        [GetHashKey("Strawberry")] = "Strawberry",
        [GetHashKey("Tumbleweed")] = "Tumbleweed",
        [GetHashKey("Valentine")]  = "Valentine",
    }
    return townNames[town_hash]
end

RegisterNetEvent('pac_camp:client:sendTownToServer')
AddEventHandler('pac_camp:client:sendTownToServer', function(itemName)
    local town = GetCurrentTownName()
    TriggerServerEvent('pac_camp:server:checkTownAndPlace', itemName, town)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for uniqueId, _ in pairs(campsEntities) do
        if ActiveVegZones[uniqueId] then RemoveVegModifierSphere(ActiveVegZones[uniqueId], 0); ActiveVegZones[uniqueId] = nil end
        local entity = campsEntities[uniqueId]
        if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
        campsEntities[uniqueId] = nil
        campsData[uniqueId]     = nil
        dynamicDoors[uniqueId]  = nil
    end
end)
