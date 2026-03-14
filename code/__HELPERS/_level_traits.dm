// Helpers for checking whether a z-level conforms to a specific requirement

// Basic levels
#define is_centcom_level(z) SSmapping.level_trait(z, ZTRAIT_CENTCOM)

GLOBAL_LIST_EMPTY(station_levels_cache)

// Used to prevent z from being re-evaluated
GLOBAL_VAR(station_level_z_scratch)

// Called a lot, somewhat slow, so has its own cache
#define is_station_level(z_level) \
	( \
		(z_level) && ( \
		( \
			/* The right hand side of this guarantees that we'll have the space to fill later on, while also not failing the condition */ \
			(GLOB.station_levels_cache.len < (GLOB.station_level_z_scratch = (z_level)) && (GLOB.station_levels_cache.len = GLOB.station_level_z_scratch)) \
			|| isnull(GLOB.station_levels_cache[GLOB.station_level_z_scratch]) \
		) \
			? (GLOB.station_levels_cache[GLOB.station_level_z_scratch] = !!SSmapping.level_trait(GLOB.station_level_z_scratch, ZTRAIT_STATION)) \
			: GLOB.station_levels_cache[GLOB.station_level_z_scratch] \
		) \
	)

#define is_mining_level(z) SSmapping.level_trait(z, ZTRAIT_MINING)

#define is_reserved_level(z) SSmapping.level_trait(z, ZTRAIT_RESERVED)

#define is_away_level(z) SSmapping.level_trait(z, ZTRAIT_AWAY)

#define is_secret_level(z) SSmapping.level_trait(z, ZTRAIT_SECRET)

#define is_multi_z_level(z) (SSmapping.level_trait(z, ZTRAIT_UP) || SSmapping.level_trait(z, ZTRAIT_DOWN))
