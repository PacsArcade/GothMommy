-- pac-grave-robbery | server
-- Goth Mommy RP | VORP only

local VorpCore
local VorpInv

TriggerEvent("getCore", function(core) VorpCore = core end)
Citizen.CreateThread(function()
    Citizen.Wait(100)
    VorpInv = exports.vorp_inventory:vorp_inventoryApi()
end)

local TEXTS    = Config.Texts
local DiggedGraves = {} -- in-memory; resets on server restart

-- =====================================================================
-- CHECK SHOVEL
-- =====================================================================
RegisterServerEvent("pac_grave:check_shovel")
AddEventHandler("pac_grave:check_shovel", function(id)
    local src = source
    if DiggedGraves[id] then
        TriggerClientEvent("pac_grave:notify", src, TEXTS.GraveRobbed, "error")
        return
    end
    local count = VorpInv.getItemCount(src, Config.ShovelItem)
    if count and count > 0 then
        TriggerClientEvent("pac_grave:start_dig", src, id)
    else
        TriggerClientEvent("pac_grave:notify", src, TEXTS.NoShovel, "error")
    end
end)

-- =====================================================================
-- REWARD
-- =====================================================================
RegisterServerEvent("pac_grave:reward")
AddEventHandler("pac_grave:reward", function(id)
    local src = source
    Citizen.Wait(math.random(200, 800))
    if DiggedGraves[id] then
        TriggerClientEvent("pac_grave:notify", src, TEXTS.GraveRobbed, "error")
        return
    end
    DiggedGraves[id] = true
    local reward = Config.Rewards[math.random(1, #Config.Rewards)]
    local canCarry = VorpInv.canCarryItem(src, reward.item, 1)
    if canCarry then
        VorpInv.addItem(src, reward.item, 1)
        TriggerClientEvent("pac_grave:notify", src, TEXTS.FoundItem .. "\n+ " .. reward.label, "success")
    else
        TriggerClientEvent("pac_grave:notify", src, "Your pockets are full.", "error")
    end
end)
