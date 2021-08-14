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
///Max amount of radiation that can be emitted per reaction cycle
#define FUSION_RAD_MAX 5000
///Maximum instability before the reaction goes endothermic
#define FUSION_INSTABILITY_ENDOTHERMALITY 4
///Maximum reachable fusion temperature
#define FUSION_MAXIMUM_TEMPERATURE 1e8
