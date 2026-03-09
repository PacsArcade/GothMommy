Config = {}
Config.Language = "en"
Config.LicensePrefix = "GMRP"
Config.ShowIdcardCommand = "idcard"
Config.TakeCardType = "sql"

Config.Keybinds = {
    ["takephoto"]  = { "INPUT_FRONTEND_OPTION",                  47  },
    ["exit"]       = { "INPUT_FRONTEND_CANCEL",                  177 },
    ["camUp"]      = { "INPUT_FRONTEND_UP",                      172 },
    ["camDown"]    = { "INPUT_FRONTEND_DOWN",                    173 },
    ["camLeft"]    = { "INPUT_FRONTEND_LEFT",                    174 },
    ["camRight"]   = { "INPUT_FRONTEND_RIGHT",                   175 },
    ["camForward"] = { "INPUT_FRONTEND_ENDSCREEN_ACCEPT",        10  },
    ["camBack"]    = { "INPUT_FRONTEND_SOCIAL_CLUB",             11  },
    ["printphoto"] = { "INPUT_FRONTEND_ACCEPT",                  18  },
    ["filterPrev"] = { "INPUT_SELECT_QUICKSELECT_SIDEARMS_LEFT", 74  },
    ["filterNext"] = { "INPUT_SELECT_QUICKSELECT_SIDEARMS_RIGHT",75  },
    ["takeidcard"] = { "INPUT_CONTEXT_Y",                        51  },
}

Config.Locale = {
    ["en"] = {
        ["promptitle"]  = "Photographer",
        ["promptitle2"] = "Id Card System",
        ["promptitle3"] = "Illegal Identity Card",
        ["takephoto"]   = "Take Photo  [G]",
        ["printphoto"]  = "Develop Film [Enter]",
        ["exit"]        = "Exit [Backspace]",
        ["camUp"]       = "Cam Up [Num8]",
        ["camDown"]     = "Cam Down [Num2]",
        ["camLeft"]     = "Cam Left [Num4]",
        ["camRight"]    = "Cam Right [Num6]",
        ["camForward"]  = "Zoom In [Num7]",
        ["camBack"]     = "Zoom Out [Num9]",
        ["filterPrev"]  = "Filter Prev [Num1]",
        ["filterNext"]  = "Filter Next [Num3]",
        ["takeidcard"]  = "Take Id Card",
        ["talkphoto"]   = "Talk to Photographer [E]",
        ["noimg"]          = "No picture ~COLOR_YELLOW~link~COLOR_WHITE~ entered !",
        ["successprint"]   = "The photo has been added to your inventory, you can view it with a ~COLOR_YELLOW~double click",
        ["addIdCard"]      = "The id card has been added to your inventory, you can view it with a ~COLOR_YELLOW~double click",
        ["errorprint"]     = "Print ~COLOR_RED~failed ~COLOR_WHITE~!",
        ["erroridcard"]    = "ID Card creation ~COLOR_RED~failed ~COLOR_WHITE~!",
        ["photodesc"]      = "Photo Id",
        ["nodata"]         = "You don't have an identity !",
        ["nomoney"]        = "You don't have enough money. Fee : ~COLOR_YELLOW~${money}",
        ["successidcard"]  = "Your ID card is attached. You can now show your ID",
        ["useitem"]        = "Use your photo from inventory within ~COLOR_YELLOW~${time}~COLOR_WHITE~ seconds",
        ["alreadyidcard"]  = "You already have an identity card. You need approval to change your ID card",
        ["idcarddesc"]     = "${name}'s identity </br>Identity Number: <span style=color:yellow;>${charid}",
        ["noprintphoto"]   = "You do not have a passport photo !",
        ["successdelete"]  = "ID Card has been deleted successfully",
        ["nojob"]          = "You are not authorised to do that !",
        ["errorcommand"]   = "Incorrect usage. Command : /deleteidcard id",
    },
}

Config.HideHud = function() end
Config.ShowHud = function() end

Config.Prices = {
    printphoto = 0,
    idcard     = 5,
    illegal    = 100,
}

Config.AuthorizedJobs = { "sheriff", "lawenforcement", "marshal", "deputy" }
Config.DeletePlayerDataCommand = "deleteidcard"
Config.CheckIdCommand          = "checkid"
Config.SelectPhotoTime         = 30
Config.PrintPhotoItem          = "printphoto"
Config.ManIdCardItem           = "man_idcard"
Config.WomanIdCardItem         = "woman_idcard"
Config.ShowDistance            = 1.5

Config.Photographers = {
    ["Blackwater"] = {
        promptCoords   = vector4(-812.00, -1373.50, 44.07, 180.0),
        promptDistance = 3.5,
        pedCoords = vector4(-814.981, -1375.036, 43.228, 270.0),
        camCoords = vector4(-812.721, -1375.099, 44.973, 0.0),
        camFov    = 45.0,
        npc = {
            model    = "mp_re_photography_females_01",
            hash     = 0x5730F05E,
            fallback = "cs_brontesbutler",
            coords       = vector4(-811.771, -1373.614, 43.073, 270.0),
            photoHeading = 90.0,
        },
        blips = {
            name     = "ID Photo",
            sprite   = 1364029453,
            scale    = 0.6,
            modifier = "BLIP_MODIFIER_MP_COLOR_32",
            coords   = vector3(-812.00, -1373.50, 44.07),
        },
    },
}

Config.PedSpawnDistance = 30
Config.TalkDistance     = 2.5

Config.Religious = {
    "Christian","Buddhist","Wiccan","Pagan",
    "Spiritualist","Coven",
    "Jewish","Muslim","Atheist","None"
}

--[[
  Camera numpad layout:
    NUM 8 = cam up        NUM 2 = cam down
    NUM 4 = cam left      NUM 6 = cam right
    NUM 7 = zoom in       NUM 9 = zoom out
    NUM 1 = filter prev   NUM 3 = filter next
    NUM 5 = reset
    NUM 0 / Backspace / Escape = exit
    Enter / NumpadEnter = take photo (3-2-1 countdown)

  filterType:
    nil      = None
    "solid"  = translucent colour panel
    "acid"   = muted lava-lamp colour warp
    "fog"    = dirty lens fog effect
    "pixel"  = low-res pixelated overlay
]]
Config.CameraFilters = {
    { name = "None" },
    { name = "Sepia",        filterType = "solid", r=110, g=65, b=15, a=0.40 },
    { name = "Thunderstorm", filterType = "solid", r=20,  g=28, b=75, a=0.42 },
    { name = "Blood Moon",   filterType = "solid", r=150, g=5,  b=5,  a=0.40 },
    { name = "Acid Trip",    filterType = "acid"  },
    { name = "Foggy Lens",   filterType = "fog"   },
    { name = "Pixelated",    filterType = "pixel", size = 32 },
}

-- IDCard NPC: placed on the OUTSIDE steps/boardwalk of the Blackwater
-- government building (fully accessible without noclip).
-- Coords tuned from the street-side approach.
Config.IDCardNPC = {
    ["Blackwater"] = {
        coords   = vector4(-802.5, -1187.8, 44.0, 340.0),
        models   = "cs_brontesbutler",
        distance = 3,
        blips = { name="IDENTITY PROCESS", sprite=0x984E7CA9, scale=0.6, modifier="BLIP_MODIFIER_MP_COLOR_32" },
        anims = { dict="WORLD_HUMAN_HANG_OUT_STREET", name=false },
        timeSettings = { open=8, close=21, blipmodifier="BLIP_MODIFIER_MP_COLOR_2" },
    },
    ["IllegalCard"] = {
        illegal=true,
        coords=vector4(-813.2076, -1378.4711, 43.6373, 181.3653),
        fakeLabel="Rhodes", models="cs_brontesbutler", distance=2,
        blips=false, anims={dict="WORLD_HUMAN_HANG_OUT_STREET",name=false}, timeSettings=false,
    },
}

function Notify(data)
    local text=data.text or "No message"; local time=data.time or 5000
    local ntype=data.type or "info"; local icon=data.icon
    local color=data.color or 0; local src=data.source
    if IsDuplicityVersion() then
        if Framework=="VORP" then
            if icon then TriggerClientEvent('vorp:ShowAdvancedRightNotification',src,text,data.dict,icon,color,time)
            else TriggerClientEvent("vorp:TipBottom",src,text,time,ntype) end
        end
    else
        if Framework=="VORP" then
            if icon then TriggerEvent("vorp:ShowAdvancedRightNotification",text,data.dict,icon,color,time)
            else TriggerEvent("vorp:TipBottom",text,time,ntype) end
        end
    end
end

function Locale(key, subs)
    local translate = Config.Locale[Config.Language][key] and Config.Locale[Config.Language][key] or "[missing: "..key.."]"
    subs = subs or {}
    for k,v in pairs(subs) do translate = translate:gsub('%${'..k..'}', tostring(v)) end
    return translate
end
