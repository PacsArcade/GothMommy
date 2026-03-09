-- ═══════════════════════════════════════════════════════════
print("[pac-idcard] VERSION: 2026-03-09-v9 countdown+shoot+fixexit")
-- ═══════════════════════════════════════════════════════════

local idcardData    = false
local cam           = nil
local currentCamPos = nil
local defaultCamPos = nil
local movements     = {}
local movements2    = {}
local movements3    = {}
local creating      = false
local currentFilter = 1

-- forward declarations so all functions can call each other
local exitCamera
local setPhotographerHeading
local cycleFilter
local applyFilter

-- ─── Prompt helpers ───────────────────────────────────────────────────────────
local function createPrompt(inputName, label, promptGroup, holdMs)
    holdMs = holdMs or 500
    local m = PromptRegisterBegin()
    PromptSetControlAction(m, GetHashKey(inputName))
    PromptSetText(m, CreateVarString(10, 'LITERAL_STRING', label))
    PromptSetEnabled(m, 1)
    PromptSetVisible(m, 1)
    PromptSetStandardMode(m, 1)
    PromptSetGroup(m, promptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, m, true)
    PromptRegisterEnd(m)
    PromptSetHoldMode(m, holdMs)
    return m
end

local promptGroup1 = GetRandomIntInRange(0, 0xffffff)
local promptGroup2 = GetRandomIntInRange(0, 0xffffff)
local promptGroup3 = GetRandomIntInRange(0, 0xffffff)

Citizen.CreateThread(function()
    Citizen.Wait(10)
    local pg1 = {
        { Config.Keybinds["takephoto"][1],  Locale("takephoto")  },
        { Config.Keybinds["printphoto"][1], Locale("printphoto") },
        { Config.Keybinds["exit"][1],       Locale("exit")       },
        { Config.Keybinds["camUp"][1],      Locale("camUp")      },
        { Config.Keybinds["camDown"][1],    Locale("camDown")    },
        { Config.Keybinds["camLeft"][1],    Locale("camLeft")    },
        { Config.Keybinds["camRight"][1],   Locale("camRight")   },
        { Config.Keybinds["camForward"][1], Locale("camForward") },
        { Config.Keybinds["camBack"][1],    Locale("camBack")    },
        { Config.Keybinds["filterPrev"][1], Locale("filterPrev") },
        { Config.Keybinds["filterNext"][1], Locale("filterNext") },
    }
    for _, kd in ipairs(pg1) do
        movements[#movements+1] = createPrompt(kd[1], kd[2], promptGroup1)
    end
    movements2[1] = createPrompt(Config.Keybinds["takeidcard"][1], Locale("takeidcard"), promptGroup2)
    local price = (Config.Prices and Config.Prices.printphoto) or 0
    local photoLabel = price > 0 and "Take Photo ($"..price..")" or "Take Photo (Free)"
    movements3[1] = createPrompt(Config.Keybinds["takeidcard"][1],  photoLabel,    promptGroup3)
    movements3[2] = createPrompt(Config.Keybinds["printphoto"][1], "Develop Film", promptGroup3)
end)

-- ─── NUI Callbacks ────────────────────────────────────────────────────────────
RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
    AnimpostfxStop("OJDominoBlur")
    Config.ShowHud()
    creating = false
end)
RegisterNUICallback('notify', function(data)
    Notify({ text = Locale(data.text), type = "error", time = 4000 })
end)
RegisterNUICallback('print', function(data)
    SetNuiFocus(false, false)
    if data.imgLink then TriggerServerEvent('fx-idcard:server:print', data.imgLink) end
end)
RegisterNUICallback('createIdCard', function(data)
    TriggerServerEvent('fx-idcard:server:buyIdCard', data)
end)

-- Shoot: NUI finished countdown, now trigger game screenshot
RegisterNUICallback('camShoot', function(data)
    -- ExportScreenshot saves to the standard screenshots folder
    -- (same as the game's built-in screenshot)
    Citizen.InvokeNative(0x3B96D87CB7DA1245, true)
    Notify({ text = "~COLOR_YELLOW~Photo saved!", time = 3000, type = "success" })
end)

-- ─── Camera movement via NUI keyboard ────────────────────────────────────────
RegisterNUICallback('camMove', function(data)
    local dir = data.dir
    if dir == "exit" then
        exitCamera(_currentPhotoKey, _currentDefaultHeading)
        return
    end
    if dir == "filter_next" then cycleFilter( 1); return end
    if dir == "filter_prev" then cycleFilter(-1); return end
    if dir == "reset" then
        if defaultCamPos and cam then
            currentCamPos = { x=defaultCamPos.x, y=defaultCamPos.y, z=defaultCamPos.z }
            SetCamCoord(cam, currentCamPos.x, currentCamPos.y, currentCamPos.z)
            if data.pcx then PointCamAtCoord(cam, data.pcx, data.pcy, data.pcz) end
        end
        return
    end
    if not cam or not currentCamPos then return end
    local step = 0.15
    if     dir == "up"    then currentCamPos.z = currentCamPos.z + step
    elseif dir == "down"  then currentCamPos.z = currentCamPos.z - step
    elseif dir == "left"  then currentCamPos.y = currentCamPos.y + step
    elseif dir == "right" then currentCamPos.y = currentCamPos.y - step
    elseif dir == "fwd"   then currentCamPos.x = currentCamPos.x + step
    elseif dir == "back"  then currentCamPos.x = currentCamPos.x - step
    end
    SetCamCoord(cam, currentCamPos.x, currentCamPos.y, currentCamPos.z)
    if data.pcx then
        PointCamAtCoord(cam, data.pcx, data.pcy, data.pcz)
    end
end)

-- ─── Network Events ───────────────────────────────────────────────────────────
RegisterNetEvent('fx-idcard:client:setData',    function(d) idcardData = d     end)
RegisterNetEvent('fx-idcard:client:clearData',  function()  idcardData = false end)
RegisterNetEvent('fx-idcard:client:updateData', function()
    TriggerServerEvent('fx-idcard:server:GetData')
end)
RegisterNetEvent('fx-idcard:client:showIDCardSQL', function()
    if idcardData then
        TriggerServerEvent('fx-idcard:server:ShowIdCard', idcardData)
    else
        TriggerServerEvent('fx-idcard:server:GetData')
        Wait(2000)
        TriggerEvent('fx-idcard:client:showIDCardSQL')
    end
end)
RegisterNetEvent("fx-idcard:client:PreviewPhoto", function(typee, data)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = typee == "photo" and 'showphoto' or 'openIdCard', array = data })
end)
RegisterNetEvent("fx-idcard:client:CreateIdcardUi", function(data, illegal)
    creating = true
    Config.HideHud()
    AnimpostfxPlay("OJDominoBlur")
    AnimpostfxSetStrength("OJDominoBlur", 0.5)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'createidcard', array = data, illegal = illegal })
end)
RegisterNetEvent("fx-idcard:client:ShowUi", function(typee, data)
    local nearby = GetClosestPlayer()
    if #nearby > 0 then
        TriggerServerEvent("fx-idcard:server:ShowUi", nearby, typee, data)
    else
        SetNuiFocus(true, true)
        SendNUIMessage({ action = typee == "photo" and 'showphoto' or 'openIdCard', array = data })
    end
end)

-- ─── Helpers ──────────────────────────────────────────────────────────────────
function GetClosestPlayer()
    local myPed    = PlayerPedId()
    local myId     = PlayerId()
    local myCoords = GetEntityCoords(myPed)
    local result   = {}
    for _, p in ipairs(GetActivePlayers()) do
        if p ~= myId then
            if #(myCoords - GetEntityCoords(GetPlayerPed(p))) < Config.ShowDistance then
                result[#result+1] = GetPlayerServerId(p)
            end
        end
    end
    return result
end

applyFilter = function(idx)
    local f = Config.CameraFilters
    if not f or #f == 0 then return end
    local filter = f[idx] or f[1]
    SendNUIMessage({ action = 'setFilter', css = filter.css, name = filter.name })
end

cycleFilter = function(dir)
    currentFilter = currentFilter + dir
    local n = #Config.CameraFilters
    if currentFilter < 1 then currentFilter = n end
    if currentFilter > n then currentFilter = 1 end
    applyFilter(currentFilter)
end

_currentPhotoKey       = nil
_currentDefaultHeading = nil

setPhotographerHeading = function(key, heading)
    local p = photographerPeds and photographerPeds[key]
    if p and DoesEntityExist(p) then
        SetEntityHeading(p, heading)
    end
end

exitCamera = function(photographerKey, restoreHeading)
    SendNUIMessage({ action = 'showCameraOverlay', visible = false })
    SetNuiFocus(false, false)
    RenderScriptCams(false, false, 0, true, true)
    if cam then DestroyCam(cam, true) end
    cam           = nil
    currentCamPos = nil
    defaultCamPos = nil
    _currentPhotoKey       = nil
    _currentDefaultHeading = nil
    SetPlayerControl(PlayerId(), true)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerServerEvent('fx-idcard:server:setBucket', 0)
    Config.ShowHud()
    if photographerKey and restoreHeading then
        setPhotographerHeading(photographerKey, restoreHeading)
    end
end

-- ─── Photo session ────────────────────────────────────────────────────────────
local function takePhoto(v, key)
    DoScreenFadeOut(1000)
    Wait(1000)
    TriggerServerEvent('fx-idcard:server:setBucket', GetPlayerServerId(PlayerId()))

    local ped = PlayerPedId()
    local pc  = v.pedCoords
    local cc  = v.camCoords

    local defaultHeading = v.npc and v.npc.coords.w or 270.0
    local photoHeading   = v.npc and v.npc.photoHeading or 90.0
    setPhotographerHeading(key, photoHeading)
    _currentPhotoKey       = key
    _currentDefaultHeading = defaultHeading

    SetEntityCoords(ped, pc.x, pc.y, pc.z, false, false, false, false)
    SetEntityHeading(ped, pc.w)
    FreezeEntityPosition(ped, true)
    SetPlayerControl(PlayerId(), false)
    Wait(800)

    local actualPos = GetEntityCoords(ped)
    print(string.format("[pac-idcard] photo pose: player landed at x=%.3f y=%.3f z=%.3f (target z=%.3f)",
        actualPos.x, actualPos.y, actualPos.z, pc.z))

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    currentCamPos = { x=cc.x, y=cc.y, z=cc.z }
    defaultCamPos = { x=cc.x, y=cc.y, z=cc.z }
    SetCamCoord(cam, cc.x, cc.y, cc.z)
    local targetZ = actualPos.z + 0.7
    PointCamAtCoord(cam, pc.x, pc.y, targetZ)
    Citizen.InvokeNative(0x27666E5988D9D429, cam, v.camFov)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Wait(500)
    DoScreenFadeIn(1000)

    currentFilter = 1
    applyFilter(currentFilter)

    SetNuiFocus(true, false)
    SendNUIMessage({
        action  = 'showCameraOverlay',
        visible = true,
        pcx     = pc.x,
        pcy     = pc.y,
        pcz     = targetZ,
    })
end

-- ─── Photographer NPC spawn ───────────────────────────────────────────────────
photographerPeds = {}

local function spawnPhotographerPed(key, v)
    if photographerPeds[key] then return end
    local npc    = v.npc
    local coords = npc.coords
    local hash   = npc.hash or GetHashKey(npc.model)
    RequestModel(hash)
    local t = 0
    while not HasModelLoaded(hash) do
        Citizen.Wait(10); t = t + 10
        if t > 5000 then
            hash = GetHashKey(npc.fallback or "cs_brontesbutler")
            RequestModel(hash)
            local t2 = 0
            while not HasModelLoaded(hash) do
                Citizen.Wait(10); t2 = t2 + 10
                if t2 > 3000 then break end
            end
            break
        end
    end
    local p = CreatePed(hash, coords.x, coords.y, coords.z, coords.w, false, 0)
    if not DoesEntityExist(p) then
        print("[pac-idcard] ERROR: could not spawn photographer '"..key.."'")
        return
    end
    FreezeEntityPosition(p, true)
    Citizen.InvokeNative(0x283978A15512B2FE, p, true)
    SetEntityCanBeDamaged(p, false)
    SetEntityInvincible(p, true)
    SetBlockingOfNonTemporaryEvents(p, true)
    Citizen.InvokeNative(0xD8B8CFD709214ACD, p, true)
    SetModelAsNoLongerNeeded(hash)
    SetEntityAsMissionEntity(p, true, true)
    ClearPedTasks(p)
    photographerPeds[key] = p
    print(string.format("[pac-idcard] Spawned photographer '%s' ped=%d at z=%.3f (config z was %.3f) heading=%.1f",
        key, p, GetEntityCoords(p).z, coords.z, coords.w))
end

Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        for key, v in pairs(Config.Photographers) do
            if v.npc then
                local nc   = v.npc.coords
                local dist = #(pos - vector3(nc.x, nc.y, nc.z))
                if dist < Config.PedSpawnDistance and not photographerPeds[key] then
                    spawnPhotographerPed(key, v)
                elseif dist > Config.PedSpawnDistance + 10 and photographerPeds[key] then
                    DeletePed(photographerPeds[key])
                    photographerPeds[key] = nil
                end
            end
        end
        Wait(2000)
    end
end)

-- ─── Photographer blips ───────────────────────────────────────────────────────
local function createPhotographerBlip(v)
    local c    = v.blips.coords or vector3(v.promptCoords.x, v.promptCoords.y, v.promptCoords.z)
    local blip = N_0x554d9d53f696d002(1664425300, c.x, c.y, c.z)
    Citizen.InvokeNative(0x0DF2B55F717DDB10, blip, false)
    Citizen.InvokeNative(0x662D364ABF16DE2F, blip, joaat(v.blips.modifier))
    SetBlipSprite(blip, v.blips.sprite, 1)
    SetBlipScale(blip, v.blips.scale)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.blips.name)
    return blip
end

Citizen.CreateThread(function()
    for k, v in pairs(Config.Photographers) do
        if v.blips and not v.blipEntity then
            v.blipEntity = createPhotographerBlip(v)
        end
    end
end)

-- ─── Photographer approach interaction ───────────────────────────────────────
Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        local myPos = GetEntityCoords(PlayerPedId())

        for k, v in pairs(Config.Photographers) do
            local ped = photographerPeds[k]
            if ped and DoesEntityExist(ped) then
                local pedPos = GetEntityCoords(ped)
                local dist   = #(myPos - pedPos)

                if dist < Config.TalkDistance and not cam then
                    sleep = 1
                    PromptSetActiveGroupThisFrame(promptGroup3,
                        CreateVarString(10, 'LITERAL_STRING', "Photographer"))

                    if movements3[1] and PromptHasHoldModeCompleted(movements3[1]) then
                        Config.HideHud()
                        takePhoto(v, k)
                        while cam do Wait(500) end
                        sleep = 2000
                    elseif movements3[2] and PromptHasHoldModeCompleted(movements3[2]) then
                        SetNuiFocus(true, true)
                        SendNUIMessage({ action = 'print' })
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- ─── /phototest ───────────────────────────────────────────────────────────────
RegisterCommand("phototest", function()
    local me = GetEntityCoords(PlayerPedId())
    print(string.format("[phototest] player x=%.3f y=%.3f z=%.3f cam=%s",
        me.x, me.y, me.z, tostring(cam)))
    print(string.format("[phototest] movements3 [1]=%s [2]=%s",
        tostring(movements3[1]~=nil), tostring(movements3[2]~=nil)))
    for k, v in pairs(Config.Photographers) do
        local p = photographerPeds[k]
        if p and DoesEntityExist(p) then
            local pc   = GetEntityCoords(p)
            local dist = #(me - pc)
            print(string.format("[phototest] '%s' ped=%d x=%.3f y=%.3f z=%.3f heading=%.1f dist=%.2f %s",
                k, p, pc.x, pc.y, pc.z, GetEntityHeading(p), dist,
                dist < Config.TalkDistance and "<<IN RANGE>>" or "out of range"))
            print(string.format("[phototest] pedCoords: x=%.3f y=%.3f z=%.3f heading=%.1f",
                v.pedCoords.x, v.pedCoords.y, v.pedCoords.z, v.pedCoords.w))
            print(string.format("[phototest] camCoords: x=%.3f y=%.3f z=%.3f fov=%.1f",
                v.camCoords.x, v.camCoords.y, v.camCoords.z, v.camFov))
        else
            print("[phototest] '"..k.."' NOT SPAWNED")
        end
    end
end, false)

-- ─── IDCard NPC ───────────────────────────────────────────────────────────────
local function isOpen(s)
    if not s then return true end
    local h = GetClockHours()
    return h >= s.open and h <= s.close
end

local function spawnPed(v, coords)
    local hash = GetHashKey((v.npc and v.npc.model) or v.models)
    RequestModel(hash)
    local t = 0
    while not HasModelLoaded(hash) do
        Citizen.Wait(10); t = t + 10
        if t > 5000 then
            if v.npc and v.npc.fallback then hash = GetHashKey(v.npc.fallback) end
            break
        end
    end
    local npc = CreatePed(hash, coords.x, coords.y, coords.z-1, coords.w, false, 0)
    FreezeEntityPosition(npc, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Citizen.InvokeNative(0xD8B8CFD709214ACD, npc, true)
    SetModelAsNoLongerNeeded(hash)
    SetEntityAsMissionEntity(npc, true, true)
    if v.anims then
        if v.anims.name then
            RequestAnimDict(v.anims.dict)
            while not HasAnimDictLoaded(v.anims.dict) do Citizen.Wait(100) end
            TaskPlayAnim(npc, v.anims.dict, v.anims.name, 1.0,-1.0,-1,1,0,true,0,false,0,false)
        else
            TaskStartScenarioInPlace(npc, GetHashKey(v.anims.dict), 0, true, false, false, false)
        end
    end
    return npc
end

local function createBlip(v)
    local blip = N_0x554d9d53f696d002(1664425300, v.coords.x, v.coords.y, v.coords.z)
    Citizen.InvokeNative(0x0DF2B55F717DDB10, blip, false)
    Citizen.InvokeNative(0x662D364ABF16DE2F, blip, joaat(v.blips.modifier))
    SetBlipSprite(blip, v.blips.sprite, 1)
    SetBlipScale(blip, v.blips.scale)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.blips.name)
    return blip
end

Citizen.CreateThread(function()
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.IDCardNPC) do
            local dist = #(coords - vector3(v.coords.x, v.coords.y, v.coords.z))
            if dist < Config.PedSpawnDistance and not v.npcEntity and isOpen(v.timeSettings) then
                v.npcEntity = spawnPed(v, v.coords); v.canInteract = true
            elseif v.npcEntity and (dist > Config.PedSpawnDistance or not isOpen(v.timeSettings)) then
                DeletePed(v.npcEntity); v.npcEntity = nil; v.canInteract = nil
            end
            if v.blips and not v.blipEntity then v.blipEntity = createBlip(v) end
            if v.blipEntity then
                local mod = isOpen(v.timeSettings) and v.blips.modifier or v.timeSettings.blipmodifier
                Citizen.InvokeNative(0x662D364ABF16DE2F, v.blipEntity, joaat(mod))
            end
        end
        Wait(2000)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep  = 2000
        local coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.IDCardNPC) do
            local dist = #(coords - vector3(v.coords.x, v.coords.y, v.coords.z))
            if dist < v.distance and v.canInteract then
                sleep = 1
                local label = Locale("promptitle2")
                if Config.Prices.idcard and not v.illegal then
                    label = label.." $"..Config.Prices.idcard
                elseif v.illegal and Config.Prices.illegal then
                    label = Locale("promptitle3").." $"..Config.Prices.illegal
                end
                PromptSetActiveGroupThisFrame(promptGroup2, CreateVarString(10,'LITERAL_STRING',label))
                if PromptHasHoldModeCompleted(movements2[1]) then
                    Wait(50)
                    Notify({ text=Locale("useitem",{time=Config.SelectPhotoTime}), time=10000, type="success" })
                    TriggerServerEvent('fx-idcard:server:useImagePlease', k)
                end
            end
        end
        Wait(sleep)
    end
end)

-- ─── /idcard ──────────────────────────────────────────────────────────────────
if Config.TakeCardType == "sql" then
    RegisterCommand(Config.ShowIdcardCommand, function()
        TriggerEvent("fx-idcard:client:showIDCardSQL")
    end)
end

-- ─── Cleanup ──────────────────────────────────────────────────────────────────
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, v in pairs(Config.Photographers) do
        if v.blipEntity then RemoveBlip(v.blipEntity) end
    end
    for _, p in pairs(photographerPeds) do
        if p then DeletePed(p) end
    end
    for _, v in pairs(Config.IDCardNPC) do
        if v.npcEntity  then DeletePed(v.npcEntity)   end
        if v.blipEntity then RemoveBlip(v.blipEntity) end
    end
    if cam then exitCamera(nil, nil) end
    if creating then
        AnimpostfxStop("OJDominoBlur")
        SetNuiFocus(false, false)
    end
end)
