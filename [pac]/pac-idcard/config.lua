Config = {}
Config.Language = "en"
Config.LicensePrefix = "GMRP"       -- Prefix on all license numbers, e.g. "GMRP-000001"
Config.ShowIdcardCommand = "idcard"  -- Command for player to view their own ID card
Config.TakeCardType = "sql"          -- Storage type: "sql" (persistent) or "item" (inventory only)

-- =====================================================================
-- KEYBINDS
-- These are RDR3 input hashes used by the Lua camera control loop.
-- NUI keyboard events (numpad) handle the actual camera movement.
-- Only change these if you know your RDR3 input hash mappings.
-- =====================================================================
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

-- =====================================================================
-- LOCALE
-- All in-game text strings. Only "en" is active; add more keys for
-- additional language support and change Config.Language above.
-- =====================================================================
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

-- =====================================================================
-- PRICES  (in-game dollars)
-- printphoto = cost to take a portrait photo (set to 0 = free)
-- idcard     = cost to develop/print the ID card
-- illegal    = cost for a forged ID card
-- =====================================================================
Config.Prices = {
    printphoto = 0,
    idcard     = 5,
    illegal    = 100,
}

-- Jobs that are allowed to run /checkid on another player
Config.AuthorizedJobs = { "sheriff", "lawenforcement", "marshal", "deputy" }

Config.DeletePlayerDataCommand = "deleteidcard" -- Admin command: /deleteidcard [charid]
Config.CheckIdCommand          = "checkid"      -- Law job command: /checkid [serverid]
Config.SelectPhotoTime         = 30             -- Seconds player has to "use" printphoto item
Config.PrintPhotoItem          = "printphoto"
Config.ManIdCardItem           = "man_idcard"
Config.WomanIdCardItem         = "woman_idcard"
Config.ShowDistance            = 1.5            -- Distance at which /idcard overlay is visible to others

-- =====================================================================
-- PHOTOGRAPHERS
-- Add one entry per town where players can take their ID photo.
--
-- Fields:
--   promptCoords   (vec4) - where the interaction prompt appears
--   promptDistance (num)  - radius to show the prompt
--   pedCoords      (vec4) - where the player stands for the photo
--                           w = heading (270 = faces camera East)
--   camCoords      (vec4) - scripted camera position
--   camFov         (num)  - camera field of view (lower = more zoom)
--   npc.model      (str)  - NPC model name
--   npc.hash       (hex)  - NPC model hash (must match model)
--   npc.fallback   (str)  - backup model if primary fails to stream
--   npc.coords     (vec4) - where the NPC stands
--   npc.photoHeading(num) - heading NPC turns to face player during shoot
--                           (90 = faces West toward player at heading 270)
--   blips          (tbl)  - map blip config; set to false to disable
--
-- NAVMESH NOTE: This building adds +1.0 to the navmesh Z.
-- NPC z config of 43.073 lands at 44.073 in-world.
-- pedCoords z of 43.228 lands near 44.228 in-world.
--
-- TO ADD A NEW PHOTOGRAPHER:
-- Copy the ["Blackwater"] block, give it a new key name,
-- and update all coords to your chosen location.
-- =====================================================================
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
            photoHeading = 90.0,  -- NPC faces player during photo (West)
        },
        blips = {
            name     = "ID Photo",
            sprite   = 1364029453,
            scale    = 0.6,
            modifier = "BLIP_MODIFIER_MP_COLOR_32",
            coords   = vector3(-812.00, -1373.50, 44.07),
        },
    },
    -- ["Valentine"] = {
    --     ... copy Blackwater block and adjust coords
    -- },
}

Config.PedSpawnDistance = 30  -- Distance from player before NPCs spawn/despawn
Config.TalkDistance     = 2.5 -- Distance player must be within to trigger prompts

Config.Religious = {
    "Christian","Buddhist","Wiccan","Pagan",
    "Spiritualist","Coven",
    "Jewish","Muslim","Atheist","None"
}

-- =====================================================================
-- CAMERA FILTERS
-- Shown in the photographer NUI overlay. Cycle with NUM 1 / NUM 3.
--
-- filterType options:
--   nil / omitted = no overlay (pass-through)
--   "solid"       = flat colour tint over the scene
--                   fields: r, g, b (0-255), a (0.0-1.0 opacity)
--   "fog"         = multi-layer dirty lens fog effect
--   "acid"        = muted colour-cycling lava-lamp warp
--
-- REMOVED / PREMIUM (TODO):
--   "pixel"       = Minecraft-style mosaic. Works as a CSS canvas overlay
--                   but CEF can't read game framebuffer pixels so it
--                   renders as a tinted mosaic rather than true downscale.
--                   Re-add as a premium perk later.
--   "demon_eyes"  = Red eye glow overlay. Saved for premium.
--
-- TO ADD A NEW FILTER: append a new table entry below.
-- =====================================================================
Config.CameraFilters = {
    { name = "None" },
    { name = "Sepia",        filterType = "solid", r=110, g=65, b=15, a=0.40 },
    { name = "Thunderstorm", filterType = "solid", r=20,  g=28, b=75, a=0.42 },
    { name = "Blood Moon",   filterType = "solid", r=150, g=5,  b=5,  a=0.40 },
    { name = "Acid Trip",    filterType = "acid"  },
    { name = "Foggy Lens",   filterType = "fog"   },
}

-- =====================================================================
-- ID CARD NPC (Identity Processing Stations)
-- These are the clerks where players turn their printphoto into an
-- official ID card. One entry per location.
--
-- Fields:
--   coords    (vec4) - NPC position and heading
--   models    (str)  - NPC model
--   distance  (num)  - interaction radius
--   blips     (tbl)  - map blip, or false to hide
--   anims     (tbl)  - idle animation dict/name (name=false = default stance)
--   timeSettings (tbl) - open/close hour (24h), or false = always open
--
-- CURRENT STATUS:
--   ["Blackwater"] is placed OUTSIDE on the boardwalk at (-802.5,-1187.8).
--   The interior building at the original coords is inaccessible (locked door).
--   TODO: Unlock the interior or find the correct door hash to open it via
--         SetStateOfClosestDoorOfType / NETWORK_SET_ENTITY_PERSISTENT.
--
-- TO ADD A NEW LOCATION:
-- Copy any block, give it a unique key, update coords and blip.
--
-- ILLEGAL ID NPCs:
-- Set illegal=true on any entry. These NPCs forge identity cards for a fee.
-- They appear with no blip and a fake location label to mislead law players.
-- Coords below are placeholder — place in a back-alley or shady interior.
-- =====================================================================
Config.IDCardNPC = {
    ["Blackwater"] = {
        -- Placed on the boardwalk outside the locked government building.
        -- TODO: move inside once building interior access is resolved.
        coords   = vector4(-802.5, -1187.8, 44.0, 340.0),
        models   = "cs_brontesbutler",
        distance = 3,
        blips = { name="IDENTITY PROCESS", sprite=0x984E7CA9, scale=0.6, modifier="BLIP_MODIFIER_MP_COLOR_32" },
        anims = { dict="WORLD_HUMAN_HANG_OUT_STREET", name=false },
        timeSettings = { open=8, close=21, blipmodifier="BLIP_MODIFIER_MP_COLOR_2" },
    },
    -- ["Valentine"] = {
    --     coords = vector4(...),
    --     models = "cs_brontesbutler",
    --     distance = 3,
    --     blips = { name="IDENTITY PROCESS", sprite=0x984E7CA9, scale=0.6, modifier="BLIP_MODIFIER_MP_COLOR_32" },
    --     anims = { dict="WORLD_HUMAN_HANG_OUT_STREET", name=false },
    --     timeSettings = { open=8, close=21, blipmodifier="BLIP_MODIFIER_MP_COLOR_2" },
    -- },

    -- ---------------------------------------------------------------
    -- ILLEGAL FORGER NPCs
    -- illegal=true   → uses the forged ID flow, charges Config.Prices.illegal
    -- fakeLabel      → town name shown on the forged card (misleads lawmen)
    -- blips = false  → NO map marker (hidden from law players)
    -- timeSettings = false → available 24/7
    --
    -- TODO: Place these in actual accessible locations in-world.
    -- Suggested locations: back alleys, abandoned buildings, bayou shacks.
    -- Current coords are near the Blackwater photographer (placeholder).
    -- ---------------------------------------------------------------
    ["IllegalCard"] = {
        illegal=true,
        coords=vector4(-813.2076, -1378.4711, 43.6373, 181.3653),
        fakeLabel="Rhodes",  -- Card will claim character is from Rhodes
        models="cs_brontesbutler",
        distance=2,
        blips=false,
        anims={dict="WORLD_HUMAN_HANG_OUT_STREET",name=false},
        timeSettings=false,
    },
    -- ["IllegalCard2"] = {
    --     illegal=true,
    --     coords=vector4(...),
    --     fakeLabel="Saint Denis",
    --     models="cs_brontesbutler",
    --     distance=2,
    --     blips=false,
    --     anims={dict="WORLD_HUMAN_HANG_OUT_STREET",name=false},
    --     timeSettings=false,
    -- },
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
