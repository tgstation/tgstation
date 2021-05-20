// Byond direction defines, because I want to put them somewhere.
// #define NORTH 1
// #define SOUTH 2
// #define EAST 4
// #define WEST 8

#define TEXT_NORTH "[NORTH]"
#define TEXT_SOUTH "[SOUTH]"
#define TEXT_EAST "[EAST]"
#define TEXT_WEST "[WEST]"

/// Inverse direction, taking into account UP|DOWN if necessary.
#define REVERSE_DIR(dir) ( ((dir & 85) << 1) | ((dir & 170) >> 1) )

//Human Overlays Indexes/////////
#define MUTATIONS_LAYER 29 //mutations. Tk headglows, cold resistance glow, etc
#define BODY_BEHIND_LAYER 28 //certain mutantrace features (tail when looking south) that must appear behind the body parts
#define BODYPARTS_LAYER 27 //Initially "AUGMENTS", this was repurposed to be a catch-all bodyparts flag
#define BODY_ADJ_LAYER 26 //certain mutantrace features (snout, body markings) that must appear above the body parts
#define BODY_LAYER 25 //underwear, undershirts, socks, eyes, lips(makeup)
#define FRONT_MUTATIONS_LAYER 24 //mutations that should appear above body, body_adj and bodyparts layer (e.g. laser eyes)
#define DAMAGE_LAYER 23 //damage indicators (cuts and burns)
#define UNIFORM_LAYER 22
#define ID_LAYER 21
#define ID_CARD_LAYER 20
#define HANDS_PART_LAYER 19
#define GLOVES_LAYER 18
#define SHOES_LAYER 17
#define EARS_LAYER 16
#define SUIT_LAYER 15
#define GLASSES_LAYER 14
#define BELT_LAYER 13 //Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER 12
#define NECK_LAYER 11
#define BACK_LAYER 10
#define HAIR_LAYER 9 //TODO: make part of head layer?
#define FACEMASK_LAYER 8
#define HEAD_LAYER 7
#define HANDCUFF_LAYER 6
#define LEGCUFF_LAYER 5
#define HANDS_LAYER 4
#define BODY_FRONT_LAYER 3
#define HALO_LAYER 2 //blood cult ascended halo, because there's currently no better solution for adding/removing
#define FIRE_LAYER 1 //If you're on fire
#define TOTAL_LAYERS 29 //KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;

//Human Overlay Index Shortcuts for alternate_worn_layer, layers
//Because I *KNOW* somebody will think layer+1 means "above"
//IT DOESN'T OK, IT MEANS "UNDER"
#define UNDER_SUIT_LAYER (SUIT_LAYER+1)
#define UNDER_HEAD_LAYER (HEAD_LAYER+1)

//AND -1 MEANS "ABOVE", OK?, OK!?!
#define ABOVE_SHOES_LAYER (SHOES_LAYER-1)
#define ABOVE_BODY_FRONT_LAYER (BODY_FRONT_LAYER-1)


//Security levels
#define SEC_LEVEL_GREEN 0
#define SEC_LEVEL_BLUE 1
#define SEC_LEVEL_RED 2
#define SEC_LEVEL_DELTA 3

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26 //Used to trigger removal from a processing list

// Cargo-related stuff.
#define MANIFEST_ERROR_CHANCE 5
#define MANIFEST_ERROR_NAME 1
#define MANIFEST_ERROR_CONTENTS 2
#define MANIFEST_ERROR_ITEM 4

#define TRANSITIONEDGE 7 //Distance from edge to move to another z-level

//used by canUseTopic()
#define BE_CLOSE TRUE //in the case of a silicon, to select if they need to be next to the atom
#define NO_DEXTERITY TRUE //if other mobs (monkeys, aliens, etc) can use this // I had to change 20+ files because some non-dnd-playing fuckchumbis can't spell "dexterity"
#define NO_TK TRUE // if you can't use it from a distance with telekinesis
#define FLOOR_OKAY TRUE // if you can use it while resting

//singularity defines
#define STAGE_ONE 1
#define STAGE_TWO 3
#define STAGE_THREE 5
#define STAGE_FOUR 7
#define STAGE_FIVE 9
#define STAGE_SIX 11 //From supermatter shard

//SSticker.current_state values
#define GAME_STATE_STARTUP 0
#define GAME_STATE_PREGAME 1
#define GAME_STATE_SETTING_UP 2
#define GAME_STATE_PLAYING 3
#define GAME_STATE_FINISHED 4

//FONTS:
// Used by Paper and PhotoCopier (and PaperBin once a year).
// Used by PDA's Notekeeper.
// Used by NewsCaster and NewsPaper.
// Used by Modular Computers
#define PEN_FONT "Verdana"
#define FOUNTAIN_PEN_FONT "Segoe Script"
#define CRAYON_FONT "Comic Sans MS"
#define PRINTER_FONT "Times New Roman"
#define SIGNFONT "Times New Roman"
#define CHARCOAL_FONT "Candara"

#define RESIZE_DEFAULT_SIZE 1

//transfer_ai() defines. Main proc in ai_core.dm
#define AI_TRANS_TO_CARD 1 //Downloading AI to InteliCard.
#define AI_TRANS_FROM_CARD 2 //Uploading AI from InteliCard
#define AI_MECH_HACK 3 //Malfunctioning AI hijacking mecha

//check_target_facings() return defines
#define FACING_SAME_DIR 1
#define FACING_EACHOTHER 2
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR 3 //Do I win the most informative but also most stupid define award?

//stages of shoe tying-ness
#define SHOES_UNTIED 0
#define SHOES_TIED 1
#define SHOES_KNOTTED 2

//how fast a disposal machinery thing is ejecting things
#define EJECT_SPEED_SLOW 1
#define EJECT_SPEED_MED 2
#define EJECT_SPEED_FAST 4
#define EJECT_SPEED_YEET 6

//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
GLOBAL_LIST_EMPTY(bloody_footprints_cache)

//Bloody shoes/footprints
#define BLOODY_FOOTPRINT_BASE_ALPHA 20 /// Minimum alpha of footprints
#define BLOOD_AMOUNT_PER_DECAL      50 /// How much blood a regular blood splatter contains
#define BLOOD_ITEM_MAX              200 /// How much blood an item can have stuck on it
#define BLOOD_POOL_MAX              300 /// How much blood a blood decal can contain
#define BLOOD_FOOTPRINTS_MIN        5 /// How much blood a footprint need to at least contain

//Bloody shoe blood states
#define BLOOD_STATE_HUMAN "blood"
#define BLOOD_STATE_XENO "xeno"
#define BLOOD_STATE_OIL "oil"
#define BLOOD_STATE_NOT_BLOODY "no blood whatsoever"

//suit sensors: sensor_mode defines

#define SENSOR_OFF 0
#define SENSOR_LIVING 1
#define SENSOR_VITALS 2
#define SENSOR_COORDS 3

//suit sensors: has_sensor defines

#define BROKEN_SENSORS -1
#define NO_SENSORS 0
#define HAS_SENSORS 1
#define LOCKED_SENSORS 2

//Wet floor type flags. Stronger ones should be higher in number.
#define TURF_DRY (0)
#define TURF_WET_WATER (1<<0)
#define TURF_WET_PERMAFROST (1<<1)
#define TURF_WET_ICE (1<<2)
#define TURF_WET_LUBE (1<<3)
#define TURF_WET_SUPERLUBE (1<<4)

#define IS_WET_OPEN_TURF(O) O.GetComponent(/datum/component/wet_floor)

//Maximum amount of time, (in deciseconds) a tile can be wet for.
#define MAXIMUM_WET_TIME 5 MINUTES

//unmagic-strings for types of polls
#define POLLTYPE_OPTION "OPTION"
#define POLLTYPE_TEXT "TEXT"
#define POLLTYPE_RATING "NUMVAL"
#define POLLTYPE_MULTI "MULTICHOICE"
#define POLLTYPE_IRV "IRV"



//subtypesof(), typesof() without the parent path
#define subtypesof(typepath) ( typesof(typepath) - typepath )

/**
 * Get the turf that `A` resides in, regardless of any containers.
 *
 * Use in favor of `A.loc` or `src.loc` so that things work correctly when
 * stored inside an inventory, locker, or other container.
 */
#define get_turf(A) (get_step(A, 0))

/**
 * Get the ultimate area of `A`, similarly to [get_turf].
 *
 * Use instead of `A.loc.loc`.
 */
#define get_area(A) (isarea(A) ? A : get_step(A, 0)?.loc)

//Ghost orbit types:
#define GHOST_ORBIT_CIRCLE "circle"
#define GHOST_ORBIT_TRIANGLE "triangle"
#define GHOST_ORBIT_HEXAGON "hexagon"
#define GHOST_ORBIT_SQUARE "square"
#define GHOST_ORBIT_PENTAGON "pentagon"

//Ghost showing preferences:
#define GHOST_ACCS_NONE 1
#define GHOST_ACCS_DIR 50
#define GHOST_ACCS_FULL 100

#define GHOST_ACCS_NONE_NAME "default sprites"
#define GHOST_ACCS_DIR_NAME "only directional sprites"
#define GHOST_ACCS_FULL_NAME "full accessories"

#define GHOST_ACCS_DEFAULT_OPTION GHOST_ACCS_FULL

GLOBAL_LIST_INIT(ghost_accs_options, list(GHOST_ACCS_NONE, GHOST_ACCS_DIR, GHOST_ACCS_FULL)) //So save files can be sanitized properly.

#define GHOST_OTHERS_SIMPLE 1
#define GHOST_OTHERS_DEFAULT_SPRITE 50
#define GHOST_OTHERS_THEIR_SETTING 100

#define GHOST_OTHERS_SIMPLE_NAME "white ghost"
#define GHOST_OTHERS_DEFAULT_SPRITE_NAME "default sprites"
#define GHOST_OTHERS_THEIR_SETTING_NAME "their setting"

#define GHOST_OTHERS_DEFAULT_OPTION GHOST_OTHERS_THEIR_SETTING

#define GHOST_MAX_VIEW_RANGE_DEFAULT 10
#define GHOST_MAX_VIEW_RANGE_MEMBER 14


GLOBAL_LIST_INIT(ghost_others_options, list(GHOST_OTHERS_SIMPLE, GHOST_OTHERS_DEFAULT_SPRITE, GHOST_OTHERS_THEIR_SETTING)) //Same as ghost_accs_options.

//pda fonts
#define MONO "Monospaced"
#define VT "VT323"
#define ORBITRON "Orbitron"
#define SHARE "Share Tech Mono"

GLOBAL_LIST_INIT(pda_styles, sortList(list(MONO, VT, ORBITRON, SHARE)))

/////////////////////////////////////
// atom.appearence_flags shortcuts //
/////////////////////////////////////

/*

// Disabling certain features
#define APPEARANCE_IGNORE_TRANSFORM RESET_TRANSFORM
#define APPEARANCE_IGNORE_COLOUR RESET_COLOR
#define APPEARANCE_IGNORE_CLIENT_COLOUR NO_CLIENT_COLOR
#define APPEARANCE_IGNORE_COLOURING (RESET_COLOR|NO_CLIENT_COLOR)
#define APPEARANCE_IGNORE_ALPHA RESET_ALPHA
#define APPEARANCE_NORMAL_GLIDE ~LONG_GLIDE

// Enabling certain features
#define APPEARANCE_CONSIDER_TRANSFORM ~RESET_TRANSFORM
#define APPEARANCE_CONSIDER_COLOUR ~RESET_COLOUR
#define APPEARANCE_CONSIDER_CLIENT_COLOUR ~NO_CLIENT_COLOR
#define APPEARANCE_CONSIDER_COLOURING (~RESET_COLOR|~NO_CLIENT_COLOR)
#define APPEARANCE_CONSIDER_ALPHA ~RESET_ALPHA
#define APPEARANCE_LONG_GLIDE LONG_GLIDE

*/

// Consider these images/atoms as part of the UI/HUD
#define APPEARANCE_UI_IGNORE_ALPHA (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA|PIXEL_SCALE)
#define APPEARANCE_UI (RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|PIXEL_SCALE)

//Just space
#define SPACE_ICON_STATE "[((x + y) ^ ~(x * y) + z) % 25]"

// Maploader bounds indices
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

// Diagonal movement
#define FIRST_DIAG_STEP 1
#define SECOND_DIAG_STEP 2

#define DEADCHAT_ANNOUNCEMENT "announcement"
#define DEADCHAT_ARRIVALRATTLE "arrivalrattle"
#define DEADCHAT_DEATHRATTLE "deathrattle"
#define DEADCHAT_LAWCHANGE "lawchange"
#define DEADCHAT_REGULAR "regular-deadchat"
#define DEADCHAT_LOGIN_LOGOUT "loginlogout"

// Bluespace shelter deploy checks
#define SHELTER_DEPLOY_ALLOWED "allowed"
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
#define SHELTER_DEPLOY_BAD_AREA "bad area"
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"
#define SHELTER_DEPLOY_OUTSIDE_MAP "outside map"

//debug printing macros
#define debug_world(msg) if (GLOB.Debug2) to_chat(world, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
#define debug_usr(msg) if (GLOB.Debug2&&usr) to_chat(usr, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
#define debug_admins(msg) if (GLOB.Debug2) to_chat(GLOB.admins, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
#define debug_world_log(msg) if (GLOB.Debug2) log_world("DEBUG: [msg]")

#define INCREMENT_TALLY(L, stat) if(L[stat]){L[stat]++}else{L[stat] = 1}

//TODO Move to a pref
#define STATION_GOAL_BUDGET  1

//Luma coefficients suggested for HDTVs. If you change these, make sure they add up to 1.
#define LUMA_R 0.213
#define LUMA_G 0.715
#define LUMA_B 0.072

//different types of atom colorations
#define ADMIN_COLOUR_PRIORITY 1 //only used by rare effects like greentext coloring mobs and when admins varedit color
#define TEMPORARY_COLOUR_PRIORITY 2 //e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define WASHABLE_COLOUR_PRIORITY 3 //color splashed onto an atom (e.g. paint on turf)
#define FIXED_COLOUR_PRIORITY 4 //color inherent to the atom (e.g. blob color)
#define COLOUR_PRIORITY_AMOUNT 4 //how many priority levels there are.

//Endgame Results
#define NUKE_NEAR_MISS 1
#define NUKE_MISS_STATION 2
#define NUKE_SYNDICATE_BASE 3
#define STATION_DESTROYED_NUKE 4
#define STATION_EVACUATED 5
#define BLOB_WIN 8
#define BLOB_NUKE 9
#define BLOB_DESTROYED 10
#define CULT_ESCAPE 11
#define CULT_FAILURE 12
#define CULT_SUMMON 13
#define NUKE_MISS 14
#define OPERATIVES_KILLED 15
#define OPERATIVE_SKIRMISH 16
#define REVS_WIN 17
#define REVS_LOSE 18
#define WIZARD_KILLED 19
#define STATION_NUKED 20
#define CLOCK_SUMMON 21
#define CLOCK_SILICONS 22
#define CLOCK_PROSELYTIZATION 23
#define SHUTTLE_HIJACK 24
#define GANG_DESTROYED 25
#define GANG_OPERATING 26

#define FIELD_TURF 1
#define FIELD_EDGE 2

//gibtonite state defines
#define GIBTONITE_UNSTRUCK 0
#define GIBTONITE_ACTIVE 1
#define GIBTONITE_STABLE 2
#define GIBTONITE_DETONATE 3

//for obj explosion block calculation
#define EXPLOSION_BLOCK_PROC -1

//for determining which type of heartbeat sound is playing
#define BEAT_FAST 1
#define BEAT_SLOW 2
#define BEAT_NONE 0

//https://secure.byond.com/docs/ref/info.html#/atom/var/mouse_opacity
#define MOUSE_OPACITY_TRANSPARENT 0
#define MOUSE_OPACITY_ICON 1
#define MOUSE_OPACITY_OPAQUE 2

//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

//server security mode
#define SECURITY_SAFE 1
#define SECURITY_ULTRASAFE 2
#define SECURITY_TRUSTED 3

//Dummy mob reserve slots
#define DUMMY_HUMAN_SLOT_PREFERENCES "dummy_preference_preview"
#define DUMMY_HUMAN_SLOT_ADMIN "admintools"
#define DUMMY_HUMAN_SLOT_MANIFEST "dummy_manifest_generation"

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

//Fullscreen overlay resolution in tiles.
#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15

#define SUMMON_GUNS "guns"
#define SUMMON_MAGIC "magic"

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

#define STANDARD_GRAVITY 1 //Anything above this is high gravity, anything below no grav
/// The gravity strength threshold for high gravity damage.
#define GRAVITY_DAMAGE_THRESHOLD 3
/// The scaling factor for high gravity damage.
#define GRAVITY_DAMAGE_SCALING 0.5
/// The maximum [BRUTE] damage a mob can take from high gravity per second.
#define GRAVITY_DAMAGE_MAXIMUM 1.5

#define CAMERA_NO_GHOSTS 0
#define CAMERA_SEE_GHOSTS_BASIC 1
#define CAMERA_SEE_GHOSTS_ORBIT 2

#define CLIENT_FROM_VAR(I) (ismob(I) ? I:client : (istype(I, /client) ? I : (istype(I, /datum/mind) ? I:current?:client : null)))

#define AREASELECT_CORNERA "corner A"
#define AREASELECT_CORNERB "corner B"

#define VARSET_FROM_LIST(L, V) if(L && L[#V]) V = L[#V]
#define VARSET_FROM_LIST_IF(L, V, C...) if(L && L[#V] && (C)) V = L[#V]
#define VARSET_TO_LIST(L, V) if(L) L[#V] = V
#define VARSET_TO_LIST_IF(L, V, C...) if(L && (C)) L[#V] = V

#define DICE_NOT_RIGGED 1
#define DICE_BASICALLY_RIGGED 2
#define DICE_TOTALLY_RIGGED 3

#define VOMIT_TOXIC 1
#define VOMIT_PURPLE 2
#define VOMIT_NANITE 3

//chem grenades defines
#define GRENADE_EMPTY 1
#define GRENADE_WIRED 2
#define GRENADE_READY 3

//Misc text define. Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"

// art quality defines, used in datums/components/art.dm, elsewhere
#define BAD_ART 12.5
#define OK_ART 20
#define GOOD_ART 25
#define GREAT_ART 50

// possible bitflag return values of intercept_zImpact(atom/movable/AM, levels = 1) calls
#define FALL_INTERCEPTED (1<<0) //Stops the movable from falling further and crashing on the ground
#define FALL_NO_MESSAGE (1<<1) //Used to suppress the "[A] falls through [old_turf]" messages where it'd make little sense at all, like going downstairs.
#define FALL_STOP_INTERCEPTING (1<<2) //Used in situations where halting the whole "intercept" loop would be better, like supermatter dusting (and thus deleting) the atom.

//Religion

#define HOLY_ROLE_DEACON 1 //role below priests, for losing most powers of priests but still being holy.
#define HOLY_ROLE_PRIEST 2 //default priestly role
#define HOLY_ROLE_HIGHPRIEST 3 //the one who designates the religion

#define ALIGNMENT_GOOD "good"
#define ALIGNMENT_NEUT "neutral"
#define ALIGNMENT_EVIL "evil"


// Play time / EXP
#define PLAYTIME_HARDCORE_RANDOM 120
#define PLAYTIME_VETERAN 300000 //Playtime is tracked in minutes. 300,000 minutes = 5,000 hours

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

// Skillchip categories
//Various skillchip categories. Use these when setting which categories a skillchip restricts being paired with
//while using the SKILLCHIP_RESTRICTED_CATEGORIES flag
#define SKILLCHIP_CATEGORY_GENERAL "general"
#define SKILLCHIP_CATEGORY_JOB "job"

/// Emoji icon set
#define EMOJI_SET 'icons/emoji.dmi'
