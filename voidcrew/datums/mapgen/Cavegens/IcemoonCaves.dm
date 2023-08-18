/datum/map_generator/cave_generator/icemoon
	open_turf_types = list(/turf/open/misc/asteroid/snow/icemoon = 19, /turf/open/misc/ice/icemoon = 1)
	closed_turf_types = list(/turf/closed/mineral/random/snow = 1)


	feature_spawn_list = list(/obj/structure/geyser/random = 1, /obj/structure/elite_tumor = 2)
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/wolf/random = 30, /obj/structure/spawner/ice_moon = 3,
		/mob/living/simple_animal/hostile/asteroid/polarbear/random = 30, /obj/structure/spawner/ice_moon/polarbear = 3,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50, /mob/living/simple_animal/hostile/asteroid/goldgrub = 10,
		/mob/living/simple_animal/hostile/asteroid/ice_demon/random = 20, /obj/structure/spawner/ice_moon/demonic_portal = 7,
		/mob/living/simple_animal/hostile/asteroid/ice_whelp = 20, /obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 7,
		/obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 7,
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 2,
		/obj/structure/flora/rock/icy = 2,
		/obj/structure/flora/rock/pile/icy = 2,
		/obj/structure/flora/grass/both = 6,
		/obj/structure/flora/ash/chilly = 2,
		/obj/structure/flora/ash/whitesands/puce = 2,
	)

/datum/map_generator/cave_generator/icemoon/surface
	flora_spawn_chance = 6
	mob_spawn_list = null
	initial_closed_chance = 30
	mob_spawn_chance = 10//danger zone, highway to the danger zone
	birth_limit = 5
	death_limit = 4
