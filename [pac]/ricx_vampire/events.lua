local TEXTS = Config.Texts
local TEXTURES = Config.Textures
local notifSettings = {}
-----------------------------------------------------------------------------------------------------
local notifSettings = {
	[1] = {
		TEXTS.Vampire, TEXTS.Died, TEXTURES.alert[1], TEXTURES.alert[2], 3000,
	},
	[2] = {
		TEXTS.Vampire, TEXTS.NoMana, TEXTURES.alert[1], TEXTURES.alert[2], 3000,
	},
	[3] = {
		TEXTS.Vampire, TEXTS.GotItem, TEXTURES.alert[1], TEXTURES.alert[2], 3000,
	},
	[4] = {
		TEXTS.Vampire, TEXTS.Became, TEXTURES.alert[1], TEXTURES.alert[2], 3000,
	},
	[5] = {
		TEXTS.Vampire, TEXTS.Already, TEXTURES.alert[1], TEXTURES.alert[2], 3000,
	},
	[6] = {
		TEXTS.Vampire, TEXTS.VampireAlert, TEXTURES.alert[1], TEXTURES.alert[2], 3000,
	},
	--[[
	[] = {
		TEXTS.TEXT, TEXTS.Saved, TEXTURES.alert[1], TEXTURES.alert[2], 3000,
	},
]]
}

-----------------------------------------------------------------------------------------------------
function CallVampireNotif(id, extra)
	local _id = tonumber(id)
	local title = notifSettings[_id][1]
	local text = notifSettings[_id][2]
	local dict = notifSettings[_id][3]
	local texture = notifSettings[_id][4]
	local timer = notifSettings[_id][5]

------------------EXTRA CODE START------------------
	if extra ~= nil then 						 --|
		if extra.title ~= nil then 				 --|
			title = extra.title					 --|
		end									 	 --|
		if extra.text ~= nil then 				 --|
			text = extra.text					 --|
		end										 --|
		if extra.dict ~= nil then 				 --|
			dict = extra.dict					 --|
		end										 --|
		if extra.texture ~= nil then 			 --|
			texture = extra.texture				 --|
		end										 --|
		if extra.timer ~= nil then 				 --|
			timer = extra.timer					 --|
		end										 --|
	end											 --|
------------------EXTRA CODE END------------------
	TriggerEvent("Notification:ricx_vampire", title, text, dict, texture, timer)--change this to a different notification logic if you want
end
-----------------------------------------------------------------------------------------------------
RegisterNetEvent("ricx_vampire:call_notif", function(id, extra)
	local _id = tonumber(id)
	CallVampireNotif(_id, extra)
end)
----------------------------Basic Notification----------------------------
RegisterNetEvent('Notification:ricx_vampire', function(t1, t2, dict, txtr, timer)
    local _dict = tostring(dict)
    PrepareTexture(_dict)
    exports.ricx_vampire.LeftNot(0, tostring(t1), tostring(t2), tostring(dict), tostring(txtr), tonumber(timer))
    SetStreamedTextureDictAsNoLongerNeeded(_dict)
end)
--------------------------------------------------------------------------------------------------------------------------------------------
function ValidPedCheck(ped)
	if IsPedAPlayer(ped) ~= 1 and IsEntityDead(ped) ~= 1 and IsPedHuman(ped) == 1 and GetMount(ped) == 0 and IsPedInAnyVehicle(ped, 1) ~= 1 and GetScriptTaskStatus(ped, 0x4924437D,1) == 8 and GetScriptTaskStatus(ped, 0xC572E06A,1) == 8 and IsEntityFrozen(ped) == 0 and GetEntityAttachedTo(ped) == 0 and IsEntityPlayingAnyAnim(ped, 1) ~= 1 then
		return true 
	else
		return false
	end
end
-----------------------------------------------------------------------------------------------------
RegisterNetEvent("ricx_vampire:reload_playerped", function()
	print("reload logic for player ped look")
	if Config.framework == "redemrp" then 
		ExecuteCommand("loadskin") --CHANGE TO PED RESET FUNCTION/EVENT
	elseif Config.framework == "redemrp-reboot" then 
		ExecuteCommand("loadskin") --CHANGE TO PED RESET FUNCTION/EVENT
	elseif Config.framework == "vorp" then 
		--CHANGE TO PED RESET FUNCTION/EVENT
	elseif Config.framework == "qbr" then 
 		--CHANGE TO PED RESET FUNCTION/EVENT
	elseif Config.framework == "rsg" then 
		--CHANGE TO PED RESET FUNCTION/EVENT
	elseif Config.framework == "qbr2" then 
		--CHANGE TO PED RESET FUNCTION/EVENT
	end
end)
-----------------------------------------------------------------------------------------------------
function isPlayerWearingHat()
	local protection = 0
	if Config?.UseClothFunctionForSun?.enable then 
		for i,v in pairs(Config.UseClothFunctionForSun.protection) do 
			if Citizen.InvokeNative(0xFB4891BD7578CDC1, PlayerPedId(), i) then 
				protection += v
			end
		end
	end
	return protection
end
-----------------------------------------------------------------------------------------------------