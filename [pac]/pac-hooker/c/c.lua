-- pac-hooker | client
-- Goth Mommy RP | VORP only | 21+ server
-- Enhanced: opposite-sex NPCs, bath requirement, noir toasts,
--           RDR3 ambient sounds, health restore, well-rested buff

local VorpCore = {}
TriggerEvent("getCore", function(core) VorpCore = core end)

local prompts        = GetRandomIntInRange(0, 0xffffff)
local talktonpc      = nil
local working        = false

-- =====================================================================
-- NOTIFICATION HELPER
-- =====================================================================
local function Notify(msg, ntype)
    ntype = ntype or "success"
    TriggerEvent("vorp:TipBottom", msg, 5000, ntype)
end

-- =====================================================================
-- SPAWN NPCs AFTER CHARACTER SELECT
-- =====================================================================
RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function()
    StartNPCs()
end)

function StartNPCs()
    for _, v in ipairs(Config.NPCs) do
        local hashModel = GetHashKey(v.npcmodel)
        if IsModelValid(hashModel) then
            RequestModel(hashModel)
            while not HasModelLoaded(hashModel) do Wait(100) end
        else
            print("[pac-hooker] Invalid model: " .. v.npcmodel)
        end
        local npc = CreatePed(hashModel, v.coords.x, v.coords.y, v.coords.z, v.heading, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        SetEntityNoCollisionEntity(PlayerPedId(), npc, false)
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(500)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        if v.blip ~= 0 then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(blip, v.blip, true)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.npc_name)
        end
    end
end

-- =====================================================================
-- INTERACTION PROMPT
-- =====================================================================
Citizen.CreateThread(function()
    Citizen.Wait(5000)
    talktonpc = PromptRegisterBegin()
    PromptSetControlAction(talktonpc, Config.keys["G"])
    PromptSetText(talktonpc, CreateVarString(10, 'LITERAL_STRING', Config.Language.press))
    PromptSetEnabled(talktonpc, 1)
    PromptSetVisible(talktonpc, 1)
    PromptSetStandardMode(talktonpc, 1)
    PromptSetHoldMode(talktonpc, 1)
    PromptSetGroup(talktonpc, prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, talktonpc, true)
    PromptRegisterEnd(talktonpc)
end)

-- =====================================================================
-- PLAY SESSION SOUND (native RDR3 audio, no custom files)
-- =====================================================================
local function PlaySessionSound()
    if #Config.SessionSounds == 0 then return end
    local s = Config.SessionSounds[math.random(1, #Config.SessionSounds)]
    Citizen.InvokeNative(0x67C540AA08E4A6F5, -1, s[1], s[2], true, 0)
end

-- =====================================================================
-- SESSION SEQUENCE
-- =====================================================================
local function RunSession(v)
    working = true
    local playerPed  = PlayerPedId()
    local originalPos = GetEntityCoords(playerPed)

    -- Invite toast
    Notify(Config.Language.invite, "info")
    Citizen.Wait(3000)

    FreezeEntityPosition(playerPed, true)
    DoScreenFadeOut(1000)
    Citizen.Wait(1500)

    -- Teleport into room
    SetEntityCoords(playerPed, v.pos.x, v.pos.y, v.pos.z)

    -- Noir toast over black screen
    local noirLine = Config.NoirLines[math.random(1, #Config.NoirLines)]
    Notify(noirLine, "info")

    -- Play ambient RDR3 sound during session
    PlaySessionSound()
    Citizen.Wait(4000)
    PlaySessionSound() -- second sound mid-session

    Citizen.Wait(14000) -- total ~20s in room with sounds

    -- Closing toast still in the dark
    Notify("...", "info")
    Citizen.Wait(2000)

    -- Teleport back, fade in
    SetEntityCoords(playerPed, originalPos.x, originalPos.y, originalPos.z)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearPedTasks(playerPed)
    FreezeEntityPosition(playerPed, false)

    -- Server handles payment, health restore, buff
    TriggerServerEvent('pac_hooker:session_end')
    working = false
end

-- =====================================================================
-- PROXIMITY LOOP
-- =====================================================================
Citizen.CreateThread(function()
    while true do
        local sleep = true
        for _, v in ipairs(Config.NPCs) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            if Vdist(playerCoords, v.coords) <= v.radius then
                if v.type ~= "nointeraction" then
                    sleep = false
                    PromptSetActiveGroupThisFrame(prompts, CreateVarString(10, 'LITERAL_STRING', Config.Language.talk))
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, talktonpc) then
                        if not working then
                            local playerPed = PlayerPedId()
                            -- Gender check
                            local isMale = IsPedMale(playerPed)
                            if (v.type == "m_interaction" and not isMale) then
                                Notify(Config.Language.reject_m, "error")
                                Citizen.Wait(3000)
                            elseif (v.type == "f_interaction" and isMale) then
                                Notify(Config.Language.reject_f, "error")
                                Citizen.Wait(3000)
                            else
                                -- Bath check (server validates timestamp)
                                TriggerServerEvent('pac_hooker:check_bath')
                                Citizen.Wait(1000)
                            end
                        end
                        Citizen.Wait(1000)
                    end
                end
            end
        end
        if sleep then Citizen.Wait(500) end
        Citizen.Wait(1)
    end
end)

-- =====================================================================
-- SERVER RESPONSES
-- =====================================================================
RegisterNetEvent('pac_hooker:bath_ok')
AddEventHandler('pac_hooker:bath_ok', function(npcIndex)
    local v = Config.NPCs[npcIndex]
    if v then RunSession(v) end
end)

RegisterNetEvent('pac_hooker:no_bath')
AddEventHandler('pac_hooker:no_bath', function()
    Notify(Config.Language.no_bath, "error")
end)

RegisterNetEvent('pac_hooker:session_complete')
AddEventHandler('pac_hooker:session_complete', function(cost)
    Notify(Config.Language.paid .. cost .. " taken.", "info")
    -- Health restore
    local ped = PlayerPedId()
    SetEntityHealth(ped, Config.HealthRestore)
    -- Well-rested buff toast
    Citizen.Wait(1500)
    Notify(Config.Language.well_rested, "success")
end)
