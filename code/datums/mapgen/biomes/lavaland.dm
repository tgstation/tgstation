/datum/biome/lavaland
	open_turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	closed_turf_type = /turf/closed/mineral/volcanic

	fauna_density = 6
	flora_density = 2
	feature_density = 0.25

	fauna_types = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 50,
		/obj/effect/spawner/random/lavaland_mob/legion = 30,
		/obj/effect/spawner/random/lavaland_mob/watcher = 40,
		/mob/living/basic/mining/bileworm = 20,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/mining/lobstrosity/lava = 20,
		/obj/effect/spawner/random/lavaland_mob/raptor = 15,
		/mob/living/basic/mining/goldgrub = 15,
		/obj/structure/spawner/lavaland = 2,
		/obj/structure/spawner/lavaland/goliath = 3,
		/obj/structure/spawner/lavaland/legion = 3,
	)

	flora_types = list(
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/fireblossom = 2,
		/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/seraka = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/tall_shroom = 2,
	)

	feature_types = list(
		/obj/structure/geyser/hollowwater = 8,
		/obj/structure/geyser/plasma_oxide = 8,
		/obj/structure/geyser/protozine = 8,
		/obj/structure/geyser/random = 2,
		/obj/structure/geyser/wittel = 8,
		/obj/structure/geyser/chiral_buffer = 8,
		/obj/structure/ore_vent/boss = 1,
	)

/datum/biome/lavaland/basalt
	closed_turf_type = /turf/closed/mineral/random/volcanic

	// Legions and goliaths, but fewer watchers and no demons
	fauna_types = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 50,
		/obj/effect/spawner/random/lavaland_mob/legion = 40,
		/obj/effect/spawner/random/lavaland_mob/watcher = 30,
		/mob/living/basic/mining/bileworm = 15,
		/mob/living/basic/mining/lobstrosity/lava = 15,
		/obj/effect/spawner/random/lavaland_mob/raptor = 15,
		/mob/living/basic/mining/goldgrub = 15,
		/obj/structure/spawner/lavaland = 1,
		/obj/structure/spawner/lavaland/goliath = 3,
		/obj/structure/spawner/lavaland/legion = 3,
	)

	flora_types = list(
		/obj/structure/flora/ash/cap_shroom = 3,
		/obj/structure/flora/ash/fireblossom = 1,
		/obj/structure/flora/ash/stem_shroom = 3,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/rock/style_random = 1,
		/obj/structure/flora/rock/pile/style_random = 1,
		/obj/structure/flora/rock/volcano = 1,
	)

	feature_types = list(
		/obj/structure/geyser/plasma_oxide = 8,
		/obj/structure/geyser/protozine = 8,
		/obj/structure/geyser/wittel = 8,
		/obj/structure/geyser/random = 3,
		/obj/structure/ore_vent/boss = 1,
	)

/datum/biome/lavaland/shale
	open_turf_type = /turf/open/misc/asteroid/basalt/smooth/shale/lava_land_surface
	closed_turf_type = /turf/closed/mineral/random/volcanic/shale

	// Higher chance of lobstrocities, goldgrubs and brimdemons, but no bileworms
	fauna_types = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 40,
		/obj/effect/spawner/random/lavaland_mob/legion = 25,
		/obj/effect/spawner/random/lavaland_mob/watcher = 30,
		/mob/living/basic/mining/brimdemon = 35,
		/mob/living/basic/mining/lobstrosity/lava = 30,
		/obj/effect/spawner/random/lavaland_mob/raptor = 15,
		/mob/living/basic/mining/goldgrub = 35,
		/obj/structure/spawner/lavaland = 2,
		/obj/structure/spawner/lavaland/goliath = 3,
		/obj/structure/spawner/lavaland/legion = 3,
	)

	flora_types = list(
		/obj/structure/flora/ash/fireblossom = 2,
		/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/seraka = 2,
		/obj/structure/flora/ash/glowgrowth = 2,
		/obj/structure/flora/rock/pile/shale/style_random = 1,
	)

	feature_types = list(
		/obj/structure/geyser/hollowwater = 12,
		/obj/structure/geyser/plasma_oxide = 12,
		/obj/structure/geyser/random = 3,
		/obj/structure/ore_vent/boss = 1,
	)

/datum/biome/lavaland/red_rock
	open_turf_type = /turf/open/misc/asteroid/basalt/smooth/siderite/lava_land_surface
	closed_turf_type = /turf/closed/mineral/random/volcanic/red_rock

	// Bileworms, raptors and watchers, but few goliaths
	fauna_types = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 30,
		/obj/effect/spawner/random/lavaland_mob/legion = 30,
		/obj/effect/spawner/random/lavaland_mob/watcher = 45,
		/mob/living/basic/mining/bileworm = 30,
		/mob/living/basic/mining/brimdemon = 15,
		/mob/living/basic/mining/lobstrosity/lava = 20,
		/obj/effect/spawner/random/lavaland_mob/raptor = 20,
		/mob/living/basic/mining/goldgrub = 15,
		/obj/structure/spawner/lavaland = 2,
		/obj/structure/spawner/lavaland/goliath = 1,
		/obj/structure/spawner/lavaland/legion = 3,
	)

	flora_types = list(
		/obj/structure/flora/ash/cacti = 2,
		/obj/structure/flora/ash/cap_shroom = 1,
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/rock/pile/siderite/style_random = 1,
		/obj/structure/flora/rock/siderite_growth = 1,
	)

	feature_types = list(
		/obj/structure/geyser/protozine = 12,
		/obj/structure/geyser/chiral_buffer = 12,
		/obj/structure/geyser/random = 3,
		/obj/structure/ore_vent/boss = 1,
	)
