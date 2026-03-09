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
        ["camUp"]       = "Cam Up [Up]",
        ["camDown"]     = "Cam Down [Down]",
        ["camLeft"]     = "Cam Left [Left]",
        ["camRight"]    = "Cam Right [Right]",
        ["camForward"]  = "Zoom In [PgUp]",
        ["camBack"]     = "Zoom Out [PgDn]",
        ["filterPrev"]  = "Filter Prev [[",
        ["filterNext"]  = "Filter Next []]",
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
    printphoto = 5,
    idcard     = 50,
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

--[[
  BLACKWATER STUDIO COORDS  (confirmed from /phototest: floor z=45.07)

  RDR heading:  0=North  90=West  180=South  270=East

  NPC  x=-812.5  heading=90   => faces WEST toward back wall
  Pose x=-807.5  heading=270  => player faces EAST toward camera
  Cam  x=-814.0              => behind tripod, looks east at subject
]]
Config.Photographers = {
    ["Blackwater"] = {
        promptCoords   = vector4(-810.48, -1372.56, 45.07, 180.0),
        promptDistance = 3.5,

        -- Player pose spot: back wall, facing east (toward camera)
        pedCoords = vector4(-807.50, -1372.56, 45.07, 270.0),

        -- Camera sits behind tripod.
        -- Original working rotation: pitch=0, roll=0, yaw=90 (faces west)
        camCoords = vector4(-814.00, -1372.56, 45.70, 90.0),
        camFov    = 50.0,

        npc = {
            model    = "mp_re_photography_females_01",
            hash     = 0x5730F05E,
            fallback = "cs_brontesbutler",
            -- floor z=45.07, heading=90 => faces west toward subject
            coords   = vector4(-812.50, -1372.56, 45.07, 90.0),
        },
        blips = {
            name     = "ID Photo",
            sprite   = 1364029453,
            scale    = 0.6,
            modifier = "BLIP_MODIFIER_MP_COLOR_32",
            coords   = vector3(-810.48, -1372.56, 45.07),
        },
    },
}

Config.PedSpawnDistance = 30
Config.TalkDistance     = 2.5

Config.Religious = {
    "Christian", "Buddhist", "Wiccan", "Pagan",
    "Spiritualist", "Coven",
    "Jewish", "Muslim", "Atheist", "None"
}

Config.CameraFilters = {
    { name = "None",         css = "none" },
    { name = "Sepia",        css = "sepia(1) contrast(1.1)" },
    { name = "Thunderstorm", css = "grayscale(0.6) brightness(0.7) contrast(1.4) saturate(0.5)" },
    { name = "Blood Moon",   css = "sepia(0.4) hue-rotate(-20deg) saturate(3) brightness(0.75) contrast(1.3)" },
    { name = "Devil Eyes",   css = "sepia(0.2) hue-rotate(300deg) saturate(4) brightness(0.85) contrast(1.5)" },
    { name = "Acid Trip",    css = "hue-rotate(90deg) saturate(8) brightness(1.1) contrast(1.4)" },
}

Config.IDCardNPC = {
    ["Blackwater"] = {
        coords   = vector4(-798.8420, -1194.6926, 44.0010, 161.6237),
        models   = "cs_brontesbutler",
        distance = 3,
        blips = {
            name     = "IDENTITY PROCESS",
            sprite   = 0x984E7CA9,
            scale    = 0.6,
            modifier = "BLIP_MODIFIER_MP_COLOR_32",
        },
        anims = {
            dict = "WORLD_HUMAN_HANG_OUT_STREET",
            name = false,
        },
        timeSettings = {
            open         = 8,
            close        = 21,
            blipmodifier = "BLIP_MODIFIER_MP_COLOR_2",
        },
    },
    ["IllegalCard"] = {
        illegal      = true,
        coords       = vector4(-813.2076, -1378.4711, 43.6373, 181.3653),
        fakeLabel    = "Rhodes",
        models       = "cs_brontesbutler",
        distance     = 2,
        blips        = false,
        anims        = { dict = "WORLD_HUMAN_HANG_OUT_STREET", name = false },
        timeSettings = false,
    },
}

function Notify(data)
    local text  = data.text  or "No message"
    local time  = data.time  or 5000
    local ntype = data.type  or "info"
    local icon  = data.icon
    local color = data.color or 0
    local src   = data.source
    if IsDuplicityVersion() then
        if Framework == "VORP" then
            if icon then TriggerClientEvent('vorp:ShowAdvancedRightNotification', src, text, data.dict, icon, color, time)
            else TriggerClientEvent("vorp:TipBottom", src, text, time, ntype) end
        end
    else
        if Framework == "VORP" then
            if icon then TriggerEvent("vorp:ShowAdvancedRightNotification", text, data.dict, icon, color, time)
            else TriggerEvent("vorp:TipBottom", text, time, ntype) end
        end
    end
end

function Locale(key, subs)
    local translate = Config.Locale[Config.Language][key]
        and Config.Locale[Config.Language][key]
        or "[missing: "..key.."]"
    subs = subs or {}
    for k, v in pairs(subs) do
        translate = translate:gsub('%${' .. k .. '}', tostring(v))
    end
    return translate
end
