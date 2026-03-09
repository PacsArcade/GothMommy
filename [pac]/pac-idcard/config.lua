Config = {}
Config.Language = "en"
Config.LicensePrefix = "GMRP" -- Prefix for license numbers e.g. GMRP-000123
Config.ShowIdcardCommand = "idcard"
Config.TakeCardType = "sql" -- "item" or "sql" — sql = one unique ID per player

-- ─── Keybinds ──────────────────────────────────────────────────────────────
-- Arrow keys: Up=0x05CA7C52  Down=0xF5F8B500  Left=0xA65EBAB4  Right=0xDEB34313
-- Plus (+):   0x4B38BFCA   Minus (-): 0x2A3F6CCE
-- Comma (,):  0xCEFD9220   Period (.): 0x4B44B534
-- G: 0x760A9C6F  Backspace: 0x156F7119  Enter: 0xC7B5340A
Config.Keybinds = {
    ["takephoto"]  = 0x760A9C6F, -- G
    ["exit"]       = 0x156F7119, -- Backspace
    ["camUp"]      = 0x05CA7C52, -- Up Arrow    (move cam up)
    ["camDown"]    = 0xF5F8B500, -- Down Arrow  (move cam down)
    ["camLeft"]    = 0xA65EBAB4, -- Left Arrow  (move cam left)
    ["camRight"]   = 0xDEB34313, -- Right Arrow (move cam right)
    ["camForward"] = 0x4B38BFCA, -- Plus (+)    (zoom in)
    ["camBack"]    = 0x2A3F6CCE, -- Minus (-)   (zoom out)
    ["printphoto"] = 0xC7B5340A, -- Enter
    ["filterPrev"] = 0xCEFD9220, -- Comma (,)   (filter left)
    ["filterNext"] = 0x4B44B534, -- Period (.)  (filter right)
    ["takeidcard"] = 0x2CD5343E,
}

Config.Locale = {
    ["en"] = {
        --- PROMPTS ---
        ["promptitle"]  = "Photographer",
        ["promptitle2"] = "Id Card System",
        ["takephoto"]   = "Take Photo  [G]",
        ["printphoto"]  = "Print Photo [Enter]",
        ["exit"]        = "Exit [Backspace]",
        ["camUp"]       = "Cam Up [↑]",
        ["camDown"]     = "Cam Down [↓]",
        ["camLeft"]     = "Cam Left [←]",
        ["camRight"]    = "Cam Right [→]",
        ["camForward"]  = "Zoom In [+]",
        ["camBack"]     = "Zoom Out [-]",
        ["filterPrev"]  = "Filter [,]",
        ["filterNext"]  = "Filter [.]",
        ["promptitle3"] = "Illegal Identity Card",
        ["takeidcard"]  = "Take Id Card",
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
        ["useitem"]        = "Use your photo from inventory within ~COLOR_YELLOW~${time} ~COLOR_WHITE~seconds",
        ["alreadyidcard"]  = "You already have an identity card. You need approval to change your ID card",
        ["idcarddesc"]     = "${name}'s identity </br>Identity Number: <span style=color:yellow;>${charid}",
        ["noprintphoto"]   = "You do not have a passport photo !",
        ["successdelete"]  = "ID Card has been deleted successfully",
        ["nojob"]          = "You are not authorised to do that !",
        ["errorcommand"]   = "Incorrect usage. Command : /deleteidcard id",
    },
}

Config.HideHud = function()
    -- exports['fx-hud']:hideHud()
end
Config.ShowHud = function()
    -- exports['fx-hud']:showHud()
end

Config.Prices = {
    printphoto = 5,   -- or false (free)
    idcard     = 50,  -- or false (free)
    illegal    = 100, -- or false (free)
}

Config.AuthorizedJobs = { "sheriff", "lawenforcement", "marshal", "deputy" }

Config.DeletePlayerDataCommand = "deleteidcard"
Config.CheckIdCommand          = "checkid"
Config.SelectPhotoTime         = 30 -- seconds
Config.PrintPhotoItem          = "printphoto"
Config.ManIdCardItem           = "man_idcard"
Config.WomanIdCardItem         = "woman_idcard"
Config.ShowDistance            = 1.5

Config.Photographers = {
    ["Blackwater"] = {
        promptCoords   = vector4(-811.7769, -1373.9686, 44.0733, 104.9485),
        promptDistance = 2,
        pedCoords      = vector4(-815.55, -1374.78, 44.28, -91.68),
        camCoords      = vector4(-814.40, -1374.85, 44.90, 86.48),
        camFov         = 60.0,
        npc = {
            model    = "mp_npcambig_m_photogr",
            fallback = "cs_brontesbutler",
            coords   = vector4(-811.50, -1372.80, 44.07, 285.0),
            anim     = "WORLD_HUMAN_SMOKE_NERVOUS_STRESSED",
        },
        blip = {
            name     = "ID Photo",
            sprite   = -1656531561,
            scale    = 0.6,
            modifier = "BLIP_MODIFIER_MP_COLOR_32",
        },
    },
}

Config.PedSpawnDistance = 30
Config.Religious = {
    "Christian", "Buddhist", "Wiccan", "Pagan",
    "Spiritualist", "Coven", "Vampire Cult",
    "Jewish", "Muslim", "Atheist", "None"
}

-- ─── Camera Filters ────────────────────────────────────────────────────────
-- Applied via CSS filter on the camera preview overlay in the NUI
-- filterNext (.) / filterPrev (,) cycle through these
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
            sprite   = -1656531561,
            scale    = 0.6,
            modifier = "BLIP_MODIFIER_MP_COLOR_32",
        },
        anims = {
            dict = "WORLD_HUMAN_SMOKE_NERVOUS_STRESSED",
            name = false,
        },
        timeSettings = {
            open          = 8,
            close         = 21,
            blipmodifier  = "BLIP_MODIFIER_MP_COLOR_2",
        },
    },
    ["IllegalCard"] = {
        illegal    = true,
        coords     = vector4(-813.2076, -1378.4711, 43.6373, 181.3653),
        fakeLabel  = "Rhodes",
        models     = "cs_brontesbutler",
        distance   = 2,
        blips      = false,
        anims = {
            dict = "WORLD_HUMAN_SMOKE_NERVOUS_STRESSED",
            name = false,
        },
        timeSettings = false,
    },
}

function Notify(data)
    local text  = data.text   or "No message"
    local time  = data.time   or 5000
    local type  = data.type   or "info"
    local dict  = data.dict
    local icon  = data.icon
    local color = data.color  or 0
    local src   = data.source

    if IsDuplicityVersion() then
        if Framework == "VORP" then
            if icon then
                TriggerClientEvent('vorp:ShowAdvancedRightNotification', src, text, dict, icon, color, time)
            else
                TriggerClientEvent("vorp:TipBottom", src, text, time, type)
            end
        end
    else
        if Framework == "VORP" then
            if icon then
                TriggerEvent("vorp:ShowAdvancedRightNotification", text, dict, icon, color, time)
            else
                TriggerEvent("vorp:TipBottom", text, time, type)
            end
        end
    end
end

function Locale(key, subs)
    local translate = Config.Locale[Config.Language][key]
        and Config.Locale[Config.Language][key]
        or "Config.Locale[" .. Config.Language .. "][" .. key .. "] doesn't exist"
    subs = subs and subs or {}
    for k, v in pairs(subs) do
        local templateToFind = '%${' .. k .. '}'
        local safeValue = tostring(v):gsub("%%", "%%%%")
        translate = translate:gsub(templateToFind, safeValue)
    end
    translate = tostring(translate):gsub("%%%%", "%%")
    return tostring(translate)
end
