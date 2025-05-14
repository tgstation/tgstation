/datum/map_generator/cave_generator/rainworld
	weighted_open_turf_types = list(/turf/open/water/no_planet_atmos/deep = 59, /turf/open/misc/asteroid/rainworld = 1)
	weighted_closed_turf_types = list(
		/turf/closed/mineral/random/snow/wet = 100,
	)

	weighted_mob_spawn_list = list(
		/mob/living/basic/mining/lobstrosity = 15,
	)

	weighted_flora_spawn_list = list(
		/obj/structure/flora/bush/reed/style_random = 2,
		/obj/structure/flora/bush/leavy/style_random = 2,
		/obj/structure/flora/rock/icy/style_random = 2,
		/obj/structure/flora/rock/pile/icy/style_random = 2,
		/obj/structure/flora/bush/sparsegrass/style_random = 8,
	)

	///Note that this spawn list is also in the lavaland generator
	weighted_feature_spawn_list = list(
		/obj/structure/geyser/hollowwater = 10,
		/obj/structure/geyser/plasma_oxide = 10,
		/obj/structure/geyser/protozine = 10,
		/obj/structure/geyser/random = 2,
		/obj/structure/geyser/wittel = 10,
		/obj/structure/ore_vent/boss/icebox = 1,
	)

/datum/map_generator/cave_generator/rainworld/surface
	flora_spawn_chance = 4
	weighted_mob_spawn_list = null
	initial_closed_chance = 53
	birth_limit = 5
	death_limit = 4
	smoothing_iterations = 10
	weighted_feature_spawn_list = list(
		/obj/structure/geyser/hollowwater = 10,
		/obj/structure/geyser/plasma_oxide = 10,
		/obj/structure/geyser/protozine = 10,
		/obj/structure/geyser/random = 2,
		/obj/structure/geyser/wittel = 10,
	)

/datum/map_generator/cave_generator/rainworld/surface/noruins //use this for when you don't want ruins to spawn in a certain area
