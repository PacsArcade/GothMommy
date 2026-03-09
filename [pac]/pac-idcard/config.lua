Config = {}
Config.Language = "en"
Config.LicensePrefix = "GMRP"
Config.ShowIdcardCommand = "idcard"
Config.TakeCardType = "sql" -- "item" or "sql" — sql = one unique ID per player

-- ─── Keybinds ──────────────────────────────────────────────────────────────────
Config.Keybinds = {
    ["takephoto"]  = { "INPUT_FRONTEND_OPTION",                  47  },  -- G
    ["exit"]       = { "INPUT_FRONTEND_CANCEL",                  177 },  -- Backspace
    ["camUp"]      = { "INPUT_FRONTEND_UP",                      172 },  -- Up Arrow
    ["camDown"]    = { "INPUT_FRONTEND_DOWN",                    173 },  -- Down Arrow
    ["camLeft"]    = { "INPUT_FRONTEND_LEFT",                    174 },  -- Left Arrow
    ["camRight"]   = { "INPUT_FRONTEND_RIGHT",                   175 },  -- Right Arrow
    ["camForward"] = { "INPUT_FRONTEND_ENDSCREEN_ACCEPT",        10  },  -- Page Up
    ["camBack"]    = { "INPUT_FRONTEND_SOCIAL_CLUB",             11  },  -- Page Down
    ["printphoto"] = { "INPUT_FRONTEND_ACCEPT",                  18  },  -- Enter
    ["filterPrev"] = { "INPUT_SELECT_QUICKSELECT_SIDEARMS_LEFT", 74  },  -- [
    ["filterNext"] = { "INPUT_SELECT_QUICKSELECT_SIDEARMS_RIGHT",75  },  -- ]
    ["takeidcard"] = { "INPUT_CONTEXT_Y",                        51  },  -- E
}

Config.Locale = {
    ["en"] = {
        --- PROMPTS ---
        ["promptitle"]  = "Photographer",
        ["promptitle2"] = "Id Card System",
        ["takephoto"]   = "Take Photo  [G]",
        ["printphoto"]  = "Print Photo [Enter]",
        ["exit"]        = "Exit [Backspace]",
        ["camUp"]       = "Cam Up [\xe2\x86\x91]",
        ["camDown"]     = "Cam Down [\xe2\x86\x93]",
        ["camLeft"]     = "Cam Left [\xe2\x86\x90]",
        ["camRight"]    = "Cam Right [\xe2\x86\x92]",
        ["camForward"]  = "Zoom In [PgUp]",
        ["camBack"]     = "Zoom Out [PgDn]",
        ["filterPrev"]  = "Filter Prev [[",
        ["filterNext"]  = "Filter Next []]",
        ["promptitle3"] = "Illegal Identity Card",
        ["takeidcard"]  = "Take Id Card",
        ["talkphoto"]   = "Talk to Photographer [E]",
        --- NOTIFY -----
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

Config.Photographers = {
    ["Blackwater"] = {
        -- promptCoords kept for blip reference; interaction is now talk-to-NPC
        promptCoords   = vector4(-810.48, -1372.56, 43.02, 104.9485),
        promptDistance = 3.5,
        pedCoords      = vector4(-810.48, -1372.56, 43.02, 285.0),
        camCoords      = vector4(-814.40, -1374.85, 44.90, 86.48),
        camFov         = 60.0,
        npc = {
            model    = "mp_re_photography_females_01",
            hash     = 0x5730F05E,
            fallback = "cs_brontesbutler",
            -- heading flipped 180 degrees: 285 -> 105
            coords   = vector4(-810.48, -1372.56, 43.02, 105.0),
            -- Standing idle scenario (not crouching)
            anim     = "WORLD_HUMAN_STAND_IMPATIENT",
        },
        blips = {
            name     = "ID Photo",
            sprite   = 1364029453,  -- blip_photo_studio
            scale    = 0.6,
            modifier = "BLIP_MODIFIER_MP_COLOR_32",
            coords   = vector3(-810.48, -1372.56, 43.02),
        },
    },
}

Config.PedSpawnDistance = 30
Config.TalkDistance     = 2.5  -- how close to trigger talk prompt on photographer NPC

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
            dict = "WORLD_HUMAN_STAND_IMPATIENT",
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
        anims        = { dict = "WORLD_HUMAN_STAND_IMPATIENT", name = false },
        timeSettings = false,
    },
}

function Notify(data)
    local text  = data.text  or "No message"
    local time  = data.time  or 5000
    local type  = data.type  or "info"
    local icon  = data.icon
    local color = data.color or 0
    local src   = data.source
    if IsDuplicityVersion() then
        if Framework == "VORP" then
            if icon then TriggerClientEvent('vorp:ShowAdvancedRightNotification', src, text, data.dict, icon, color, time)
            else TriggerClientEvent("vorp:TipBottom", src, text, time, type) end
        end
    else
        if Framework == "VORP" then
            if icon then TriggerEvent("vorp:ShowAdvancedRightNotification", text, data.dict, icon, color, time)
            else TriggerEvent("vorp:TipBottom", text, time, type) end
        end
    end
end

function Locale(key, subs)
    local translate = Config.Locale[Config.Language][key]
        and Config.Locale[Config.Language][key]
        or "[missing: "..key.."]"
    subs = subs or {}
    -- Simple ${key} substitution — no leading %% required
    for k, v in pairs(subs) do
        translate = translate:gsub('%${' .. k .. '}', tostring(v))
    end
    return translate
end
