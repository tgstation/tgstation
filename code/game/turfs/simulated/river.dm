#define RANDOM_UPPER_X 200
#define RANDOM_UPPER_Y 200

#define RANDOM_LOWER_X 50
#define RANDOM_LOWER_Y 50

/proc/spawn_rivers(target_z = 5, nodes = 4, turf_type = /turf/open/floor/plating/lava/smooth/lava_land_surface, whitelist_area = /area/lavaland/surface/outdoors)
	var/list/river_nodes = list()
	var/num_spawned = 0
	while(num_spawned < nodes)
		var/turf/F = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), target_z)

		river_nodes += new /obj/effect/landmark/river_waypoint(F)
		num_spawned++

	//make some randomly pathing rivers
	for(var/A in river_nodes)
		var/obj/effect/landmark/river_waypoint/W = A
		if (W.z != target_z || W.connected)
			continue
		W.connected = 1
		var/turf/cur_turf = new turf_type(get_turf(W))
		//cur_turf.ChangeTurf(turf_type)
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
				var/turf/open/river_turf = new turf_type(cur_turf)
				river_turf.Spread(30, 25)

	for(var/WP in river_nodes)
		qdel(WP)


/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	var/connected = 0
	invisibility = 101


/turf/proc/Spread(probability = 30, prob_loss = 25)
	if(probability <= 0)
		return

	for(var/turf/F in orange(1, src))
		if(!F.density || istype(F, /turf/closed/mineral))
			var/turf/L = new src.type(F)

			if(L && prob(probability))
				L.Spread(probability - prob_loss)


#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y
