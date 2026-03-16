Config = {}
Config.framework = "redemrp-reboot"--"redemrp" or "vorp" or "qbr" or "qbr2" or "redemrp-reboot" or "rsg"
Config.RefreshRate = 5
Config.InteractionDist = 0.9

Config.UseClothFunctionForSun = {
    enable = false,
    protection = {
        [0x9925C067] = 0.001,
    }
}

Config.Debug = true

Config.DataSendToSaveFromClientTimer = 40 -- seconds

Config.Prompts = {
    PromptBloodS = 0x05CA7C52,
}

Config.Texts = {
    PromptBloodS = "Blood Suck",
    --
    Vampire = "Vampire",
    Died = "Died as a vampire!",
    NoMana = "You dont have enough mana! (%s/%s)",
    GotItem = "You got some item!",
    Became = "You have became a Vampire!",
    Already = "You are already a Vampire!",
    Mana = "Mana",
    XP = "XP",
    SunDMG = "Sun Damage",
    VampireAlert = "Vampire activity reported!",
}

Config.Textures = {
    cross = {"scoretimer_textures", "scoretimer_generic_cross"},
    locked = {"menu_textures","stamp_locked_rank"},
    tick = {"scoretimer_textures","scoretimer_generic_tick"},
    money = {"inventory_items", "money_moneystack"},
    alert = {"menu_textures", "menu_icon_alert"},
}

Config.TransformVampireItem = {
    id = "ricx_vampire_transform_drink",
    label = "Vampire Drink",
}

Config.DisableKeys = {
    bloodsuck = {
        --add here control hashes
        --0x00000,
    },
    bat_transform = {
        --add here control hashes
    },
}

Config.BatTransformSmoke = {
    color = {126, 0, 0},
    size = 2.0,
    time = 5,--seconds
}
Config.BatTransformCommand = "bat_t"
Config.BigJumpToggleCommand = "big_jump"
Config.HUDCommand = "vampire"
Config.Icon = {size = "6.0x", url = "https://raw.githubusercontent.com/abdulkadiraktas/rdr3_discoveries/7f10ca1f4f6ee36a40f385cef03053433bee84c1/useful_info_from_rpfs/textures/pm_collectors_bag_mp/images/pm_collectors_bag_mp/collector_fossil_tooth_mega.png"}

Config.Mana = {
    base_max = 100,
    base_regen = 0.1,
}

Config.XPEarns = {
    bloods = 0.5,
}

Config.ManaUsages = {
    bloods = 5,
    bat_transform = 10,
}

Config.ItemAdd = {
    bloods = {
        enable = true,
        id = "ricx_human_blood", label = "Human Blood", amount = 1,
        required_item = {id = "ricx_empty_jar", label = "Empty Jar", amount = 1},
    }
}

Config.SunDamage = 0.005
Config.SunHours = {rise = 6, set = 22}
Config.BloodsuckHeading = {min = -15.0, max = 15.0}
Config.BloodsuckAlert = {
    enable = true,
    chance = 80,
    police_jobs = {"police", "police2"},
    area_blip = `BLIP_STYLE_PROC_MISSION_RADIUS`,
    blip_modifier = `BLIP_MODIFIER_MP_TEAM_COLOR_3`,
    delete_alert_blip = 30,-- seconds after its created
}

Config.ExtraSkills = {
    --DO NOT CHANGE THE INDEX ("skill_1" and other indexes), change only xp and enable options
    skill_1 = {label = "Bullet Proof", xp = 100, enable = true},
    skill_2 = {label = "Flame Proof", xp = 50, enable = true},
    skill_3 = {label = "Explosion Proof", xp = 100}, enable = true,
    skill_4 = {label = "Melee Proof", xp = 10}, enable = true,
    skill_5 = {label = "Smoke Proof", xp = 25, enable = true},
    skill_6 = {label = "Headshot Proof", xp = 400}, enable = true,
    skill_7 = {label = "Projectile Proof", xp = 50, enable = true},
    skill_8 = {label = "Big Jump", xp = 750, enable = true},
    skill_9 = {label = "Double Mana Regen", xp = 500, enable = true},
    skill_10 = {label = "Double Max Mana", xp = 650, enable = true},
    skill_11 = {label = "Half Sun Damage", xp = 1000, enable = true},
    skill_12 = {label = "Double Sun Resistance", xp = 1500, enable = true},
}

--[[
    --REDEM:RP INVENTORY ITEM

    ["ricx_vampire_transform_drink"] = { label = "Vampire Drink", description = "Drink", weight = 0.05, canBeDropped = true, canBeUsed = true, requireLvl = 0, limit = 10,imgsrc = "items/ricx_vampire_transform_drink.png", type = "item_standard",},
    ["ricx_human_blood"] = { label = "Human Blood", description = "Product", weight = 0.05, canBeDropped = true, canBeUsed = false, requireLvl = 0, limit = 50,imgsrc = "items/ricx_human_blood.png", type = "item_standard",},
    ["ricx_empty_jar"] = { label = "Empty Jar", description = "Product", weight = 0.05, canBeDropped = true, canBeUsed = false, requireLvl = 0, limit = 50,imgsrc = "items/ricx_empty_jar.png", type = "item_standard",},

    --QBR/QR/RS ITEM
    ['ricx_vampire_transform_drink'] 					= {['name'] = 'ricx_vampire_transform_drink', 			 	  	['label'] = 'Vampire Drink',	    				['weight'] = 1,			['type'] = 'item', 				['image'] = 'ricx_vampire_transform_drink.png', 					['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,   ['combinable'] = nil,    	['level'] = 0,		['description'] = 'Drink'},
	['ricx_human_blood'] 					= {['name'] = 'ricx_human_blood', 			 	  	['label'] = 'Human Blood',	    				['weight'] = 1,			['type'] = 'item', 				['image'] = 'ricx_human_blood.png', 					['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,   ['combinable'] = nil,    	['level'] = 0,		['description'] = 'Product'},
	['ricx_empty_jar'] 					= {['name'] = 'ricx_empty_jar', 			 	  	['label'] = 'Empty Jar',	    				['weight'] = 1,			['type'] = 'item', 				['image'] = 'ricx_empty_jar.png', 					['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,   ['combinable'] = nil,    	['level'] = 0,		['description'] = 'Product'},
	
]]
