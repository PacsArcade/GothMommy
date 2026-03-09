-- Based on Malik's and Blue's animal shelters and vorp animal shelter, hunting/raising/tracking system added by HAL
-- Modified for Goth Mommy RP: VORP only, fully grown pets, no feeding, uiprompt shop approach

local keys = Config.Keys

local recentlySpawned = 0
local currentPetPed = nil
local CurrentZoneActive = 0
local petXP = 0
local pets = Config.Pets
local fetchedObj = nil
local Retrieving = false
local notifyHungry = false
local RetrievedEntities = {}
local FeedTimer = 0
local recentlyCombat = 0
local isPetHungry = false
local TrackingEnabled = false
local AddedFeedPrompts = false
local HuntMode = false

local HuntModePrompt = {}
local FeedPrompt = {}
local AttackPrompt = {}
local TrackPrompt = {}
local StayPrompt = {}
local FollowPrompt = {}
local AddedAttackPrompt = {}
local AddedTrackPrompt = {}

-- =====================================================================
-- NOTIFICATION HELPER
-- =====================================================================
local function Notify(msg, ntype)
    ntype = ntype or "success"
    TriggerEvent("vorp:TipBottom", msg, 4000, ntype)
end

-- =====================================================================
-- SHOP APPROACH PROMPT
-- =====================================================================
local shopPromptGroup = GetRandomIntInRange(0, 0xffffff)
local shopPrompt = nil

Citizen.CreateThread(function()
    Citizen.Wait(50)
    shopPrompt = PromptRegisterBegin()
    PromptSetControlAction(shopPrompt, keys[Config.TriggerKeys.OpenShop])
    local str = CreateVarString(10, 'LITERAL_STRING', 'Animal Shelter')
    PromptSetText(shopPrompt, str)
    PromptSetEnabled(shopPrompt, 1)
    PromptSetVisible(shopPrompt, 1)
    PromptSetStandardMode(shopPrompt, 1)
    PromptSetGroup(shopPrompt, shopPromptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, shopPrompt, true)
    PromptRegisterEnd(shopPrompt)
    PromptSetHoldMode(shopPrompt, 500)
end)

Citizen.CreateThread(function()
    for _, info in pairs(Config.Shops) do
        local binfo = info.Blip
        local blip = N_0x554d9d53f696d002(1664425300, binfo.x, binfo.y, binfo.z)
        SetBlipSprite(blip, binfo.sprite, 1)
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, info.Name)
    end
end)

local function SetPetAttributes(entity)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 0, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 1, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 2, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 0, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 1, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 2, 1100)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 0, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 1, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 2, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 0, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 1, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 2, 10)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 0, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 1, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 2, 5000.0, false)
end

local function IsNearZone(location, distance, ring)
    local player = PlayerPedId()
    local playerloc = GetEntityCoords(player, 0)
    for i = 1, #location do
        if #(playerloc - location[i]) < distance then
            if ring == true then
                Citizen.InvokeNative(0x2A32FAA57B937173, 0x6903B113, location[i].x, location[i].y, location[i].z,
                    0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.0, 100, 1, 1, 190, false, true, 2, false, false, false, false)
            end
            return true, i
        end
    end
end

local function checkAvailability(pet)
    local availability = pet.Availability
    if availability ~= nil then
        for _, peti in pairs(availability) do
            if peti == CurrentZoneActive then return true end
        end
        return false
    end
    return true
end

-- =====================================================================
-- MENU THREAD
-- =====================================================================
Citizen.CreateThread(function()
    WarMenu.CreateMenu('id_dog', '')
    repeat
        if WarMenu.IsMenuOpened('id_dog') then
            if WarMenu.Button(_U('GiveAway')) then
                TriggerServerEvent('rdn_companions:sellpet')
                WarMenu.CloseMenu()
            end
            for i = 1, #pets do
                if checkAvailability(pets[i]) then
                    if WarMenu.Button(pets[i]['Text'], pets[i]['SubText'], pets[i]['Desc']) then
                        TriggerServerEvent('rdn_companions:buydog', pets[i]['Param'])
                        WarMenu.CloseMenu()
                    end
                end
            end
            WarMenu.Display()
        end
        Citizen.Wait(0)
    until false
end)

-- =====================================================================
-- SHOP PROXIMITY LOOP
-- =====================================================================
Citizen.CreateThread(function()
    while true do
        local waitTime = 500
        for index, shop in pairs(Config.Shops) do
            local IsZone = IsNearZone(shop.Coords, shop.ActiveDistance, shop.Ring)
            if IsZone then
                waitTime = 1
                PromptSetActiveGroupThisFrame(shopPromptGroup, CreateVarString(10, 'LITERAL_STRING', shop.Name))
                if shopPrompt and PromptHasHoldModeCompleted(shopPrompt) then
                    WarMenu.SetTitle('id_dog', shop.Name)
                    WarMenu.OpenMenu('id_dog')
                    CurrentZoneActive = index
                end
            end
        end
        Citizen.Wait(waitTime)
    end
end)

-- =====================================================================
-- U KEY THREAD — dedicated 0ms loop so no keypress is ever missed
-- Calls pet if none out, dismisses if one is active.
-- =====================================================================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Config.CallPetKey == true then
            if IsControlJustPressed(1, keys[Config.TriggerKeys.CallPet]) then
                if currentPetPed and DoesEntityExist(currentPetPed) then
                    -- Pet is out — dismiss it
                    TriggerEvent('rdn_companions:putaway')
                else
                    -- No pet — call it
                    Notify("Calling your companion...", "info")
                    TriggerServerEvent('rdn_companions:loaddog')
                end
            end
        end
    end
end)
-- =====================================================================


-- | Main Thread - hunt mode, timers, death check |

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if not Config.RaiseAnimal then
            if currentPetPed and not Retrieving and not isPetHungry and HuntMode then
                local ped = PlayerPedId()
                local ClosestPed = GetClosestAnimalPed(ped, Config.SearchRadius)
                local pedType = GetPedType(ClosestPed)
                if pedType == 28 and IsEntityDead(ClosestPed) and not RetrievedEntities[ClosestPed] then
                    local whoKilledPed = GetPedSourceOfDeath(ClosestPed)
                    if ped == whoKilledPed then
                        local model = GetEntityModel(ClosestPed)
                        for k, v in pairs(Config.Animals) do
                            if model == k then RetrieveKill(ClosestPed) end
                        end
                    else
                        RetrievedEntities[ClosestPed] = true
                    end
                end
            end
        else
            if currentPetPed and not Retrieving and petXP >= Config.FullGrownXp and not isPetHungry and HuntMode then
                local ped = PlayerPedId()
                local ClosestPed = GetClosestAnimalPed(ped, Config.SearchRadius)
                local pedType = GetPedType(ClosestPed)
                if pedType == 28 and IsEntityDead(ClosestPed) and not RetrievedEntities[ClosestPed] then
                    local whoKilledPed = GetPedSourceOfDeath(ClosestPed)
                    if ped == whoKilledPed then
                        local model = GetEntityModel(ClosestPed)
                        for k, v in pairs(Config.Animals) do
                            if model == k then RetrieveKill(ClosestPed) end
                        end
                    else
                        RetrievedEntities[ClosestPed] = true
                    end
                end
            end
        end

        if currentPetPed then
            if Config.DefensiveMode and recentlyCombat <= 0 then
                local ped = PlayerPedId()
                local enemyPed = GetClosestFightingPed(ped, 50.0)
                if enemyPed then
                    ClearPedTasks(currentPetPed)
                    TaskCombatPed(currentPetPed, enemyPed, 0, 16)
                    recentlyCombat = 15
                end
            end
            FeedTimer = FeedTimer + 1
            if Config.FeedInterval <= FeedTimer then
                isPetHungry = true
                if not AddedFeedPrompts then
                    local itemSet = CreateItemset(true)
                    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, GetEntityCoords(PlayerPedId()), 3.0, itemSet, 1, Citizen.ResultAsInteger())
                    if size > 0 then
                        for index = 0, size - 1 do
                            local entity = GetIndexedItemInItemset(index, itemSet)
                            if entity == currentPetPed then
                                AddFeedPrompts(entity)
                                AddedFeedPrompts = true
                            end
                        end
                    end
                    if IsItemsetValid(itemSet) then DestroyItemset(itemSet) end
                end
                if not notifyHungry and Config.NotifyWhenHungry then
                    Notify(_U('Hungry'), "error")
                    notifyHungry = true
                end
            end
            if IsEntityDead(currentPetPed) then
                recentlySpawned = Config.PetAttributes.DeathCooldown
                Notify(_U('PetDead'), "error")
                Wait(3000)
                DeleteEntity(currentPetPed)
                currentPetPed = nil
            end
        end
        if recentlySpawned > 0 then recentlySpawned = recentlySpawned - 1 end
        if recentlyCombat > 0 then recentlyCombat = recentlyCombat - 1 end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local id = PlayerId()
        if IsPlayerTargettingAnything(id) then
            local result, entity = GetPlayerTargetEntity(id)
            if PromptHasStandardModeCompleted(FeedPrompt[entity]) then
                local ped = PlayerPedId()
                local distance = #(GetEntityCoords(ped) - GetEntityCoords(entity))
                if distance <= 3.75 then
                    if Config.FeedInterval <= FeedTimer then
                        TaskTurnPedToFaceEntity(ped, currentPetPed, 5000)
                        TaskTurnPedToFaceEntity(currentPetPed, ped, 5000)
                        TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 60000, true, false, false, false)
                        Wait(2000)
                        DogEatAnimation()
                        Wait(4000)
                        ClearPedTasks(ped)
                        Wait(4000)
                        ClearPedTasks(currentPetPed)
                        followOwner(currentPetPed, ped, false)
                        TriggerServerEvent('rdn_companions:feedPet', petXP)
                    else
                        Notify("Your companion can be fed in: " .. SecondsToClock(Config.FeedInterval - FeedTimer), "info")
                    end
                    Wait(2000)
                end
            end
            if PromptHasStandardModeCompleted(FollowPrompt[entity]) then
                followOwner(currentPetPed, PlayerPedId(), false)
                Wait(2000)
            end
            if PromptHasStandardModeCompleted(StayPrompt[entity]) then
                petStay(currentPetPed)
                Wait(2000)
            end
            if PromptHasStandardModeCompleted(AttackPrompt[entity]) then
                AttackTarget(entity)
            end
            if PromptHasStandardModeCompleted(TrackPrompt[entity]) then
                TrackTarget(entity)
            end
            if PromptHasStandardModeCompleted(HuntModePrompt[entity]) then
                if not HuntMode then
                    Notify("Your companion is ready to retrieve.", "success")
                    HuntMode = true
                else
                    HuntMode = false
                    Notify("Your companion will not retrieve.", "info")
                end
            end
            if Config.AttackCommand and currentPetPed then
                if not AddedAttackPrompt[entity] and entity ~= currentPetPed then
                    if Config.AttackOnlyAnimals and GetPedType(entity) == 28 then
                        AddAttackPrompts(entity); AddedAttackPrompt[entity] = true
                    elseif Config.AttackOnlyNPC and not IsPedAPlayer(entity) then
                        AddAttackPrompts(entity); AddedAttackPrompt[entity] = true
                    elseif Config.AttackOnlyPlayers and IsPedAPlayer(entity) then
                        AddAttackPrompts(entity); AddedAttackPrompt[entity] = true
                    elseif not Config.AttackOnlyAnimals and not Config.AttackOnlyNPC and not Config.AttackOnlyPlayers then
                        AddAttackPrompts(entity); AddedAttackPrompt[entity] = true
                    end
                end
            end
            if Config.TrackCommand and currentPetPed then
                if not AddedTrackPrompt[entity] and entity ~= currentPetPed then
                    if Config.TrackOnlyAnimals and GetPedType(entity) == 28 then
                        AddTrackPrompts(entity); AddedTrackPrompt[entity] = true
                    elseif Config.TrackOnlyNPC and not IsPedAPlayer(entity) then
                        AddTrackPrompts(entity); AddedTrackPrompt[entity] = true
                    elseif Config.TrackOnlyPlayers and IsPedAPlayer(entity) then
                        AddTrackPrompts(entity); AddedTrackPrompt[entity] = true
                    elseif not Config.TrackOnlyAnimals and not Config.TrackOnlyNPC and not Config.TrackOnlyPlayers then
                        AddTrackPrompts(entity); AddedTrackPrompt[entity] = true
                    end
                end
            end
        else
            Wait(500)
        end
    end
end)

function DogEatAnimation()
    local waiting = 0
    local dict = "amb_creature_mammal@world_dog_eating_ground@base"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        waiting = waiting + 100
        Citizen.Wait(100)
        if waiting > 5000 then Notify("Animation failed, try relocating.", "error"); break end
    end
    TaskPlayAnim(currentPetPed, dict, "base", 1.0, 8.0, -1, 1, 0, false, false, false)
end

function DogSitAnimation()
    local waiting = 0
    local dict = "amb_creature_mammal@world_dog_sitting@base"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        waiting = waiting + 100
        Citizen.Wait(100)
        if waiting > 5000 then Notify("Animation failed, try relocating.", "error"); break end
    end
    TaskPlayAnim(currentPetPed, dict, "base", 1.0, 8.0, -1, 1, 0, false, false, false)
end

function AddFeedPrompts(entity)
    local group = Citizen.InvokeNative(0xB796970BD125FCE8, entity, Citizen.ResultAsLong())
    FeedPrompt[entity] = PromptRegisterBegin()
    PromptSetControlAction(FeedPrompt[entity], 0xCEFD9220)
    PromptSetText(FeedPrompt[entity], CreateVarString(10, 'LITERAL_STRING', 'Feed'))
    PromptSetEnabled(FeedPrompt[entity], true); PromptSetVisible(FeedPrompt[entity], true)
    PromptSetStandardMode(FeedPrompt[entity], true)
    PromptSetGroup(FeedPrompt[entity], group)
    PromptRegisterEnd(FeedPrompt[entity])
end

function AddAttackPrompts(entity)
    local group = Citizen.InvokeNative(0xB796970BD125FCE8, entity, Citizen.ResultAsLong())
    AttackPrompt[entity] = PromptRegisterBegin()
    PromptSetControlAction(AttackPrompt[entity], 0x63A38F2C)
    PromptSetText(AttackPrompt[entity], CreateVarString(10, 'LITERAL_STRING', 'Pet Attack'))
    PromptSetEnabled(AttackPrompt[entity], true); PromptSetVisible(AttackPrompt[entity], true)
    PromptSetStandardMode(AttackPrompt[entity], true)
    PromptSetGroup(AttackPrompt[entity], group)
    PromptRegisterEnd(AttackPrompt[entity])
end

function AddTrackPrompts(entity)
    local group = Citizen.InvokeNative(0xB796970BD125FCE8, entity, Citizen.ResultAsLong())
    TrackPrompt[entity] = PromptRegisterBegin()
    PromptSetControlAction(TrackPrompt[entity], 0x9959A6F0)
    PromptSetText(TrackPrompt[entity], CreateVarString(10, 'LITERAL_STRING', 'Pet Track'))
    PromptSetEnabled(TrackPrompt[entity], true); PromptSetVisible(TrackPrompt[entity], true)
    PromptSetStandardMode(TrackPrompt[entity], true)
    PromptSetGroup(TrackPrompt[entity], group)
    PromptRegisterEnd(TrackPrompt[entity])
end

function AddFollowPrompts(entity)
    local group = Citizen.InvokeNative(0xB796970BD125FCE8, entity, Citizen.ResultAsLong())
    FollowPrompt[entity] = PromptRegisterBegin()
    PromptSetControlAction(FollowPrompt[entity], 0x63A38F2C)
    PromptSetText(FollowPrompt[entity], CreateVarString(10, 'LITERAL_STRING', 'Follow'))
    PromptSetEnabled(FollowPrompt[entity], true); PromptSetVisible(FollowPrompt[entity], true)
    PromptSetStandardMode(FollowPrompt[entity], true)
    PromptSetGroup(FollowPrompt[entity], group)
    PromptRegisterEnd(FollowPrompt[entity])
end

function AddStayPrompts(entity)
    local group = Citizen.InvokeNative(0xB796970BD125FCE8, entity, Citizen.ResultAsLong())
    StayPrompt[entity] = PromptRegisterBegin()
    PromptSetControlAction(StayPrompt[entity], 0x9959A6F0)
    PromptSetText(StayPrompt[entity], CreateVarString(10, 'LITERAL_STRING', 'Stay'))
    PromptSetEnabled(StayPrompt[entity], true); PromptSetVisible(StayPrompt[entity], true)
    PromptSetStandardMode(StayPrompt[entity], true)
    PromptSetGroup(StayPrompt[entity], group)
    PromptRegisterEnd(StayPrompt[entity])
end

function AddHuntModePrompts(entity)
    local group = Citizen.InvokeNative(0xB796970BD125FCE8, entity, Citizen.ResultAsLong())
    HuntModePrompt[entity] = PromptRegisterBegin()
    PromptSetControlAction(HuntModePrompt[entity], 0xB2F377E8)
    PromptSetText(HuntModePrompt[entity], CreateVarString(10, 'LITERAL_STRING', 'Hunt Mode'))
    PromptSetEnabled(HuntModePrompt[entity], true); PromptSetVisible(HuntModePrompt[entity], true)
    PromptSetStandardMode(HuntModePrompt[entity], true)
    PromptSetGroup(HuntModePrompt[entity], group)
    PromptRegisterEnd(HuntModePrompt[entity])
end

RegisterNetEvent('UI:DrawNotification')
AddEventHandler('UI:DrawNotification', function(_message)
    Notify(_message, "info")
end)

RegisterNetEvent('rdn_companions:removedog')
AddEventHandler('rdn_companions:removedog', function()
    if currentPetPed then
        DeleteEntity(currentPetPed)
        currentPetPed = nil
        Notify(_U('ReleasePet'), "info")
    end
end)

RegisterNetEvent('rdn_companions:putaway')
AddEventHandler('rdn_companions:putaway', function()
    if currentPetPed then
        DeleteEntity(currentPetPed)
        currentPetPed = nil
        Notify(_U('PetAway'), "info")
    end
end)

RegisterCommand("fleepet", function()
    TriggerEvent('rdn_companions:putaway')
end)

RegisterCommand("callpet", function()
    TriggerServerEvent('rdn_companions:loaddog')
end)

function AttackTarget(targetentity)
    local retval, group = AddRelationshipGroup("attackedPeds")
    SetPedRelationshipGroupHash(targetentity, group)
    SetRelationshipBetweenGroups(5, GetPedRelationshipGroupHash(currentPetPed), GetPedRelationshipGroupHash(targetentity))
    TaskCombatPed(currentPetPed, targetentity, 0, 16)
end

function TrackTarget(targetentity)
    TaskFollowToOffsetOfEntity(currentPetPed, targetentity, 0.0, -1.5, 0.0, 1.0, -1, 2 * 100000000, 1, 1, 0, 0, 1)
end

function RetrieveKill(ClosestPed)
    fetchedObj = ClosestPed
    local ped = PlayerPedId()
    local coords = GetEntityCoords(fetchedObj)
    TaskGoToCoordAnyMeans(currentPetPed, coords, 2.0, 0, 0, 786603, 0xbf800000)
    Retrieving = true
    while true do
        Citizen.Wait(2000)
        TaskGoToCoordAnyMeans(currentPetPed, coords, 2.0, 0, 0, 786603, 0xbf800000)
        local petCoords = GetEntityCoords(currentPetPed)
        coords = GetEntityCoords(fetchedObj)
        if GetDistanceBetweenCoords(coords, petCoords, true) <= 2.5 then
            AttachEntityToEntity(fetchedObj, currentPetPed, GetPedBoneIndex(currentPetPed, 21030), 0.14, 0.14, 0.09798, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
            RetrievedEntities[fetchedObj] = true
            ReturnKillToPlayer(fetchedObj, ped)
            break
        end
    end
end

function setPetBehavior(petPed)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 143493179)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -2040077242)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1222652248)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1077299173)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -887307738)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1998572072)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -661858713)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1232372459)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1836932466)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1878159675)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1078461828)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1535431934)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1862763509)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1663301869)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1448293989)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1201903818)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -886193798)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1996978098)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 555364152)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -2020052692)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 707888648)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 378397108)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -350651841)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1538724068)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1030835986)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1919885972)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1976316465)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 841021282)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 889541022)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1329647920)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -319516747)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -767591988)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -989642646)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), 1986610512)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(petPed), -1683752762)
end

function followOwner(pet, owner, isInShop)
    FreezeEntityPosition(pet, false)
    ClearPedTasks(pet)
    ClearPedSecondaryTask(pet)
    TaskFollowToOffsetOfEntity(pet, owner, 0.0, -1.5, 0.0, 1.0, -1, Config.PetAttributes.FollowDistance * 100000000, 1, 1, 0, 0, 1)
    if isInShop then
        Citizen.InvokeNative(0x489FFCCCE7392B55, pet, owner)
    end
end

function petStay(pet)
    ClearPedTasks(pet)
    ClearPedSecondaryTask(pet)
    DogSitAnimation()
    FreezeEntityPosition(pet, true)
end

function ReturnKillToPlayer(fetchedKill, owner)
    local coords = GetEntityCoords(owner)
    TaskGoToCoordAnyMeans(currentPetPed, coords, 1.5, 0, 0, 786603, 0xbf800000)
    while true do
        Citizen.Wait(2000)
        coords = GetEntityCoords(owner)
        local coords2 = GetEntityCoords(currentPetPed)
        TaskGoToCoordAnyMeans(currentPetPed, coords, 1.5, 0, 0, 786603, 0xbf800000)
        if GetDistanceBetweenCoords(coords, coords2, true) <= 2.0 then
            DetachEntity(fetchedObj)
            Wait(100)
            PlaceObjectOnGroundProperly(fetchedObj, true)
            Retrieving = false
            followOwner(currentPetPed, owner, false)
            break
        end
    end
end

function spawnAnimal(model, player, x, y, z, h, skin, ownerId, isdead, isshop, xp)
    -- Guard: only skip re-spawn if pet is already nearby and healthy
    -- When currentPetPed is nil, always spawn
    local shouldSpawn = true
    if currentPetPed ~= nil and DoesEntityExist(currentPetPed) and not isshop and not isdead then
        local EntityPedCoord = GetEntityCoords(player)
        local EntitydogCoord = GetEntityCoords(currentPetPed)
        if #(EntityPedCoord - EntitydogCoord) <= 100.0 then
            shouldSpawn = false
        end
    end

    if shouldSpawn then
        if currentPetPed ~= nil then DeleteEntity(currentPetPed) end
        petXP = xp
        currentPetPed = CreatePed(model, x, y, z, h, 1, 1)
        SET_PED_OUTFIT_PRESET(currentPetPed, skin)
        SET_BLIP_TYPE(currentPetPed)
        if Config.PetAttributes.Invincible then SetEntityInvincible(currentPetPed, true) end
        AddFollowPrompts(currentPetPed)
        if Config.NoFear then
            Citizen.InvokeNative(0x013A7BA5015C1372, currentPetPed, true)
            Citizen.InvokeNative(0x3B005FF0538ED2A9, currentPetPed)
            Citizen.InvokeNative(0xAEB97D84CDF3C00B, currentPetPed, false)
        end
        SetPetAttributes(currentPetPed)
        setPetBehavior(currentPetPed)
        SetPedAsGroupMember(currentPetPed, GetPedGroupIndex(ownerId))
        if Config.RaiseAnimal then
            local halfGrowth = Config.FullGrownXp / 2
            if petXP >= Config.FullGrownXp then
                SetPedScale(currentPetPed, 1.0)
                AddStayPrompts(currentPetPed)
                AddHuntModePrompts(currentPetPed)
            elseif petXP >= halfGrowth then
                SetPedScale(currentPetPed, 0.8)
                AddStayPrompts(currentPetPed)
            else
                SetPedScale(currentPetPed, 0.6)
            end
        else
            petXP = Config.FullGrownXp
            AddStayPrompts(currentPetPed)
        end
        while (GetScriptTaskStatus(currentPetPed, 0x4924437d) ~= 8) do Wait(1000) end
        followOwner(currentPetPed, player, isshop)
        Notify("Your companion has arrived.", "success")
        if isdead and not Config.PetAttributes.Invincible then
            Notify(_U('petHealed'), "success")
        end
    end
end

RegisterNetEvent('rdn_companions:UpdateDogFed')
AddEventHandler('rdn_companions:UpdateDogFed', function(newXP, growAnimal)
    if Config.RaiseAnimal and growAnimal then
        petXP = newXP
        local halfGrowth = Config.FullGrownXp / 2
        if petXP >= Config.FullGrownXp then
            SetPedScale(currentPetPed, 1.0)
            AddStayPrompts(currentPetPed)
            AddHuntModePrompts(currentPetPed)
        elseif petXP >= halfGrowth then
            SetPedScale(currentPetPed, 0.8)
            AddStayPrompts(currentPetPed)
        else
            SetPedScale(currentPetPed, 0.6)
        end
    end
    isPetHungry = false
    FeedTimer = 0
    notifyHungry = false
end)

RegisterNetEvent('rdn_companions:spawndog')
AddEventHandler('rdn_companions:spawndog', function(dog, skin, isInShop, xp, canTrack)
    if recentlySpawned <= 0 then
        recentlySpawned = Config.PetAttributes.SpawnLimiter
    else
        Notify(_U('SpawnLimiter'), "error")
        return
    end
    TrackingEnabled = canTrack
    local player = PlayerPedId()
    local model = GetHashKey(dog)
    local x, y, z, heading, a, b

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(500) end

    if isInShop then
        local sx, sy, sz, sw = table.unpack(Config.Shops[CurrentZoneActive].Spawndog)
        spawnAnimal(model, player, sx, sy, sz, sw, skin, PlayerPedId(), false, true, xp)
    else
        x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(player, 0.0, -5.0, 0.3))
        a, b = GetGroundZAndNormalFor_3dCoord(x, y, z + 10)
        local EntityIsDead = currentPetPed ~= nil and IsEntityDead(currentPetPed)
        if EntityIsDead then
            spawnAnimal(model, player, x, y, b, heading, skin, PlayerPedId(), true, false, xp)
        else
            spawnAnimal(model, player, x, y, b, heading, skin, PlayerPedId(), false, false, xp)
        end
    end
end)

function GetClosestAnimalPed(playerPed, radius)
    local playerCoords = GetEntityCoords(playerPed)
    local itemset = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, playerCoords, radius, itemset, 1, Citizen.ResultAsInteger())
    local closestPed, minDist = nil, radius
    if size > 0 then
        for i = 0, size - 1 do
            local ped = GetIndexedItemInItemset(i, itemset)
            if playerPed ~= ped then
                local pedType = GetPedType(ped)
                local model = GetEntityModel(ped)
                if pedType == 28 and IsEntityDead(ped) and not RetrievedEntities[ped] and Config.Animals[model] then
                    local distance = #(playerCoords - GetEntityCoords(ped))
                    if distance < minDist then closestPed = ped; minDist = distance end
                end
            end
        end
    end
    if IsItemsetValid(itemset) then DestroyItemset(itemset) end
    return closestPed
end

function GetClosestFightingPed(playerPed, radius)
    local playerCoords = GetEntityCoords(playerPed)
    local itemset = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, playerCoords, radius, itemset, 1, Citizen.ResultAsInteger())
    local closestPed, minDist = nil, radius
    if size > 0 then
        for i = 0, size - 1 do
            local ped = GetIndexedItemInItemset(i, itemset)
            if playerPed ~= ped and ped ~= currentPetPed then
                local distance = #(playerCoords - GetEntityCoords(ped))
                if IsPedInCombat(playerPed, ped) then closestPed = ped; minDist = distance end
            end
        end
    end
    if IsItemsetValid(itemset) then DestroyItemset(itemset) end
    return closestPed
end

function SecondsToClock(seconds)
    seconds = tonumber(seconds)
    if seconds <= 0 then return "00:00:00" end
    local h = string.format("%02.f", math.floor(seconds / 3600))
    local m = string.format("%02.f", math.floor(seconds / 60 - h * 60))
    local s = string.format("%02.f", math.floor(seconds - h * 3600 - m * 60))
    return h .. ":" .. m .. ":" .. s
end

function SET_BLIP_TYPE(animal) return Citizen.InvokeNative(0x23f74c2fda6e7c61, -1749618580, animal) end
function SET_ANIMAL_TUNING_BOOL_PARAM(animal, p1, p2) return Citizen.InvokeNative(0x9FF1E042FA597187, animal, p1, p2) end
function SET_PED_DEFAULT_OUTFIT(dog) return Citizen.InvokeNative(0x283978A15512B2FE, dog, true) end
function SET_PED_OUTFIT_PRESET(dog, preset) return Citizen.InvokeNative(0x77FF8D35EEC6BBC4, dog, preset, 0) end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerEvent('rdn_companions:removedog')
        if fetchedObj ~= nil then DeleteEntity(fetchedObj) end
    end
end)
