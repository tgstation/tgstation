#define PATHFINDING_QUEUE_MOBS			"mobs"
#define PATHFINDING_QUEUE_DEFAULT		"default"

/// Queue full, try again later.
#define PATHFIND_FAIL_QUEUE_FULL			"QUEUE_FULL"
/// Start turf not specified and caller isn't atom
#define PATHFIND_FAIL_NO_START_TURF			"START_TURF_MISSING"
/// End turf not specified
#define PATHFIND_FAIL_NO_END_TURF			"END_TURF_MISSING"
/// Multiz support isn't in yet
#define PATHFIND_FAIL_MULTIZ				"MULTIZ_NOT_IMPLEMENTED"
/// Too far away according to max_path_distnace
#define PATHFIND_FAIL_TOO_FAR				"TARGET_TOO_FAR"
/// Target is already within minimum distance
#define PATHFIND_FAIL_TOO_CLOSE				"TARGET_TOO_CLOSE"

/// extra weight applied to heuristic to tiebreaks when dealing with multiple equally good paths.
#define PATHFINDING_HEURISTIC_TIEBREAKER_WEIGHT 0.005

/// manhattan distance - cardinal moves only
#define PATHFINDING_HEURISTIC_MANHATTAN				1
/// byond distance - smallest number of alldir moves to get to location
#define PATHFINDING_HEURISTIC_BYOND					2
/// euclidean distance - sqrt(dx^2 + dy^2)
#define PATHFINDING_HEURISTIC_EUCLIDEAN				3
