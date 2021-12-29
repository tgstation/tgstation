//LISTMOS
//indices of values in gas lists.
///Amount of total moles in said gas mixture
#define MOLES 1
///Archived version of MOLES
#define ARCHIVE 2
///All gas related variables
#define GAS_META 3
///Gas specific heat per mole
#define META_GAS_SPECIFIC_HEAT 1
///Name of the gas
#define META_GAS_NAME 2
///Amount of moles required of the gas to be visible
#define META_GAS_MOLES_VISIBLE 3
///Overlay path of the gas, also setup the alpha based on the amount
#define META_GAS_OVERLAY 4
///Let the air alarm know if the gas is dangerous
#define META_GAS_DANGER 5
///Id of the gas for quick access
#define META_GAS_ID 6
///Power of the gas when used in the current iteration of fusion
#define META_GAS_FUSION_POWER 7
//ATMOS
//stuff you should probably leave well alone!
/// kPa*L/(K*mol)
#define R_IDEAL_GAS_EQUATION 8.31
/// kPa
#define ONE_ATMOSPHERE 101.325
/// -270.3degC
#define TCMB 2.7
/// -48.15degC
#define TCRYO 225
/// 0degC
#define T0C 273.15
/// 20degC
#define T20C 293.15
/// -14C - Temperature used for kitchen cold room, medical freezer, etc.
#define COLD_ROOM_TEMP 259.15

/**
 *I feel the need to document what happens here. Basically this is used
 *catch rounding errors, and make gas go away in small portions.
 *People have raised it to higher levels in the past, do not do this. Consider this number a soft limit
 *If you're making gasmixtures that have unexpected behavior related to this value, you're doing something wrong.
 *
 *On an unrelated note this may cause a bug that creates negative gas, related to round(). When it has a second arg it will round up.
 *So for instance round(0.5, 1) == 1. I've hardcoded a fix for this into share, by forcing the garbage collect.
 *Any other attempts to fix it just killed atmos. I leave this to a greater man then I
 */
/// The minimum heat capacity of a gas
#define MINIMUM_HEAT_CAPACITY 0.0003
/// Minimum mole count of a gas
#define MINIMUM_MOLE_COUNT 0.01
/// Molar accuracy to round to
#define MOLAR_ACCURACY  1E-4
/// Types of gases (based on gaslist_cache)
#define GAS_TYPE_COUNT GLOB.gaslist_cache.len
/// Maximum error caused by QUANTIZE when removing gas (roughly, in reality around 2 * MOLAR_ACCURACY less)
#define MAXIMUM_ERROR_GAS_REMOVAL (MOLAR_ACCURACY * GAS_TYPE_COUNT)

/// Moles in a standard cell after which gases are visible
#define MOLES_GAS_VISIBLE 0.25

/// moles_visible * FACTOR_GAS_VISIBLE_MAX = Moles after which gas is at maximum visibility
#define FACTOR_GAS_VISIBLE_MAX 20
/// Mole step for alpha updates. This means alpha can update at 0.25, 0.5, 0.75 and so on
#define MOLES_GAS_VISIBLE_STEP 0.25
/// The total visible states
#define TOTAL_VISIBLE_STATES (FACTOR_GAS_VISIBLE_MAX * (1 / MOLES_GAS_VISIBLE_STEP))

//REACTIONS
//return values for reactions (bitflags)
///The gas mixture is not reacting
#define NO_REACTION 0
///The gas mixture is reacting
#define REACTING 1
///The gas mixture is able to stop all reactions
#define STOP_REACTIONS 2

//Fusion
///Maximum instability before the reaction goes endothermic
#define FUSION_INSTABILITY_ENDOTHERMALITY 4
///Maximum reachable fusion temperature
#define FUSION_MAXIMUM_TEMPERATURE 1e8


//EXCITED GROUPS
/**
 * Some further context on breakdown. Unlike dismantle, the breakdown ticker doesn't reset itself when a tile is added
 * This is because we cannot expect maps to have small spaces, so we need to even ourselves out often
 * We do this to avoid equalizing a large space in one tick, with some significant amount of say heat diff
 * This way large areas don't suddenly all become cold at once, it acts more like a wave
 *
 * Because of this and the behavior of share(), the breakdown cycles value can be tweaked directly to effect how fast we want gas to move
 */
/// number of FULL air controller ticks before an excited group breaks down (averages gas contents across turfs)
#define EXCITED_GROUP_BREAKDOWN_CYCLES 5
/// number of FULL air controller ticks before an excited group dismantles and removes its turfs from active
#define EXCITED_GROUP_DISMANTLE_CYCLES (EXCITED_GROUP_BREAKDOWN_CYCLES * 2) + 1 //Reset after 2 breakdowns
/// Ratio of air that must move to/from a tile to reset group processing
#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.1
/// Minimum ratio of air that must move to/from a tile
#define MINIMUM_AIR_RATIO_TO_MOVE 0.001
/// Minimum amount of moles that has to move before a whole-group processing gets delayed (its about 10)
#define MINIMUM_AIR_TO_SUSPEND (MOLES_CELLSTANDARD * MINIMUM_AIR_RATIO_TO_SUSPEND)
/// Either this must be active (its about 0.1) //Might need to raise this a tad to better support space leaks. we'll see
#define MINIMUM_MOLES_DELTA_TO_MOVE (MOLES_CELLSTANDARD * MINIMUM_AIR_RATIO_TO_MOVE)
/// or this (or both, obviously)
#define MINIMUM_TEMPERATURE_TO_MOVE (T20C+100)
/// Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4
/// Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5
///Minimum temperature to continue superconduction once started
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION (T20C+80)
///Minimum temperature to start doing superconduction calculations
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION (T20C+400)

//HEAT TRANSFER COEFFICIENTS
//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Should not exceed 0.4 else strange heat flow occur
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.0
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
/// a hack for now
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.1
/// a hack to help make vacuums "cold", sacrificing realism for gameplay
#define HEAT_CAPACITY_VACUUM 7000

//FIRE
///Minimum temperature for fire to move to the next turf (150 °C or 433 K)
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD (150+T0C)
///Minimum temperature for fire to exist on a turf (100 °C or 373 K)
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST (100+T0C)
///Multiplier for the temperature shared to other turfs
#define FIRE_SPREAD_RADIOSITY_SCALE 0.85
///Helper for small fires to grow
#define FIRE_GROWTH_RATE 40000
///Minimum temperature to burn plasma
#define PLASMA_MINIMUM_BURN_TEMPERATURE (100+T0C)
///Upper temperature ceiling for plasmafire reaction calculations for fuel consumption
#define PLASMA_UPPER_TEMPERATURE (1370+T0C)
///Multiplier for plasmafire with O2 moles * PLASMA_OXYGEN_FULLBURN for the maximum fuel consumption
#define PLASMA_OXYGEN_FULLBURN 10
///Minimum temperature to burn hydrogen
#define HYDROGEN_MINIMUM_BURN_TEMPERATURE (100+T0C)
///Upper temperature ceiling for h2fire reaction calculations for fuel consumption
#define HYDROGEN_UPPER_TEMPERATURE (1370+T0C)
///Multiplier for h2fire with O2 moles * HYDROGEN_OXYGEN_FULLBURN for the maximum fuel consumption
#define HYDROGEN_OXYGEN_FULLBURN 10

//COLD FIRE (this is used only for the freon-o2 reaction, there is no fire still)
///fire will spread if the temperature is -10 °C
#define COLD_FIRE_MAXIMUM_TEMPERATURE_TO_SPREAD 263
///fire will start if the temperature is 0 °C
#define COLD_FIRE_MAXIMUM_TEMPERATURE_TO_EXIST 273
#define COLD_FIRE_SPREAD_RADIOSITY_SCALE 0.95 //Not yet implemented
#define COLD_FIRE_GROWTH_RATE 40000 //Not yet implemented
///Maximum temperature to burn freon
#define FREON_MAXIMUM_BURN_TEMPERATURE 283
///Minimum temperature allowed for the burn to go, we would have negative pressure otherwise
#define FREON_LOWER_TEMPERATURE 60
///Multiplier for freonfire with O2 moles * FREON_OXYGEN_FULLBURN for the maximum fuel consumption
#define FREON_OXYGEN_FULLBURN 10

///moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC (103 or so)
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE * CELL_VOLUME / (T20C * R_IDEAL_GAS_EQUATION))
///compared against for superconductivity
#define M_CELL_WITH_RATIO (MOLES_CELLSTANDARD * 0.005)
/// percentage of oxygen in a normal mixture of air
#define O2STANDARD 0.21
/// same but for nitrogen
#define N2STANDARD 0.79
/// O2 standard value (21%)
#define MOLES_O2STANDARD (MOLES_CELLSTANDARD * O2STANDARD)
/// N2 standard value (79%)
#define MOLES_N2STANDARD (MOLES_CELLSTANDARD * N2STANDARD)
/// liters in a cell
#define CELL_VOLUME 2500

//CANATMOSPASS
#define ATMOS_PASS_YES 1
#define ATMOS_PASS_NO 0
/// ask can_atmos_pass()
#define ATMOS_PASS_PROC -1
/// just check density
#define ATMOS_PASS_DENSITY -2

//Adjacent turf related defines, they dictate what to do with a turf once it's been recalculated
//Used as "state" in CALCULATE_ADJACENT_TURFS
///Normal non-active turf
#define NORMAL_TURF 1
///Set the turf to be activated on the next calculation
#define MAKE_ACTIVE 2
///Disable excited group
#define KILL_EXCITED 3
