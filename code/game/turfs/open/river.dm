#define RANDOM_UPPER_X 200
#define RANDOM_UPPER_Y 200

#define RANDOM_LOWER_X 50
#define RANDOM_LOWER_Y 50

/proc/spawn_rivers(target_z, nodes = 4, turf_type = /turf/open/lava/smooth/lava_land_surface, whitelist_area = /area/lavaland/surface/outdoors/unexplored, min_x = RANDOM_LOWER_X, min_y = RANDOM_LOWER_Y, max_x = RANDOM_UPPER_X, max_y = RANDOM_UPPER_Y)
	var/list/river_nodes = list()
	var/num_spawned = 0
	var/width = max_x - min_x
	var/height = max_y - min_y
	var/turf/corner = locate(min_x, min_y, target_z)
	var/list/possible_locs = CORNER_BLOCK(corner, width, height)
	while(num_spawned < nodes && possible_locs.len)
		var/turf/T = pick(possible_locs)
		var/area/A = get_area(T)
		if(!istype(A, whitelist_area) || (T.turf_flags & NO_LAVA_GEN))
			possible_locs -= T
		else
			river_nodes += new /obj/effect/landmark/river_waypoint(T)
			num_spawned++

	//make some randomly pathing rivers
	for(var/A in river_nodes)
		var/obj/effect/landmark/river_waypoint/W = A
		if (W.z != target_z || W.connected)
			continue
		W.connected = TRUE
		// Workaround around ChangeTurf that's safe because of when this proc is called
		var/turf/cur_turf = get_turf(W)
		cur_turf = new turf_type(cur_turf)
		var/turf/target_turf = get_turf(pick(river_nodes - W))
		if(!target_turf)
			break
		var/detouring = FALSE
		var/cur_dir = get_dir(cur_turf, target_turf)
		while(cur_turf != target_turf)

			if(detouring) //randomly snake around a bit
				if(prob(20))
					detouring = FALSE
					cur_dir = get_dir(cur_turf, target_turf)
			else if(prob(20))
				detouring = TRUE
				if(prob(50))
					cur_dir = turn(cur_dir, 45)
				else
					cur_dir = turn(cur_dir, -45)
			else
				cur_dir = get_dir(cur_turf, target_turf)

			cur_turf = get_step(cur_turf, cur_dir)
			var/area/new_area = get_area(cur_turf)
			if(!istype(new_area, whitelist_area) || (cur_turf.turf_flags & NO_LAVA_GEN)) //Rivers will skip ruins
				detouring = FALSE
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue
			else
				// Workaround around ChangeTurf that's safe because of when this proc is called
				var/turf/river_turf = new turf_type(cur_turf)
				river_turf.Spread(25, 11, whitelist_area)

	for(var/WP in river_nodes)
		qdel(WP)


/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	var/connected = FALSE
	invisibility = INVISIBILITY_ABSTRACT


/turf/proc/Spread(probability = 30, prob_loss = 25, whitelisted_area)
	if(probability <= 0)
		return
	var/list/cardinal_turfs = list()
	var/list/diagonal_turfs = list()
	var/logged_turf_type
	for(var/turf/canidate as anything in RANGE_TURFS(1, src) - src)
		if(!canidate || (canidate.density && !ismineralturf(canidate)) || isindestructiblefloor(canidate))
			continue

		var/area/new_area = get_area(canidate)
		if((!istype(new_area, whitelisted_area) && whitelisted_area) || (canidate.turf_flags & NO_LAVA_GEN))
			continue

		if(!logged_turf_type && ismineralturf(canidate))
			var/turf/closed/mineral/mineral_canidate = canidate
			logged_turf_type = mineral_canidate.turf_type

		if(get_dir(src, canidate) in GLOB.cardinals)
			cardinal_turfs += canidate
		else
			diagonal_turfs += canidate

	for(var/turf/cardinal_canidate as anything in cardinal_turfs) //cardinal turfs are always changed but don't always spread
		// NOTE: WE ARE SKIPPING CHANGETURF HERE
		// The calls in this proc only serve to provide a satisfactory (if it's not ALREADY this) check. They do not actually call changeturf
		// This is safe because this proc can only be run during mapload, and nothing has initialized by now so there's nothing to inherit or delete
		if(!istype(cardinal_canidate, logged_turf_type) && cardinal_canidate.ChangeTurf(type, baseturfs, CHANGETURF_SKIP) && prob(probability))
			if(baseturfs)
				cardinal_canidate.baseturfs = baseturfs
			cardinal_canidate.Spread(probability - prob_loss, prob_loss, whitelisted_area)

	for(var/turf/diagonal_canidate as anything in diagonal_turfs) //diagonal turfs only sometimes change, but will always spread if changed
		// Important NOTE: SEE ABOVE
		if(!istype(diagonal_canidate, logged_turf_type) && prob(probability) && diagonal_canidate.ChangeTurf(type, baseturfs, CHANGETURF_SKIP))
			if(baseturfs)
				diagonal_canidate.baseturfs = baseturfs
			diagonal_canidate.Spread(probability - prob_loss, prob_loss, whitelisted_area)
		else if(ismineralturf(diagonal_canidate))
			var/turf/closed/mineral/diagonal_mineral = diagonal_canidate
			// SEE ABOVE, THIS IS ONLY VERY RARELY SAFE
			new diagonal_mineral.turf_type(diagonal_mineral)

#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y
