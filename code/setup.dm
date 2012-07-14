//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define TRUE 1
#define FALSE 0

#define PI 3.1415

#define R_IDEAL_GAS_EQUATION	8.31 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa

#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC

#define O2STANDARD 0.21
#define N2STANDARD 0.79

#define MOLES_O2STANDARD MOLES_CELLSTANDARD*O2STANDARD	// O2 standard value (21%)
#define MOLES_N2STANDARD MOLES_CELLSTANDARD*N2STANDARD	// N2 standard value (79%)

#define MOLES_PLASMA_VISIBLE	0.5 //Moles in a standard cell after which plasma is visible

#define SPECIFIC_HEAT_TOXIN		200
#define SPECIFIC_HEAT_AIR		20
#define SPECIFIC_HEAT_CDO		30
#define HEAT_CAPACITY_CALCULATION(oxygen,carbon_dioxide,nitrogen,toxins) \
	(carbon_dioxide*SPECIFIC_HEAT_CDO + (oxygen+nitrogen)*SPECIFIC_HEAT_AIR + toxins*SPECIFIC_HEAT_TOXIN)

#define MINIMUM_HEAT_CAPACITY	0.0003
#define QUANTIZE(variable)		(round(variable,0.0001))
#define TRANSFER_FRACTION 5 //What fraction (1/#) of the air difference to try and transfer

#define BREATH_VOLUME 0.5	//liters in a normal breath
#define BREATH_PERCENTAGE BREATH_VOLUME/CELL_VOLUME
	//Amount of air to take a from a tile
#define HUMAN_NEEDED_OXYGEN	MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16
	//Amount of air needed before pass out/suffocation commences

// Pressure limits.
#define HAZARD_HIGH_PRESSURE 750
#define HIGH_STEP_PRESSURE HAZARD_HIGH_PRESSURE/2
#define WARNING_HIGH_PRESSURE HAZARD_HIGH_PRESSURE*0.7
#define HAZARD_LOW_PRESSURE 20
#define WARNING_LOW_PRESSURE HAZARD_LOW_PRESSURE*2.5
#define MAX_PRESSURE_DAMAGE 20

// Doors!
#define DOOR_CRUSH_DAMAGE 10

// Factor of how fast mob nutrition decreases
#define	HUNGER_FACTOR 0.1
#define	REAGENTS_METABOLISM 0.05
#define REAGENTS_OVERDOSE 30

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

#define FLOOR_HEAT_TRANSFER_COEFFICIENT 0.08
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.03
#define SPACE_HEAT_TRANSFER_COEFFICIENT 0.20 //a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.40
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.10 //a hack for now
	//Must be between 0 and 1. Values closer to 1 equalize temperature faster
	//Should not exceed 0.4 else strange heat flow occur

#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	150+T0C
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	100+T0C
#define FIRE_SPREAD_RADIOSITY_SCALE		0.85
#define FIRE_CARBON_ENERGY_RELEASED	  500000 //Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PLASMA_ENERGY_RELEASED	 3000000 //Amount of heat released per mole of burnt plasma into the tile
#define FIRE_GROWTH_RATE			25000 //For small fires

//Plasma fire properties
#define PLASMA_MINIMUM_BURN_TEMPERATURE		100+T0C
#define PLASMA_UPPER_TEMPERATURE			1370+T0C
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define PLASMA_OXYGEN_FULLBURN				10

#define T0C 273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC

#define TANK_LEAK_PRESSURE		(30.*ONE_ATMOSPHERE)	// Tank starts leaking
#define TANK_RUPTURE_PRESSURE	(40.*ONE_ATMOSPHERE) // Tank spills all contents into atmosphere

#define TANK_FRAGMENT_PRESSURE	(50.*ONE_ATMOSPHERE) // Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    (10.*ONE_ATMOSPHERE) // +1 for each SCALE kPa aboe threshold
								// was 2 atm

//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
var/MAX_EXPLOSION_RANGE = 14
//#define MAX_EXPLOSION_RANGE		14					// Defaults to 12 (was 8) -- TLE


#define NORMPIPERATE 30					//pipe-insulation rate divisor
#define HEATPIPERATE 8					//heat-exch pipe insulation

#define FLOWFRAC 0.99				// fraction of gas transfered per process

#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up


//ITEM INVENTORY SLOT BITMASKS: (HUMANS ONLY!)
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


//FLAGS BITMASK
#define TABLEPASS 2			// can pass by a table or rack

/********************************************************************************
*	WOO WOO WOO	THIS IS UNUSED	WOO WOO WOO										*
*	#define HALFMASK 4	// mask only gets 1/2 of air supply from internals		*
*	WOO WOO WOO	THIS IS UNUSED	WOO WOO WOO										*
********************************************************************************/

#define HEADSPACE 4			// head wear protects against space

#define MASKINTERNALS	8	// mask allows internals
#define SUITSPACE		8	// suit protects against space

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

// #define ONESIZEFITSALL	8192	// can be worn by fatties (or children? ugh)

#define	NOREACT		16384 		//Reagents dont' react inside this container.

#define BLOCKHAIR	32768		// temporarily removes the user's hair icon

#define PLASMAGUARD 65536		//Does not get contaminated by plasma.

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
#define HIDEMASK	1	//APPLIES ONLY TO HELMETS!!
#define HIDEEARS	2	//APPLIES ONLY TO HELMETS!!
#define HIDEEYES	4	//APPLIES ONLY TO HELMETS!!

//clothing-overlay layers. They are floats so they always appear above the Mob
#define DAMAGE_LAYER		-23
#define UNIFORM_LAYER		-22
#define B_UNIFORM_LAYER		-21
#define SHOES_LAYER			-20
#define B_SHOES_LAYER		-19
#define ID_LAYER			-18
#define GLOVES_LAYER		-17
#define B_GLOVES_LAYER		-16
#define EARS_LAYER			-15
#define SUIT_LAYER			-14
#define B_SUIT_LAYER		-13
#define FACE_LAYER			-12
#define GLASSES_LAYER		-11
#define FACEMASK_LAYER		-10
#define B_FACEMASK_LAYER	-9
#define HEAD_LAYER			-8
#define B_HEAD_LAYER		-7
#define SUIT_STORE_LAYER	-6
#define BELT_LAYER			-5
#define BACK_LAYER			-4
#define CUFFED_LAYER		-3
#define SHIELD_LAYER		-2
#define INHANDS_LAYER		-1




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

/*
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


	// Nanoaugmentations:
#define SUPRSTR			(1<<20)	// super strength
#define RADAR			(1<<21)	// on-screen mob radar
#define ELECTRICHANDS	(1<<22)	// electric hands
#define ESWORDSYNTH		(1<<23)	// esword synthesizer
#define REBREATHER		(1<<24)	// removes the need to breathe
#define DERMALARMOR		(1<<25)	// 35% damage decrease
#define REFLEXES		(1<<26)	// dodge 50% of projectiles, dodge 25% of melee attacks
#define NANOREGEN		(1<<27)	// regenerative nanobots, -3 all damage types per second
*/

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


// mob/var/list/augmentations

	// Nanoaugmentations:
#define SUPRSTR			21 	// super strength (hulk powers)
#define RADAR			22 	// on-screen mob radar
#define ELECTRICHANDS	23 	// electric hands
#define ESWORDSYNTH		24 	// esword synthesizer
#define REBREATHER		25 	// removes the need to breathe
#define DERMALARMOR		26 	// 35% damage decrease
#define REFLEXES		27 	// dodge 50% of projectiles
#define NANOREGEN		28 	// regenerative nanobots, -3 all damage types per second

	// Other Mutations:
#define mNobreath		100 	// no need to breathe
#define mRemote			101 	// remote viewing
#define mRegen			102 	// health regen
#define mRun			103 	// no slowdown
#define mRemotetalk		104 	// remote talking
#define mMorph			105 	// changing appearance
#define mBlend			106 	// nothing (seriously nothing)
#define mHallucination	107 	// hallucinations
#define mFingerprints	108 	// no fingerprints
#define mShock			109 	// insulated hands
#define mSmallsize		110 	// table climbing

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


var/list/accessable_z_levels = list("3" = 15, "4" = 35, "6" = 50)
//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//(Exceptions: extended, sandbox and nuke) -Errorage
//Was list("1" = 10, "3" = 15, "4" = 60, "5" = 15); changed it to list("3" = 30, "4" = 70).
//Spacing should be a reliable method of getting rid of a body -- Urist.

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))


var/list/global_mutations = list() // list of hidden mutation things

//Bluh shields


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

var/static/list/scarySounds = list('thudswoosh.ogg','Taser.ogg','armbomb.ogg','hiss1.ogg','hiss2.ogg','hiss3.ogg','hiss4.ogg','hiss5.ogg','hiss6.ogg','Glassbr1.ogg','Glassbr2.ogg','Glassbr3.ogg','Welder.ogg','Welder2.ogg','airlock.ogg','clownstep1.ogg','clownstep2.ogg')

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

#define TRANSITIONEDGE	7 //Distance from edge to move to another z-level

#define CLOSED 0

// Maximum and minimum character ages.
var/const/minimum_age = 20
var/const/maximum_age = 65

var/list/liftable_structures = list(\

	/obj/machinery/autolathe, \
	/obj/machinery/constructable_frame, \
	/obj/machinery/hydroponics, \
	/obj/machinery/computer, \
	/obj/machinery/optable, \
	/obj/machinery/dispenser, \
	/obj/machinery/gibber, \
	/obj/machinery/microwave, \
	/obj/machinery/vending, \
	/obj/machinery/seed_extractor, \
	/obj/machinery/space_heater, \
	/obj/machinery/recharge_station, \
	/obj/machinery/flasher, \
	/obj/structure/stool, \
	/obj/structure/closet, \
/*	/obj/machinery/photocopier, \*/
	/obj/structure/filingcabinet, \
	/obj/structure/reagent_dispensers, \
	/obj/machinery/portable_atmospherics/canister)

//////////////////
//GLOBAL DEFINES//
//////////////////

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
#define INFINITY 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216

#define MAX_NAME_LEN 32

/////////////////
//RADIO DEFINES//
/////////////////
#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

/* filters */
#define RADIO_TO_AIRALARM "1"
#define RADIO_FROM_AIRALARM "2"
#define RADIO_CHAT "3"
#define RADIO_ATMOSIA "4"
#define RADIO_NAVBEACONS "5"
#define RADIO_AIRLOCK "6"
#define RADIO_SECBOT "7"
#define RADIO_MULEBOT "8"
#define RADIO_MAGNETS "9"
#define RADIO_POWER "10"

/////////////////
//ORGAN DEFINES//
/////////////////
#define ORGAN_CUT_AWAY 1
#define ORGAN_GAUZED 2
#define ORGAN_ATTACHABLE 4
#define ORGAN_BLEEDING 8
#define ORGAN_BANDAGED 16
#define ORGAN_BROKEN 32
#define ORGAN_DESTROYED 64
#define ORGAN_ROBOT 128
#define ORGAN_SPLINTED 256