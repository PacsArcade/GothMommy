local idcardData    = false
local cam           = nil   -- MUST be nil, not 0: 'not 0' is false in Lua!
local currentCamPos = nil
local movements     = {}
local movements2    = {}
local movements3    = {}  -- photographer prompts
local creating      = false
local currentFilter = 1

-- ─── Prompt setup ───────────────────────────────────────────────────────────────
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

local promptGroup1 = GetRandomIntInRange(0, 0xffffff)  -- camera controls
local promptGroup2 = GetRandomIntInRange(0, 0xffffff)  -- idcard NPC
local promptGroup3 = GetRandomIntInRange(0, 0xffffff)  -- photographer NPC

Citizen.CreateThread(function()
    Citizen.Wait(10)
    -- Camera controls (promptGroup1)
    local pg1keys = {
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
    for _, kd in ipairs(pg1keys) do
        movements[#movements+1] = createPrompt(kd[1], kd[2], promptGroup1)
    end
    -- IDCard NPC prompt (promptGroup2)
    movements2[1] = createPrompt(Config.Keybinds["takeidcard"][1], Locale("takeidcard"), promptGroup2)
    -- Photographer prompts (promptGroup3) - two prompts, same group
    movements3[1] = createPrompt(Config.Keybinds["takeidcard"][1],  "Take Photo ($" .. (Config.Prices.printphoto or 5) .. ")", promptGroup3)
    movements3[2] = createPrompt(Config.Keybinds["printphoto"][1], "Print Photo", promptGroup3)
end)

local function ctrl(key) return Config.Keybinds[key][2] end

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

local function setActivePrompts(mode)
    local show = mode == "photo"
        and {true,true,false,false,false,false,false,false,false,false,false}
        or  {false,false,true,true,true,true,true,true,true,true,true}
    for i, v in ipairs(show) do
        if movements[i] then Citizen.InvokeNative(0x71215ACCFDE075EE, movements[i], v) end
    end
end

local function applyFilter(idx)
    local f = Config.CameraFilters
    if not f or #f == 0 then return end
    local filter = f[idx] or f[1]
    SendNUIMessage({ action = 'setFilter', css = filter.css, name = filter.name })
end

local filterCooldown = false
local function cycleFilter(dir)
    if filterCooldown then return end
    filterCooldown = true
    currentFilter = currentFilter + dir
    local n = #Config.CameraFilters
    if currentFilter < 1 then currentFilter = n end
    if currentFilter > n then currentFilter = 1 end
    applyFilter(currentFilter)
    Citizen.SetTimeout(250, function() filterCooldown = false end)
end

local function moveCam(x, y, z)
    currentCamPos = GetOffsetFromCoordAndHeadingInWorldCoords(
        currentCamPos.x, currentCamPos.y, currentCamPos.z, currentCamPos.w, x, y, z)
    if #(GetEntityCoords(PlayerPedId()) - currentCamPos) < 1.5 then
        SetCamCoord(cam, currentCamPos.x, currentCamPos.y, currentCamPos.z)
    end
end

local function exitCamera()
    SendNUIMessage({ action = 'showCameraOverlay', visible = false })
    RenderScriptCams(false, false, 0, true, true)
    if cam then DestroyCam(cam, true) end
    cam = nil
    SetPlayerControl(PlayerId(), true)
    FreezeEntityPosition(PlayerPedId(), false)
    SetNuiFocus(false, false)
    TriggerServerEvent('fx-idcard:server:setBucket', 0)
    Config.ShowHud()
end

-- ─── Camera / photo session ───────────────────────────────────────────────────
local function takePhoto(v)
    DoScreenFadeOut(1000)
    Wait(1000)
    TriggerServerEvent('fx-idcard:server:setBucket', GetPlayerServerId(PlayerId()))
    local ped = PlayerPedId()
    SetEntityCoords(ped, v.pedCoords.x, v.pedCoords.y, v.pedCoords.z - 1)
    SetEntityHeading(ped, v.pedCoords.w)
    FreezeEntityPosition(ped, true)
    SetPlayerControl(PlayerId(), false)
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    currentCamPos = v.camCoords
    SetCamCoord(cam, currentCamPos.x, currentCamPos.y, currentCamPos.z)
    SetCamRot(cam, 0, 0, currentCamPos.w, 2)
    Citizen.InvokeNative(0x27666E5988D9D429, cam, v.camFov)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Wait(1000)
    DoScreenFadeIn(1000)

    currentFilter = 1
    applyFilter(currentFilter)
    SendNUIMessage({ action = 'showCameraOverlay', visible = true })

    Citizen.CreateThread(function()
        while cam do
            PromptSetActiveGroupThisFrame(promptGroup1, CreateVarString(10,'LITERAL_STRING',"Photographer"))
            setActivePrompts("camera")

            if IsDisabledControlPressed(0, ctrl("exit")) then
                exitCamera()
                break
            elseif IsDisabledControlPressed(0, ctrl("camUp"))      then moveCam(0, 0,  0.01)
            elseif IsDisabledControlPressed(0, ctrl("camDown"))    then moveCam(0, 0, -0.01)
            elseif IsDisabledControlPressed(0, ctrl("camLeft"))    then moveCam(0, -0.01, 0)
            elseif IsDisabledControlPressed(0, ctrl("camRight"))   then moveCam(0,  0.01, 0)
            elseif IsDisabledControlPressed(0, ctrl("camForward")) then moveCam(-0.01, 0, 0)
            elseif IsDisabledControlPressed(0, ctrl("camBack"))    then moveCam( 0.01, 0, 0)
            elseif IsDisabledControlJustPressed(0, ctrl("filterNext")) then cycleFilter(1)
            elseif IsDisabledControlJustPressed(0, ctrl("filterPrev")) then cycleFilter(-1)
            end
            Wait(1)
        end
    end)
end

-- ─── Photographer NPC spawn ───────────────────────────────────────────────────
local photographerPeds = {}

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
    local ped = CreatePed(hash, coords.x, coords.y, coords.z, coords.w, false, 0)
    if not DoesEntityExist(ped) then
        print("[pac-idcard] ERROR: Failed to create photographer ped for " .. key)
        return
    end
    FreezeEntityPosition(ped, true)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
    SetEntityCanBeDamaged(ped, false)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    Citizen.InvokeNative(0xD8B8CFD709214ACD, ped, true)
    SetModelAsNoLongerNeeded(hash)
    SetEntityAsMissionEntity(ped, true, true)
    ClearPedTasks(ped)
    photographerPeds[key] = ped
    print("[pac-idcard] Spawned photographer '" .. key .. "' ped=" .. ped)
end

Citizen.CreateThread(function()
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        for key, v in pairs(Config.Photographers) do
            if v.npc then
                local ncoords = v.npc.coords
                local dist = #(coords - vector3(ncoords.x, ncoords.y, ncoords.z))
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
    local c = v.blips.coords or vector3(v.promptCoords.x, v.promptCoords.y, v.promptCoords.z)
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

-- ─── Photographer NPC interaction ────────────────────────────────────────────
-- Uses the same PromptHasHoldModeCompleted system as the IDCard NPC (known working)
-- promptGroup3: [E] Take Photo | [Enter] Print Photo
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
                    sleep = 1  -- run every ms (same as idcard NPC loop)
                    PromptSetActiveGroupThisFrame(promptGroup3,
                        CreateVarString(10, 'LITERAL_STRING', "Photographer"))

                    if movements3[1] and PromptHasHoldModeCompleted(movements3[1]) then
                        Config.HideHud()
                        takePhoto(v)
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

-- ─── DEBUG: /phototest ───────────────────────────────────────────────────────────
RegisterCommand("phototest", function()
    local myCoords = GetEntityCoords(PlayerPedId())
    print(string.format("[phototest] Player: x=%.2f y=%.2f z=%.2f  cam=%s",
        myCoords.x, myCoords.y, myCoords.z, tostring(cam)))
    print(string.format("[phototest] movements3 ready: [1]=%s [2]=%s",
        tostring(movements3[1] ~= nil), tostring(movements3[2] ~= nil)))
    for k, v in pairs(Config.Photographers) do
        local ped = photographerPeds[k]
        if ped and DoesEntityExist(ped) then
            local p = GetEntityCoords(ped)
            local dist = #(myCoords - p)
            print(string.format("[phototest] '%s' ped=%d at x=%.2f y=%.2f z=%.2f dist=%.2f %s",
                k, ped, p.x, p.y, p.z, dist,
                dist < Config.TalkDistance and "IN RANGE" or "out of range"))
        else
            print("[phototest] '" .. k .. "' NOT SPAWNED or stale")
        end
    end
end, false)

-- ─── ID Card NPC spawn + interact ────────────────────────────────────────────
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
            if v.npc and v.npc.fallback then hash = GetHashKey(v.npc.fallback); RequestModel(hash) end
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

-- ─── /idcard command ──────────────────────────────────────────────────────────
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
    for key, ped in pairs(photographerPeds) do
        if ped then DeletePed(ped) end
    end
    for _, v in pairs(Config.IDCardNPC) do
        if v.npcEntity  then DeletePed(v.npcEntity)   end
        if v.blipEntity then RemoveBlip(v.blipEntity) end
    end
    if cam then exitCamera() end
    if creating then
        AnimpostfxStop("OJDominoBlur")
        SetNuiFocus(false, false)
    end
end)
