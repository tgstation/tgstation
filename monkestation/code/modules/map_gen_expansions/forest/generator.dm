
/datum/map_generator/cave_generator/forest
	buildmode_name = "Forest Generator"
	weighted_open_turf_types = list(/turf/open/misc/asteroid/forest = 1)
	weighted_closed_turf_types = list(/turf/closed/mineral/random/forest = 1)
	flora_spawn_chance = 35
	initial_closed_chance = 53
	birth_limit = 5
	death_limit = 4
	smoothing_iterations = 10

	weighted_mob_spawn_list = list(
		/mob/living/basic/deer/mining = 50,
		/mob/living/basic/mining/megadeer = 15,
		/mob/living/basic/mining/goldgrub = 1,
	)

	weighted_flora_spawn_list = list(
		/obj/structure/flora/ash/fireblossom = 2,
		/obj/structure/flora/grass/jungle/a/style_random = 15,
		/obj/structure/flora/grass/jungle/b/style_random = 30,
		/obj/structure/flora/bush/jungle/a/style_random = 5,
		/obj/structure/flora/bush/jungle/b/style_random = 5,
		/obj/structure/flora/bush/jungle/c/style_random = 5,
		/obj/structure/flora/rock/pile/jungle/style_random = 3,
		/obj/structure/flora/rock/pile/jungle/large/style_random = 1,
		/obj/structure/flora/tree/jungle/style_random = 7,
		/obj/structure/flora/tree/jungle/small/style_random = 3,
	)
	///Note that this spawn list is also in the lavaland generator
	weighted_feature_spawn_list = list(
		/obj/structure/geyser/hollowwater = 10,
		/obj/structure/geyser/plasma_oxide = 10,
		/obj/structure/geyser/protozine = 10,
		/obj/structure/geyser/random = 2,
		/obj/structure/geyser/wittel = 10,
	)
