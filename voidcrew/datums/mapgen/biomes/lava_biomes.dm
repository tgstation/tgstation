/datum/biome/lavaland
	open_turf_types = list(/turf/open/misc/asteroid/basalt/lava_land_surface/lit = 1)
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/ywflowers/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 40,
		/obj/structure/flora/ash/whitesands/fern = 5,
		/obj/structure/flora/ash/whitesands/fireblossom = 1,
		/obj/structure/flora/ash/whitesands/puce = 5
	)
	feature_spawn_chance = 0.4
	feature_spawn_list = list(
		/obj/structure/flora/rock/hell = 7,
		/obj/structure/elite_tumor = 1,
		/obj/structure/geyser/random = 1,
		/obj/structure/spawner/lavaland = 3,
		/obj/structure/spawner/lavaland/legion = 3,
		/obj/structure/spawner/lavaland/goliath = 3,
	)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50,

		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 40,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 10
	)

/datum/biome/lavaland/forest
	open_turf_types = list(/turf/open/misc/asteroid/purple/lit = 1)
	flora_spawn_list = list(
		/obj/structure/flora/tree/dead/tall/grey = 1,
		/obj/structure/flora/tree/dead/barren/purple = 1,
		/obj/structure/flora/ausbushes/fullgrass/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 5
	)
	flora_spawn_chance = 85

/datum/biome/lavaland/forest/rocky
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile/lava = 3,
		/obj/structure/flora/rock/lava = 2,
		/obj/structure/flora/tree/dead/tall/grey = 10,
		/obj/structure/flora/ausbushes/fullgrass/hell = 40,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 20,
		/obj/structure/flora/ausbushes/hell = 2
	)
	flora_spawn_chance = 65

/datum/biome/lavaland/plains
	open_turf_types = list(/turf/open/misc/grass/lava/purple = 30)

	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass/hell = 50,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 35,
		/obj/structure/flora/ausbushes/ywflowers/hell = 1,
		/obj/structure/flora/ausbushes/grassybush/hell = 4,
		/obj/structure/flora/firebush = 1
	)
	flora_spawn_chance = 15

/datum/biome/lavaland/plains/dense
	flora_spawn_chance = 85
	open_turf_types = list(/turf/open/misc/grass/lava = 50)
	feature_spawn_chance = 5
	feature_spawn_list = list(
		/obj/structure/flora/tree/dead/barren/purple = 60,
		/obj/structure/flora/tree/dead/tall/grey = 60,
		/obj/structure/spawner/lavaland = 5,
		/obj/structure/spawner/lavaland/legion = 5,
		/obj/structure/spawner/lavaland/goliath = 5,
	)

/datum/biome/lavaland/plains/dense/mixed
	flora_spawn_chance = 50
	open_turf_types = list(/turf/open/misc/grass/lava = 50, /turf/open/misc/grass/lava/purple = 45, /turf/open/misc/moss = 1)

/datum/biome/lavaland/outback
	open_turf_types = list(/turf/open/misc/grass/lava/orange = 20)
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/grassybush/hell = 10,
		/obj/structure/flora/ausbushes/genericbush/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 3,
		/obj/structure/flora/ausbushes/hell = 3,
		/obj/structure/flora/tree/dead/hell = 3,
		/obj/structure/flora/rock/lava = 2
	)
	flora_spawn_chance = 30

/datum/biome/lavaland/lush
	open_turf_types = list(/turf/open/misc/grass/lava/purple = 20, /turf/open/misc/asteroid/basalt/purple/lit = 1)
	flora_spawn_list = list(
		/obj/structure/flora/ash/whitesands/fireblossom = 3,
		/obj/structure/flora/tree/dead/hell = 1,
		/obj/structure/flora/ausbushes/grassybush/hell = 5,
		/obj/structure/flora/ausbushes/fullgrass/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 8,
		/obj/structure/flora/ausbushes/hell = 5,
		/obj/structure/flora/ausbushes/fernybush/hell = 5,
		/obj/structure/flora/ausbushes/genericbush/hell = 5,
		/obj/structure/flora/ausbushes/ywflowers/hell = 7,
		/obj/structure/flora/firebush = 3
	)
	flora_spawn_chance = 30

/datum/biome/lavaland/lava
	open_turf_types = list(/turf/open/lava/smooth/lava_land_surface/lit = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock/lava = 1,
		/obj/structure/flora/rock/pile/lava = 1
	)
	flora_spawn_chance = 2
	feature_spawn_list = list(
		/obj/structure/spawner/lavaland = 3,
		/obj/structure/spawner/lavaland/legion = 3,
		/obj/structure/spawner/lavaland/goliath = 3,
		/obj/vehicle/ridden/lavaboat/dragon = 1
	)

/datum/biome/lavaland/lava/rocky
	flora_spawn_chance = 4

/datum/biome/cave/lavaland
	open_turf_types = list(/turf/open/misc/asteroid/basalt/lava_land_surface = 1)
	closed_turf_types = list(/turf/closed/mineral/random/volcanic = 1)
	mob_spawn_chance = 4
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 40,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 10
	)
	feature_spawn_list = list(
		/obj/structure/spawner/lavaland/goliath = 1,
		/obj/structure/spawner/lavaland = 1,
		/obj/structure/spawner/lavaland/legion = 1
	)
	feature_spawn_chance = 0.4
	flora_spawn_chance = 1
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/ash/whitesands/fern = 2,
		/obj/structure/flora/ash/whitesands/puce = 2
	)

/datum/biome/cave/lavaland/rocky
	open_turf_types = list(/turf/open/misc/asteroid/purple = 1)
	flora_spawn_list = list(
		/obj/structure/flora/rock/pile/lava = 1,
		/obj/structure/flora/rock/lava = 1
	)
	flora_spawn_chance = 5

/datum/biome/cave/lavaland/mossy
	open_turf_types = list(/turf/open/misc/moss = 1)
	flora_spawn_chance = 80
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass/hell = 10,
		/obj/structure/flora/ausbushes/sparsegrass/hell = 5,
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2
	)

/datum/biome/cave/lavaland/lava
	open_turf_types = list(/turf/open/misc/asteroid/basalt/lava_land_surface = 10, /turf/open/lava/smooth/lava_land_surface/lit = 1)
	feature_spawn_chance = 1
	feature_spawn_list = list(/obj/structure/flora/rock/pile/lava = 1)
