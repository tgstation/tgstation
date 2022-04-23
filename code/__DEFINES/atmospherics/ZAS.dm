#define ZASDBG
//#define MULTIZAS

#define AIR_ALLOWED 0
#define AIR_BLOCKED 1
#define ZONE_BLOCKED 2
#define BLOCKED 3

#define ZONE_MIN_SIZE 14 //zones with less than this many turfs will always merge, even if the connection is not direct

#define CANPASS_ALWAYS 1
#define CANPASS_DENSITY 2
#define CANPASS_PROC 3
#define CANPASS_NEVER 4

#define NORTHUP (NORTH|UP)
#define EASTUP (EAST|UP)
#define SOUTHUP (SOUTH|UP)
#define WESTUP (WEST|UP)
#define NORTHDOWN (NORTH|DOWN)
#define EASTDOWN (EAST|DOWN)
#define SOUTHDOWN (SOUTH|DOWN)
#define WESTDOWN (WEST|DOWN)

//#define TURF_HAS_VALID_ZONE(T) (istype(T, /turf/simulated) && T:zone && !T:zone:invalid) ZASTURF

#define TURF_HAS_VALID_ZONE(T) (!istype(T, /turf/open/space) && T:zone && !T:zone:invalid)
#ifdef MULTIZAS

GLOBAL_REAL(list/csrfz_check) = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST, NORTHUP, EASTUP, WESTUP, SOUTHUP, NORTHDOWN, EASTDOWN, WESTDOWN, SOUTHDOWN)
GLOBAL_REAL(list/gzn_check) = list(NORTH, SOUTH, EAST, WEST, UP, DOWN)

#define ATMOS_CANPASS_TURF(ret,A,B) \
	if (A.blocks_air & AIR_BLOCKED || B.blocks_air & AIR_BLOCKED) { \
		ret = BLOCKED; \
	} \
	else if (B.z != A.z) { \
		if (B.z < A.z) { \
			ret = (A.z_flags & ZM_ALLOW_ATMOS) ? ZONE_BLOCKED : BLOCKED; \
		} \
		else { \
			ret = (B.z_flags & ZM_ALLOW_ATMOS) ? ZONE_BLOCKED : BLOCKED; \
		} \
	} \
	else if (A.blocks_air & ZONE_BLOCKED || B.blocks_air & ZONE_BLOCKED) { \
		ret = (A.z == B.z) ? ZONE_BLOCKED : AIR_BLOCKED; \
	} \
	else if (A.contents.len) { \
		ret = 0;\
		for (var/thing in A) { \
			var/atom/movable/AM = thing; \
			switch (AM.can_atmos_pass) { \
				if (CANPASS_ALWAYS) { \
					continue; \
				} \
				if (CANPASS_DENSITY) { \
					if (AM.density) { \
						ret |= AIR_BLOCKED; \
					} \
				} \
				if (CANPASS_PROC) { \
					ret |= AM.c_airblock(B); \
				} \
				if (CANPASS_NEVER) { \
					ret = BLOCKED; \
				} \
			} \
			if (ret == BLOCKED) { \
				break;\
			}\
		}\
	}
#else

GLOBAL_REAL_VAR(list/csrfz_check) = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
GLOBAL_REAL_VAR(list/gzn_check) = list(NORTH, SOUTH, EAST, WEST)

#define ATMOS_CANPASS_TURF(ret,A,B) \
	if (A.blocks_air & AIR_BLOCKED || B.blocks_air & AIR_BLOCKED) { \
		ret = BLOCKED; \
	} \
	else if (A.blocks_air & ZONE_BLOCKED || B.blocks_air & ZONE_BLOCKED) { \
		ret = ZONE_BLOCKED; \
	} \
	else if (A.contents.len) { \
		ret = 0;\
		for (var/thing in A) { \
			var/atom/movable/AM = thing; \
			switch (AM.can_atmos_pass) { \
				if (CANPASS_ALWAYS) { \
					continue; \
				} \
				if (CANPASS_DENSITY) { \
					if (AM.density) { \
						ret |= AIR_BLOCKED; \
					} \
				} \
				if (CANPASS_PROC) { \
					ret |= AM.c_airblock(B); \
				} \
				if (CANPASS_NEVER) { \
					ret = BLOCKED; \
				} \
			} \
			if (ret == BLOCKED) { \
				break;\
			}\
		}\
	}

#endif

//#define ATMOS_CANPASS(A, O) ( A.can_atmos_pass == CANPASS_PROC ? A.c_airblock(O) : ( A.can_atmos_pass == CANPASS_DENSITY? !A.density : A.can_atmos_pass))
#define ATMOS_CANPASS_NOTTURF(A) (A.can_atmos_pass == CANPASS_DENSITY ? !A.density : A.can_atmos_pass)
#define CELL_VOLUME        2500 // Liters in a cell.
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION)) // Moles in a 2.5 m^3 cell at 101.325 kPa and 20 C.

#define O2STANDARD 0.21 // Percentage.
#define N2STANDARD 0.79

#define MOLES_PHORON_VISIBLE 0.7 // Moles in a standard cell after which phoron is visible.
#define MOLES_O2STANDARD     (MOLES_CELLSTANDARD * O2STANDARD) // O2 standard value (21%)
#define MOLES_N2STANDARD     (MOLES_CELLSTANDARD * N2STANDARD) // N2 standard value (79%)
#define MOLES_O2ATMOS (MOLES_O2STANDARD*50)
#define MOLES_N2ATMOS (MOLES_N2STANDARD*50)

// These are for when a mob breathes poisonous air.
#define MIN_TOXIN_DAMAGE 1
#define MAX_TOXIN_DAMAGE 10

#define STD_BREATH_VOLUME      12 // Liters in a normal breath.

#define HUMAN_HEAT_CAPACITY 280000 //J/K For 80kg person

#define SOUND_MINIMUM_PRESSURE 10

#define PRESSURE_DAMAGE_COEFFICIENT 4   // The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE.
#define MAX_HIGH_PRESSURE_DAMAGE 4   // This used to be 20... I got this much random rage for some retarded decision by polymorph?! Polymorph now lies in a pool of blood with a katana jammed in his spleen. ~Errorage --PS: The katana did less than 20 damage to him :(
#define LOW_PRESSURE_DAMAGE 0.6 // The amount of damage someone takes when in a low pressure area. (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define MINIMUM_PRESSURE_DIFFERENCE_TO_SUSPEND (MINIMUM_AIR_TO_SUSPEND*R_IDEAL_GAS_EQUATION*T20C)/CELL_VOLUME			// Minimum pressure difference between zones to suspend
#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.05 // Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_TO_SUSPEND       (MOLES_CELLSTANDARD * MINIMUM_AIR_RATIO_TO_SUSPEND) // Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_MOLES_DELTA_TO_MOVE  (MOLES_CELLSTANDARD * MINIMUM_AIR_RATIO_TO_SUSPEND) // Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE  (T20C + 100)                                        // or this (or both, obviously)

#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND      0.012        // Minimum temperature difference before group processing is suspended.
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND      4
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER     0.5          // Minimum temperature difference before the gas temperatures are just set to be equal.
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION   (T20C + 10)
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION (T20C + 200)

// Must be between 0 and 1. Values closer to 1 equalize temperature faster. Should not exceed 0.4, else strange heat flow occurs.
#define  FLOOR_HEAT_TRANSFER_COEFFICIENT 0.4
#define   WALL_HEAT_TRANSFER_COEFFICIENT 0.0
#define   DOOR_HEAT_TRANSFER_COEFFICIENT 0.0
#define  SPACE_HEAT_TRANSFER_COEFFICIENT 0.2 // A hack to partly simulate radiative heat.
#define   OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.1 // A hack for now.

// Fire damage.
#define CARBON_LIFEFORM_FIRE_RESISTANCE (T0C + 200)
#define CARBON_LIFEFORM_FIRE_DAMAGE     4

// Phoron fire properties.
#define PHORON_MINIMUM_BURN_TEMPERATURE    (T0C +  126) //400 K - autoignite temperature in tanks and canisters - enclosed environments I guess
#define PHORON_FLASHPOINT                  (T0C +  246) //519 K - autoignite temperature in air if that ever gets implemented.

//These control the mole ratio of oxidizer and fuel used in the combustion reaction
#define FIRE_REACTION_OXIDIZER_AMOUNT	3 //should be greater than the fuel amount if fires are going to spread much
#define FIRE_REACTION_FUEL_AMOUNT		2

//These control the speed at which fire burns
#define FIRE_GAS_BURNRATE_MULT			1
#define FIRE_LIQUID_BURNRATE_MULT		0.225

//If the fire is burning slower than this rate then the reaction is going too slow to be self sustaining and the fire burns itself out.
//This ensures that fires don't grind to a near-halt while still remaining active forever.
#define FIRE_GAS_MIN_BURNRATE			0.01
#define FIRE_LIQUD_MIN_BURNRATE			0.0025

//How many moles of fuel are contained within one solid/liquid fuel volume unit
#define LIQUIDFUEL_AMOUNT_TO_MOL		0.45  //mol/volume unit

// XGM gas flags.
#define XGM_GAS_FUEL        1
#define XGM_GAS_OXIDIZER    2
#define XGM_GAS_CONTAMINANT 4
#define XGM_GAS_FUSION_FUEL 8

#define TANK_LEAK_PRESSURE     (30 * ONE_ATMOSPHERE) // Tank starts leaking.
#define TANK_RUPTURE_PRESSURE  (40 * ONE_ATMOSPHERE) // Tank spills all contents into atmosphere.
#define TANK_FRAGMENT_PRESSURE (50 * ONE_ATMOSPHERE) // Boom 3x3 base explosion.
#define TANK_FRAGMENT_SCALE    (10 * ONE_ATMOSPHERE) // +1 for each SCALE kPa above threshold. Was 2 atm.

#define NORMPIPERATE             30   // Pipe-insulation rate divisor.
#define HEATPIPERATE             8    // Heat-exchange pipe insulation.
#define FLOWFRAC                 0.99 // Fraction of gas transfered per process.

//Flags for zone sleeping
#define ZONE_ACTIVE   1
#define ZONE_SLEEPING 0

//OPEN TURF ATMOS
/// the default air mix that open turfs spawn
#define OPENTURF_DEFAULT_ATMOS list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN=MOLES_N2STANDARD)
#define OPENTURF_LOW_PRESSURE list(GAS_OXYGEN = 14, GAS_NITROGEB = 30)
//#define OPENTURF_LOW_PRESSURE "o2=14;n2=30;TEMP=293.15"
/// -193,15°C telecommunications. also used for xenobiology slime killrooms
#define TCOMMS_ATMOS list(GAS_NITROGEN = 100)
//#define TCOMMS_ATMOS "n2=100;TEMP=80"
/// space
#define AIRLESS_ATMOS list()
/// -93.15°C snow and ice turfs
//#define FROZEN_ATMOS "o2=22;n2=82;TEMP=180"
/// -14°C kitchen coldroom, just might loss your tail; higher amount of mol to reach about 101.3 kpA
//#define KITCHEN_COLDROOM_ATMOS "o2=26;n2=97;TEMP=[COLD_ROOM_TEMP]"

// Defines how much of certain gas do the Atmospherics tanks start with. Values are in kpa per tile (assuming 20C)
#define ATMOSTANK_NITROGEN      list(GAS_NITROGEN = 90000) // A lot of N2 is needed to produce air mix, that's why we keep 90MPa of it
#define ATMOSTANK_OXYGEN        list(GAS_OXYGEN = 50000) // O2 is also important for airmix, but not as much as N2 as it's only 21% of it.
#define ATMOSTANK_CO2           list(GAS_CO2 = 60000) // CO2 is used for the GUP, Charon, and Torch as the primary fuel propellant, and we need lots to stick around.
#define ATMOSTANK_PLASMA        list(GAS_PHORON = 25000)
#define ATMOSTANK_PLASMA_FUEL	list(GAS_PHORON = 15000)
#define ATMOSTANK_HYDROGEN      list(GAS_HYDROGEN = 50000)
#define ATMOSTANK_HYDROGEN_FUEL list(GAS_HYDROGEN = 25000)
#define ATMOSTANK_NITROUSOXIDE  list(GAS_N2O = 10000) // N2O doesn't have a real useful use, i guess it's on station just to allow refilling of sec's riot control canisters?
#define ATMOSTANK_AIRMIX		list(GAS_OXYGEN = 2644, GAS_NITROGEN = 10580)

#define MAX_PUMP_PRESSURE		15000	// Maximal pressure setting for pumps and vents
#define MAX_OMNI_PRESSURE		15000	// Maximal output(s) pressure for omni devices (filters/mixers)

#define GAS_OXYGEN				"oxygen"
#define GAS_CO2					"carbon_dioxide"
#define GAS_CO					"carbon_monoxide"
#define GAS_METHYL_BROMIDE		"methyl_bromide"
#define GAS_N2O					"sleeping_agent"
#define GAS_NITROGEN			"nitrogen"
#define GAS_NO2					"nitrodioxide"
#define GAS_NO					"nitricoxide"
#define GAS_METHANE				"methane"
#define GAS_ALIEN				"aliether"
#define GAS_HYDROGEN			"hydrogen"
#define GAS_DEUTERIUM			"deuterium"
#define GAS_TRITIUM				"tritium"
#define GAS_HELIUM				"helium"
#define GAS_ARGON				"argon"
#define GAS_KRYPTON				"krypton"
#define GAS_NEON				"neon"
#define GAS_XENON				"xenon"
#define GAS_AMMONIA				"ammonia"
#define GAS_CHLORINE			"chlorine"
#define GAS_SULFUR				"sulfurdioxide"
#define GAS_STEAM				"water"
#define GAS_PLASMA				"phoron"

GLOBAL_LIST_INIT(all_gases, list(GAS_OXYGEN, GAS_CO2, GAS_CO, GAS_METHYL_BROMIDE, GAS_N2O, GAS_NITROGEN, GAS_NO, GAS_METHANE, GAS_ALIEN, GAS_HYDROGEN, GAS_DEUTERIUM, GAS_TRITIUM, GAS_HELIUM, GAS_ARGON, GAS_KRYPTON, GAS_NEON, GAS_XENON, GAS_AMMONIA, GAS_CHLORINE, GAS_SULFUR, GAS_STEAM, GAS_PLASMA))
GLOBAL_LIST_INIT(common_gases, list(GAS_OXYGEN, GAS_CO2, GAS_N2O, GAS_PLASMA, GAS_NITROGEN))

GLOBAL_LIST_INIT(reverse_dir, list( // reverse_dir[dir] = reverse of dir
	     2,  1,  3,  8, 10,  9, 11,  4,  6,  5,  7, 12, 14, 13, 15,
	32, 34, 33, 35, 40, 42,	41, 43, 36, 38, 37, 39, 44, 46, 45, 47,
	16, 18, 17, 19, 24, 26, 25, 27, 20, 22, 21,	23, 28, 30, 29, 31,
	48, 50, 49, 51, 56, 58, 57, 59, 52, 54, 53, 55, 60, 62, 61, 63
))

// The flow rate/effectiveness of various atmos devices is limited by their internal volume,
// so for many atmos devices these will control maximum flow rates in L/s.
#define ATMOS_DEFAULT_VOLUME_PUMP   200 // Liters.
#define ATMOS_DEFAULT_VOLUME_FILTER 500 // L.
#define ATMOS_DEFAULT_VOLUME_MIXER  500 // L.
#define ATMOS_DEFAULT_VOLUME_PIPE   70  // L.
