Config = {}

Config.framework = "vorp"

Config.PrayAnim = {
    {"amb_misc@world_human_pray_rosary@base", "base"},
    {"amb_misc@prop_human_seat_pray@male_b@idle_b", "idle_d"},
    {"script_common@shared_scenarios@stand@random@town_burial@stand_mourn@male@react_look@loop@generic", "front"},
    {"amb_misc@world_human_grave_mourning@kneel@female_a@idle_a", "idle_a"},
    {"script_common@shared_scenarios@kneel@mourn@female@a@base", "base"},
    {"amb_misc@world_human_grave_mourning@female_a@idle_a", "idle_a"},
    {"amb_misc@world_human_grave_mourning@male_b@idle_c", "idle_g"},
    {"amb_misc@world_human_grave_mourning@male_b@idle_c", "idle_h"},
}

Config.ShovelItem    = "shovel"
Config.DiggingTimer  = 20 -- seconds

Config.Dig = {
    shovel = `p_shovel02x`,
    anim   = {"amb_work@world_human_gravedig@working@male_b@idle_a", "idle_a"},
    bone   = "skel_r_hand",
    pos    = {0.06, -0.06, -0.03, 270.0, 165.0, 17.0},
}

-- Loot table - edit items/labels to match vorp_inventory item names
Config.Rewards = {
    {item = "grave_trinket",  label = "Old Trinket"},
    {item = "old_coin",       label = "Old Coin"},
    {item = "grave_ring",     label = "Tarnished Ring"},
    {item = "golden_nugget",  label = "Gold Nugget"},
    {item = "rock",           label = "Just a Rock"},
}

Config.Prompts = {
    Prompt1 = 0x05CA7C52, -- F (dig)
    Prompt2 = 0x156F7119, -- G (pray)
}

Config.Texts = {
    Prompt1      = "Dig",
    Prompt2      = "Pay Respects",
    GraveRobbery = "Grave Robbery",
    GraveDisplay = "Grave:",
    CantDoThat   = "You can't do that right now.",
    GraveRobbed  = "This grave has already been robbed.",
    NoShovel     = "You'll need a shovel for this.",
    FoundItem    = "You found something...",
}

Config.Textures = {
    cross  = {"scoretimer_textures", "scoretimer_generic_cross"},
    locked = {"menu_textures", "stamp_locked_rank"},
    tick   = {"scoretimer_textures", "scoretimer_generic_tick"},
    money  = {"inventory_items", "money_moneystack"},
    alert  = {"menu_textures", "menu_icon_alert"},
}

-- =====================================================================
-- GRAVES
-- =====================================================================
Config.Graves = {
    -- Rhodes Cemetery
    [1]  = {name = "Elsie Feeney",                   coords = vector3(1282.042, -1242.295, 79.989), heading = 26.079},
    [2]  = {name = "Harvey Feeney",                  coords = vector3(1280.190, -1243.406, 79.721), heading = 26.999},
    [3]  = {name = "Nettie Mae Feeney",              coords = vector3(1277.646, -1243.937, 79.641), heading = 28.891},
    [4]  = {name = "Stephen Banks",                  coords = vector3(1273.183, -1238.915, 79.715), heading = 21.938},
    [5]  = {name = "Marietta Banks",                 coords = vector3(1275.114, -1237.997, 79.923), heading = 17.270},
    [6]  = {name = "Charlie Banks",                  coords = vector3(1277.472, -1237.081, 80.183), heading = 22.858},
    [7]  = {name = "Unknown",                        coords = vector3(1277.429, -1231.219, 80.685), heading = 9.586},
    [8]  = {name = "Unknown",                        coords = vector3(1273.790, -1229.006, 80.594), heading = 5.973},
    [9]  = {name = "Unknown",                        coords = vector3(1270.969, -1230.913, 80.255), heading = 11.065},
    [10] = {name = "Unknown",                        coords = vector3(1267.327, -1232.056, 79.946), heading = 16.203},
    [11] = {name = "Douglas Gray",                   coords = vector3(1268.745, -1228.923, 80.280), heading = 15.811},
    [12] = {name = "Lucille Braithwaite",            coords = vector3(1275.525, -1220.127, 81.420), heading = 18.769},
    [13] = {name = "Unknown",                        coords = vector3(1271.028, -1224.483, 80.772), heading = 15.921},
    [14] = {name = "Unknown",                        coords = vector3(1272.812, -1224.395, 80.905), heading = 16.950},
    [15] = {name = "Unknown",                        coords = vector3(1274.721, -1223.716, 81.162), heading = 22.049},
    [16] = {name = "Unknown",                        coords = vector3(1279.936, -1214.892, 81.869), heading = 14.358},
    [17] = {name = "Unknown",                        coords = vector3(1275.776, -1207.828, 82.502), heading = 192.68},
    [18] = {name = "Unknown",                        coords = vector3(1292.837, -1214.911, 81.841), heading = 358.17},
    [19] = {name = "Unknown",                        coords = vector3(1295.810, -1215.574, 81.551), heading = 14.873},
    [20] = {name = "Unknown",                        coords = vector3(1298.355, -1214.914, 81.341), heading = 4.816},
    [21] = {name = "Unknown",                        coords = vector3(1297.090, -1212.736, 81.562), heading = 15.686},
    [22] = {name = "Unknown",                        coords = vector3(1295.598, -1213.070, 81.674), heading = 103.04},
    [23] = {name = "Unknown",                        coords = vector3(1294.745, -1213.792, 81.716), heading = 17.239},
    [24] = {name = "Unknown",                        coords = vector3(1292.806, -1211.421, 82.019), heading = 19.154},
    [25] = {name = "Unknown",                        coords = vector3(1293.655, -1210.771, 81.990), heading = 11.110},
    [26] = {name = "Unknown",                        coords = vector3(1295.177, -1210.914, 81.834), heading = 28.956},
    [27] = {name = "William 'Willie' Bowley",        coords = vector3(1302.913, -1214.625, 80.995), heading = 14.057},
    [28] = {name = "Unknown",                        coords = vector3(1292.054, -1209.464, 82.274), heading = 24.189},
    [29] = {name = "Unknown",                        coords = vector3(1290.816, -1210.013, 82.305), heading = 17.146},
    [30] = {name = "Unknown",                        coords = vector3(1296.455, -1210.326, 81.760), heading = 26.106},

    -- Blackwater Cemetery
    [31] = {name = "Unknown",                        coords = vector3(-698.822, -1370.012, 43.532), heading = 180.0},
    [32] = {name = "Unknown",                        coords = vector3(-701.540, -1371.200, 43.532), heading = 180.0},
    [33] = {name = "Unknown",                        coords = vector3(-704.100, -1370.500, 43.532), heading = 180.0},
    [34] = {name = "Unknown",                        coords = vector3(-706.800, -1369.800, 43.532), heading = 180.0},
    [35] = {name = "Unknown",                        coords = vector3(-698.822, -1366.500, 43.532), heading = 180.0},
    [36] = {name = "Unknown",                        coords = vector3(-701.540, -1365.200, 43.532), heading = 180.0},

    -- Armadillo Cemetery
    [37] = {name = "Unknown",                        coords = vector3(-3696.580, -2630.140, -13.050), heading = 90.0},
    [38] = {name = "Unknown",                        coords = vector3(-3699.200, -2631.500, -13.050), heading = 90.0},
    [39] = {name = "Unknown",                        coords = vector3(-3701.800, -2630.000, -13.050), heading = 90.0},
    [40] = {name = "Unknown",                        coords = vector3(-3704.400, -2631.200, -13.050), heading = 90.0},

    -- Tumbleweed Cemetery
    [41] = {name = "Unknown",                        coords = vector3(-5391.710, -2943.760, -1.460),  heading = 0.0},
    [42] = {name = "Unknown",                        coords = vector3(-5394.300, -2944.500, -1.460),  heading = 0.0},
    [43] = {name = "Unknown",                        coords = vector3(-5391.710, -2948.200, -1.460),  heading = 0.0},
    [44] = {name = "Unknown",                        coords = vector3(-5394.300, -2949.000, -1.460),  heading = 0.0},
}
