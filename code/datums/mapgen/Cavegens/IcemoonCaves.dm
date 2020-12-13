/datum/map_generator/cave_generator/icemoon
	open_turf_types =  list(/turf/open/floor/plating/asteroid/snow/icemoon = 19, /turf/open/floor/plating/ice/icemoon = 1)
	closed_turf_types =  list(/turf/closed/mineral/random/snow = 1)


	feature_spawn_list = list(/obj/structure/geyser/random = 1)
	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/wolf = 50, /obj/structure/spawner/ice_moon = 3, \
						  /mob/living/simple_animal/hostile/asteroid/polarbear = 30, /obj/structure/spawner/ice_moon/polarbear = 3, \
						  /mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow = 50, /mob/living/simple_animal/hostile/asteroid/goldgrub = 10, \
						  /mob/living/simple_animal/hostile/asteroid/lobstrosity = 15)
	flora_spawn_list = list(/obj/structure/flora/tree/pine = 2, /obj/structure/flora/rock/icy = 2, /obj/structure/flora/rock/pile/icy = 2, /obj/structure/flora/grass/both = 6, /obj/structure/flora/ash/chilly = 2)

/datum/map_generator/cave_generator/icemoon/surface
	flora_spawn_chance = 4
	mob_spawn_list = null
	initial_closed_chance = 40
	birth_limit = 5
	death_limit = 4
