/datum/map_generator/cave_generator/icemoon
	weighted_open_turf_types = list(/turf/open/misc/asteroid/snow/icemoon = 19, /turf/open/misc/ice/icemoon = 1)
	weighted_closed_turf_types = list(
		/turf/closed/mineral/random/snow = 100,
		/turf/closed/mineral/gibtonite/ice/icemoon = 4,
	)

	weighted_mob_spawn_list = list(
		/mob/living/basic/mining/goldgrub = 10,
		/mob/living/basic/mining/legion/snow = 50,
		/mob/living/basic/mining/lobstrosity = 15,
		/mob/living/basic/mining/wolf = 50,
		/obj/effect/spawner/random/lavaland_mob/raptor = 15,
		/mob/living/simple_animal/hostile/asteroid/polarbear = 30,
		/obj/structure/spawner/ice_moon = 3,
		/obj/structure/spawner/ice_moon/polarbear = 3,
	)

	weighted_flora_spawn_list = list(
		/obj/structure/flora/ash/chilly = 2,
		/obj/structure/flora/grass/both/style_random = 6,
		/obj/structure/flora/rock/icy/style_random = 2,
		/obj/structure/flora/rock/pile/icy/style_random = 2,
		/obj/structure/flora/tree/pine/style_random = 2,
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

/datum/map_generator/cave_generator/icemoon/surface
	weighted_open_turf_types = list(/turf/open/misc/asteroid/snow/icemoon = 1)
	flora_spawn_chance = 60
	weighted_mob_spawn_list = null
	initial_closed_chance = 0
	birth_limit = 5
	death_limit = 4
	smoothing_iterations = 10

	feature_spawn_chance = 0.15
	weighted_feature_spawn_list = list(
		/obj/structure/geyser/hollowwater = 10,
		/obj/structure/geyser/plasma_oxide = 10,
		/obj/structure/geyser/protozine = 10,
		/obj/structure/geyser/random = 2,
		/obj/structure/geyser/wittel = 10,
	)

	weighted_flora_spawn_list = list(
		/obj/structure/flora/ash/chilly = 2,
		/obj/structure/flora/grass/both/style_random = 20,
		/obj/structure/flora/tree/pine/style_random = 2,
	)

/// Surface snow generator variant for forested station trait, WITH FORESTSSSS
/datum/map_generator/cave_generator/icemoon/surface/forested
	initial_closed_chance = 10

	flora_spawn_chance = 80
	weighted_flora_spawn_list = list(
		/obj/structure/flora/tree/pine/style_random = 18,
		/obj/structure/flora/tree/dead/style_random = 1,
		/obj/structure/flora/tree/stump = 1,
		/obj/structure/flora/rock/icy/style_random = 1,
		/obj/structure/flora/rock/pile/icy/style_random = 3,
		/obj/structure/flora/grass/both/style_random = 50,
		/obj/structure/flora/bush/flowers_pp/style_random = 25,
		/obj/structure/flora/ash/chilly = 1,
	)

	mob_spawn_chance = 0.2
	weighted_mob_spawn_list = list(/mob/living/basic/deer/ice = 99, /mob/living/basic/tree = 1, /obj/effect/spawner/random/lavaland_mob/raptor = 15)

/datum/map_generator/cave_generator/icemoon/surface/rocky
	initial_closed_chance = 53
	mob_spawn_chance = 0.5

/datum/map_generator/cave_generator/icemoon/surface/noruins //use this for when you don't want ruins to spawn in a certain area

/datum/map_generator/cave_generator/icemoon/deep
	weighted_closed_turf_types = list(/turf/closed/mineral/random/snow = 1)
	weighted_mob_spawn_list = list(
		SPAWN_MEGAFAUNA = 1,
		/mob/living/basic/mining/ice_demon = 100,
		/mob/living/basic/mining/ice_whelp = 60,
		/mob/living/basic/mining/legion/snow = 100,
		/obj/effect/spawner/random/lavaland_mob/raptor = 25,

		/obj/structure/spawner/ice_moon/demonic_portal = 6,
		/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 6,
		/obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 6,
	)
	weighted_megafauna_spawn_list = list(/mob/living/simple_animal/hostile/megafauna/colossus = 1)
	weighted_flora_spawn_list = list(
		/obj/structure/flora/rock/icy/style_random = 6,
		/obj/structure/flora/rock/pile/icy/style_random = 6,
		/obj/structure/flora/ash/chilly = 1,
	)
