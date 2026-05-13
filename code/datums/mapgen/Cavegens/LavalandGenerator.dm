/datum/map_generator/cave_generator/lavaland
	weighted_open_turf_types = list(/turf/open/misc/asteroid/basalt/lava_land_surface = 1)
	weighted_closed_turf_types = list(/turf/closed/mineral/random/volcanic = 1)

	possible_biomes = list(
		BIOME_LOW_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland/basalt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/basalt,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland/shale,
			),
		BIOME_MEDIUM_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland/basalt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/basalt,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland/shale,
			),
		BIOME_HIGH_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/lavaland/basalt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/lavaland/red_rock,
			BIOME_HIGH_HUMIDITY = /datum/biome/lavaland/red_rock,
			),
		)

	high_heat_threshold = 0.15
	high_humidity_threshold = 0.15
	biome_stamp_size = 60
	smoothing_iterations = 50

/datum/map_generator/cave_generator/lavaland/ruin_version
	biome_population = FALSE
	weighted_open_turf_types = list(/turf/open/misc/asteroid/basalt/lava_land_surface/no_ruins = 1)
	weighted_closed_turf_types = list(/turf/closed/mineral/volcanic/lava_land_surface/do_not_chasm = 1)
