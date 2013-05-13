//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
//As a host, you should probably leave these defines alone.
//They define low-level stuff you don't really want/need to mess with

#define PI						3.1415
#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day
#define SPEED_OF_LIGHT			3e8		//not exact but hey!
#define SPEED_OF_LIGHT_SQ		9e+16
#define FIRE_DAMAGE_MODIFIER	0.0215	//Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER		2.025	//More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
#define INFINITY				1e31	//closer then enough



//atmos
#define R_IDEAL_GAS_EQUATION	8.31	//kPa*L/(K*mol)
#define ONE_ATMOSPHERE			101.325	//kPa
#define T0C						273.15	// 0degC
#define T20C					293.15	// 20degC
#define TCMB					2.7		// -270.3degC
#define MOLES_CELLSTANDARD		(ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC
#define M_CELL_WITH_RATIO		(MOLES_CELLSTANDARD * 0.005)
#define O2STANDARD				0.21
#define N2STANDARD				0.79
#define MOLES_O2STANDARD		(MOLES_CELLSTANDARD*O2STANDARD)	// O2 standard value (21%)
#define MOLES_N2STANDARD		(MOLES_CELLSTANDARD*N2STANDARD)	// N2 standard value (79%)


var/turf/space/Space_Tile = locate(/turf/space) // A space tile to reference when atmos wants to remove excess heat.


//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING	1
#define SLOT_ICLOTHING	2
#define SLOT_GLOVES		4
#define SLOT_EYES		8
#define SLOT_EARS		16
#define SLOT_MASK		32
#define SLOT_HEAD		64
#define SLOT_FEET		128
#define SLOT_ID			256
#define SLOT_BELT		512
#define SLOT_BACK		1024
#define SLOT_POCKET		2048		//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET	4096	//this is to deny items with a w_class of 2 or 1 to fit in pockets.


//FLAGS BITMASK
#define STOPSPRESSUREDMAGE 1	//This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere
//To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.

#define TABLEPASS 2			// can pass by a table or rack

#define MASKINTERNALS	8	// mask allows internals
//#define SUITSPACE		8	// suit protects against space

#define USEDELAY 	16		// 1 second extra delay on use (Can be used once every 2s)
#define NODELAY 	32768	// 1 second attackby delay skipped (Can be used once every 0.2s). Most objects have a 1s attackby delay, which doesn't require a flag.
#define NOSHIELD	32		// weapon not affected by shield
#define CONDUCT		64		// conducts electricity (metal etc.)
#define FPRINT		256		// takes a fingerprint
#define ON_BORDER	512		// item has priority to check when entering or leaving

#define GLASSESCOVERSEYES	1024
#define MASKCOVERSEYES		1024		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES		1024		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		2048		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		2048

#define NOSLIP		1024 		//prevents from slipping on wet floors, in space etc

#define OPENCONTAINER	4096	// is an open container for chemistry purposes

#define BLOCK_GAS_SMOKE_EFFECT 8192	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL	8192	// can be worn by fatties (or children? ugh) --jumpsuit only (NOTE: flag shared with BLOCK_GAS_SMOKE_EFFECT)

#define	NOREACT		16384 		//Reagents dont' react inside this container.

#define BLOCKHAIR	32768		// temporarily removes the user's hair icon

//flags for pass_flags
#define PASSTABLE	1
#define PASSGLASS	2
#define PASSGRILLE	4
#define PASSBLOB	8

//turf-only flags
#define NOJAUNT		1


//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
#define HIDEGLOVES		1	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESUITSTORAGE	2	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEJUMPSUIT	4	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESHOES		8	//APPLIES ONLY TO THE EXTERIOR SUIT!!

#define HIDEMASK		1	//APPLIES ONLY TO HELMETS/MASKS!!
#define HIDEEARS		2	//APPLIES ONLY TO HELMETS/MASKS!! (ears means headsets and such)
#define HIDEEYES		4	//APPLIES ONLY TO HELMETS/MASKS!! (eyes means glasses)
#define HIDEFACE		8	//APPLIES ONLY TO HELMETS/MASKS!! Dictates whether we appear as unknown.

//slots
#define slot_back			1
#define slot_wear_mask		2
#define slot_handcuffed		3
#define slot_l_hand			4
#define slot_r_hand			5
#define slot_belt			6
#define slot_wear_id		7
#define slot_ears			8
#define slot_glasses		9
#define slot_gloves			10
#define slot_head			11
#define slot_shoes			12
#define slot_wear_suit		13
#define slot_w_uniform		14
#define slot_l_store		15
#define slot_r_store		16
#define slot_s_store		17
#define slot_in_backpack	18
#define slot_legcuffed		19

//Cant seem to find a mob bitflags area other than the powers one

// bitflags for clothing parts
#define HEAD		1
#define CHEST		2
#define GROIN		4
#define LEG_LEFT	8
#define LEG_RIGHT	16
#define LEGS		24
#define FOOT_LEFT	32
#define FOOT_RIGHT	64
#define FEET		96
#define ARM_LEFT	128
#define ARM_RIGHT	256
#define ARMS		384
#define HAND_LEFT	512
#define HAND_RIGHT	1024
#define HANDS		1536
#define FULL_BODY	2047

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_CHEST		0.15
#define THERMAL_PROTECTION_GROIN		0.15
#define THERMAL_PROTECTION_LEG_LEFT		0.075
#define THERMAL_PROTECTION_LEG_RIGHT	0.075
#define THERMAL_PROTECTION_FOOT_LEFT	0.025
#define THERMAL_PROTECTION_FOOT_RIGHT	0.025
#define THERMAL_PROTECTION_ARM_LEFT		0.075
#define THERMAL_PROTECTION_ARM_RIGHT	0.075
#define THERMAL_PROTECTION_HAND_LEFT	0.025
#define THERMAL_PROTECTION_HAND_RIGHT	0.025


//bitflags for mutations
	// Extra powers:
#define SHADOW			(1<<10)	// shadow teleportation (create in/out portals anywhere) (25%)
#define SCREAM			(1<<11)	// supersonic screaming (25%)
#define EXPLOSIVE		(1<<12)	// exploding on-demand (15%)
#define REGENERATION	(1<<13)	// superhuman regeneration (30%)
#define REPROCESSOR		(1<<14)	// eat anything (50%)
#define SHAPESHIFTING	(1<<15)	// take on the appearance of anything (40%)
#define PHASING			(1<<16)	// ability to phase through walls (40%)
#define SHIELD			(1<<17)	// shielding from all projectile attacks (30%)
#define SHOCKWAVE		(1<<18)	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define ELECTRICITY		(1<<19)	// ability to shoot electric attacks (15%)


// String identifiers for associative list lookup

// mob/var/list/mutations

	// Generic mutations:
#define	TK				1
#define COLD_RESISTANCE	2
#define XRAY			3
#define HULK			4
#define CLUMSY			5
#define FAT				6
#define HUSK			7
#define NOCLONE			8


	// Extra powers:
#define LASER			9 	// harm intent - click anywhere to shoot lasers from eyes
#define HEAL			10 	// healing people with hands
#define SHADOW			11 	// shadow teleportation (create in/out portals anywhere) (25%)
#define SCREAM			12 	// supersonic screaming (25%)
#define EXPLOSIVE		13 	// exploding on-demand (15%)
#define REGENERATION	14 	// superhuman regeneration (30%)
#define REPROCESSOR		15 	// eat anything (50%)
#define SHAPESHIFTING	16 	// take on the appearance of anything (40%)
#define PHASING			17 	// ability to phase through walls (40%)
#define SHIELD			18 	// shielding from all projectile attacks (30%)
#define SHOCKWAVE		19 	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define ELECTRICITY		20 	// ability to shoot electric attacks (15%)

	//2spooky
#define SKELETON 29

//disabilities
#define NEARSIGHTED		1
#define EPILEPSY		2
#define COUGHING		4
#define TOURETTES		8
#define NERVOUS			16

//sdisabilities
#define BLIND			1
#define MUTE			2
#define DEAF			4

//mob/var/stat things
#define CONSCIOUS	0
#define UNCONSCIOUS	1
#define DEAD		2

// channel numbers for power
#define EQUIP	1
#define LIGHT	2
#define ENVIRON	3
#define TOTAL	4	//for total power used only

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse

//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

#define GAS_O2 	(1 << 0)
#define GAS_N2	(1 << 1)
#define GAS_PL	(1 << 2)
#define GAS_CO2	(1 << 3)
#define GAS_N2O	(1 << 4)


var/list/accessable_z_levels = list("1" = 5, "3" = 10, "4" = 15, "5" = 10, "6" = 60)
//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//(Exceptions: extended, sandbox and nuke) -Errorage
//Was list("3" = 30, "4" = 70).
//Spacing should be a reliable method of getting rid of a body -- Urist.
//Go away Urist, I'm restoring this to the longer list. ~Errorage

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))


var/list/global_mutations = list() // list of hidden mutation things

//Bluh shields


//Damage things	//TODO: merge these down to reduce on defines
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define HALLOSS		"halloss"

#define STUN		"stun"
#define WEAKEN		"weaken"
#define PARALYZE	"paralize"
#define IRRADIATE	"irradiate"
#define STUTTER		"stutter"
#define EYE_BLUR	"eye_blur"
#define DROWSY		"drowsy"

//I hate adding defines like this but I'd much rather deal with bitflags than lists and string searches
#define BRUTELOSS 1
#define FIRELOSS 2
#define TOXLOSS 4
#define OXYLOSS 8

//Bitflags defining which status effects could be or are inflicted on a mob
#define CANSTUN		1
#define CANWEAKEN	2
#define CANPARALYSE	4
#define CANPUSH		8
#define GODMODE		4096
#define FAKEDEATH	8192	//Replaces stuff like changeling.changeling_fakedeath
#define DISFIGURED	16384	//I'll probably move this elsewhere if I ever get wround to writing a bitflag mob-damage system
#define XENO_HOST	32768	//Tracks whether we're gonna be a baby alien's mummy.

var/static/list/scarySounds = list('sound/weapons/thudswoosh.ogg','sound/weapons/Taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg','sound/items/Welder.ogg','sound/items/Welder2.ogg','sound/machines/airlock.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')

//Grab levels
#define GRAB_PASSIVE	1
#define GRAB_AGGRESSIVE	2
#define GRAB_NECK		3
#define GRAB_UPGRADING	4
#define GRAB_KILL		5

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3



//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC			1
#define MUTE_OOC		2
#define MUTE_PRAY		4
#define MUTE_ADMINHELP	8
#define MUTE_DEADCHAT	16
#define MUTE_ALL		31

//Some constants for DB_Ban
#define BANTYPE_PERMA		1
#define BANTYPE_TEMP		2
#define BANTYPE_JOB_PERMA	3
#define BANTYPE_JOB_TEMP	4
#define BANTYPE_ANY_FULLBAN	5 //used to locate stuff to unban.
#define BANTYPE_APPEARANCE	6
#define BANTYPE_ADMIN_PERMA	7
#define BANTYPE_ADMIN_TEMP	8

#define SEE_INVISIBLE_MINIMUM 5

#define SEE_INVISIBLE_OBSERVER_NOLIGHTING 15

#define INVISIBILITY_LIGHTING 20

#define SEE_INVISIBLE_LIVING 25

#define SEE_INVISIBLE_LEVEL_ONE 35	//Used by some stuff in code. It's really poorly organized.
#define INVISIBILITY_LEVEL_ONE 35	//Used by some stuff in code. It's really poorly organized.

#define SEE_INVISIBLE_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.
#define INVISIBILITY_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.

#define INVISIBILITY_OBSERVER 60
#define SEE_INVISIBLE_OBSERVER 60

#define INVISIBILITY_MAXIMUM 100

#define BORGMESON 1
#define BORGTHERM 2
#define BORGXRAY  4

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.
var/list/TAGGERLOCATIONS = list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "Security", "HoS Office", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Theatre",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics")

#define HOSTILE_STANCE_IDLE			1
#define HOSTILE_STANCE_ALERT		2
#define HOSTILE_STANCE_ATTACK		3
#define HOSTILE_STANCE_ATTACKING	4
#define HOSTILE_STANCE_TIRED		5

//Please don't edit these values without speaking to Errorage first	~Carn
//Admin Permissions
#define R_BUILDMODE		1
#define R_ADMIN			2
#define R_BAN			4
#define R_FUN			8
#define R_SERVER		16
#define R_DEBUG			32
#define R_POSSESS		64
#define R_PERMISSIONS	128
#define R_STEALTH		256
#define R_REJUVINATE	512
#define R_VAREDIT		1024
#define R_SOUNDS		2048
#define R_SPAWN			4096

#define R_MAXPERMISSION 4096 //This holds the maximum value for a permission. It is used in iteration, so keep it updated.

#define R_HOST			65535

//Preference toggles
#define SOUND_ADMINHELP	1
#define SOUND_MIDI		2
#define SOUND_AMBIENCE	4
#define SOUND_LOBBY		8
#define CHAT_OOC		16
#define CHAT_DEAD		32
#define CHAT_GHOSTEARS	64
#define CHAT_GHOSTSIGHT	128
#define CHAT_PRAYER		256
#define CHAT_RADIO		512

#define TOGGLES_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO)

#define BE_TRAITOR		1
#define BE_OPERATIVE	2
#define BE_CHANGELING	4
#define BE_WIZARD		8
#define BE_MALF			16
#define BE_REV			32
#define BE_ALIEN		64
#define BE_PAI			128
#define BE_CULTIST		256
#define BE_MONKEY		512
#define BE_NINJA		1024

var/list/be_special_flags = list(
	"Traitor" = BE_TRAITOR,
	"Operative" = BE_OPERATIVE,
	"Changeling" = BE_CHANGELING,
	"Wizard" = BE_WIZARD,
	"Malf AI" = BE_MALF,
	"Revolutionary" = BE_REV,
	"Xenomorph" = BE_ALIEN,
	"pAI" = BE_PAI,
	"Cultist" = BE_CULTIST,
	"Monkey" = BE_MONKEY,
	"Ninja" = BE_NINJA
	)

// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list of humans.
#define HEALTH_HUD		1 // dead, alive, sick, health status
#define STATUS_HUD		2 // a simple line rounding the mob's number health
#define ID_HUD			3 // the job asigned to your ID
#define WANTED_HUD		4 // wanted, released, parroled, security status
#define IMPLOYAL_HUD	5 // loyality implant
#define IMPCHEM_HUD		6 // chemical implant
#define IMPTRACK_HUD	7 // tracking implant

#define MANIFEST_ERROR_NAME		1
#define MANIFEST_ERROR_COUNT	2
#define MANIFEST_ERROR_ITEM		4
//DNA - Because fuck you and your magic numbers being all over the codebase.
#define DNA_BLOCK_SIZE				3

#define DNA_UNI_IDENTITY_BLOCKS		7
#define DNA_HAIR_COLOR_BLOCK		1
#define DNA_FACIAL_HAIR_COLOR_BLOCK	2
#define DNA_SKIN_TONE_BLOCK			3
#define DNA_EYE_COLOR_BLOCK			4
#define DNA_GENDER_BLOCK			5
#define DNA_FACIAL_HAIR_STYLE_BLOCK	6
#define DNA_HAIR_STYLE_BLOCK		7

#define DNA_STRUC_ENZYMES_BLOCKS	14
#define DNA_UNIQUE_ENZYMES_LEN		32