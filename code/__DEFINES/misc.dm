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
