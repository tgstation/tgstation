
/datum/biome/snow
	open_turf_types = list(/turf/open/misc/asteroid/snow/breathable/lit = 25)
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 2,
		/obj/structure/flora/rock/icy = 2,
		/obj/structure/flora/rock/pile/icy = 2,
		/obj/structure/flora/grass/both = 6,
		/obj/structure/flora/ash/chilly = 2
	)
	flora_spawn_chance = 10
	mob_spawn_chance = 1
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/wolf/random = 30,
		/obj/structure/spawner/ice_moon = 3,
		/obj/structure/spawner/ice_moon/polarbear = 3,
		/mob/living/simple_animal/hostile/asteroid/polarbear/random = 30,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 10,
		/mob/living/simple_animal/hostile/asteroid/ice_demon/random = 20,
		/mob/living/simple_animal/hostile/asteroid/ice_whelp = 20,
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		/obj/structure/spawner/ice_moon/demonic_portal = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 1
	)

/datum/biome/snow/lush
	open_turf_types = list(/turf/open/misc/asteroid/snow/breathable/lit = 25)
	flora_spawn_list = list(
		/obj/structure/flora/grass/both = 1,
	)
	flora_spawn_chance = 30

/datum/biome/snow/thawed
	open_turf_types = list(/turf/open/misc/dirt/jungle/dark/lit = 1)
	flora_spawn_chance = 40
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1
	)

/datum/biome/snow/forest
	flora_spawn_chance = 15
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 10,
		/obj/structure/flora/tree/dead = 3,
		/obj/structure/flora/grass/both = 4
	)

/datum/biome/snow/forest/dense
	flora_spawn_chance = 25
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 20,
		/obj/structure/flora/grass/both = 6,
		/obj/structure/flora/tree/dead = 3,
	)

/datum/biome/snow/forest/dense/christmas
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 500,
		/obj/structure/flora/tree/dead = 100,
		/obj/structure/flora/grass/both = 350,
		/obj/structure/flora/tree/pine/xmas/presents = 1
	)
	feature_spawn_chance = 10
	feature_spawn_list = list(
		/obj/item/a_gift = 50,
		/obj/item/a_gift/anything = 1,
		/obj/item/clothing/head/costume/santa = 1,
		/obj/item/storage/backpack/santabag = 1
	)

/datum/biome/arctic
	open_turf_types = list(/turf/open/misc/asteroid/snow/breathable/lit = 1)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(/obj/structure/statue/snow/snowman = 3, /obj/structure/statue/snow/snowlegion = 1)
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/wolf/random = 30,
		/obj/structure/spawner/ice_moon = 3,
		/obj/structure/spawner/ice_moon/polarbear = 3,
		/mob/living/simple_animal/hostile/asteroid/polarbear/random = 30,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 10,
		/mob/living/simple_animal/hostile/asteroid/ice_demon/random = 15,
		/mob/living/simple_animal/hostile/asteroid/ice_whelp = 15,
	)
	mob_spawn_chance = 1

/datum/biome/arctic/rocky
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/flora/rock/icy = 2,
		/obj/structure/flora/rock/pile/icy = 2,
	)

/datum/biome/icey
	open_turf_types = list(/turf/open/misc/asteroid/snow/breathable/lit = 5, /turf/open/misc/ice/lit = 1)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/wolf/random = 30,
		/mob/living/simple_animal/hostile/asteroid/polarbear/random = 30,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 10,
		/mob/living/simple_animal/hostile/asteroid/ice_demon/random = 15,
		/mob/living/simple_animal/hostile/asteroid/ice_whelp = 15,
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/structure/spawner/ice_moon/demonic_portal = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 1
	)

/datum/biome/icey/lake
	open_turf_types = list(/turf/open/misc/ice/lit = 1)

/datum/biome/plasma
	open_turf_types = list(/turf/open/lava/plasma/ice_moon = 5, /turf/open/misc/dirt/jungle/dark/lit = 1)

/datum/biome/cave/snow
	open_turf_types = list(/turf/open/misc/asteroid/snow/breathable = 1)
	flora_spawn_chance = 6
	flora_spawn_list = list(
		/obj/structure/flora/grass/both = 5,
		/obj/structure/flora/rock/pile = 1,
		/obj/structure/flora/rock/snow = 1,
//		/obj/structure/flora/ash/space = 1,
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 1,
		/obj/structure/flora/ash/stem_shroom = 1,
		/obj/structure/flora/ash/whitesands/puce = 1
	)
	closed_turf_types = list(/turf/closed/mineral/random/snow = 1)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/wolf/random = 30,
		/obj/structure/spawner/ice_moon = 3,
		/obj/structure/spawner/ice_moon/polarbear = 3,
		/mob/living/simple_animal/hostile/asteroid/polarbear/random = 30,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 10,
		/mob/living/simple_animal/hostile/asteroid/ice_demon/random = 15,
		/mob/living/simple_animal/hostile/asteroid/ice_whelp = 15
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		/obj/structure/spawner/ice_moon/demonic_portal = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 1
	)

/datum/biome/cave/snow/thawed
	//open_turf_types = list(/turf/open/floor/plating/ashplanet/rocky = 1)

/datum/biome/cave/snow/ice
	open_turf_types = list(/turf/open/misc/asteroid/snow/breathable = 20, /turf/open/misc/ice = 3)

/datum/biome/cave/volcanic
	open_turf_types = list(/turf/open/misc/asteroid/basalt = 1)
	closed_turf_types = list(/turf/closed/mineral/random/snow = 1)
	mob_spawn_chance = 2
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/wolf/random = 30,
		/obj/structure/spawner/ice_moon = 3,
		/obj/structure/spawner/ice_moon/polarbear = 3,
		/mob/living/simple_animal/hostile/asteroid/polarbear/random = 30,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 10,
		/mob/living/simple_animal/hostile/asteroid/ice_demon/random = 15,
		/mob/living/simple_animal/hostile/asteroid/ice_whelp = 15,
	)
	flora_spawn_chance = 3
	flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 1,
		/obj/structure/flora/ash/cap_shroom = 1,
		/obj/structure/flora/ash/stem_shroom = 1,
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		/obj/structure/spawner/ice_moon/demonic_portal = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 1,
		/obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 1,
	)

/datum/biome/cave/volcanic/lava
	open_turf_types = list(/turf/open/lava/smooth = 1)

/datum/biome/cave/volcanic/lava/plasma
	open_turf_types = list(/turf/open/lava/plasma = 7, /turf/open/misc/dirt/jungle/dark = 1)
