local idcardData = false
local cam = 0
local currentCamPosition = nil
local movements = {}
local movements2 = {}
local creating = false

local function createPrompts(keysTable, prompts)
    local array = {}
    for _, keyData in pairs(keysTable) do
        local movement = PromptRegisterBegin()
        PromptSetControlAction(movement, keyData[2])
        local str = CreateVarString(10, 'LITERAL_STRING', keyData[1])
        PromptSetText(movement, str)
        PromptSetEnabled(movement, 1)
        PromptSetVisible(movement, 1)
        PromptSetStandardMode(movement, 1)
        PromptSetGroup(movement, prompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, movement, true)
        PromptRegisterEnd(movement)
        table.insert(array, movement)
        PromptSetHoldMode(movement, 500)
    end
    return array
end

local prompts  = GetRandomIntInRange(0, 0xffffff)
local prompts2 = GetRandomIntInRange(0, 0xffffff)

local keysTable = {
    {Locale("takephoto"),  Config.Keybinds["takephoto"]},
    {Locale("printphoto"), Config.Keybinds["printphoto"]},
    {Locale("exit"),       Config.Keybinds["exit"]},
    {Locale("camUp"),      Config.Keybinds["camUp"]},
    {Locale("camDown"),    Config.Keybinds["camDown"]},
    {Locale("camLeft"),    Config.Keybinds["camLeft"]},
    {Locale("camRight"),   Config.Keybinds["camRight"]},
    {Locale("camForward"), Config.Keybinds["camForward"]},
    {Locale("camBack"),    Config.Keybinds["camBack"]},
}

local keysTable2 = {
    {Locale("takeidcard"), Config.Keybinds["takeidcard"]},
}

Citizen.CreateThread(function()
    Citizen.Wait(10)
    movements  = createPrompts(keysTable,  prompts)
    movements2 = createPrompts(keysTable2, prompts2)
end)

-- ── NUI Callbacks ─────────────────────────────────────────
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
    if data.imgLink then
        TriggerServerEvent('fx-idcard:server:print', data.imgLink)
    end
end)

RegisterNUICallback('createIdCard', function(data)
    TriggerServerEvent('fx-idcard:server:buyIdCard', data)
end)

-- ── Network Events ────────────────────────────────────────
RegisterNetEvent('fx-idcard:client:setData', function(data)
    idcardData = data
end)

-- Called when ID card is revoked or no record found
RegisterNetEvent('fx-idcard:client:clearData', function()
    idcardData = false
end)

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
    if typee == "photo" then
        SendNUIMessage({ action = 'showphoto',  array = data })
    else
        SendNUIMessage({ action = 'openIdCard', array = data })
    end
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
    local closestPlayers = GetClosestPlayer()
    local action = typee == "photo" and 'showphoto' or 'openIdCard'
    if #closestPlayers > 0 then
        TriggerServerEvent("fx-idcard:server:ShowUi", closestPlayers, typee, data)
    else
        SetNuiFocus(true, true)
        SendNUIMessage({ action = action, array = data })
    end
end)

-- ── Helpers ───────────────────────────────────────────────
function GetClosestPlayer()
    local players        = GetActivePlayers()
    local playerPed      = PlayerPedId()
    local playerId       = PlayerId()
    local coords         = GetEntityCoords(playerPed)
    local closestPlayers = {}
    for i = 1, #players do
        if players[i] ~= playerId then
            local dist = #(coords - GetEntityCoords(GetPlayerPed(players[i])))
            if dist < Config.ShowDistance then
                closestPlayers[#closestPlayers + 1] = GetPlayerServerId(players[i])
            end
        end
    end
    return closestPlayers
end

local function setActivePrompts(Type)
    local show = {}
    if Type == "photo" then
        show = {true,true,false,false,false,false,false,false,false}
    elseif Type == "camera" then
        show = {false,false,true,true,true,true,true,true,true}
    end
    for i, v in ipairs(show) do
        Citizen.InvokeNative(0x71215ACCFDE075EE, movements[i], v)
    end
end

local function changeCamPosition(x, y, z)
    currentCamPosition = GetOffsetFromCoordAndHeadingInWorldCoords(
        currentCamPosition.x, currentCamPosition.y, currentCamPosition.z, currentCamPosition.w, x, y, z)
    local coords = GetEntityCoords(PlayerPedId())
    if #(coords - currentCamPosition) < 1.5 then
        SetCamCoord(cam, currentCamPosition.x, currentCamPosition.y, currentCamPosition.z)
    end
end

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
    currentCamPosition = v.camCoords
    SetCamCoord(cam, currentCamPosition.x, currentCamPosition.y, currentCamPosition.z)
    SetCamRot(cam, 0, 0, currentCamPosition.w, 2)
    Citizen.InvokeNative(0x27666E5988D9D429, cam, v.camFov)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Wait(1000)
    DoScreenFadeIn(1000)

    Citizen.CreateThread(function()
        while cam do
            local title = CreateVarString(10, 'LITERAL_STRING', "Photographer")
            PromptSetActiveGroupThisFrame(prompts, title)
            setActivePrompts("camera")
            if IsDisabledControlPressed(0, Config.Keybinds["exit"]) then
                RenderScriptCams(false, false, 0, true, true)
                DestroyCam(cam, true)
                cam = nil
                SetPlayerControl(PlayerId(), true)
                FreezeEntityPosition(PlayerPedId(), false)
                TriggerServerEvent('fx-idcard:server:setBucket', 0)
                Config.ShowHud()
            elseif IsDisabledControlPressed(0, Config.Keybinds["camUp"]) then
                changeCamPosition(0, 0, 0.01)
            elseif IsDisabledControlPressed(0, Config.Keybinds["camDown"]) then
                changeCamPosition(0, 0, -0.01)
            elseif IsDisabledControlPressed(0, Config.Keybinds["camLeft"]) then
                changeCamPosition(0, -0.01, 0)
            elseif IsDisabledControlPressed(0, Config.Keybinds["camRight"]) then
                changeCamPosition(0, 0.01, 0)
            elseif IsDisabledControlPressed(0, Config.Keybinds["camForward"]) then
                changeCamPosition(-0.01, 0, 0)
            elseif IsDisabledControlPressed(0, Config.Keybinds["camBack"]) then
                changeCamPosition(0.01, 0, 0)
            end
            Wait(1)
        end
    end)
end

-- ── Photographer NPC spawn thread ─────────────────────────
Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for k, v in pairs(Config.Photographers) do
            local dist = #(vector3(v.promptCoords.x, v.promptCoords.y, v.promptCoords.z) - coords)
            if dist < v.promptDistance then
                sleep = 1
                local label = Locale("promptitle")
                if Config.Prices.printphoto then
                    label = Locale("promptitle") .. " $" .. Config.Prices.printphoto
                end
                local title = CreateVarString(10, 'LITERAL_STRING', label)
                PromptSetActiveGroupThisFrame(prompts, title)
                setActivePrompts("photo")
                if PromptHasHoldModeCompleted(movements[1]) then
                    sleep = 2000
                    Config.HideHud()
                    takePhoto(v)
                elseif PromptHasHoldModeCompleted(movements[2]) then
                    sleep = 2000
                    SetNuiFocus(true, true)
                    SendNUIMessage({ action = 'print' })
                end
            end
        end
        Wait(sleep)
    end
end)

-- ── ID Card NPC spawn + interact thread ───────────────────
local function isOpen(settings)
    if not settings then return true end
    local time = GetClockHours()
    return time >= settings.open and time <= settings.close
end

local function spawnPed(v, coords)
    local modelName = (v.npc and v.npc.model) or v.models
    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
        timeout = timeout + 10
        if timeout > 5000 then
            -- fallback model
            if v.npc and v.npc.fallback then
                modelHash = GetHashKey(v.npc.fallback)
                RequestModel(modelHash)
            end
            break
        end
    end
    local npc = CreatePed(modelHash, coords.x, coords.y, coords.z - 1, coords.w, false, 0)
    FreezeEntityPosition(npc, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(modelHash)
    SetEntityAsMissionEntity(npc, true, true)
    if v.anims then
        if v.anims.name then
            RequestAnimDict(v.anims.dict)
            while not HasAnimDictLoaded(v.anims.dict) do Citizen.Wait(100) end
            TaskPlayAnim(npc, v.anims.dict, v.anims.name, 1.0, -1.0, -1, 1, 0, true, 0, false, 0, false)
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
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for k, v in pairs(Config.IDCardNPC) do
            local dist = #(coords - vector3(v.coords.x, v.coords.y, v.coords.z))
            if dist < Config.PedSpawnDistance and not v.npcEntity and isOpen(v.timeSettings) then
                v.npcEntity  = spawnPed(v, v.coords)
                v.canInteract = true
            elseif v.npcEntity and (dist > Config.PedSpawnDistance or not isOpen(v.timeSettings)) then
                DeletePed(v.npcEntity)
                v.npcEntity   = nil
                v.canInteract = nil
            end
            if v.blips and not v.blipEntity then
                v.blipEntity = createBlip(v)
            end
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
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for k, v in pairs(Config.IDCardNPC) do
            local dist = #(coords - vector3(v.coords.x, v.coords.y, v.coords.z))
            if dist < v.distance and v.canInteract then
                sleep = 1
                local label = Locale("promptitle2")
                if Config.Prices.idcard and not v.illegal then
                    label = Locale("promptitle2") .. " $" .. Config.Prices.idcard
                elseif v.illegal and Config.Prices.illegal then
                    label = Locale("promptitle3") .. " $" .. Config.Prices.illegal
                end
                PromptSetActiveGroupThisFrame(prompts2, CreateVarString(10, 'LITERAL_STRING', label))
                if PromptHasHoldModeCompleted(movements2[1]) then
                    Wait(50)
                    Notify({ text = Locale("useitem", {time=Config.SelectPhotoTime}), time=10000, type="success" })
                    TriggerServerEvent('fx-idcard:server:useImagePlease', k)
                end
            end
        end
        Wait(sleep)
    end
end)

-- ── /idcard command (sql mode) ────────────────────────────
if Config.TakeCardType == "sql" then
    RegisterCommand(Config.ShowIdcardCommand, function()
        TriggerEvent("fx-idcard:client:showIDCardSQL")
    end)
end

-- ── Cleanup on resource stop ──────────────────────────────
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k, v in pairs(Config.IDCardNPC) do
        if v.npcEntity then DeletePed(v.npcEntity) end
        if v.blipEntity then RemoveBlip(v.blipEntity) end
    end
    if cam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, true)
        cam = nil
        SetPlayerControl(PlayerId(), true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
    if creating then AnimpostfxStop("OJDominoBlur") end
end)
