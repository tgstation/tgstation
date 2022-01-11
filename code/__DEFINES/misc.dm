//server security mode
#define SECURITY_SAFE 1
#define SECURITY_ULTRASAFE 2
#define SECURITY_TRUSTED 3

//Dummy mob reserve slots
#define DUMMY_HUMAN_SLOT_ADMIN "admintools"
#define DUMMY_HUMAN_SLOT_MANIFEST "dummy_manifest_generation"
#define DUMMY_HUMAN_SLOT_CTF "dummy_ctf_preview_generation"

#define PR_ANNOUNCEMENTS_PER_ROUND 5 //The number of unique PR announcements allowed per round
									//This makes sure that a single person can only spam 3 reopens and 3 closes before being ignored

#define MAX_PROC_DEPTH 195 // 200 proc calls deep and shit breaks, this is a bit lower to give some safety room

//gold slime core spawning
#define NO_SPAWN 0
#define HOSTILE_SPAWN 1
#define FRIENDLY_SPAWN 2

//slime core activation type
#define SLIME_ACTIVATE_MINOR 1
#define SLIME_ACTIVATE_MAJOR 2

#define LUMINESCENT_DEFAULT_GLOW 2

#define RIDING_OFFSET_ALL "ALL"

//stack recipe placement check types
#define STACK_CHECK_CARDINALS "cardinals" //checks if there is an object of the result type in any of the cardinal directions
#define STACK_CHECK_ADJACENT "adjacent" //checks if there is an object of the result type within one tile

//text files
#define BRAIN_DAMAGE_FILE "traumas.json"
#define ION_FILE "ion_laws.json"
#define PIRATE_NAMES_FILE "pirates.json"
#define REDPILL_FILE "redpill.json"
#define ARCADE_FILE "arcade.json"
#define BOOMER_FILE "boomer.json"
#define LOCATIONS_FILE "locations.json"
#define WANTED_FILE "wanted_message.json"
#define VISTA_FILE "steve.json"
#define FLESH_SCAR_FILE "wounds/flesh_scar_desc.json"
#define BONE_SCAR_FILE "wounds/bone_scar_desc.json"
#define SCAR_LOC_FILE "wounds/scar_loc.json"
#define EXODRONE_FILE "exodrone.json"
#define CLOWN_NONSENSE_FILE "clown_nonsense.json"
#define CULT_SHUTTLE_CURSE "cult_shuttle_curse.json"

//Fullscreen overlay resolution in tiles.
#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15

#define TELEPORT_CHANNEL_BLUESPACE "bluespace" //Classic bluespace teleportation, requires a sender but no receiver
#define TELEPORT_CHANNEL_QUANTUM "quantum" //Quantum-based teleportation, requires both sender and receiver, but is free from normal disruption
#define TELEPORT_CHANNEL_WORMHOLE "wormhole" //Wormhole teleportation, is not disrupted by bluespace fluctuations but tends to be very random or unsafe
#define TELEPORT_CHANNEL_MAGIC "magic" //Magic teleportation, does whatever it wants (unless there's antimagic)
#define TELEPORT_CHANNEL_CULT "cult" //Cult teleportation, does whatever it wants (unless there's holiness)
#define TELEPORT_CHANNEL_FREE "free" //Anything else

//Force the log directory to be something specific in the data/logs folder
#define OVERRIDE_LOG_DIRECTORY_PARAMETER "log-directory"
//Prevent the master controller from starting automatically
#define NO_INIT_PARAMETER "no-init"
//Force the config directory to be something other than "config"
#define OVERRIDE_CONFIG_DIRECTORY_PARAMETER "config-directory"

#define EGG_LAYING_MESSAGES list("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")

//Filters
#define AMBIENT_OCCLUSION filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")
#define GAUSSIAN_BLUR(filter_size) filter(type="blur", size=filter_size)

#define CLIENT_FROM_VAR(I) (ismob(I) ? I:client : (istype(I, /client) ? I : (istype(I, /datum/mind) ? I:current?:client : null)))

#define AREASELECT_CORNERA "corner A"
#define AREASELECT_CORNERB "corner B"

#define VOMIT_TOXIC 1
#define VOMIT_PURPLE 2

//Misc text define. Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"

// The alpha we give to stuff under tiles, if they want it
#define ALPHA_UNDERTILE 128

// Anonymous names defines (used in the secrets panel)

#define ANON_DISABLED "" //so it's falsey
#define ANON_RANDOMNAMES "Random Default"

/// Possible value of [/atom/movable/buckle_lying]. If set to a different (positive-or-zero) value than this, the buckling thing will force a lying angle on the buckled.
#define NO_BUCKLE_LYING -1

// timed_action_flags parameter for `/proc/do_after_mob`, `/proc/do_mob` and `/proc/do_after`
#define IGNORE_USER_LOC_CHANGE (1<<0)
#define IGNORE_TARGET_LOC_CHANGE (1<<1)
#define IGNORE_HELD_ITEM (1<<2)
#define IGNORE_INCAPACITATED (1<<3)
///Used to prevent important slowdowns from being abused by drugs like kronkaine
#define IGNORE_SLOWDOWNS (1<<4)

// Skillchip categories
//Various skillchip categories. Use these when setting which categories a skillchip restricts being paired with
//while using the SKILLCHIP_RESTRICTED_CATEGORIES flag
#define SKILLCHIP_CATEGORY_GENERAL "general"
#define SKILLCHIP_CATEGORY_JOB "job"

/// Emoji icon set
#define EMOJI_SET 'icons/emoji.dmi'
