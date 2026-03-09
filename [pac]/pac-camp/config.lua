Config = {}

-- How far away objects fade out when player moves away
Config.RenderDistance = 100.0

-- Max placeable objects per player character
Config.MaxObject = 100

-- =====================================================================
-- ALLOWED TOWNS
-- false = placement blocked inside this town (wilderness only)
-- true  = placement allowed
-- nil town hash (wilderness) = always allowed
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
    Camp         = "camp",
    CampInvite   = "campinvite",
    CampKick     = "campkick",
    CampWho      = "campwho",
    Shareperms   = "shareperm",
    Unshareperms = "unshareperm",
}

Config.Text = {
    StorageName      = "Camp Storage",
    Chest            = "Chest",
    Dontchest        = "You are not a member of this camp",
    Target           = "Target",
    Targeton         = "Target activated",
    Targetoff        = "Target deactivated",
    TargetActiveText  = "Use /",
    TargetActiveText1 = " to deactivate the target",
    Camp             = "Camp",
    Place            = "Camp item placed!",
    Cancel           = "Placement cancelled.",
    Picked           = "You stored your camp item",
    Dont             = "This item does not belong to you",
    NotInTown        = "You cannot place items inside town limits",
    MaxItems         = "You have reached the maximum number of placed items",
    chestfull        = "Empty the chest before picking it up!",
    NotFlat          = "Ground is too uneven here. Find a flatter spot.",
    SpeedLabel       = "Speed",
    Door             = "Door",
    Dontdoor         = "You are not a member of this camp",
    Perms            = "Permissions",
    Sharecorret      = "Player ID",
    Dontowner        = "You are not the owner of this item",
    Playerno         = "Player not found or not connected",
    Already          = "This player already has access",
    Permsyes         = "Successfully shared",
    Permsdont        = "Item not found",
    Corret           = "Chest or Door ID",
    Allpermission    = "All permissions have been revoked",
    Playerpermi      = "ID of the player to give permission to",
    Shared           = "Share a chest or door with another player",
    Remove           = "Remove all permissions",
    InviteSuccess    = "You invited {name} to your camp",
    InviteReceived   = "You were invited to {name}'s camp",
    InviteUsage      = "Usage: /campinvite [serverID]",
    InviteSelf       = "You cannot invite yourself",
    AlreadyMember    = "That player is already a member of your camp",
    KickSuccess      = "You removed {name} from your camp",
    KickReceived     = "You were removed from {name}'s camp",
    KickUsage        = "Usage: /campkick [serverID]",
    NotMember        = "That player is not a member of your camp",
    NoMembers        = "No members invited yet",
    MemberList       = "Camp members:",
    BedrollSet       = "Bedroll set. You will respawn here.",
    BedrollSleep     = "Sleep",
    BedrollNotOwner  = "This is not your bedroll",
    CampCmdDesc      = "Toggle camp pickup mode",
    InviteDesc       = "Invite a player to your camp (grants chest/door access)",
    KickDesc         = "Remove a player from your camp",
    WhoDesc          = "List your current camp members",
    YouAreOwner      = "You are the camp owner.",
}

Config.AdminGroups = { "admin", "moderator" }

-- Placement panel: mouse-driven controls
Config.ControlsPanel = {
    title = "Camp Placement",
    controls = {
        "[Mouse]    - Move",
        "[Scroll]   - Rotate",
        "[E]        - Confirm",
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
    Bedroll   = "Bedroll",
    Key = {
        Pickut  = 0xE30CD707,
        Chest   = 0x760A9C6F,
        Door    = 0x760A9C6F,
        Bedroll = 0xCEFD9220,  -- E key
    }
}

-- Keys used during placement (disable game controls for these)
Config.Keys = {
    placeOnGround = 0xB2F377E8,  -- F
    cancelPlace   = 0x760A9C6F,  -- G
    confirmPlace  = 0xCEFD9220,  -- E
    increaseSpeed = 0xCC1075A7,  -- scroll up  (rotation speed)
    decreaseSpeed = 0xFD0F0C2C,  -- scroll down
}

Config.MaxSlopeAngle = 15.0

Config.Chests = {
    { object = 's_re_rcboatbox01x',  capacity = 400  },
    { object = 'p_trunk04x',         capacity = 700  },
    { object = 's_lootablebedchest', capacity = 1000 },
}

Config.Doors = {
    { modelDoor = 'val_p_door_lckd_1'          },
    { modelDoor = 'p_doornbd39x_destruct'       },
    { modelDoor = 'p_doorstrawberry01x_new'     },
    { modelDoor = 'p_doorriverboat01x'          },
}

-- Bedroll models — proximity prompt + sleep on use
Config.Bedrolls = {
    { object = 'p_bedroll01x' },
}

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
    -- bedroll: placeable prop, proximity prompt triggers sleep + respawn set
    ["bedroll"]                  = { model = "p_bedroll01x" },
}
