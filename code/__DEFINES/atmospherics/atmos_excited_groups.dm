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
/// Minimum amount of air that has to move before a group processing can be suspended (Round about 10)
#define MINIMUM_AIR_TO_SUSPEND (MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND)
/// Either this must be active (round about 0.1) //Might need to raise this a tad to better support space leaks. we'll see
#define MINIMUM_MOLES_DELTA_TO_MOVE (MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_MOVE)
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
