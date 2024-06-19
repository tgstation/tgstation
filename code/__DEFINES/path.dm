// Define set that decides how an atom will be scanned for astar things
/// If set, we make the assumption that CanAStarPass() will NEVER return FALSE unless density is true
#define CANASTARPASS_DENSITY 0
/// If this is set, we bypass density checks and always call the proc
#define CANASTARPASS_ALWAYS_PROC 1

/**
 * A helper macro to see if it's possible to step from the first turf into the second one, minding things like door access and directional windows.
 * If you really want to optimize things, optimize this, cuz this gets called a lot.
 * We do early next.density check despite it being already checked in LinkBlockedWithAccess for short-circuit performance
 */
#define CAN_STEP(cur_turf, next, simulated_only, pass_info, avoid) (next && !next.density && !(simulated_only && SSpathfinder.space_type_cache[next.type]) && !cur_turf.LinkBlockedWithAccess(next, pass_info) && (next != avoid))

#define DIAGONAL_DO_NOTHING NONE
#define DIAGONAL_REMOVE_ALL 1
#define DIAGONAL_REMOVE_CLUNKY 2

// Set of delays for path_map reuse
// The longer you go, the higher the risk of invalid paths
#define MAP_REUSE_INSTANT (0)
#define MAP_REUSE_SNAPPY (0.5 SECONDS)
#define MAP_REUSE_FAST (2 SECONDS)
#define MAP_REUSE_SLOW (20 SECONDS)
// Longest delay, so any maps older then this will be discarded from the subsystem cache
#define MAP_REUSE_SLOWEST (60 SECONDS)
