Config = {}

-- How far away objects fade out when player moves away
Config.RenderDistance = 100.0

-- Max placeable objects per player character
Config.MaxObject = 100

-- =====================================================================
-- ALLOWED TOWNS
-- Controls whether players can place objects INSIDE town limits.
-- true  = placement allowed inside this town
-- false = placement blocked inside this town
--
-- Note: placement is always allowed in the wilderness (no town hash).
-- To add a new town, add its exact hash key name here.
-- =====================================================================
Config.AllowedTowns = {
    ["Annesburg"]  = false,
    ["Armadillo"]  = false,
    ["Blackwater"] = false,
    ["Rhodes"]     = false,
    ["StDenis"]    = false,
    ["Strawberry"] = false,
    ["Tumbleweed"] = false,
    ["Valentine"]  = false,
}
-- All towns set to false = players must place camps in the wilderness.
-- Change any to true if you want to allow in-town placement.

Config.Commands = {
    Camp        = "camp",       -- /camp to pick up placed items (target mode)
    Shareperms  = "shareperm",  -- /shareperm [chestId] [playerId]
    Unshareperms = "unshareperm", -- /unshareperm [chestId]
}

Config.Text = {
    StorageName      = "Storage",
    Chest            = "Chest",
    Dontchest        = "You cannot open this storage",
    Target           = "Target",
    Targeton         = "Target activated",
    Targetoff        = "Target deactivated",
    Camp             = "Camp",
    Place            = "Camp placed!",
    Cancel           = "Placement cancelled.",
    Picked           = "You have stored your camp",
    Dont             = "This camp does not belong to you",
    TargetActiveText  = "Use /",
    TargetActiveText1 = " to deactivate the target",
    Sharecorret      = "Player ID",
    Dontowner        = "You are not the owner of this object",
    Playerno         = "Player not found or not connected",
    Already          = "The player already has access to this object",
    Permsyes         = "Successfully shared",
    Permsdont        = "Object not found",
    Corret           = "Chest or Door ID",
    Allpermission    = "All permissions have been revoked",
    Playerpermi      = "ID of the player you want to give permission to",
    Shared           = "Share a chest or door with another player",
    Remove           = "Remove all permissions",
    Door             = "Door",
    Dontdoor         = "You do not have access to this door",
    Perms            = "Permissions",
    SpeedLabel       = "Speed",
    NotInTown        = "You cannot place objects inside town limits",
    MaxItems         = "You have reached the maximum number of placed objects",
    chestfull        = "Empty the chest before picking it up!",
    NotFlat          = "Ground is too uneven here. Find a flatter spot.",
}

-- Jobs / groups that can remove other players' objects
Config.AdminGroups = {
    "admin",
    "moderator",
    -- add more here
}

Config.ControlsPanel = {
    title = "Camp Placement",
    controls = {
        "[Mouse Scroll] - Adjust Speed",
        "[Arrow Keys]   - Move object",
        "[1/2]          - Rotate Z",
        "[3/4]          - Rotate X",
        "[5/6]          - Rotate Y",
        "[7/8]          - Move Up/Down",
        "[ENTER]        - Confirm",
        "[G]            - Cancel",
        "[F]            - Snap to Ground",
    }
}

Config.Promp = {
    Collect  = "Pick Up",
    Controls = "Camp",
    Chest    = "Chest",
    Chestopen = "Storage",
    Door     = "Door",
    Dooropen = "Open/Close",
    Key = {
        Pickut = 0xE30CD707, -- R
        Chest  = 0x760A9C6F, -- G
        Door   = 0x760A9C6F, -- G
    }
}

Config.Keys = {
    moveForward   = 0x6319DB71, -- Arrow Up
    moveBackward  = 0x05CA7C52, -- Arrow Down
    moveLeft      = 0xA65EBAB4, -- Arrow Left
    moveRight     = 0xDEB34313, -- Arrow Right
    rotateLeftZ   = 0xE6F612E4, -- 1
    rotateRightZ  = 0x1CE6D9EB, -- 2
    rotateUpX     = 0x4F49CC4C, -- 3
    rotateDownX   = 0x8F9F9E58, -- 4
    rotateLeftY   = 0xAB62E997, -- 5
    rotateRightY  = 0xA1FDE2A6, -- 6
    moveUp        = 0xB03A913B, -- 7
    moveDown      = 0x42385422, -- 8
    placeOnGround = 0xB2F377E8, -- F
    cancelPlace   = 0x760A9C6F, -- G
    confirmPlace  = 0xC7B5340A, -- ENTER
    increaseSpeed = 0xCC1075A7, -- Mouse Scroll Up
    decreaseSpeed = 0xFD0F0C2C, -- Mouse Scroll Down
}

-- Maximum slope angle in degrees before placement is rejected
-- 15.0 = gentle hill is fine, steep slope is blocked
-- Increase to allow steeper terrain, decrease to require flatter ground
Config.MaxSlopeAngle = 15.0

-- =====================================================================
-- CHESTS
-- Define which prop models count as storage chests and their capacity.
-- capacity = max item slots in that chest's inventory
-- object   = prop model hash name (must match Config.Items model)
-- =====================================================================
Config.Chests = {
    { object = 's_re_rcboatbox01x',  capacity = 400  },
    { object = 'p_trunk04x',         capacity = 700  },
    { object = 's_lootablebedchest', capacity = 1000 },
    -- Add more chest models here
}

-- =====================================================================
-- DOORS
-- Define which prop models count as placeable doors.
-- Players who own (or have shared access to) a door can open/close it.
-- =====================================================================
Config.Doors = {
    { modelDoor = 'val_p_door_lckd_1' },
    { modelDoor = 'p_doornbd39x_destruct' },
    { modelDoor = 'p_doorstrawberry01x_new' },
    { modelDoor = 'p_doorriverboat01x' },
    -- Add more door models here
}

-- =====================================================================
-- ITEMS
-- Maps inventory item name -> in-world prop model.
-- veg (optional) = radius in units to suppress vegetation when placed.
--
-- TO ADD A NEW ITEM:
-- 1. Add entry here:  ["item_name"] = { model = "prop_model_name", veg = 5.0 }
-- 2. Add to SQL inject file (pac-camp-inject.sql)
-- 3. Copy image to [vorp]/vorp_inventory/html/img/
-- =====================================================================
Config.Items = {
    -- Tents
    ["tent_trader"]      = { model = "mp005_s_posse_tent_trader07x",       veg = 10.0 },
    ["tent_bounty07"]    = { model = "mp005_s_posse_tent_bountyhunter07x", veg = 10.0 },
    ["tent_bounty02"]    = { model = "mp005_s_posse_tent_bountyhunter02x", veg = 10.0 },
    ["tent_bounty06"]    = { model = "mp005_s_posse_tent_bountyhunter06x", veg = 10.0 },
    ["tent_collector04"] = { model = "mp005_s_posse_tent_collector04x",    veg = 10.0 },

    -- Hitching Posts
    ["hitchingpost_wood"]        = { model = "p_hitchingpost04x"   },
    ["hitchingpost_iron"]        = { model = "p_horsehitchnbd01x"  },
    ["hitchingpost_wood_double"] = { model = "p_hitchingpost01x"   },

    -- Furniture
    ["chair_wood"]   = { model = "p_chair05x"  },
    ["table_wood01"] = { model = "p_table48x"  },

    -- Campfires
    ["campfire_01"] = { model = "p_campfirecombined03x" },
    ["campfire_02"] = { model = "p_campfire05x"         },

    -- Chests (storage)
    ["chest_little"] = { model = "s_re_rcboatbox01x"  },
    ["chest_medium"] = { model = "p_trunk04x"          },
    ["chest_big"]    = { model = "s_lootablebedchest"  },

    -- Doors
    ["door_01"] = { model = "val_p_door_lckd_1"          },
    ["door_02"] = { model = "p_doornbd39x_destruct"      },
    ["door_03"] = { model = "p_doorstrawberry01x_new"    },
    ["door_04"] = { model = "p_doorriverboat01x"         },
}
