#define RANDOM_UPPER_X 200
#define RANDOM_UPPER_Y 200

#define RANDOM_LOWER_X 50
#define RANDOM_LOWER_Y 50

/proc/spawn_lava_rivers(target_z = 5, nodes = 4)
	var/list/river_nodes = list()
	var/num_spawned = 0
	while(num_spawned < nodes)
		var/turf/simulated/F = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), target_z)

		river_nodes += new /obj/effect/landmark/river_waypoint(F)
		num_spawned++

	//make some randomly pathing rivers
	for(var/obj/effect/landmark/river_waypoint/W in river_nodes)
		if (W.z != target_z || W.connected)
			continue
		W.connected = 1
		var/turf/cur_turf = new /turf/simulated/floor/plating/lava/smooth(get_turf(W))
		var/turf/target_turf = get_turf(pick(river_nodes))

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

			if(istype(cur_turf, /turf/simulated/floor/plating/asteroid) || istype(cur_turf, /turf/simulated/mineral))
				var/turf/simulated/floor/plating/lava/smooth/lava_turf = new(cur_turf)
				lava_turf.Spread(30, 25)
			else
				detouring = 0
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue





/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	var/connected = 0
	invisibility = 101


/turf/simulated/floor/plating/lava/smooth/proc/Spread(probability = 30, prob_loss = 25)
	if(probability <= 0)
		return

	for(var/turf/simulated/F in orange(1, src))

		var/turf/simulated/floor/plating/lava/smooth/L = new(F)

		if(L && prob(probability))
			L.Spread(probability - prob_loss)


#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y