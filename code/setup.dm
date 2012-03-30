#define R_IDEAL_GAS_EQUATION	8.31 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa

#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC

#define O2STANDARD 0.21
#define N2STANDARD 0.79

#define MOLES_O2STANDARD MOLES_CELLSTANDARD*O2STANDARD	// O2 standard value (21%)
#define MOLES_N2STANDARD MOLES_CELLSTANDARD*N2STANDARD	// N2 standard value (79%)

#define MOLES_PLASMA_VISIBLE	0.5 //Moles in a standard cell after which plasma is visible

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


//FLAGS BITMASK
#define ONBACK 1			// can be put in back slot
#define TABLEPASS 2			// can pass by a table or rack
#define HALFMASK 4			// mask only gets 1/2 of air supply from internals

#define HEADSPACE 4			// head wear protects against space

#define MASKINTERNALS 8		// mask allows internals
#define SUITSPACE 8			// suit protects against space

#define USEDELAY 16			// 1 second extra delay on use (Can be used once every 2s)
#define NODELAY 32768		// 1 second attackby delay skipped (Can be used once every 0.2s). Most objects have a 1s attackby delay, which doesn't require a flag.
#define NOSHIELD 32			// weapon not affected by shield
#define CONDUCT 64			// conducts electricity (metal etc.)
#define ONBELT 128			// can be put in belt slot
#define FPRINT 256			// takes a fingerprint
#define ON_BORDER 512		// item has priority to check when entering or leaving

#define GLASSESCOVERSEYES 1024
#define MASKCOVERSEYES 1024		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES 1024		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH 2048		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH 2048

#define NOSLIP 1024 //prevents from slipping on wet floors, in space etc

#define OPENCONTAINER	4096	// is an open container for chemistry purposes

#define ONESIZEFITSALL	8192	// can be worn by fatties (or children? ugh)

#define	NOREACT	16384 //Reagents dont' react inside this container.

#define BLOCKHAIR 32768			// temporarily removes the user's hair icon

#define PLASMAGUARD 65536

//flags for pass_flags
#define PASSTABLE 1
#define PASSGLASS 2
#define PASSGRILLE 4
#define PASSBLOB 8

//turf-only flags
#define NOJAUNT 1

//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
#define HIDEGLOVES 1		//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESUITSTORAGE 2	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEJUMPSUIT 4		//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESHOES 8			//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEMASK 1			//APPLIES ONLY TO HELMETS!!
#define HIDEEARS 2			//APPLIES ONLY TO HELMETS!!
#define HIDEEYES 4			//APPLIES ONLY TO HELMETS!!

//Cant seem to find a mob bitflags area other than the powers one
#define NOGRAV 1

//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
#define HIDEGLOVES 1		//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESUITSTORAGE 2	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEJUMPSUIT 4		//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESHOES 8			//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEMASK 1			//APPLIES ONLY TO HELMETS!!
#define HIDEEARS 2			//APPLIES ONLY TO HELMETS!!
#define HIDEEYES 4			//APPLIES ONLY TO HELMETS!!


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

//bitflags for mutations
var/const
	TK				=(1<<0)
	COLD_RESISTANCE	=(1<<1)
	XRAY			=(1<<2)
	HULK			=(1<<3)
	CLUMSY			=(1<<4)
	FAT				=(1<<5)
	HUSK			=(1<<6)
	LASER			=(1<<7)
	HEAL			=(1<<8)
	mNobreath		=(1<<9)
	mRemote			=(1<<10)
	mRegen			=(1<<11)
	mRun			=(1<<12)
	mRemotetalk		=(1<<13)
	mMorph			=(1<<14)
	mBlend			=(1<<15)
//the "&" operator cannot go higher than (2^16)-1
	mHallucination	=(1<<0)
	mFingerprints	=(1<<1)
	mShock			=(1<<2)
	mSmallsize		=(1<<3)
	NOCLONE			=(1<<4)

//mob/var/stat things
var/const
	CONSCIOUS = 0
	UNCONSCIOUS = 1
	DEAD = 2

// channel numbers for power
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
#define TOTAL 4	//for total power used only

// bitflags for machine stat variable
#define BROKEN 1
#define NOPOWER 2
#define POWEROFF 4		// tbd
#define MAINT 8			// under maintaince
#define EMPED 16		// temporary broken by EMP pulse

//bitflags for door switches.
#define OPEN 1
#define IDSCAN 2
#define BOLTS 4
#define SHOCK 8
#define SAFE 16

#define ENGINE_EJECT_Z 3

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL 50
#define MAX_STACK_AMOUNT_GLASS 50
#define MAX_STACK_AMOUNT_RODS 60

var/const
	GAS_O2 = 1 << 0
	GAS_N2 = 1 << 1
	GAS_PL = 1 << 2
	GAS_CO2 = 1 << 3
	GAS_N2O = 1 << 4


var/list/accessable_z_levels = list("3" = 15, "4" = 35, "6" = 50)
//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//(Exceptions: extended, sandbox and nuke) -Errorage
//Was list("1" = 10, "3" = 15, "4" = 60, "5" = 15); changed it to list("3" = 30, "4" = 70).
//Spacing should be a reliable method of getting rid of a body -- Urist.

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))


var/list/global_mutations = list() // list of hidden mutation things

//Bluh shields


//Damage things
#define BRUTE "brute"
#define BURN "fire"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"
#define HALLOSS "halloss"

#define STUN "stun"
#define WEAKEN "weaken"
#define PARALYZE "paralize"
#define IRRADIATE "irradiate"
#define STUTTER "stutter"
#define SLUR "slur"
#define EYE_BLUR "eye_blur"
#define DROWSY "drowsy"

var/static/list/scarySounds = list('thudswoosh.ogg','Taser.ogg','armbomb.ogg','hiss1.ogg','hiss2.ogg','hiss3.ogg','hiss4.ogg','hiss5.ogg','hiss6.ogg','Glassbr1.ogg','Glassbr2.ogg','Glassbr3.ogg','Welder.ogg','Welder2.ogg','airlock.ogg','clownstep1.ogg','clownstep2.ogg')

//Security levels
#define SEC_LEVEL_GREEN 0
#define SEC_LEVEL_BLUE 1
#define SEC_LEVEL_RED 2
#define SEC_LEVEL_DELTA 3
