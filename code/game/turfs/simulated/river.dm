#define RANDOM_UPPER_X 200
#define RANDOM_UPPER_Y 200

#define RANDOM_LOWER_X 50
#define RANDOM_LOWER_Y 50

/proc/spawn_rivers(target_z = 5, nodes = 4, turf_type = /turf/open/floor/plating/lava/smooth/lava_land_surface, whitelist_area = /area/lavaland/surface/outdoors, min_x = RANDOM_LOWER_X, min_y = RANDOM_LOWER_Y, max_x = RANDOM_UPPER_X, max_y = RANDOM_UPPER_Y)
	var/list/river_nodes = list()
	var/num_spawned = 0
	while(num_spawned < nodes)
		var/turf/F = locate(rand(min_x, max_x), rand(min_y, max_y), target_z)

		river_nodes += new /obj/effect/landmark/river_waypoint(F)
		num_spawned++

	//make some randomly pathing rivers
	for(var/A in river_nodes)
		var/obj/effect/landmark/river_waypoint/W = A
		if (W.z != target_z || W.connected)
			continue
		W.connected = 1
		var/turf/cur_turf = get_turf(W)
		cur_turf.ChangeTurf(turf_type,FALSE,FALSE,TRUE)
		var/turf/target_turf = get_turf(pick(river_nodes - W))
		if(!target_turf)
			break
		var/detouring = 0
		var/cur_dir = get_dir(cur_turf, target_turf)
		while(cur_turf != target_turf)

			if(detouring) //randomly snake around a bit
				if(prob(20))
					detouring = 0
					cur_dir = get_dir(cur_turf, target_turf)
			else if(prob(20))
				detouring = 1
				if(prob(50))
					cur_dir = turn(cur_dir, 45)
				else
					cur_dir = turn(cur_dir, -45)
			else
				cur_dir = get_dir(cur_turf, target_turf)

			cur_turf = get_step(cur_turf, cur_dir)
			var/area/new_area = get_area(cur_turf)
			if(!istype(new_area, whitelist_area)) //Rivers will skip ruins
				detouring = 0
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue
			else
				var/turf/river_turf = cur_turf.ChangeTurf(turf_type,FALSE,FALSE,TRUE)
				river_turf.Spread(25, 11, whitelist_area)

	for(var/WP in river_nodes)
		qdel(WP)


/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	var/connected = 0
	invisibility = INVISIBILITY_ABSTRACT


/turf/proc/Spread(probability = 30, prob_loss = 25, whitelisted_area)
	if(probability <= 0)
		return
	var/list/cardinal_turfs = list()
	var/list/diagonal_turfs = list()
	var/logged_turf_type
	for(var/F in RANGE_TURFS(1, src) - src)
		var/turf/T = F
		var/area/new_area = get_area(T)
		if(!T || (T.density && !ismineralturf(T)) || istype(T, /turf/open/indestructible) || (whitelisted_area && !istype(new_area, whitelisted_area)))
			continue

		if(!logged_turf_type && ismineralturf(T))
			var/turf/closed/mineral/M = T
			logged_turf_type = M.turf_type

		if(get_dir(src, F) in GLOB.cardinals)
			cardinal_turfs += F
		else
			diagonal_turfs += F

	for(var/F in cardinal_turfs) //cardinal turfs are always changed but don't always spread
		var/turf/T = F
		if(!istype(T, logged_turf_type) && T.ChangeTurf(type,FALSE,FALSE,TRUE) && prob(probability))
			T.Spread(probability - prob_loss, prob_loss, whitelisted_area)

	for(var/F in diagonal_turfs) //diagonal turfs only sometimes change, but will always spread if changed
		var/turf/T = F
		if(!istype(T, logged_turf_type) && prob(probability) && T.ChangeTurf(type,FALSE,FALSE,TRUE))
			T.Spread(probability - prob_loss, prob_loss, whitelisted_area)
		else if(ismineralturf(T))
			var/turf/closed/mineral/M = T
			M.ChangeTurf(M.turf_type,FALSE,FALSE,TRUE)


#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y
