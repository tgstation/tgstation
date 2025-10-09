/datum/map_generator/cave_generator/lavaland
	weighted_open_turf_types = list(/turf/open/misc/asteroid/basalt/lava_land_surface = 1)
	weighted_closed_turf_types = list(/turf/closed/mineral/random/volcanic = 1)

	weighted_mob_spawn_list = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 50,
		/obj/effect/spawner/random/lavaland_mob/legion = 30,
		/obj/effect/spawner/random/lavaland_mob/watcher = 40,
		/mob/living/basic/mining/bileworm = 20,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/mining/lobstrosity/lava = 20,
		/obj/effect/spawner/random/lavaland_mob/raptor = 15,
		/mob/living/basic/mining/goldgrub = 10,
		/obj/structure/spawner/lavaland = 2,
		/obj/structure/spawner/lavaland/goliath = 3,
		/obj/structure/spawner/lavaland/legion = 3,
	)

	weighted_flora_spawn_list = list(
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/fireblossom = 2,
		/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/seraka = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/tall_shroom = 2,
	)

	///Note that this spawn list is also in the icemoon generator
	weighted_feature_spawn_list = list(
		/obj/structure/geyser/hollowwater = 8,
		/obj/structure/geyser/plasma_oxide = 8,
		/obj/structure/geyser/protozine = 8,
		/obj/structure/geyser/random = 2,
		/obj/structure/geyser/wittel = 8,
		/obj/structure/geyser/chiral_buffer = 8,
		/obj/structure/ore_vent/boss = 1,
	)

	initial_closed_chance = 45
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3

/datum/map_generator/cave_generator/lavaland/ruin_version
	weighted_open_turf_types = list(/turf/open/misc/asteroid/basalt/lava_land_surface/no_ruins = 1)
	weighted_closed_turf_types = list(/turf/closed/mineral/volcanic/lava_land_surface/do_not_chasm = 1)
