-- pac-hooker config
-- Goth Mommy RP | VORP only | 21+ server

Config = {}

Config.pay = 15  -- dollars deducted per session (VORP currency type 0 = cash)

-- 12 in-game hours in real seconds
-- RDR2 in-game clock runs ~2 real minutes per in-game hour
-- 12 in-game hours = ~24 real minutes = 1440 real seconds
Config.BathWindowSeconds = 1440

Config.HealthRestore = 200.0   -- health restored after session (out of 200)
Config.BuffDuration   = 1800   -- well-rested buff duration in real seconds (30 min)

-- =====================================================================
-- NPCs
-- Each location has two NPCs: one for male customers (type="m"),
-- one for female customers (type="f"). b_interaction serves both.
-- pos = teleport destination during blackout. TODO: verify in-game.
-- =====================================================================
Config.NPCs = {
    -- Valentine Saloon
    {
        npc_name  = "Valentine Saloon Girl",
        blip      = 1451797164,
        npcmodel  = "cs_valprostitute_02",
        coords    = vector3(-313.21, 802.43, 120.98),
        pos       = vector3(-311.85, 798.95, 120.99), -- TODO: verify room coords in-game
        heading   = -11.18,
        radius    = 3.0,
        type      = "m_interaction",
    },
    {
        npc_name  = "Valentine Saloon Gentleman",
        blip      = 1451797164,
        npcmodel  = "mp_m_freemode_01",           -- TODO: swap for a better dressed period NPC model
        coords    = vector3(-310.50, 802.00, 120.98),
        pos       = vector3(-311.85, 798.95, 120.99), -- TODO: verify room coords in-game
        heading   = 170.0,
        radius    = 3.0,
        type      = "f_interaction",
    },

    -- Blackwater Saloon
    {
        npc_name  = "Blackwater Parlour Girl",
        blip      = 1451797164,
        npcmodel  = "cs_valprostitute_01",
        coords    = vector3(-808.30, -1264.50, 43.65),
        pos       = vector3(-802.00, -1268.00, 43.65), -- TODO: verify room coords in-game
        heading   = 90.0,
        radius    = 3.0,
        type      = "m_interaction",
    },
    {
        npc_name  = "Blackwater Parlour Gentleman",
        blip      = 1451797164,
        npcmodel  = "mp_m_freemode_01",           -- TODO: swap model
        coords    = vector3(-808.30, -1261.50, 43.65),
        pos       = vector3(-802.00, -1268.00, 43.65), -- TODO: verify room coords in-game
        heading   = 270.0,
        radius    = 3.0,
        type      = "f_interaction",
    },

    -- Rhodes Saloon
    {
        npc_name  = "Rhodes Saloon Girl",
        blip      = 1451797164,
        npcmodel  = "cs_valprostitute_01",
        coords    = vector3(1339.87, -1377.90, 83.28),
        pos       = vector3(1360.44, -1399.47, 78.35), -- TODO: verify room coords in-game
        heading   = -97.54,
        radius    = 3.0,
        type      = "f_interaction",
    },
    {
        npc_name  = "Rhodes Saloon Gentleman",
        blip      = 1451797164,
        npcmodel  = "mp_m_freemode_01",           -- TODO: swap model
        coords    = vector3(1342.00, -1377.90, 83.28),
        pos       = vector3(1360.44, -1399.47, 78.35), -- TODO: verify room coords in-game
        heading   = 82.46,
        radius    = 3.0,
        type      = "m_interaction",
    },
}

-- =====================================================================
-- NOIR TOASTS shown during blackout (random pick each session)
-- =====================================================================
Config.NoirLines = {
    "The whiskey wasn't the only thing warm in Blackwater tonight.",
    "Some doors in this town don't have locks. This was one of them.",
    "She smelled like trouble and lavender. Mostly trouble.",
    "He had the hands of a working man and the eyes of someone who'd stopped caring.",
    "The night had a way of making saints out of sinners and sinners out of saints.",
    "Ain't the first time a man's good sense took the evening off.",
    "Some transactions leave marks. Some leave bruises. This one left a smile.",
    "You can't buy dignity in this town, but they'll give you a discount on everything else.",
    "The clock on the wall had stopped. Time does that here.",
    "Whatever happened in that room, the rats in the walls knew better than to talk.",
}

-- RDR3 native audio for the blackout screen
-- Format: {soundName, soundSet}
Config.SessionSounds = {
    {"INTERACTION_MENU_OPEN",        "GTAO_PROPERTY_INTERACTION_SOUNDSET"},  -- door creak
    {"Bed_Creak",                    "EXPRESSWAY_AMBIENCE_SOUNDSET"},         -- bed
    {"KISSING",                      "PLAYER_ACTION_SOUNDSET"},               -- suggestive
    {"Fumble",                       "GTAO_LESTERS_GARAGE_SOUNDSET"},         -- fumbling
}

Config.Language = {
    talk         = "Talk",
    press        = "Interact",
    invite       = "Well now, don't just stand there. Come on in.",
    reject_f     = "Sorry darlin', I only keep company with gentlemen.",
    reject_m     = "I ain't in the business of entertainin' ladies, sweetheart.",
    no_bath      = "You smell like a mule's backside. Come back when you've had a wash.",
    well_rested  = "You look like a new man. Get some rest.",
    paid         = "That'll be $",
    buff_active  = "Well Rested",
}

Config.keys = {
    G = 0x760A9C6F,
}
