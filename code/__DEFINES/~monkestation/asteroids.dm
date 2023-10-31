/// Used in asteroid composition lists to indicate a skip
#define SKIP "skip"

// Mining template rarities
#define MINING_NO_RANDOM_SPAWN -1
#define MINING_COMMON 1
#define MINING_UNCOMMON 2
#define MINING_RARE 3

/// YOU MUST USE THIS OVER CHECK_TICK IN ASTEROID GENERATION
#define GENERATOR_CHECK_TICK \
	if(TICK_CHECK) { \
		SSatoms.map_loader_stop(REF(template)); \
		stoplag(); \
		SSatoms.map_loader_begin(REF(template)); \
	}
