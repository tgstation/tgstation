/datum/map_generator/cave_generator/asteroid
	open_turf_types = list(/turf/open/floor/plating/asteroid/airless = 1)
	closed_turf_types =  list(/turf/closed/mineral/random = 1)


	feature_spawn_list = list()
	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goliath = 50, \
						  /mob/living/simple_animal/hostile/asteroid/basilisk = 40, \
						  /mob/living/simple_animal/hostile/asteroid/hivelord = 30, \
						  /mob/living/simple_animal/hostile/asteroid/goldgrub = 10)
	flora_spawn_list = list()

	flora_spawn_chance = 0
	feature_spawn_chance = 0
	initial_closed_chance = 45
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3
