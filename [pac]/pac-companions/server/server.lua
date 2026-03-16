-- rdn_companions server.lua - Modified for Goth Mommy RP (VORP only)
-- Original by HALALsnackbar | Modified by PacsArcade

local VorpCore = {}
local VorpInv

TriggerEvent("getCore", function(core)
    VorpCore = core
end)
VorpInv = exports.vorp_inventory:vorp_inventoryApi()

-- Sell / remove pet
RegisterServerEvent('rdn_companions:sellpet')
AddEventHandler('rdn_companions:sellpet', function()
    local _src = source
    local Character = VorpCore.getUser(_src).getUsedCharacter
    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier
    exports.ghmattimysql:execute(
        "DELETE FROM companions WHERE identifier = @identifier AND charidentifier = @charidentifier",
        { ["identifier"] = u_identifier, ["charidentifier"] = u_charid }
    )
    TriggerClientEvent('rdn_companions:removedog', _src)
end)

-- Feed pet (disabled in config but handler kept for safety)
RegisterServerEvent('rdn_companions:feedPet')
AddEventHandler('rdn_companions:feedPet', function(xp)
    local _src = source
    local Character = VorpCore.getUser(_src).getUsedCharacter
    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier
    local newXp = xp + Config.XpPerFeed
    local amount = VorpInv.getItemCount(_src, Config.AnimalFood)
    if amount >= 1 then
        if newXp <= Config.FullGrownXp then
            VorpInv.subItem(_src, Config.AnimalFood, 1)
            exports.ghmattimysql:execute(
                "UPDATE companions SET xp = xp + @addedXp WHERE identifier = @identifier AND charidentifier = @charidentifier",
                { ["identifier"] = u_identifier, ["charidentifier"] = u_charid, ["addedXp"] = Config.XpPerFeed }
            )
            TriggerClientEvent('UI:DrawNotification', _src, "+" .. Config.XpPerFeed .. " Pet XP Progress: " .. newXp .. "/" .. Config.FullGrownXp .. " XP")
            TriggerClientEvent('rdn_companions:UpdateDogFed', _src, newXp)
        else
            VorpInv.subItem(_src, Config.AnimalFood, 1)
            TriggerClientEvent('rdn_companions:UpdateDogFed', _src, newXp)
        end
    else
        TriggerClientEvent('UI:DrawNotification', _src, _U('NoFood'))
    end
end)

-- Buy pet
RegisterServerEvent('rdn_companions:buydog')
AddEventHandler('rdn_companions:buydog', function(args)
    local _src = source
    local Character = VorpCore.getUser(_src).getUsedCharacter
    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier
    local _price = args['Price']
    local _model = args['Model']
    local skin = math.floor(math.random(0, 2))
    local canTrack = CanTrack(_src)
    local u_money = Character.money

    if u_money <= _price then
        TriggerClientEvent('UI:DrawNotification', _src, _U('NoMoney'))
        return
    end

    exports.ghmattimysql:execute(
        "SELECT * FROM companions WHERE identifier = @identifier AND charidentifier = @charidentifier",
        { ["identifier"] = u_identifier, ["charidentifier"] = u_charid },
        function(result)
            if #result > 0 then
                exports.ghmattimysql:execute(
                    "UPDATE companions SET dog = @dog, skin = @skin, xp = @xp WHERE identifier = @identifier AND charidentifier = @charidentifier",
                    { ["identifier"] = u_identifier, ["charidentifier"] = u_charid, ["dog"] = _model, ["skin"] = skin, ["xp"] = Config.FullGrownXp },
                    function()
                        Character.removeCurrency(0, _price)
                        TriggerClientEvent('rdn_companions:spawndog', _src, _model, skin, true, Config.FullGrownXp, canTrack)
                        TriggerClientEvent('UI:DrawNotification', _src, _U('ReplacePet'))
                    end
                )
            else
                exports.ghmattimysql:execute(
                    "INSERT INTO companions (identifier, charidentifier, dog, skin, xp) VALUES (@identifier, @charidentifier, @dog, @skin, @xp)",
                    { ["identifier"] = u_identifier, ["charidentifier"] = u_charid, ["dog"] = _model, ["skin"] = skin, ["xp"] = Config.FullGrownXp },
                    function()
                        Character.removeCurrency(0, _price)
                        TriggerClientEvent('rdn_companions:spawndog', _src, _model, skin, true, Config.FullGrownXp, canTrack)
                        TriggerClientEvent('UI:DrawNotification', _src, _U('NewPet'))
                    end
                )
            end
        end
    )
end)

-- Load pet on spawn
RegisterServerEvent('rdn_companions:loaddog')
AddEventHandler('rdn_companions:loaddog', function()
    local _src = source
    local Character = VorpCore.getUser(_src).getUsedCharacter
    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier
    local canTrack = CanTrack(_src)
    exports.ghmattimysql:execute(
        "SELECT * FROM companions WHERE identifier = @identifier AND charidentifier = @charidentifier",
        { ["identifier"] = u_identifier, ["charidentifier"] = u_charid },
        function(result)
            if result[1] then
                TriggerClientEvent("rdn_companions:spawndog", _src, result[1].dog, result[1].skin, false, Config.FullGrownXp, canTrack)
            else
                TriggerClientEvent('UI:DrawNotification', _src, _U('NoPet'))
            end
        end
    )
end)

function CanTrack(source)
    if not Config.TrackCommand then return false end
    if not Config.AnimalTrackingJobOnly then return true end
    local Character = VorpCore.getUser(source).getUsedCharacter
    local job = Character.job
    for _, v in pairs(Config.AnimalTrackingJobs) do
        if job == v then return true end
    end
    return false
end
