// Byond direction defines, because I want to put them somewhere.
// #define NORTH 1
// #define SOUTH 2
// #define EAST 4
// #define WEST 8


#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

#define JANUARY		1
#define FEBRUARY	2
#define MARCH		3
#define APRIL		4
#define MAY			5
#define JUNE		6
#define JULY		7
#define AUGUST		8
#define SEPTEMBER	9
#define OCTOBER		10
#define NOVEMBER	11
#define DECEMBER	12

//Select holiday names -- If you test for a holiday in the code, make the holiday's name a define and test for that instead
#define NEW_YEAR				"New Year"
#define VALENTINES				"Valentine's Day"
#define APRIL_FOOLS				"April Fool's Day"
#define EASTER					"Easter"
#define HALLOWEEN				"Halloween"
#define CHRISTMAS				"Christmas"
#define FESTIVE_SEASON			"Festive Season"
#define FRIDAY_13TH				"Friday the 13th"

//Human Overlays Indexes/////////
#define MUTATIONS_LAYER			26		//mutations. Tk headglows, cold resistance glow, etc
#define BODY_BEHIND_LAYER		25		//certain mutantrace features (tail when looking south) that must appear behind the body parts
#define BODYPARTS_LAYER			24		//Initially "AUGMENTS", this was repurposed to be a catch-all bodyparts flag
#define BODY_ADJ_LAYER			23		//certain mutantrace features (snout, body markings) that must appear above the body parts
#define BODY_LAYER				22		//underwear, undershirts, socks, eyes, lips(makeup)
#define FRONT_MUTATIONS_LAYER	21		//mutations that should appear above body, body_adj and bodyparts layer (e.g. laser eyes)
#define DAMAGE_LAYER			20		//damage indicators (cuts and burns)
#define UNIFORM_LAYER			19
#define ID_LAYER				18
#define SHOES_LAYER				17
#define GLOVES_LAYER			16
#define EARS_LAYER				15
#define SUIT_LAYER				14
#define GLASSES_LAYER			13
#define BELT_LAYER				12		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		11
#define NECK_LAYER				10
#define BACK_LAYER				9
#define HAIR_LAYER				8		//TODO: make part of head layer?
#define FACEMASK_LAYER			7
#define HEAD_LAYER				6
#define HANDCUFF_LAYER			5
#define LEGCUFF_LAYER			4
#define HANDS_LAYER				3
#define BODY_FRONT_LAYER		2
#define FIRE_LAYER				1		//If you're on fire
#define TOTAL_LAYERS			26		//KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;

//Human Overlay Index Shortcuts for alternate_worn_layer, layers
//Because I *KNOW* somebody will think layer+1 means "above"
//IT DOESN'T OK, IT MEANS "UNDER"
#define UNDER_BODY_BEHIND_LAYER		BODY_BEHIND_LAYER+1
#define UNDER_BODY_LAYER			BODY_LAYER+1
#define UNDER_BODY_ADJ_LAYER		BODY_ADJ_LAYER+1
#define UNDER_MUTATIONS_LAYER		MUTATIONS_LAYER+1
#define UNDER_BODYPARTS_LAYER		BODYPARTS_LAYER+1
#define UNDER_DAMAGE_LAYER			DAMAGE_LAYER+1
#define UNDER_UNIFORM_LAYER			UNIFORM_LAYER+1
#define UNDER_ID_LAYER				ID_LAYER+1
#define UNDER_SHOES_LAYER			SHOES_LAYER+1
#define UNDER_GLOVES_LAYER			GLOVES_LAYER+1
#define UNDER_EARS_LAYER			EARS_LAYER+1
#define UNDER_SUIT_LAYER			SUIT_LAYER+1
#define UNDER_GLASSES_LAYER			GLASSES_LAYER+1
#define UNDER_BELT_LAYER			BELT_LAYER+1
#define UNDER_SUIT_STORE_LAYER		SUIT_STORE_LAYER+1
#define UNDER_BACK_LAYER			BACK_LAYER+1
#define UNDER_HAIR_LAYER			HAIR_LAYER+1
#define UNDER_FACEMASK_LAYER		FACEMASK_LAYER+1
#define UNDER_HEAD_LAYER			HEAD_LAYER+1
#define UNDER_HANDCUFF_LAYER		HANDCUFF_LAYER+1
#define UNDER_LEGCUFF_LAYER			LEGCUFF_LAYER+1
#define UNDER_HANDS_LAYER			HANDS_LAYER+1
#define UNDER_BODY_FRONT_LAYER		BODY_FRONT_LAYER+1
#define UNDER_FIRE_LAYER			FIRE_LAYER+1

//AND -1 MEANS "ABOVE", OK?, OK!?!
#define ABOVE_BODY_BEHIND_LAYER		BODY_BEHIND_LAYER-1
#define ABOVE_BODY_LAYER			BODY_LAYER-1
#define ABOVE_BODY_ADJ_LAYER		BODY_ADJ_LAYER-1
#define ABOVE_MUTATIONS_LAYER		MUTATIONS_LAYER-1
#define ABOVE_BODYPARTS_LAYER		BODYPARTS_LAYER-1
#define ABOVE_DAMAGE_LAYER			DAMAGE_LAYER-1
#define ABOVE_UNIFORM_LAYER			UNIFORM_LAYER-1
#define ABOVE_ID_LAYER				ID_LAYER-1
#define ABOVE_SHOES_LAYER			SHOES_LAYER-1
#define ABOVE_GLOVES_LAYER			GLOVES_LAYER-1
#define ABOVE_EARS_LAYER			EARS_LAYER-1
#define ABOVE_SUIT_LAYER			SUIT_LAYER-1
#define ABOVE_GLASSES_LAYER			GLASSES_LAYER-1
#define ABOVE_BELT_LAYER			BELT_LAYER-1
#define ABOVE_SUIT_STORE_LAYER		SUIT_STORE_LAYER-1
#define ABOVE_BACK_LAYER			BACK_LAYER-1
#define ABOVE_HAIR_LAYER			HAIR_LAYER-1
#define ABOVE_FACEMASK_LAYER		FACEMASK_LAYER-1
#define ABOVE_HEAD_LAYER			HEAD_LAYER-1
#define ABOVE_HANDCUFF_LAYER		HANDCUFF_LAYER-1
#define ABOVE_LEGCUFF_LAYER			LEGCUFF_LAYER-1
#define ABOVE_HANDS_LAYER			HANDS_LAYER-1
#define ABOVE_BODY_FRONT_LAYER		BODY_FRONT_LAYER-1
#define ABOVE_FIRE_LAYER			FIRE_LAYER-1


//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

// Cargo-related stuff.
#define MANIFEST_ERROR_CHANCE		5
#define MANIFEST_ERROR_NAME			1
#define MANIFEST_ERROR_CONTENTS		2
#define MANIFEST_ERROR_ITEM			4

#define TRANSITIONEDGE			7 //Distance from edge to move to another z-level



//HUD styles. Please ensure HUD_VERSIONS is the same as the maximum index. Index order defines how they are cycled in F12.
#define HUD_STYLE_STANDARD 1
#define HUD_STYLE_REDUCED 2
#define HUD_STYLE_NOHUD 3


#define HUD_VERSIONS 3	//used in show_hud()
//1 = standard hud
//2 = reduced hud (just hands and intent switcher)
//3 = no hud (for screenshots)

#define MINERAL_MATERIAL_AMOUNT 2000
//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
#define MAX_STACK_SIZE 50
//The maximum size of a stack object.

#define CLICK_CD_MELEE 8
#define CLICK_CD_RANGE 4
#define CLICK_CD_RAPID 2
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_BREAKOUT 100
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_RESIST 20
#define CLICK_CD_GRABBING 10

//click cooldowns, in tenths of a second


#define BE_CLOSE 1		//in the case of a silicon, to select if they need to be next to the atom
#define NO_DEXTERY 1	//if other mobs (monkeys, aliens, etc) can use this
//used by canUseTopic()

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_TINY 0
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3

//Cuff resist speeds

#define FAST_CUFFBREAK 1
#define INSTANT_CUFFBREAK 2

//Slime evolution threshold. Controls how fast slimes can split/grow
#define SLIME_EVOLUTION_THRESHOLD 10

//singularity defines
#define STAGE_ONE 1
#define STAGE_TWO 3
#define STAGE_THREE 5
#define STAGE_FOUR 7
#define STAGE_FIVE 9
#define STAGE_SIX 11 //From supermatter shard

//zlevel defines, can be overridden for different maps in the appropriate _maps file.
#define ZLEVEL_STATION 1
#define ZLEVEL_CENTCOM 2
#define ZLEVEL_MINING 5
#define ZLEVEL_LAVALAND 5
#define ZLEVEL_EMPTY_SPACE 11

#define ZLEVEL_SPACEMIN 3
#define ZLEVEL_SPACEMAX 11

//ticker.current_state values
#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4
//SOUND:
#define SOUND_MINIMUM_PRESSURE 10
#define FALLOFF_SOUNDS	1
#define SURROUND_CAP	7

//FONTS:
// Used by Paper and PhotoCopier (and PaperBin once a year).
// Used by PDA's Notekeeper.
// Used by NewsCaster and NewsPaper.
#define PEN_FONT "Verdana"
#define CRAYON_FONT "Comic Sans MS"
#define SIGNFONT "Times New Roman"


//NPC DEFINES
#define INTERACTING 2
#define TRAVEL 4
#define FIGHTING 8

//TRAITS

#define TRAIT_ROBUST 2
#define TRAIT_UNROBUST 4
#define TRAIT_SMART 8
#define TRAIT_DUMB 16
#define TRAIT_MEAN 32
#define TRAIT_FRIENDLY 64
#define TRAIT_THIEVING 128

//SNPC defines
#define MAX_RANGE_FIND 32
#define MIN_RANGE_FIND 16
#define FUZZY_CHANCE_HIGH 85
#define FUZZY_CHANCE_LOW 50
#define CHANCE_TALK 1

#define SNPC_BRUTE 1
#define SNPC_STEALTH 2
#define SNPC_MARTYR 3
#define SNPC_PSYCHO 4


#define MAXCOIL 30
#define RESIZE_DEFAULT_SIZE 1

//transfer_ai() defines. Main proc in ai_core.dm
#define AI_TRANS_TO_CARD	1 //Downloading AI to InteliCard.
#define AI_TRANS_FROM_CARD	2 //Uploading AI from InteliCard
#define AI_MECH_HACK		3 //Malfunctioning AI hijacking mecha

//Material defines
#define MAT_METAL		"$metal"
#define MAT_GLASS		"$glass"
#define MAT_SILVER		"$silver"
#define MAT_GOLD		"$gold"
#define MAT_DIAMOND		"$diamond"
#define MAT_URANIUM		"$uranium"
#define MAT_PLASMA		"$plasma"
#define MAT_BANANIUM	"$bananium"
#define MAT_TITANIUM	"$titanium"
#define MAT_BIOMASS		"$biomass"


//check_target_facings() return defines
#define FACING_FAILED											0
#define FACING_SAME_DIR											1
#define FACING_EACHOTHER										2
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR	3 //Do I win the most informative but also most stupid define award?


//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
var/list/bloody_footprints_cache = list()

//Bloody shoes/footprints
#define MAX_SHOE_BLOODINESS			100
#define BLOODY_FOOTPRINT_BASE_ALPHA	150
#define BLOOD_GAIN_PER_STEP			100
#define BLOOD_LOSS_PER_STEP			5
#define BLOOD_FADEOUT_TIME			2

//Bloody shoe blood states
#define BLOOD_STATE_HUMAN			"blood"
#define BLOOD_STATE_XENO			"xeno"
#define BLOOD_STATE_OIL				"oil"
#define BLOOD_STATE_NOT_BLOODY		"no blood whatsoever"
//Turf wet states
#define TURF_DRY		0
#define TURF_WET_WATER	1
#define TURF_WET_LUBE	2
#define TURF_WET_ICE	3
#define TURF_WET_PERMAFROST 4
#define TURF_WET_SLIDE	5

//Maximum amount of time, (in approx. seconds.) a tile can be wet for.
#define MAXIMUM_WET_TIME 300

//Object/Item sharpness
#define IS_BLUNT			0
#define IS_SHARP			1
#define IS_SHARP_ACCURATE	2

//unmagic-strings for types of polls
#define POLLTYPE_OPTION		"OPTION"
#define POLLTYPE_TEXT		"TEXT"
#define POLLTYPE_RATING		"NUMVAL"
#define POLLTYPE_MULTI		"MULTICHOICE"
#define POLLTYPE_IRV		"IRV"



//lighting area defines
#define DYNAMIC_LIGHTING_DISABLED 0 //dynamic lighting disabled (area stays at full brightness)
#define DYNAMIC_LIGHTING_ENABLED 1 //dynamic lighting enabled
#define DYNAMIC_LIGHTING_IFSTARLIGHT 2 //dynamic lighting enabled only if starlight is.
#define IS_DYNAMIC_LIGHTING(A) ( A.lighting_use_dynamic == DYNAMIC_LIGHTING_IFSTARLIGHT ? config.starlight : A.lighting_use_dynamic )

//subtypesof(), typesof() without the parent path
#define subtypesof(typepath) ( typesof(typepath) - typepath )

//Gets the turf this atom inhabits
#define get_turf(A) (get_step(A, 0))

//Bot types
#define SEC_BOT				1	// Secutritrons (Beepsky) and ED-209s
#define MULE_BOT			2	// MULEbots
#define FLOOR_BOT			4	// Floorbots
#define CLEAN_BOT			8	// Cleanbots
#define MED_BOT				16	// Medibots

//Sentience types
#define SENTIENCE_ORGANIC 1
#define SENTIENCE_ARTIFICIAL 2
#define SENTIENCE_OTHER 3
#define SENTIENCE_MINEBOT 4
#define SENTIENCE_BOSS 5


//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF 1
#define FIRE_PROOF 2 //100% immune to fire damage (but not necessarily to lava or heat)
#define FLAMMABLE 4
#define ON_FIRE 8
#define UNACIDABLE 16 //acid can't even appear on it, let alone melt it.
#define ACID_PROOF 32 //acid stuck on it doesn't melt it.
#define INDESTRUCTIBLE 64 //doesn't take damage

//Ghost orbit types:
#define GHOST_ORBIT_CIRCLE		"circle"
#define GHOST_ORBIT_TRIANGLE	"triangle"
#define GHOST_ORBIT_HEXAGON		"hexagon"
#define GHOST_ORBIT_SQUARE		"square"
#define GHOST_ORBIT_PENTAGON	"pentagon"

//Ghost showing preferences:
#define GHOST_ACCS_NONE		1
#define GHOST_ACCS_DIR		50
#define GHOST_ACCS_FULL		100

#define GHOST_ACCS_NONE_NAME		"default sprites"
#define GHOST_ACCS_DIR_NAME			"only directional sprites"
#define GHOST_ACCS_FULL_NAME		"full accessories"

#define GHOST_ACCS_DEFAULT_OPTION	GHOST_ACCS_FULL

var/global/list/ghost_accs_options = list(GHOST_ACCS_NONE, GHOST_ACCS_DIR, GHOST_ACCS_FULL) //So save files can be sanitized properly.

#define GHOST_OTHERS_SIMPLE 			1
#define GHOST_OTHERS_DEFAULT_SPRITE		50
#define GHOST_OTHERS_THEIR_SETTING 		100

#define GHOST_OTHERS_SIMPLE_NAME 			"white ghost"
#define GHOST_OTHERS_DEFAULT_SPRITE_NAME 	"default sprites"
#define GHOST_OTHERS_THEIR_SETTING_NAME 	"their setting"

#define GHOST_OTHERS_DEFAULT_OPTION			GHOST_OTHERS_THEIR_SETTING

var/global/list/ghost_others_options = list(GHOST_OTHERS_SIMPLE, GHOST_OTHERS_DEFAULT_SPRITE, GHOST_OTHERS_THEIR_SETTING) //Same as ghost_accs_options.

//Bloodcrawling
#define BLOODCRAWL 1
#define BLOODCRAWL_EAT 2

//Color Defines
#define OOC_COLOR  "#002eb8"

/////////////////////////////////////
// atom.appearence_flags shortcuts //
/////////////////////////////////////
//this was added midway thru 510, so it might not exist in some versions, but we can't check by minor verison
#ifndef TILE_BOUND
#error this version of 510 is too old, You must use byond 510.1332 or later. (TILE_BOUND is not defined)
#endif

// Disabling certain features
#define APPEARANCE_IGNORE_TRANSFORM			RESET_TRANSFORM
#define APPEARANCE_IGNORE_COLOUR			RESET_COLOR
#define	APPEARANCE_IGNORE_CLIENT_COLOUR		NO_CLIENT_COLOR
#define APPEARANCE_IGNORE_COLOURING			RESET_COLOR|NO_CLIENT_COLOR
#define APPEARANCE_IGNORE_ALPHA				RESET_ALPHA
#define APPEARANCE_NORMAL_GLIDE				~LONG_GLIDE

// Enabling certain features
#define APPEARANCE_CONSIDER_TRANSFORM		~RESET_TRANSFORM
#define APPEARANCE_CONSIDER_COLOUR			~RESET_COLOUR
#define APPEARANCE_CONSIDER_CLIENT_COLOUR	~NO_CLIENT_COLOR
#define APPEARANCE_CONSIDER_COLOURING		~RESET_COLOR|~NO_CLIENT_COLOR
#define APPEARANCE_CONSIDER_ALPHA			~RESET_ALPHA
#define APPEARANCE_LONG_GLIDE				LONG_GLIDE

// Consider these images/atoms as part of the UI/HUD
#define APPEARANCE_UI_IGNORE_ALPHA			RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA
#define APPEARANCE_UI						RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR

//Just space
#define SPACE_ICON_STATE	"[((x + y) ^ ~(x * y) + z) % 25]"

//Gun trigger guards
#define TRIGGER_GUARD_ALLOW_ALL -1
#define TRIGGER_GUARD_NONE 0
#define TRIGGER_GUARD_NORMAL 1

// Maploader bounds indices
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

#define CHECK_DNA_AND_SPECIES(C) if((!(C.dna)) || (!(C.dna.species))) return

// Evil narsie colour
#define NARSIE_WINDOW_COLOUR "#7D1919"

//let's just pretend fulltile windows being children of border windows is fine
#define FULLTILE_WINDOW_DIR NORTHEAST

// Defib stats
#define DEFIB_TIME_LIMIT 120
#define DEFIB_TIME_LOSS 60

// Diagonal movement
#define FIRST_DIAG_STEP 1
#define SECOND_DIAG_STEP 2

//Slime commands defines
#define SLIME_FRIENDSHIP_FOLLOW 			3 //Min friendship to order it to follow
#define SLIME_FRIENDSHIP_STOPEAT 			5 //Min friendship to order it to stop eating someone
#define SLIME_FRIENDSHIP_STOPEAT_NOANGRY	7 //Min friendship to order it to stop eating someone without it losing friendship
#define SLIME_FRIENDSHIP_STOPCHASE			4 //Min friendship to order it to stop chasing someone (their target)
#define SLIME_FRIENDSHIP_STOPCHASE_NOANGRY	6 //Min friendship to order it to stop chasing someone (their target) without it losing friendship
#define SLIME_FRIENDSHIP_STAY				3 //Min friendship to order it to stay
#define SLIME_FRIENDSHIP_ATTACK				8 //Min friendship to order it to attack

#define DEADCHAT_ARRIVALRATTLE "arrivalrattle"
#define DEADCHAT_DEATHRATTLE "deathrattle"
#define DEADCHAT_REGULAR "regular-deadchat"

// Bluespace shelter deploy checks
#define SHELTER_DEPLOY_ALLOWED "allowed"
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
#define SHELTER_DEPLOY_BAD_AREA "bad area"
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"

//debug printing macros
#define debug_world(msg) if (Debug2) world << "DEBUG: [msg]"
#define debug_admins(msg) if (Debug2) admins << "DEBUG: [msg]"
#define debug_world_log(msg) if (Debug2) world.log << "DEBUG: [msg]"

#define COORD(A) "([A.x],[A.y],[A.z])"
#define INCREMENT_TALLY(L, stat) if(L[stat]){L[stat]++}else{L[stat] = 1}

// Inventory depth: limits how many nested storage items you can access directly.
// 1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH		3
#define STORAGE_VIEW_DEPTH	2


// Medal names

#define BOSS_KILL_MEDAL "Killer"

#define ALL_KILL_MEDAL "Exterminator"	//Killing all of x type

// Score names

#define LEGION_SCORE "Legion Killed"
#define COLOSSUS_SCORE "Colossus Killed"
#define BUBBLEGUM_SCORE "Bubblegum Killed"
#define DRAKE_SCORE "Drakes Killed"
#define BIRD_SCORE "Hierophants Killed"
#define SWARMER_BEACON_SCORE "Swarmer Beacons Killed"
#define BOSS_SCORE "Bosses Killed"
#define TENDRIL_CLEAR_SCORE "Tendrils Killed"



									// NTNet module-configuration values. Do not change these. If you need to add another use larger number (5..6..7 etc)
#define NTNET_SOFTWAREDOWNLOAD 1 	// Downloads of software from NTNet
#define NTNET_PEERTOPEER 2			// P2P transfers of files between devices
#define NTNET_COMMUNICATION 3		// Communication (messaging)
#define NTNET_SYSTEMCONTROL 4		// Control of various systems, RCon, air alarm control, etc.

// NTNet transfer speeds, used when downloading/uploading a file/program.
#define NTNETSPEED_LOWSIGNAL 0.5	// GQ/s transfer speed when the device is wirelessly connected and on Low signal
#define NTNETSPEED_HIGHSIGNAL 1	// GQ/s transfer speed when the device is wirelessly connected and on High signal
#define NTNETSPEED_ETHERNET 2		// GQ/s transfer speed when the device is using wired connection


// Program bitflags
#define PROGRAM_ALL 7
#define PROGRAM_CONSOLE 1
#define PROGRAM_LAPTOP 2
#define PROGRAM_TABLET 4

#define PROGRAM_STATE_KILLED 0
#define PROGRAM_STATE_BACKGROUND 1
#define PROGRAM_STATE_ACTIVE 2

// Caps for NTNet logging. Less than 10 would make logging useless anyway, more than 500 may make the log browser too laggy. Defaults to 100 unless user changes it.
#define MAX_NTNET_LOGS 300
#define MIN_NTNET_LOGS 10
//TODO Move to a pref
#define STATION_GOAL_BUDGET  1

//Luma coefficients suggested for HDTVs. If you change these, make sure they add up to 1.
#define LUMA_R 0.213
#define LUMA_G 0.715
#define LUMA_B 0.072


//attack visual effects
#define ATTACK_EFFECT_PUNCH		"punch"
#define ATTACK_EFFECT_KICK		"kick"
#define ATTACK_EFFECT_SMASH		"smash"
#define ATTACK_EFFECT_CLAW		"claw"
#define ATTACK_EFFECT_DISARM	"disarm"
#define ATTACK_EFFECT_BITE		"bite"
#define ATTACK_EFFECT_MECHFIRE	"mech_fire"
#define ATTACK_EFFECT_MECHTOXIN	"mech_toxin"
#define ATTACK_EFFECT_BOOP "boop"	//Honk


//different types of atom colorations
#define ADMIN_COLOUR_PRIORITY 		1 //only used by rare effects like greentext coloring mobs and when admins varedit color
#define TEMPORARY_COLOUR_PRIORITY 	2 //e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define WASHABLE_COLOUR_PRIORITY 	3 //color splashed onto an atom (e.g. paint on turf)
#define FIXED_COLOUR_PRIORITY 		4 //color inherent to the atom (e.g. blob color)
#define COLOUR_PRIORITY_AMOUNT 4 //how many priority levels there are.

// w_class (weight class)
#define WEIGHT_CLASS_TINY     1 // Usually items smaller then a human hand
#define WEIGHT_CLASS_SMALL    2 // Pockets can hold small and tiny items
#define WEIGHT_CLASS_NORMAL   3 // Standard backpacks can carry tiny, small & normal items
#define WEIGHT_CLASS_BULKY    4 // Items that can be weilded or equipped but not stored in an inventory
#define WEIGHT_CLASS_HUGE     5 // Usually represents objects that require two hands to operate
#define WEIGHT_CLASS_GIGANTIC 6 // Essentially means it cannot be picked up or placed in an inventory

// Examples of tiny items: Playing Cards, Lighter, Scalpel, Coins/Money
// Examples of small items: Flashlight, Multitool, Grenades, GPS Device
// Examples of normal items: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
// Examples of bulky items: Defibrillator, Backpack, Space Suits
// Examples of huge items: Shotgun, Two Handed Melee Weapons
// Examples of gigantic items: Mech Parts, Safe

// m_intent
#define MOVE_INTENT_WALK "walk"
#define MOVE_INTENT_RUN  "run"

//Endgame Results

#define NUKE_NEAR_MISS 1
#define NUKE_MISS_STATION 2
#define NUKE_SYNDICATE_BASE 3
#define STATION_DESTROYED_NUKE 4
#define STATION_EVACUATED 5
#define GANG_LOSS 6
#define GANG_TAKEOVER 7
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

//For SSTimer

#define TIMER_NORMAL "normal"
#define TIMER_UNIQUE "unique"

// Ventcrawling
#define VENTCRAWLER_NONE   0
#define VENTCRAWLER_NUDE   1
#define VENTCRAWLER_ALWAYS 2

// Intent
#define INTENT_HELP   "help"
#define INTENT_GRAB   "grab"
#define INTENT_DISARM "disarm"
#define INTENT_HARM   "harm"
// NOTE: INTENT_HOTKEY_* defines are not actual intents!
// they are here to support hotkeys
#define INTENT_HOTKEY_LEFT  "left"
#define INTENT_HOTKEY_RIGHT "right"

#define DEFAULT_AI_LAWID "default"
