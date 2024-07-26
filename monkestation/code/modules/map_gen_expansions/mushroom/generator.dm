
/datum/map_generator/cave_generator/forest/mushroom
	name = "Mushroom Cave Biome Generator"
	buildmode_name = "Mushroom Cave Biome Generator"
	weighted_open_turf_types = list(/turf/open/misc/dirt/forest = 2, /turf/open/misc/asteroid/forest/mushroom = 3)
	weighted_closed_turf_types = list(/turf/closed/mineral/random/forest = 1)
	initial_closed_chance = 53
	birth_limit = 5
	death_limit = 4
	smoothing_iterations = 10

	mob_spawn_chance = 0.25 //planning to increase this once we have custom mushroom mobs to increase diversity
	flora_spawn_chance = 25

	biome_accepted_turfs = list(
		/turf/open/misc/asteroid/forest/mushroom = TRUE,
	)
	possible_biomes = list(
		BIOME_LOW_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/mushroom_cave/blue,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/mushroom_cave,
			BIOME_HIGH_HUMIDITY = /datum/biome/mushroom_cave/green,
		),
		BIOME_MEDIUM_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/mushroom_cave/green,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/mushroom_cave/blue,
			BIOME_HIGH_HUMIDITY = /datum/biome/mushroom_cave,
		),
		BIOME_HIGH_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/mushroom_cave,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/mushroom_cave/green,
			BIOME_HIGH_HUMIDITY = /datum/biome/mushroom_cave/blue,
		)
	)

	weighted_mob_spawn_list = list(
		/obj/effect/spawner/random/lavaland_mob/goliath = 1,
	)
	weighted_flora_spawn_list = list(
		/obj/structure/flora/tree/mushroom = 4,
		/obj/structure/flora/tree/mushroom/reverse = 4,
		/obj/structure/flora/ash/lightshroom = 2,
		/obj/structure/flora/mushroom = 2,
		/obj/structure/flora/ash/cap_shroom/colored = 1,
		/obj/structure/flora/ash/leaf_shroom/colored = 1,
		/obj/structure/flora/ash/stem_shroom/colored = 1,
		/obj/structure/flora/ash/tall_shroom/colored = 1,
	)

/datum/biome/mushroom_cave
	turf_type = /turf/open/misc/asteroid/forest/mushroom
	flora_density = 25
	feature_density = 0.25
	fauna_density = 1
	flora_types = list(
		/obj/structure/flora/tree/mushroom = 4,
		/obj/structure/flora/tree/mushroom/reverse = 4,
		/obj/structure/flora/ash/lightshroom = 2,
		/obj/structure/flora/mushroom = 2,
		/obj/structure/flora/ash/cap_shroom/colored = 1,
		/obj/structure/flora/ash/leaf_shroom/colored = 1,
		/obj/structure/flora/ash/stem_shroom/colored = 1,
		/obj/structure/flora/ash/tall_shroom/colored = 1,
	)
	fauna_types = list(
		/mob/living/basic/mining/stillcap = 3,
	)
	feature_types = list(
		/obj/structure/geyser/hollowwater = 10,
		/obj/structure/geyser/plasma_oxide = 10,
		/obj/structure/geyser/protozine = 10,
		/obj/structure/geyser/random = 2,
		/obj/structure/geyser/wittel = 10,
	)

/datum/biome/mushroom_cave/blue
	turf_type = /turf/open/misc/asteroid/forest/mushroom/blue
	flora_density = 25
	feature_density = 0.25
	fauna_types = list(
		/mob/living/basic/mining/stillcap/blue = 3,
	)
	flora_types = list(
		/obj/structure/flora/tree/mushroom/blue = 4,
		/obj/structure/flora/tree/mushroom/blue/reverse = 4,
		/obj/structure/flora/ash/lightshroom/blue = 2,
		/obj/structure/flora/mushroom/blue = 2,
		/obj/structure/flora/ash/cap_shroom/colored/blue = 1,
		/obj/structure/flora/ash/leaf_shroom/colored/blue = 1,
		/obj/structure/flora/ash/stem_shroom/colored/blue = 1,
		/obj/structure/flora/ash/tall_shroom/colored/blue = 1,
	)

/datum/biome/mushroom_cave/green
	turf_type = /turf/open/misc/asteroid/forest/mushroom/green
	flora_density = 25
	feature_density = 0.25
	fauna_types = list(
		/mob/living/basic/mining/stillcap/green = 3,
	)
	flora_types = list(
		/obj/structure/flora/tree/mushroom/green = 4,
		/obj/structure/flora/tree/mushroom/green/reverse = 4,
		/obj/structure/flora/ash/lightshroom/green = 2,
		/obj/structure/flora/mushroom/green = 2,
		/obj/structure/flora/ash/cap_shroom/colored/green = 1,
		/obj/structure/flora/ash/leaf_shroom/colored/green = 1,
		/obj/structure/flora/ash/stem_shroom/colored/green = 1,
		/obj/structure/flora/ash/tall_shroom/colored/green = 1,
	)
