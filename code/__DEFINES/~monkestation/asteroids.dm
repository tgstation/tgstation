/// Used in asteroid composition lists to indicate a skip
#define SKIP "skip"

#define islevelbaseturf(A) istype(A, SSmapping.level_trait(A.z, ZTRAIT_BASETURF) || /turf/open/space)

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

// error codes for the asteroid magnet
#define MAGNET_ERROR_KEY_BUSY 1
#define MAGNET_ERROR_KEY_USED_COORD 2
#define MAGNET_ERROR_KEY_COOLDOWN 3
#define MAGNET_ERROR_KEY_MOB 4
#define MAGNET_ERROR_KEY_NO_COORD 5
