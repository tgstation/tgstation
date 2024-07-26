
// Hiding AI blackboard keys

/// Whether or not the mob is currently hiding.
#define BB_HIDING_HIDDEN "BB_hiding_hidden"
/// The typecache (populated on `Initialize()` with the first argument of
/// `/datum/element/can_hide/basic/New()`) of turfs that our mob can hide onto.
#define BB_HIDING_CAN_HIDE_ON "BB_hiding_can_hide_on"
/// The aggro range the mob has when hiding.
#define BB_HIDING_AGGRO_RANGE "BB_hiding_aggro_range"
/// The aggro range the mob has when NOT hiding (set dynamically).
#define BB_HIDING_AGGRO_RANGE_NOT_HIDING "BB_hiding_aggro_range_not_hiding"
/// The cooldown before the mob can hide again (set dynamically).
#define BB_HIDING_COOLDOWN_BEFORE_HIDING "BB_hiding_cooldown_before_hiding"
/// The cooldown before the mob can stop hiding (set dynamically).
#define BB_HIDING_COOLDOWN_BEFORE_STOP_HIDING "BB_hiding_cooldown_before_stop_hiding"
/// The minimum value for the cooldown before the mob can hide / come out of hiding again.
#define BB_HIDING_COOLDOWN_MINIMUM "BB_hiding_cooldown_minimum"
/// The maximum value for the cooldown before the mob can hide / come out of hiding again.
#define BB_HIDING_COOLDOWN_MAXIMUM "BB_hiding_cooldown_maximum"
/// The probability (in %) that the mob will stop hiding randomly every process.
#define BB_HIDING_RANDOM_STOP_HIDING_CHANCE "BB_hiding_random_stop_hiding_chance"

/// The default vision range when hiding, if none is specified.
#define DEFAULT_HIDING_AGGRO_RANGE 2
/// The default chance to get out of hiding for every random hiding subtree process.
#define DEFAULT_RANDOM_STOP_HIDING_CHANCE 2

#define BB_TEMPORARY_TARGET "BB_targetting_temporary"
