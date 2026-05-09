/datum/biome/lavaland
	open_turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	closed_turf_type = /turf/closed/mineral/volcanic


/datum/biome/lavaland/basalt
	closed_turf_type = /turf/closed/mineral/random/volcanic

	fauna_density = 6
	flora_density = 2.5
	feature_density = 0.25

	// Legions and goliaths, but fewer watchers and no demons
	fauna_types = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 50,
		/obj/effect/spawner/random/lavaland_mob/legion = 40,
		/obj/effect/spawner/random/lavaland_mob/watcher = 20,
		/mob/living/basic/mining/bileworm = 10,
		/mob/living/basic/mining/lobstrosity/lava = 20,
		/obj/effect/spawner/random/lavaland_mob/raptor = 15,
		/mob/living/basic/mining/goldgrub = 15,
		/obj/structure/spawner/lavaland = 1,
		/obj/structure/spawner/lavaland/goliath = 3,
		/obj/structure/spawner/lavaland/legion = 3,
	)

	flora_types = list(
		/obj/structure/flora/ash/cap_shroom = 3,
		/obj/structure/flora/ash/fireblossom = 1,
		/obj/structure/flora/ash/stem_shroom = 1,
		/obj/structure/flora/rock/style_random = 1,
		/obj/structure/flora/rock/pile/style_random = 3,
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
	flora_density = 5

	// Higher chance of lobstrocities, goldgrubs and brimdemons, but no bileworms
	fauna_types = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 40,
		/obj/effect/spawner/random/lavaland_mob/legion = 20,
		/obj/effect/spawner/random/lavaland_mob/watcher = 30,
		/mob/living/basic/mining/brimdemon = 40,
		/mob/living/basic/mining/lobstrosity/lava = 40,
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
		/obj/structure/flora/rock/pile/shale/style_random = 5,
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
	flora_density = 4

	// Bileworms, raptors and watchers, but few goliaths
	fauna_types = list(
		SPAWN_MEGAFAUNA = 2,
		/obj/effect/spawner/random/lavaland_mob/goliath = 20,
		/obj/effect/spawner/random/lavaland_mob/legion = 25,
		/obj/effect/spawner/random/lavaland_mob/watcher = 55,
		/mob/living/basic/mining/bileworm = 35,
		/mob/living/basic/mining/brimdemon = 15,
		/mob/living/basic/mining/lobstrosity/lava = 25,
		/obj/effect/spawner/random/lavaland_mob/raptor = 20,
		/mob/living/basic/mining/goldgrub = 15,
		/obj/structure/spawner/lavaland = 2,
		/obj/structure/spawner/lavaland/goliath = 1,
		/obj/structure/spawner/lavaland/legion = 3,
	)

	flora_types = list(
		/obj/structure/flora/ash/cacti = 2,
		/obj/structure/flora/ash/cap_shroom = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/rock/pile/siderite/style_random = 4,
		/obj/structure/flora/rock/siderite_growth = 1,
	)

	feature_types = list(
		/obj/structure/geyser/protozine = 12,
		/obj/structure/geyser/chiral_buffer = 12,
		/obj/structure/geyser/random = 3,
		/obj/structure/ore_vent/boss = 1,
	)
