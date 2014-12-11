//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define DEBUG
#define PROFILE_MACHINES // Disable when not debugging.

#ifdef PROFILE_MACHINES
#define CHECK_DISABLED(TYPE) if(disable_##TYPE) return
var/global/disable_scrubbers = 0
var/global/disable_vents     = 0
#else
#define CHECK_DISABLED(TYPE) /* DO NOTHINK */
#endif

#define PI 3.1415

#define R_IDEAL_GAS_EQUATION	8.31 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa

#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC

#define O2STANDARD 0.21
#define N2STANDARD 0.79

#define MOLES_O2STANDARD MOLES_CELLSTANDARD*O2STANDARD	// O2 standard value (21%)
#define MOLES_N2STANDARD MOLES_CELLSTANDARD*N2STANDARD	// N2 standard value (79%)

#define MOLES_PLASMA_VISIBLE	0.7 //Moles in a standard cell after which plasma is visible
#define MIN_PLASMA_DAMAGE 1
#define MAX_PLASMA_DAMAGE 10

#define BREATH_VOLUME 0.5	//liters in a normal breath
#define BREATH_MOLES (ONE_ATMOSPHERE * BREATH_VOLUME /(T20C*R_IDEAL_GAS_EQUATION))
#define BREATH_PERCENTAGE BREATH_VOLUME/CELL_VOLUME
	//Amount of air to take a from a tile
#define HUMAN_NEEDED_OXYGEN	MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16
	//Amount of air needed before pass out/suffocation commences

#define BASE_ZAS_FUEL_REQ	0.1

// Pressure limits.
#define HAZARD_HIGH_PRESSURE 550	//This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE 325 	//This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE 50 	//This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE 20		//This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT 1.5	//This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define BODYTEMP_AUTORECOVERY_DIVISOR 12 //This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM 10 //Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR 6 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR 6 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX 30 //The maximum number of degrees that your body can cool in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX 30 //The maximum number of degrees that your body can heat up in 1 tick, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT 360.15 // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT 260.15 // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_HELMET_MIN_COLD_PROTECITON_TEMPERATURE 2.0 //what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_SUIT_MIN_COLD_PROTECITON_TEMPERATURE 2.0 //what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE 5000	//These need better heat protect
#define FIRESUIT_MAX_HEAT_PROTECITON_TEMPERATURE 30000 //what max_heat_protection_temperature is set to for firesuit quality headwear. MUST NOT BE 0.
#define FIRE_HELMET_MAX_HEAT_PROTECITON_TEMPERATURE 30000 //for fire helmet quality items (red and white hardhats)
#define HELMET_MIN_COLD_PROTECITON_TEMPERATURE 160	//For normal helmets
#define HELMET_MAX_HEAT_PROTECITON_TEMPERATURE 600	//For normal helmets
#define ARMOR_MIN_COLD_PROTECITON_TEMPERATURE 160	//For armor
#define ARMOR_MAX_HEAT_PROTECITON_TEMPERATURE 600	//For armor

#define GLOVES_MIN_COLD_PROTECITON_TEMPERATURE 2.0	//For some gloves (black and)
#define GLOVES_MAX_HEAT_PROTECITON_TEMPERATURE 1500		//For some gloves
#define SHOE_MIN_COLD_PROTECITON_TEMPERATURE 2.0	//For gloves
#define SHOE_MAX_HEAT_PROTECITON_TEMPERATURE 1500		//For gloves


#define PRESSURE_DAMAGE_COEFFICIENT 4 //The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE 4	//This used to be 20... I got this much random rage for some retarded decision by polymorph?! Polymorph now lies in a pool of blood with a katana jammed in his spleen. ~Errorage --PS: The katana did less than 20 damage to him :(
#define LOW_PRESSURE_DAMAGE 2 	//The amounb of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define PRESSURE_SUIT_REDUCTION_COEFFICIENT 0.8 //This is how much (percentual) a suit with the flag STOPSPRESSUREDMAGE reduces pressure.
#define PRESSURE_HEAD_REDUCTION_COEFFICIENT 0.4 //This is how much (percentual) a helmet/hat with the flag STOPSPRESSUREDMAGE reduces pressure.

// Doors!
#define DOOR_CRUSH_DAMAGE 10

// Factor of how fast mob nutrition decreases
#define HUNGER_FACTOR 0.12

// How many units of reagent are consumed per tick, by default.
#define REAGENTS_METABOLISM 0.2

// By defining the effect multiplier this way, it'll exactly adjust
// all effects according to how they originally were with the 0.4 metabolism
#define REAGENTS_EFFECT_MULTIPLIER REAGENTS_METABOLISM / 0.4


#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.05
	//Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_TO_SUSPEND MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND
	//Minimum amount of air that has to move before a group processing can be suspended

#define MINIMUM_MOLES_DELTA_TO_MOVE MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE	T20C+100 		  //or this (or both, obviously)

#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND 0.012
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4
	//Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5
	//Minimum temperature difference before the gas temperatures are just set to be equal

#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		T20C+10
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	T20C+200

#define FLOOR_HEAT_TRANSFER_COEFFICIENT 0.4
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.0
#define DOOR_HEAT_TRANSFER_COEFFICIENT 0.0
#define SPACE_HEAT_TRANSFER_COEFFICIENT 0.2 //a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.1 //a hack for now
	//Must be between 0 and 1. Values closer to 1 equalize temperature faster
	//Should not exceed 0.4 else strange heat flow occur

#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	150+T0C
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	100+T0C
#define FIRE_SPREAD_RADIOSITY_SCALE		0.85
#define FIRE_CARBON_ENERGY_RELEASED	  500000 //Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PLASMA_ENERGY_RELEASED	 3000000 //Amount of heat released per mole of burnt plasma into the tile
#define FIRE_GROWTH_RATE			40000 //For small fires

//#define WATER_BOIL_TEMP 393

// Fire Damage
#define CARBON_LIFEFORM_FIRE_RESISTANCE 200+T0C
#define CARBON_LIFEFORM_FIRE_DAMAGE		4

//Plasma fire properties
#define PLASMA_MINIMUM_BURN_TEMPERATURE		100+T0C
#define PLASMA_FLASHPOINT 					246+T0C
#define PLASMA_UPPER_TEMPERATURE			1370+T0C
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	20
#define PLASMA_OXYGEN_FULLBURN				10

#define T0C  273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC

var/turf/space/Space_Tile = locate(/turf/space) // A space tile to reference when atmos wants to remove excess heat.

#define TANK_LEAK_PRESSURE		(30.*ONE_ATMOSPHERE)	// Tank starts leaking
#define TANK_RUPTURE_PRESSURE	(40.*ONE_ATMOSPHERE) // Tank spills all contents into atmosphere

#define TANK_FRAGMENT_PRESSURE	(50.*ONE_ATMOSPHERE) // Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    (10.*ONE_ATMOSPHERE) // +1 for each SCALE kPa aboe threshold
								// was 2 atm

//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
var/MAX_EXPLOSION_RANGE = 14
//#define MAX_EXPLOSION_RANGE		14					// Defaults to 12 (was 8) -- TLE

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.

#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.
#define ROLE_SELECT_AFK_BUFFER  1 // Default value.

#define NORMPIPERATE 30					//pipe-insulation rate divisor
#define HEATPIPERATE 8					//heat-exch pipe insulation

#define FLOWFRAC 0.99				// fraction of gas transfered per process

#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up


//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING 1
#define SLOT_ICLOTHING 2
#define SLOT_GLOVES 4
#define SLOT_EYES 8
#define SLOT_EARS 16
#define SLOT_MASK 32
#define SLOT_HEAD 64
#define SLOT_FEET 128
#define SLOT_ID 256
#define SLOT_BELT 512
#define SLOT_BACK 1024
#define SLOT_POCKET 2048		//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET 4096	//this is to deny items with a w_class of 2 or 1 to fit in pockets.
#define SLOT_TWOEARS 8192
#define SLOT_LEGS = 16384

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
#define NOBLUDGEON  4  // when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define NOBLOODY	2048	// used to items if they don't want to get a blood overlay

#define GLASSESCOVERSEYES	1024
#define MASKCOVERSEYES		1024		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES		1024		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		2048		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		2048

#define NOSLIP		1024 		//prevents from slipping on wet floors, in space etc

#define OPENCONTAINER	4096	// is an open container for chemistry purposes

#define BLOCK_GAS_SMOKE_EFFECT 8192	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL 8192
#define PLASMAGUARD 16384			//Does not get contaminated by plasma.

#define	NOREACT		16384 			//Reagents dont' react inside this container.

#define BLOCKHEADHAIR 4             // temporarily removes the user's hair overlay. Leaves facial hair.
#define BLOCKHAIR	32768			// temporarily removes the user's hair, facial and otherwise.

#define INVULNERABLE 128

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
#define HIDEMASK	1	//APPLIES ONLY TO HELMETS/MASKS!!
#define HIDEEARS	2	//APPLIES ONLY TO HELMETS/MASKS!! (ears means headsets and such)
#define HIDEEYES	4	//APPLIES ONLY TO HELMETS/MASKS!! (eyes means glasses)
#define HIDEFACE	8	//APPLIES ONLY TO HELMETS/MASKS!! Dictates whether we appear as unknown.

//slots
#define slot_back 1
#define slot_wear_mask 2
#define slot_handcuffed 3
#define slot_l_hand 4
#define slot_r_hand 5
#define slot_belt 6
#define slot_wear_id 7
#define slot_ears 8
#define slot_glasses 9
#define slot_gloves 10
#define slot_head 11
#define slot_shoes 12
#define slot_wear_suit 13
#define slot_w_uniform 14
#define slot_l_store 15
#define slot_r_store 16
#define slot_s_store 17
#define slot_in_backpack 18
#define slot_legcuffed 19
#define slot_legs 21

//Cant seem to find a mob bitflags area other than the powers one

// bitflags for clothing parts
#define HEAD			1
#define UPPER_TORSO		2
#define LOWER_TORSO		4
#define LEG_LEFT		8
#define LEG_RIGHT		16
#define LEGS			24
#define FOOT_LEFT		32
#define FOOT_RIGHT		64
#define FEET			96
#define ARM_LEFT		128
#define ARM_RIGHT		256
#define ARMS			384
#define HAND_LEFT		512
#define HAND_RIGHT		1024
#define HANDS			1536
#define FULL_BODY		2047

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_UPPER_TORSO	0.15
#define THERMAL_PROTECTION_LOWER_TORSO	0.15
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

// Used in preferences.
#define DISABILITY_FLAG_NEARSIGHTED 1
#define DISABILITY_FLAG_FAT         2
#define DISABILITY_FLAG_EPILEPTIC   4
#define DISABILITY_FLAG_DEAF        8

///////////////////////////////////////
// MUTATIONS
///////////////////////////////////////

// Generic mutations:
#define	M_TK			1
#define M_RESIST_COLD	2
#define M_XRAY			3
#define M_HULK			4
#define M_CLUMSY			5
#define M_FAT				6
#define M_HUSK			7
#define M_NOCLONE			8


// Extra powers:
#define M_LASER			9 	// harm intent - click anywhere to shoot lasers from eyes
//#define HEAL			10 	// (Not implemented) healing people with hands
//#define SHADOW		11 	// (Not implemented) shadow teleportation (create in/out portals anywhere) (25%)
//#define SCREAM		12 	// (Not implemented) supersonic screaming (25%)
//#define EXPLOSIVE		13 	// (Not implemented) exploding on-demand (15%)
//#define REGENERATION	14 	// (Not implemented) superhuman regeneration (30%)
//#define REPROCESSOR	15 	// (Not implemented) eat anything (50%)
//#define SHAPESHIFTING	16 	// (Not implemented) take on the appearance of anything (40%)
//#define PHASING		17 	// (Not implemented) ability to phase through walls (40%)
//#define SHIELD		18 	// (Not implemented) shielding from all projectile attacks (30%)
//#define SHOCKWAVE		19 	// (Not implemented) attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
//#define ELECTRICITY	20 	// (Not implemented) ability to shoot electric attacks (15%)

	//2spooky
#define SKELETON 29
#define PLANT 30

// Other Mutations:
#define M_NO_BREATH		100 	// no need to breathe
#define M_REMOTE_VIEW	101 	// remote viewing
#define M_REGEN			102 	// health regen
#define M_RUN			103 	// no slowdown
#define M_REMOTE_TALK	104 	// remote talking
#define M_MORPH			105 	// changing appearance
#define M_RESIST_HEAT	106 	// heat resistance
#define M_HALLUCINATE	107 	// hallucinations
#define M_FINGERPRINTS	108 	// no fingerprints
#define M_NO_SHOCK		109 	// insulated hands
#define M_DWARF			110 	// table climbing

// Goon muts
#define M_OBESITY       200		// Decreased metabolism
#define M_TOXIC_FARTS   201		// Duh
#define M_STRONG        202		// (Nothing)
#define M_SOBER         203		// Increased alcohol metabolism
#define M_PSY_RESIST    204		// Block remoteview
#define M_SUPER_FART    205		// Duh
#define M_SMILE         206		// :)
#define M_ELVIS         207		// You ain't nothin' but a hound dog.

// /vg/ muts
#define M_LOUD		208		// CAUSES INTENSE YELLING
#define M_WHISPER	209		// causes quiet whispering
#define M_DIZZY		210		// Trippy.
#define M_SANS		211		// IF YOU SEE THIS WHILST BROWSING CODE, YOU HAVE BEEN VISITED BY: THE FONT OF SHITPOSTING. GREAT LUCK AND WEALTH WILL COME TO YOU, BUT ONLY IF YOU SAY 'fuck comic sans' IN YOUR PR.

// Bustanuts
#define M_HARDCORE      300

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

#define ENGINE_EJECT_Z	3

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

#define GAS_O2 	(1 << 0)
#define GAS_N2	(1 << 1)
#define GAS_PL	(1 << 2)
#define GAS_CO2	(1 << 3)
#define GAS_N2O	(1 << 4)

#define CC_PER_SHEET_METAL 3750
#define CC_PER_SHEET_GLASS 3750
#define CC_PER_SHEET_MISC 2000

#define INV_SLOT_SIGHT "sight_slot"
#define INV_SLOT_TOOL "tool_slot"

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
#define AGONY		"agony" // Added in PAIN!
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

#define TRANSITIONEDGE	7 //Distance from edge to move to another z-level

var/list/liftable_structures = list(\

	/obj/machinery/autolathe, \
	/obj/machinery/constructable_frame, \
	/obj/machinery/portable_atmospherics/hydroponics, \
	/obj/machinery/computer, \
	/obj/machinery/optable, \
	/obj/structure/dispenser, \
	/obj/machinery/gibber, \
	/obj/machinery/microwave, \
	/obj/machinery/vending, \
	/obj/machinery/seed_extractor, \
	/obj/machinery/space_heater, \
	/obj/machinery/recharge_station, \
	/obj/machinery/flasher, \
	/obj/structure/stool, \
	/obj/structure/closet, \
	/obj/machinery/photocopier, \
	/obj/structure/filingcabinet, \
	/obj/structure/reagent_dispensers, \
	/obj/machinery/portable_atmospherics/canister)

//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC			1
#define MUTE_OOC		2
#define MUTE_PRAY		4
#define MUTE_ADMINHELP	8
#define MUTE_DEADCHAT	16
#define MUTE_ALL		31

//Number of identical messages required to get the spam-prevention automute thing to trigger warnings and automutes
#define SPAM_TRIGGER_WARNING 5
#define SPAM_TRIGGER_AUTOMUTE 10

//Some constants for DB_Ban
#define BANTYPE_PERMA		1
#define BANTYPE_TEMP		2
#define BANTYPE_JOB_PERMA	3
#define BANTYPE_JOB_TEMP	4
#define BANTYPE_ANY_FULLBAN	5 //used to locate stuff to unban.
#define BANTYPE_APPEARANCE	6

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

// Object specific defines.
#define CANDLE_LUM 2 //For how bright candles are.


// Some mob defines below.
#define AI_CAMERA_LUMINOSITY 5

#define BORGMESON 1
#define BORGTHERM 2
#define BORGXRAY  4

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.
var/list/TAGGERLOCATIONS = list(
	"Disposals",     // 1
	"Cargo Bay",     // 2
	"QM Office",     // 3
	"Engineering",   // 4
	"CE Office",     // 5
	"Atmospherics",  // 6
	"Security",      // 7
	"HoS Office",    // 8
	"Medbay",        // 9
	"CMO Office",    // 10
	"Chemistry",     // 11
	"Research",      // 12
	"RD Office",     // 13
	"Robotics",      // 14
	"HoP Office",    // 15
	"Library",       // 16
	"Chapel",        // 17
	"Theatre",       // 18
	"Bar",           // 19
	"Kitchen",       // 20
	"Hydroponics",   // 21
	"Janitor Closet",// 22
	"Genetics",      // 23
	"Telecomms")     // 24

#define HOSTILE_STANCE_IDLE 1
#define HOSTILE_STANCE_ALERT 2
#define HOSTILE_STANCE_ATTACK 3
#define HOSTILE_STANCE_ATTACKING 4
#define HOSTILE_STANCE_TIRED 5

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

//Damage things

#define CUT 		"cut"
#define BRUISE		"bruise"
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
#define SLUR 		"slur"
#define EYE_BLUR	"eye_blur"
#define DROWSY		"drowsy"

///////////////////ORGAN DEFINES///////////////////

#define ORGAN_CUT_AWAY		1
#define ORGAN_GAUZED		2
#define ORGAN_ATTACHABLE	4
#define ORGAN_BLEEDING		8
#define ORGAN_BROKEN		32
#define ORGAN_DESTROYED		64
#define ORGAN_ROBOT			128
#define ORGAN_SPLINTED		256
#define SALVED				512
#define ORGAN_DEAD			1024
#define ORGAN_MUTATED		2048
#define ORGAN_PEG			4096 // ROB'S MAGICAL PEGLEGS v2

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
#define R_MOD			8192
#define R_ADMINBUS		16384

#define R_MAXPERMISSION 16384 //This holds the maximum value for a permission. It is used in iteration, so keep it updated.

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
#define CHAT_ATTACKLOGS	1024
#define CHAT_DEBUGLOGS	2048
#define CHAT_LOOC		4096
#define CHAT_GHOSTRADIO 8192
#define SOUND_STREAMING 16384 // /vg/
#define CHAT_GHOSTPDA   32768


#define TOGGLES_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_ATTACKLOGS|CHAT_LOOC|SOUND_STREAMING)

//////////////////////////////////
// ROLES 2.0
//////////////////////////////////
// First bit is no/yes.
// Second bit is persistence (save to char prefs).
// Third bit is whether we polled for that role yet.
#define ROLEPREF_ENABLE         1 // Enable role for this character.
#define ROLEPREF_PERSIST        2 // Save preference.
#define ROLEPREF_POLLED         4 // Have we polled this guy?

#define ROLEPREF_NEVER   ROLEPREF_PERSIST
#define ROLEPREF_NO      0
#define ROLEPREF_YES     ROLEPREF_ENABLE
#define ROLEPREF_ALWAYS  (ROLEPREF_ENABLE|ROLEPREF_PERSIST)

// Masks.
#define ROLEPREF_SAVEMASK 1 // 0b00000001 - For saving shit.
#define ROLEPREF_VALMASK  3 // 0b00000011 - For a lot of things.

// Should correspond to jobbans, too.
#define ROLE_ALIEN      "alien"
#define ROLE_BLOB       "blob"      // New!
#define ROLE_BORER      "borer"     // New!
#define ROLE_CHANGELING "changeling"
#define ROLE_COMMANDO   "commando"  // New!
#define ROLE_CULTIST    "cultist"
#define ROLE_MALF       "malf AI"
#define ROLE_NINJA      "ninja"
#define ROLE_OPERATIVE  "operative" // New!
#define ROLE_PAI        "pAI"
#define ROLE_PLANT      "Dionaea"
#define ROLE_POSIBRAIN  "posibrain"
#define ROLE_REV        "revolutionary"
#define ROLE_TRAITOR    "traitor"
#define ROLE_VAMPIRE    "vampire"
#define ROLE_VOXRAIDER  "vox raider"
#define ROLE_WIZARD     "wizard"


#define AGE_MIN 17			//youngest a character can be
#define AGE_MAX 85			//oldest a character can be

//Languages!
#define LANGUAGE_HUMAN		1
#define LANGUAGE_ALIEN		2
#define LANGUAGE_DOG		4
#define LANGUAGE_CAT		8
#define LANGUAGE_BINARY		16
#define LANGUAGE_OTHER		32768

#define LANGUAGE_UNIVERSAL	65535

#define LEFT 1
#define RIGHT 2

// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list of humans.
#define HEALTH_HUD          1 // a simple line rounding the mob's number health
#define STATUS_HUD          2 // alive, dead, diseased, etc.
#define ID_HUD              3 // the job asigned to your ID
#define WANTED_HUD          4 // wanted, released, parroled, security status
#define IMPLOYAL_HUD		5 // loyality implant
#define IMPCHEM_HUD		    6 // chemical implant
#define IMPTRACK_HUD		7 // tracking implant
#define SPECIALROLE_HUD 	8 // AntagHUD image
#define STATUS_HUD_OOC		9 // STATUS_HUD without virus db check for someone being ill.

//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock
//feel free to add shit to lists below
var/list/tachycardics = list("coffee", "inaprovaline", "hyperzine", "nitroglycerin", "thirteenloko", "nicotine")	//increase heart rate
var/list/bradycardics = list("neurotoxin", "cryoxadone", "clonexadone", "space_drugs", "stoxin")					//decrease heart rate
var/list/heartstopper = list("potassium_phorochloride", "zombie_powder") //this stops the heart
var/list/cheartstopper = list("potassium_chloride") //this stops the heart when overdose is met -- c = conditional

//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

var/list/RESTRICTED_CAMERA_NETWORKS = list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	"thunder",
	"ERT",
	"NUKE",
	"CREED"
	)

//Species flags.
#define NO_BLOOD 1
#define NO_BREATHE 2
#define NO_SCAN 4
#define NO_PAIN 8

#define HAS_SKIN_TONE 16
#define HAS_LIPS 32
#define HAS_UNDERWEAR 64
#define HAS_TAIL 128

#define IS_SLOW 256
#define IS_PLANT 512
#define IS_WHITELISTED 1024

#define RAD_ABSORB 2048
#define REQUIRE_LIGHT 4096

#define CAN_BE_FAT 8192 // /vg/

#define IS_SYNTHETIC 16384 // from baystation


// from bay station
#define INFECTION_LEVEL_ONE 100
#define INFECTION_LEVEL_TWO 500
#define INFECTION_LEVEL_THREE 1000



//Language flags.
#define WHITELISTED 1  // Language is available if the speaker is whitelisted.
#define RESTRICTED 2   // Language can only be accquired by spawning or an admin.

// Hairstyle flags
#define HAIRSTYLE_CANTRIP 1 // 5% chance of tripping your stupid ass if you're running.

// equip_to_slot_if_possible flags
#define EQUIP_FAILACTION_NOTHING 0
#define EQUIP_FAILACTION_DELETE 1
#define EQUIP_FAILACTION_DROP 2

// Vampire power defines
#define VAMP_REJUV   1
#define VAMP_GLARE   2
#define VAMP_HYPNO   3
#define VAMP_SHAPE   4
#define VAMP_VISION  5
#define VAMP_DISEASE 6
#define VAMP_CLOAK   7
#define VAMP_BATS    8
#define VAMP_SCREAM  9
#define VAMP_JAUNT   10
#define VAMP_SLAVE   11
#define VAMP_BLINK   12
#define VAMP_FULL    13

// Moved from machine_interactions.dm
#define STATION_Z  1
#define CENTCOMM_Z 2
#define TELECOMM_Z 3
#define ASTEROID_Z 5

// canGhost(Read|Write) flags
#define PERMIT_ALL 1

// Bay fixed recursive_mob_check (so shit can hear things from inside a container)
// Unfortunately, it created incredible amounts of lag.
// Comment the following line if you want it anyway.
#define USE_BROKEN_RECURSIVE_MOBCHECK


//////////////////
// RECYCLING SHIT
//////////////////

// Sorting categories
#define NOT_RECYCLABLE   0
#define RECYK_MISC       1
#define RECYK_GLASS      2
#define RECYK_BIOLOGICAL 3
#define RECYK_METAL      4
#define RECYK_ELECTRONIC 5

////////////////
// job.info_flags
#define JINFO_SILICON 1 // Silicon job

// The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.
// 1 will enable set background. 0 will disable set background.
#define BACKGROUND_ENABLED 0

// multitool_topic() shit
#define MT_ERROR  -1
#define MT_UPDATE 1
#define MT_REINIT 2

#define AUTOIGNITION_WOOD  573.15
#define AUTOIGNITION_PAPER 519.15

#define MELTPOINT_GLASS   1500+T0C
#define MELTPOINT_STEEL   1510+T0C
#define MELTPOINT_SILICON 1687 // KELVIN
#define MELTPOINT_PLASTIC 180+T0C

//used to define machine behaviour in attackbys and other code situations
#define EMAGGABLE		1 //can we emag it? If this is flagged, the machine calls emag()
#define SCREWTOGGLE		2 //does it toggle panel_open when hit by a screwdriver?
#define CROWDESTROY		4 //does hitting a panel_open machine with a crowbar disassemble it?
#define WRENCHMOVE		8 //does hitting it with a wrench toggle its anchored state?
#define FIXED2WORK		16 //does it need to be anchored to work? Try to use this with WRENCHMOVE
#define EJECTNOTDEL		32 //when we destroy the machine, does it remove all its items or destroy them?
#define WELD_FIXED		64 //if it is attacked by a welder and is anchored, it'll toggle between welded and unwelded to the floor

//gun shit - prepare to have various things added to this
#define SILENCECOMP  1 		//Silencer-compatible
#define AUTOMAGDROP  2		//Does the mag drop when it's empty?
#define EMPTYCASINGS 4		//Does the gun eject empty casings?

///////////////////////
///////RESEARCH////////
///////////////////////
//used in rdmachines, to define certain behaviours
//bitflags are my waifu - Comic

//NB TRUELOCKS should ONLY be used for machines that produce stuff that's not good in an emergency i.e. a gun fabricator. Be very careful with it
#define CONSOLECONTROL		1	//does the console control it? can't be interacted if not linked
#define HASOUTPUT			2	//does it have an output? - mainly for fabricators
#define TAKESMATIN			4	//does it takes materials (sheets) - mainly for fabricators
#define NANOTOUCH			8	//does it have a nanoui when you smack it with your hand? - mainly for fabricators
#define HASMAT_OVER			16	//does it have overlays for when you load materials in? - mainly for fabricators
#define ACCESS_EMAG			32	//does it lose all its access when smacked by an emag? incompatible with CONSOLECONTROl, for obvious reasons
#define LOCKBOXES			64	//does it spawn a lockbox around a design which is said to be locked? - for fabricators
#define TRUELOCKS			128 //does it make a truly locked lockbox? If not set, the lockboxes made are unlockable by any crew with an ID

// Mecca scanner flags
#define MECH_SCAN_FAIL     1 // Cannot be scanned at all.
#define MECH_SCAN_ILLEGAL  2 // Can only be scanned by the antag scanner.


// EMOTES!
#define VISIBLE 1
#define HEARABLE 2

// /vg/ - Pipeline processing (enables exploding pipes and whatnot)
#define ATMOS_PIPELINE_PROCESSING 1
