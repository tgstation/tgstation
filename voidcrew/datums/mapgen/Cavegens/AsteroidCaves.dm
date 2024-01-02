/datum/map_generator/cave_generator/asteroid
	open_turf_types = list(/turf/open/misc/asteroid/airless = 1)
	closed_turf_types =  list(/turf/closed/mineral/random = 1)

	feature_spawn_chance = 1
	feature_spawn_list = list(/obj/structure/geyser/random = 1)
	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goliath = 25, /obj/structure/spawner/mining/goliath = 30, \
		/mob/living/simple_animal/hostile/asteroid/basilisk = 25, /obj/structure/spawner/mining = 30, \
		/mob/living/simple_animal/hostile/asteroid/hivelord = 25, /obj/structure/spawner/mining/hivelord = 30, \
		SPAWN_MEGAFAUNA = 4, /mob/living/basic/mining/goldgrub = 10)
	//flora_spawn_list = list(/obj/structure/flora/ash/space/voidmelon = 2)

	initial_closed_chance = 55
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3
	mob_spawn_chance = 6

/datum/map_generator/cave_generator/asteroid/generate_terrain(list/turfs)
	var/maxx
	var/maxy
	var/minx
	var/miny
	for(var/turf/T as anything in turfs)
		//Gets the min/max X value
		if(T.x < minx || !minx)
			minx = T.x
		else if(T.x > maxx)
			maxx = T.x

		//Gets the min/max Y value
		if(T.y < miny || !miny)
			miny = T.y
		else if(T.y > maxy)
			maxy = T.y

	var/midx = minx + (maxx - minx) / 2
	var/midy = miny + (maxy - miny) / 2
	var/radius = min(maxx - minx, maxy - miny) / 2

	var/list/turfs_to_gen = list()
	var/area/centcom/asteroid/voidcrew/asteroid_area = GLOB.areas_by_type[/area/centcom/asteroid/voidcrew] || new
	for(var/turf/T as anything in turfs)
		var/randradius = rand(radius - 2, radius + 2) * rand(radius - 2, radius + 2)
		if((T.y - midy) ** 2 + (T.x - midx) ** 2 >= randradius)
			continue
		turfs_to_gen += T
		var/area/old_area = get_area(T)
		asteroid_area.contents += T
		T.change_area(old_area, asteroid_area)

	return ..(turfs_to_gen)

