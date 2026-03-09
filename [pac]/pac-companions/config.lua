-- rdn_companions - Modified for Goth Mommy RP
-- Framework: VORP | Pets spawn fully grown | No feeding/raising required

Config = {}

Config.Locale = "en"

Config.Framework = "vorp" -- VORP for Goth Mommy RP

Config.CallPetKey = true -- U key to call/load pet

Config.TriggerKeys = {
    OpenShop = 'E',
    CallPet = 'U'
}

-- Attack command: hold right-click on target to send pet
Config.AttackCommand = true
Config.AttackOnlyPlayers = false
Config.AttackOnlyAnimals = false
Config.AttackOnlyNPC = false

-- Track command: send pet to follow a target
Config.TrackCommand = true
Config.TrackOnlyPlayers = false
Config.TrackkOnlyAnimals = false
Config.TrackOnlyNPC = false

Config.DefensiveMode = true -- Pets go hostile when owner is attacked

Config.NoFear = true -- Prevents horse fear (important for wolf/bear pets)

Config.AnimalTrackingJobOnly = false
Config.AnimalTrackingJobs = {
    [1] = 'police',
    [2] = 'hunter',
}

Config.SearchRadius = 50.0

-- FEEDING DISABLED - pets do not require food
Config.FeedInterval = 99999
Config.RaiseAnimal = false      -- Pets spawn fully grown, no XP/raising system
Config.FullGrownXp = 200        -- Not in use (RaiseAnimal = false)
Config.XpPerFeed = 20           -- Not in use
Config.NotifyWhenHungry = false -- Disabled
Config.AnimalFood = 'meat'      -- Not in use

Config.Shops = {
    {
        Name = 'Animal Shelter',
        Ring = false,
        ActiveDistance = 5.0,
        Coords = {
            vector3(-273.51, 689.26, 112.45)
        },
        Spawndog = vector4(-273.51, 689.26, 112.45, 234.45), -- Fixed: matches shop coords
        Blip = { sprite = -1646261997, x = -273.51, y = 689.26, z = 113.41 }
    }
}

Config.PetAttributes = {
    FollowDistance = 5,
    Invincible = false,
    SpawnLimiter = 5,   -- Reduced from 60: prevents rapid re-spawn but doesn't block initial purchase
    DeathCooldown = 300
}

Config.Animals = { -- Animals pets will retrieve when in Hunt Mode
    [-1003616053]  = { ["name"] = "Duck" },
    [1459778951]   = { ["name"] = "Eagle" },
    [-164963696]   = { ["name"] = "Herring Seagull" },
    [-1104697660]  = { ["name"] = "Vulture" },
    [-466054788]   = { ["name"] = "Wild Turkey" },
    [-2011226991]  = { ["name"] = "Wild Turkey" },
    [-166054593]   = { ["name"] = "Wild Turkey" },
    [-1076508705]  = { ["name"] = "Roseate Spoonbill" },
    [-466687768]   = { ["name"] = "Red-Footed Booby" },
    [-575340245]   = { ["name"] = "Western Raven" },
    [1416324601]   = { ["name"] = "Ring-Necked Pheasant" },
    [1265966684]   = { ["name"] = "American White Pelican" },
    [-1797450568]  = { ["name"] = "Blue And Yellow Macaw" },
    [-2073130256]  = { ["name"] = "Double-Crested Cormorant" },
    [-564099192]   = { ["name"] = "Whooping Crane" },
    [723190474]    = { ["name"] = "Canada Goose" },
    [-2145890973]  = { ["name"] = "Ferruginous Hawk" },
    [1095117488]   = { ["name"] = "Great Blue Heron" },
    [386506078]    = { ["name"] = "Common Loon" },
    [-861544272]   = { ["name"] = "Great Horned Owl" },
}

Config.Pets = {
    {
        Text = "$200 - Husky",
        SubText = "",
        Desc = "A loyal and powerful companion.",
        Param = { Price = 200, Model = "A_C_DogHusky_01", Level = 1 }
    },
    {
        Text = "$50 - Mutt",
        SubText = "",
        Desc = "Scrappy and loveable.",
        Param = { Price = 50, Model = "A_C_DogCatahoulaCur_01", Level = 1 }
    },
    {
        Text = "$100 - Labrador Retriever",
        SubText = "",
        Desc = "A classic, faithful retriever.",
        Param = { Price = 100, Model = "A_C_DogLab_01", Level = 1 }
    },
    {
        Text = "$100 - Rufus",
        SubText = "",
        Desc = "Good boy.",
        Param = { Price = 100, Model = "A_C_DogRufus_01", Level = 1 }
    },
    {
        Text = "$150 - Coon Hound",
        SubText = "",
        Desc = "Born to track.",
        Param = { Price = 150, Model = "A_C_DogBluetickCoonhound_01", Level = 1 }
    },
    {
        Text = "$150 - Hound Dog",
        SubText = "",
        Desc = "Steady and reliable.",
        Param = { Price = 150, Model = "A_C_DogHound_01", Level = 1 }
    },
    {
        Text = "$200 - Border Collie",
        SubText = "",
        Desc = "Smart as a whip.",
        Param = { Price = 200, Model = "A_C_DogCollie_01", Level = 1 }
    },
    {
        Text = "$200 - Poodle",
        SubText = "",
        Desc = "Fancy but fierce.",
        Param = { Price = 200, Model = "A_C_DogPoodle_01", Level = 1 }
    },
    {
        Text = "$100 - Foxhound",
        SubText = "",
        Desc = "Quick and clever.",
        Param = { Price = 100, Model = "A_C_DogAmericanFoxhound_01", Level = 1 }
    },
    {
        Text = "$100 - Australian Shepherd",
        SubText = "",
        Desc = "Energetic and sharp.",
        Param = { Price = 100, Model = "A_C_DogAustralianSheperd_01", Level = 1 }
    },
}

Config.Keys = { ['G'] = 0x760A9C6F, ["B"] = 0x4CC0E2FE, ['S'] = 0xD27782E3, ['W'] = 0x8FD015D8, ['H'] = 0x24978A28, ['U'] = 0xD8F73058, ["R"] = 0x0D55A0F0, ["ENTER"] = 0xC7B5340A, ['E'] = 0xDFF812F9, ["J"] = 0xF3830D8E }
