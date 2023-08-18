/datum/planet/jungle
	biomes = list(
		//NORMAL BIOMES
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle_wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle_wasteland,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/mudlands
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle_wasteland,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_HIGH_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/mudlands
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGH_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/mudlands,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle/water,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/water,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/mudlands
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/plains,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/dense
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/jungle/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/mudlands,
			BIOME_HIGH_HUMIDITY = /datum/biome/jungle/water,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/jungle/water
		),
		//CAVE BIOMES
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle/dirt
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/jungle
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/jungle,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/jungle/dirt,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/lush/bright,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/lush/bright
		)
	)
