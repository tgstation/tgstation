#define PATHFINDING_QUEUE_MOBS			"mobs"
#define PATHFINDING_QUEUE_DEFAULT		"default"

#define PATHFIND_FAIL_QUEUE_FULL			"QUEUE_FULL"
#define PATHFIND_FAIL_NO_START_TURF			"START_TURF_MISSING"
#define PATHFIND_FAIL_NO_END_TURF			"END_TURF_MISSING"

/// extra weight applied to heuristic to tiebreaks when dealing with multiple equally good paths.
#define PATHFINDING_HEURISTIC_TIEBREAKING_WEIGHT 0.005

/// manhattan distance - cardinal moves only
#define PATHFINDING_HEURISTIC_MANHATTAN				1
/// byond distance - smallest number of alldir moves to get to location
#define PATHFINDING_HEURISTIC_BYOND					2
/// euclidean distance - sqrt(dx^2 + dy^2)
#define PATHFINDING_HEURISTIC_EUCLIDEAN				3
