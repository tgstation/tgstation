////////////////////////MAP GENERATOR////////////////////////////////

/datum/map_generator/cave_generator/rockplanet
	open_turf_types = list(/turf/open/floor/plating/asteroid/lowpressure = 1)
	closed_turf_types =  list(/turf/closed/mineral/random/asteroid/rockplanet = 1)

	mob_spawn_chance = 3

	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 20,
		/mob/living/simple_animal/hostile/netherworld/mine_mob = 10,
		/mob/living/simple_animal/hostile/ooze/grapes/mine_mob = 20,
		/mob/living/simple_animal/hostile/asteroid/fugu = 30,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 40,
		/mob/living/simple_animal/hostile/asteroid/hivelord = 20,
		/mob/living/simple_animal/hostile/netherworld/migo/mine_mob = 10,
		/*/mob/living/simple_animal/hostile/lost_husk = 50,*/
		SPAWN_MEGAFAUNA = 3,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 10
		)
	flora_spawn_list = list(
		/obj/structure/flora/rock/jungle = 2,
		/obj/structure/flora/junglebush = 2,
		/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2
		)
	feature_spawn_list = list(/obj/structure/geyser/random = 1, /obj/effect/mine/shrapnel/human_only = 1)

	initial_closed_chance = 45
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3

/turf/closed/mineral/random/stationside/asteroid/rockplanet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	turf_type = /turf/open/floor/plating/asteroid
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/titanium = 11,
		/turf/closed/mineral/gibtonite = 4,
		/obj/item/stack/ore/bluespace_crystal = 1
		)
	mineralChance = 30
