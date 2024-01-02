/datum/planet
	var/list/biomes = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/ocean,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/ocean/deep
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/ocean,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/ocean/deep
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/grass/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/ocean,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/ocean/deep
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/beach/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/beach
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/grass/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/ocean,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/ocean/deep
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/grass,
			BIOME_LOW_HUMIDITY = /datum/biome/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/ocean,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/ocean/deep
		),
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach/cove,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach/magical,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach/magical,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach/cove
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach/magical,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/beach,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/beach,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/beach,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/beach/cove,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/beach
		)
	)
