-- pac-hooker | server
-- Goth Mommy RP | VORP only
-- Handles: bath timestamp check, payment, health buff, well-rested status

local VorpCore = {}
TriggerEvent("getCore", function(core) VorpCore = core end)

-- =====================================================================
-- BATH CHECK
-- Validates player bathed within Config.BathWindowSeconds
-- =====================================================================
RegisterServerEvent('pac_hooker:check_bath')
AddEventHandler('pac_hooker:check_bath', function()
    local src = source
    if not VorpCore.getUser(src) then return end
    local Character = VorpCore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid     = Character.charIdentifier

    exports.oxmysql:execute(
        'SELECT last_bath FROM pac_player_status WHERE identifier = ? AND charid = ?',
        {identifier, charid},
        function(result)
            local now = os.time()
            if result and result[1] and result[1].last_bath then
                local lastBath = result[1].last_bath
                if (now - lastBath) <= Config.BathWindowSeconds then
                    -- Find which NPC they were closest to and send back index
                    -- Client will handle the session with the right NPC
                    -- We send a generic ok since client already knows which NPC they're near
                    TriggerClientEvent('pac_hooker:bath_ok', src, 1) -- client uses nearest NPC
                else
                    TriggerClientEvent('pac_hooker:no_bath', src)
                end
            else
                TriggerClientEvent('pac_hooker:no_bath', src)
            end
        end
    )
end)

-- =====================================================================
-- SESSION END: deduct payment, record well-rested, notify client
-- =====================================================================
RegisterServerEvent('pac_hooker:session_end')
AddEventHandler('pac_hooker:session_end', function()
    local src = source
    if not VorpCore.getUser(src) then return end
    local Character = VorpCore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local charid     = Character.charIdentifier

    -- Deduct payment
    Character.removeCurrency(0, Config.pay)

    -- Record well-rested timestamp
    exports.oxmysql:execute(
        'INSERT INTO pac_player_status (identifier, charid, well_rested_until) VALUES (?, ?, ?) ' ..
        'ON DUPLICATE KEY UPDATE well_rested_until = VALUES(well_rested_until)',
        {identifier, charid, os.time() + Config.BuffDuration},
        function() end
    )

    TriggerClientEvent('pac_hooker:session_complete', src, Config.pay)
end)
