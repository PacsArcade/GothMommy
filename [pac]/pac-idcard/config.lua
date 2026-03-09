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
  BLACKWATER PHOTOGRAPHY STUDIO - COORDINATE MAP
  Room runs roughly east(-813) <-> west(-807) along X axis
  Y is constant ~-1372.56, Z floor = ~44.07

  [BACK WALL]  x=-807  <-- subject stands here, faces EAST (heading=90)
  [TRIPOD]     x=-813  <-- camera tripod prop is here
  [NPC]        x=-813  <-- stands beside tripod, faces WEST toward subject (heading=90 in RDR = faces west... wait)

  RDR HEADING NOTE:
    0   = North (+Y direction)
    90  = West  (-X direction)  <-- faces toward back wall from tripod side
    180 = South (-Y direction)
    270 = East  (+X direction)  <-- faces toward door/tripod from back wall

  So:
    Subject  at x=-807.5, heading=270 (faces east, toward camera)
    NPC/cam  at x=-813.0, heading=90  (faces west, toward subject/back wall)
]]

Config.Photographers = {
    ["Blackwater"] = {
        promptCoords   = vector4(-810.48, -1372.56, 44.07, 180.0),
        promptDistance = 3.5,

        -- Player is placed HERE when photo session starts
        -- x=-807.5 = back wall area, heading=270 = faces east toward camera
        pedCoords = vector4(-807.50, -1372.56, 44.07, 270.0),

        -- Scripted camera sits near the tripod, points west at subject
        -- w component unused (we use PointCamAtCoord instead)
        camCoords = vector4(-813.50, -1372.56, 44.80, 0.0),
        camFov    = 50.0,

        npc = {
            model    = "mp_re_photography_females_01",
            hash     = 0x5730F05E,
            fallback = "cs_brontesbutler",
            -- x=-812.5 = beside tripod
            -- z=44.07  = exact floor level (from /phototest player z)
            -- heading=90 = faces WEST toward back wall / subject
            coords   = vector4(-812.50, -1372.56, 44.07, 90.0),
        },
        blips = {
            name     = "ID Photo",
            sprite   = 1364029453,
            scale    = 0.6,
            modifier = "BLIP_MODIFIER_MP_COLOR_32",
            coords   = vector3(-810.48, -1372.56, 44.07),
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
