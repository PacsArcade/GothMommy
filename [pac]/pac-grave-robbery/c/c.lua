-- pac-grave-robbery | client
-- Goth Mommy RP | VORP only
-- Ported from ricx_grave_robbery by zelbeus

local TEXTS    = Config.Texts
local TEXTURES = Config.Textures

local pcoords   = nil
local isdead    = nil
local praying   = false
local digging   = false
local shovelObj = nil

local PromptKey
local PromptKey2
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local prompts     = {}

-- =====================================================================
-- NOTIFICATION HELPER
-- =====================================================================
local function Notify(msg, ntype)
    ntype = ntype or "success"
    TriggerEvent("vorp:TipBottom", msg, 4000, ntype)
end

-- =====================================================================
-- PROMPTS
-- =====================================================================
local function LoadPrompts()
    PromptKey = PromptRegisterBegin()
    PromptSetControlAction(PromptKey, Config.Prompts.Prompt1)
    PromptSetText(PromptKey, CreateVarString(10, 'LITERAL_STRING', TEXTS.Prompt1))
    PromptSetEnabled(PromptKey, 1)
    PromptSetVisible(PromptKey, 1)
    PromptSetStandardMode(PromptKey, 1)
    PromptSetGroup(PromptKey, PromptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, PromptKey, true)
    PromptRegisterEnd(PromptKey)
    prompts[#prompts + 1] = PromptKey

    PromptKey2 = PromptRegisterBegin()
    PromptSetControlAction(PromptKey2, Config.Prompts.Prompt2)
    PromptSetText(PromptKey2, CreateVarString(10, 'LITERAL_STRING', TEXTS.Prompt2))
    PromptSetEnabled(PromptKey2, 1)
    PromptSetVisible(PromptKey2, 1)
    PromptSetStandardMode(PromptKey2, 1)
    PromptSetGroup(PromptKey2, PromptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, PromptKey2, true)
    PromptRegisterEnd(PromptKey2)
    prompts[#prompts + 1] = PromptKey2
end

-- =====================================================================
-- POSITION / DEATH TRACKER
-- =====================================================================
Citizen.CreateThread(function()
    LoadPrompts()
    while true do
        Citizen.Wait(500)
        pcoords = GetEntityCoords(PlayerPedId())
        isdead  = IsEntityDead(PlayerPedId())
    end
end)

-- =====================================================================
-- PROXIMITY LOOP
-- =====================================================================
Citizen.CreateThread(function()
    while true do
        local t = 5
        if pcoords and isdead == false then
            for i, v in pairs(Config.Graves) do
                local dist = #(pcoords - v.coords)

                -- draw grave circle indicator
                if dist < 10.0 then
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x6903B113,
                        v.coords.x, v.coords.y, v.coords.z - 0.995,
                        0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0,
                        126, 0, 0, 255, 0, 0, 2, 0, 0, 0, 0)
                end

                if dist < 1.0 then
                    local label = CreateVarString(10, 'LITERAL_STRING', TEXTS.GraveDisplay .. " " .. v.name)
                    PromptSetActiveGroupThisFrame(PromptGroup, label)

                    if Citizen.InvokeNative(0xC92AC953F0A982AE, PromptKey) then
                        TriggerEvent("pac_grave:dig", i)
                        Citizen.Wait(2000)
                    end
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, PromptKey2) then
                        TriggerEvent("pac_grave:pray", i)
                        Citizen.Wait(2000)
                    end
                end
            end
        else
            t = 1500
        end
        Citizen.Wait(t)
    end
end)

-- =====================================================================
-- SHOVEL CLEANUP
-- =====================================================================
local function EndShovel()
    digging = false
    if shovelObj then
        DeleteObject(shovelObj)
        SetEntityAsNoLongerNeeded(shovelObj)
        shovelObj = nil
    end
    ClearPedTasks(PlayerPedId())
end

local function AttachEnt(from, to, boneIndex, x, y, z, pitch, roll, yaw)
    return AttachEntityToEntity(from, to, boneIndex, x, y, z, pitch, roll, yaw,
        false, false, true, false, 1, true, false, false)
end

-- =====================================================================
-- DIG EVENTS
-- =====================================================================
RegisterNetEvent("pac_grave:dig")
AddEventHandler("pac_grave:dig", function(id)
    if praying then
        Notify(TEXTS.CantDoThat, "error")
        return
    end
    if digging then
        EndShovel()
    else
        TriggerServerEvent("pac_grave:check_shovel", id)
    end
end)

RegisterNetEvent("pac_grave:start_dig")
AddEventHandler("pac_grave:start_dig", function(id)
    if shovelObj then
        DeleteObject(shovelObj)
        SetEntityAsNoLongerNeeded(shovelObj)
        shovelObj = nil
    end
    digging = true
    local pedp   = PlayerPedId()
    local pc     = GetEntityCoords(pedp)
    local model  = Config.Dig.shovel
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    shovelObj = CreateObject(model, pc.x, pc.y, pc.z, true, true, true)
    local boneIndex = GetEntityBoneIndexByName(pedp, Config.Dig.bone)
    local A         = Config.Dig.pos
    SetEntityHeading(pedp, Config.Graves[id].heading)
    local anim = Config.Dig.anim
    RequestAnimDict(anim[1])
    while not HasAnimDictLoaded(anim[1]) do Citizen.Wait(0) end
    TaskPlayAnim(pedp, anim[1], anim[2], 1.0, 1.0, -1, 1, 0, false, false, false)
    AttachEnt(shovelObj, pedp, boneIndex, A[1], A[2], A[3], A[4], A[5], A[6])
    TriggerEvent("pac_grave:digging_timer", id)
    Citizen.Wait(200)
    RemoveAnimDict(anim[1])
    SetModelAsNoLongerNeeded(model)
end)

RegisterNetEvent("pac_grave:digging_timer")
AddEventHandler("pac_grave:digging_timer", function(id)
    local timer  = Config.DiggingTimer
    local timer2 = 0
    while timer2 ~= timer and digging do
        Citizen.Wait(1000)
        timer2 = timer2 + 1
    end
    if digging then
        EndShovel()
        TriggerServerEvent("pac_grave:reward", id)
    end
end)

-- =====================================================================
-- PRAY EVENT
-- =====================================================================
RegisterNetEvent("pac_grave:pray")
AddEventHandler("pac_grave:pray", function(id)
    if digging then
        Notify(TEXTS.CantDoThat, "error")
        return
    end
    if praying then
        ClearPedTasks(PlayerPedId())
    else
        local anim = Config.PrayAnim[math.random(1, #Config.PrayAnim)]
        RequestAnimDict(anim[1])
        while not HasAnimDictLoaded(anim[1]) do Citizen.Wait(0) end
        SetEntityHeading(PlayerPedId(), Config.Graves[id].heading)
        TaskPlayAnim(PlayerPedId(), anim[1], anim[2], 1.0, 1.0, -1, 1, 0, true, 0, false, 0, false)
        Citizen.Wait(500)
        RemoveAnimDict(anim[1])
    end
    praying = not praying
end)

-- =====================================================================
-- NOTIFICATIONS FROM SERVER
-- =====================================================================
RegisterNetEvent('pac_grave:notify')
AddEventHandler('pac_grave:notify', function(msg, ntype)
    Notify(msg, ntype or "info")
end)

-- =====================================================================
-- CLEANUP
-- =====================================================================
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    if praying or digging then EndShovel() end
    for _, v in pairs(prompts) do PromptDelete(v) end
end)
