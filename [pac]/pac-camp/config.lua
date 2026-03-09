Config = {}

-- How far away objects fade out when player moves away
Config.RenderDistance = 100.0

-- Max placeable objects per player character
Config.MaxObject = 100

-- =====================================================================
-- ALLOWED TOWNS
-- Controls whether players can place objects INSIDE town limits.
-- true  = placement allowed inside this town
-- false = placement blocked (wilderness only)
--
-- Note: nil town hash = wilderness = always allowed regardless of this table.
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

Config.Commands = {
    Camp         = "camp",        -- /camp  toggles pickup target mode
    Shareperms   = "shareperm",   -- /shareperm [objectId] [playerId]
    Unshareperms = "unshareperm", -- /unshareperm [objectId]
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
    Playerpermi      = "ID of the player to give permission to",
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

Config.AdminGroups = { "admin", "moderator" }

Config.ControlsPanel = {
    title = "Camp Placement",
    controls = {
        "[Scroll]   - Speed",
        "[Arrows]   - Move",
        "[1/2]      - Rotate Z",
        "[3/4]      - Rotate X",
        "[5/6]      - Rotate Y",
        "[7/8]      - Up/Down",
        "[ENTER]    - Confirm",
        "[G]        - Cancel",
        "[F]        - Snap to Ground",
    }
}

Config.Promp = {
    Collect   = "Pick Up",
    Controls  = "Camp",
    Chest     = "Chest",
    Chestopen = "Storage",
    Door      = "Door",
    Dooropen  = "Open/Close",
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

-- Max slope angle in degrees. 15 = gentle hill ok, steep blocked.
-- Raise this value if you want to allow steeper terrain.
Config.MaxSlopeAngle = 15.0

-- =====================================================================
-- CHESTS  (models that act as storage)
-- =====================================================================
Config.Chests = {
    { object = 's_re_rcboatbox01x',  capacity = 400  },
    { object = 'p_trunk04x',         capacity = 700  },
    { object = 's_lootablebedchest', capacity = 1000 },
}

-- =====================================================================
-- DOORS  (models that can be opened/closed by owner or shared players)
-- =====================================================================
Config.Doors = {
    { modelDoor = 'val_p_door_lckd_1'          },
    { modelDoor = 'p_doornbd39x_destruct'       },
    { modelDoor = 'p_doorstrawberry01x_new'     },
    { modelDoor = 'p_doorriverboat01x'          },
}

-- =====================================================================
-- ITEMS
-- Maps inventory item name -> in-world prop model.
-- veg (optional) = vegetation suppression radius when placed.
--
-- TO ADD A NEW ITEM:
-- 1. Add entry here
-- 2. Add INSERT to sql/pac-camp-inject.sql
-- 3. Add PNG to assets/items/ and copy to vorp_inventory/html/img/
-- =====================================================================
Config.Items = {
    ["tent_trader"]             = { model = "mp005_s_posse_tent_trader07x",       veg = 10.0 },
    ["tent_bounty07"]           = { model = "mp005_s_posse_tent_bountyhunter07x", veg = 10.0 },
    ["tent_bounty02"]           = { model = "mp005_s_posse_tent_bountyhunter02x", veg = 10.0 },
    ["tent_bounty06"]           = { model = "mp005_s_posse_tent_bountyhunter06x", veg = 10.0 },
    ["tent_collector04"]        = { model = "mp005_s_posse_tent_collector04x",    veg = 10.0 },
    ["hitchingpost_wood"]        = { model = "p_hitchingpost04x"   },
    ["hitchingpost_iron"]        = { model = "p_horsehitchnbd01x"  },
    ["hitchingpost_wood_double"] = { model = "p_hitchingpost01x"   },
    ["chair_wood"]               = { model = "p_chair05x"          },
    ["table_wood01"]             = { model = "p_table48x"          },
    ["campfire_01"]              = { model = "p_campfirecombined03x" },
    ["campfire_02"]              = { model = "p_campfire05x"         },
    ["chest_little"]             = { model = "s_re_rcboatbox01x"   },
    ["chest_medium"]             = { model = "p_trunk04x"           },
    ["chest_big"]                = { model = "s_lootablebedchest"  },
    ["door_01"]                  = { model = "val_p_door_lckd_1"         },
    ["door_02"]                  = { model = "p_doornbd39x_destruct"     },
    ["door_03"]                  = { model = "p_doorstrawberry01x_new"   },
    ["door_04"]                  = { model = "p_doorriverboat01x"        },
}
