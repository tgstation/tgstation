/datum/map_generator/cave_generator/rainworld
	weighted_open_turf_types = list(/turf/open/water/no_planet_atmos/deep/rainworld = 100)
	weighted_closed_turf_types = list(
		/turf/closed/mineral/random/rainworld = 1,
	)

	weighted_flora_spawn_list = list(
		/obj/structure/flora/bush/reed/style_random = 8,
		/obj/structure/flora/bush/leavy/style_random = 4,
		/obj/structure/flora/rock/icy/style_random = 1,
		/obj/structure/flora/rock/pile/icy/style_random = 4,
		/obj/structure/flora/bush/sparsegrass/style_random = 24,
		/obj/structure/flora/ash/seraka = 6,
	)

	///Note that this spawn list is also in the lavaland generator
	weighted_feature_spawn_list = list(
		/obj/structure/geyser/hollowwater = 10,
		/obj/structure/geyser/plasma_oxide = 10,
		/obj/structure/geyser/protozine = 10,
		/obj/structure/geyser/random = 2,
		/obj/structure/geyser/wittel = 10,
		/obj/structure/ore_vent/random/water = 10,
	)

/datum/map_generator/cave_generator/rainworld/surface
	flora_spawn_chance = 3
	mob_spawn_chance = 4
	feature_spawn_chance = 0.2
	initial_closed_chance = 50
	birth_limit = 6
	death_limit = 4
	smoothing_iterations = 10
	weighted_mob_spawn_list = list(
		/mob/living/basic/mining/lobstrosity = 25,
		/mob/living/basic/mining/hivelord = 10,
		/mob/living/basic/mining/basilisk = 20,
		/mob/living/basic/lightgeist = 5,
		/mob/living/basic/turtle = 1,
		/mob/living/basic/frog = 1,
		/mob/living/basic/axolotl = 1,
	)

/datum/map_generator/cave_generator/rainworld/surface/mining
	mob_spawn_chance = 6
	weighted_mob_spawn_list = list(
		SPAWN_MEGAFAUNA = 1,
		/mob/living/basic/mining/lobstrosity = 100,
		/mob/living/basic/mining/hivelord = 60,
		/mob/living/basic/mining/basilisk = 80,
		/mob/living/basic/lightgeist = 10,

		/obj/structure/spawner/ice_moon/demonic_portal/lobstrocity = 4,
		/obj/structure/spawner/ice_moon/demonic_portal/hivelord = 4,
		/obj/structure/spawner/ice_moon/demonic_portal/basilisk = 4,
	)
	weighted_megafauna_spawn_list = list(/mob/living/simple_animal/hostile/megafauna/serpent = 25, /mob/living/simple_animal/hostile/megafauna/colossus = 5, /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner = 1)

/datum/map_generator/cave_generator/rainworld/surface/noruins //use this for when you don't want ruins to spawn in a certain area
