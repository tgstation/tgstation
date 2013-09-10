//some testin stuff

#define PATH_SPREAD_CHANCE_START 90
#define PATH_SPREAD_CHANCE_LOSS_UPPER 80
#define PATH_SPREAD_CHANCE_LOSS_LOWER 50

#define RIVER_SPREAD_CHANCE_START 100
#define RIVER_SPREAD_CHANCE_LOSS_UPPER 65
#define RIVER_SPREAD_CHANCE_LOSS_LOWER 50

#define RANDOM_UPPER_X 100
#define RANDOM_UPPER_Y 100

#define RANDOM_LOWER_X 18
#define RANDOM_LOWER_Y 18

/area/jungle
	name = "jungle"
	icon = 'code/workinprogress/cael_aislinn/jungle/jungle.dmi'
	icon_state = "area"
	lighting_use_dynamic = 0
	luminosity = 1

//randomly spawns, will create paths around the map
/obj/effect/landmark/path_waypoint
	name = "path waypoint"
	icon_state = "x2"
	var/connected = 0

/obj/effect/landmark/temple
	name = "temple entrance"
	icon_state = "x2"
	var/obj/structure/ladder/my_ladder

	New()
		//pick a random temple to link to
		var/list/waypoints = list()
		for(var/obj/effect/landmark/temple/destination/T in landmarks_list)
			waypoints.Add(T)
			if(!T)
				return
			else continue
		var/obj/effect/landmark/temple/destination/dest_temple = pick(waypoints)
		dest_temple.init()

		//connect this landmark to the other
		my_ladder = new /obj/structure/ladder(src.loc)
		my_ladder.id = dest_temple.my_ladder.id
		dest_temple.my_ladder.up = my_ladder

		//delete the landmarks now that we're finished
		del(dest_temple)
		del(src)

/obj/effect/landmark/temple/destination/New()
	//nothing

/obj/effect/landmark/temple/destination/proc/init()
	my_ladder = new /obj/structure/ladder(src.loc)
	my_ladder.id = rand(999)
	my_ladder.height = -1

	//loop over the walls in the temple and make them a random pre-chosen mineral (null is a stand in for plasma, which the walls already are)
	//treat plasma slightly differently because it's the default wall type
	var/mineral = pick("uranium","sandstone","gold","iron","silver","diamond","clown","plasma")
	//world << "init [mineral]"
	var/area/my_area = get_area(src)
	var/list/temple_turfs = get_area_turfs(my_area.type)

	for(var/turf/simulated/floor/T in temple_turfs)

		for(var/obj/effect/landmark/falsewall_spawner/F in T.contents)
			var/obj/structure/temple_falsewall/fwall = new(F.loc)
			fwall.mineral = mineral
			if(mineral == "iron")
				fwall.is_metal = 1
			del(F)

		for(var/obj/effect/landmark/door_spawner/D in T.contents)
			var/spawn_type
			if(mineral == "iron")
				spawn_type = text2path("/obj/machinery/door/airlock/vault")
			else
				spawn_type = text2path("/obj/machinery/door/airlock/[mineral]")
			new spawn_type(D.loc)
			del(D)

	for(var/turf/unsimulated/wall/T in temple_turfs)
		if(mineral != "plasma")
			T.icon_state = replacetext(T.icon_state, "plasma", mineral)

		/*for(var/obj/effect/landmark/falsewall_spawner/F in T.contents)
			//world << "falsewall_spawner found in wall"
			var/obj/structure/temple_falsewall/fwall = new(F.loc)
			fwall.mineral = mineral
			del(F)

		for(var/obj/effect/landmark/door_spawner/D in T.contents)
			//world << "door_spawner found in wall"
			T = new /turf/unsimulated/floor(T.loc)
			T.icon_state = "dark"
			var/spawn_type = text2path("/obj/machinery/door/airlock/[door_mineral]")
			new spawn_type(T)
			del(D)*/

//a shuttle has crashed somewhere on the map, it should have a power cell to let the adventurers get home
/area/jungle/crash_ship_source
	icon_state = "crash"

/area/jungle/crash_ship_clean
	icon_state = "crash"

/area/jungle/crash_ship_one
	icon_state = "crash"

/area/jungle/crash_ship_two
	icon_state = "crash"

/area/jungle/crash_ship_three
	icon_state = "crash"

/area/jungle/crash_ship_four
	icon_state = "crash"

//randomly spawns, will create rivers around the map
//uses the same logic as jungle paths
/obj/effect/landmark/river_waypoint
	name = "river source waypoint"
	var/connected = 0

/obj/machinery/jungle_controller
	name = "jungle controller"
	desc = "a mysterious and ancient piece of machinery"
	var/list/animal_spawners = list()


/obj/machinery/jungle_controller/initialize()
	world << "\red \b Setting up jungle, this may take a bleeding eternity..."

	//crash dat shuttle
	var/area/start_location = locate(/area/jungle/crash_ship_source)
	var/area/clean_location = locate(/area/jungle/crash_ship_clean)
	var/list/ship_locations = list(/area/jungle/crash_ship_one, /area/jungle/crash_ship_two, /area/jungle/crash_ship_three, /area/jungle/crash_ship_four)
	var/area/end_location = locate( pick(ship_locations) )
	ship_locations -= end_location.type

	start_location.move_contents_to(end_location)
	for(var/area_type in ship_locations)
		var/area/cur_location = locate(area_type)
		clean_location.copy_turfs_to(cur_location)

	//drop some random river nodes
	var/list/river_nodes = list()
	var/max = rand(1,3)
	var/num_spawned = 0
	while(num_spawned < max)
		var/turf/unsimulated/jungle/J = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), src.z)
		if(!istype(J))
			continue
		if(!J.bushes_spawn)
			continue
		river_nodes.Add(new /obj/effect/landmark/river_waypoint(J))
		num_spawned++

	//make some randomly pathing rivers
	for(var/obj/effect/landmark/river_waypoint/W in landmarks_list)
		if (W.z != src.z || W.connected)
			continue

		W.connected = 1
		var/turf/cur_turf = new /turf/unsimulated/jungle/water(get_turf(W))
		var/turf/target_turf = get_turf(pick(river_nodes))

		var/detouring = 0
		var/cur_dir = get_dir(cur_turf, target_turf)
		//
		while(cur_turf != target_turf)
			//randomly snake around a bit
			if(detouring)
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

			var/skip = 0
			if(!istype(cur_turf, /turf/unsimulated/jungle) || istype(cur_turf, /turf/unsimulated/jungle/rock))
				detouring = 0
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue

			if(!skip)
				var/turf/unsimulated/jungle/water/water_turf = new(cur_turf)
				water_turf.Spread(75, rand(65, 25))

	var/list/path_nodes = list()

	//place some ladders leading down to pre-generated temples
	max = rand(2,5)
	num_spawned = 0
	while(num_spawned < max)
		var/turf/unsimulated/jungle/J = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), src.z)
		if(!J || !J.bushes_spawn)
			continue
		new /obj/effect/landmark/temple(J)
		path_nodes.Add(new /obj/effect/landmark/path_waypoint(J))
		num_spawned++

	//put a native tribe somewhere
	num_spawned = 0
	while(num_spawned < 1)
		var/turf/unsimulated/jungle/J = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), src.z)
		if(!J || !J.bushes_spawn)
			continue
		new /obj/effect/jungle_tribe_spawn(J)
		path_nodes.Add(new /obj/effect/landmark/path_waypoint(J))
		num_spawned++

	//place some random path waypoints to confuse players
	max = rand(1,3)
	num_spawned = 0
	while(num_spawned < max)
		var/turf/unsimulated/jungle/J = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), src.z)
		if(!J || !J.bushes_spawn)
			continue
		path_nodes.Add(new /obj/effect/landmark/path_waypoint(J))
		num_spawned++

	//get any path nodes placed on the map
	for(var/obj/effect/landmark/path_waypoint/W in landmarks_list)
		if (W.z == src.z)
			path_nodes.Add(W)

	//make random, connecting paths
	for(var/obj/effect/landmark/path_waypoint/W in path_nodes)
		if (W.connected)
			continue

		W.connected = 1
		var/turf/cur_turf = get_turf(W)
		path_nodes.Remove(W)
		var/turf/target_turf = get_turf(pick(path_nodes))
		path_nodes.Add(W)
		//
		cur_turf = new /turf/unsimulated/jungle/path(cur_turf)

		var/detouring = 0
		var/cur_dir = get_dir(cur_turf, target_turf)
		//
		while(cur_turf != target_turf)
			//randomly snake around a bit
			if(detouring)
				if(prob(20) || get_dist(cur_turf, target_turf) < 5)
					detouring = 0
					cur_dir = get_dir(cur_turf, target_turf)
			else if(prob(20) && get_dist(cur_turf, target_turf) > 5)
				detouring = 1
				if(prob(50))
					cur_dir = turn(cur_dir, 45)
				else
					cur_dir = turn(cur_dir, -45)
			else
				cur_dir = get_dir(cur_turf, target_turf)

			//move a step forward
			cur_turf = get_step(cur_turf, cur_dir)

			//if we're not a jungle turf, get back to what we were doing
			if(!istype(cur_turf, /turf/unsimulated/jungle/))
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue

			var/turf/unsimulated/jungle/J = cur_turf
			if(istype(J, /turf/unsimulated/jungle/impenetrable) || istype(J, /turf/unsimulated/jungle/water/deep))
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue

			if(!istype(J, /turf/unsimulated/jungle/water))
				J = new /turf/unsimulated/jungle/path(cur_turf)
				J.Spread(PATH_SPREAD_CHANCE_START, rand(PATH_SPREAD_CHANCE_LOSS_UPPER, PATH_SPREAD_CHANCE_LOSS_LOWER))

	//create monkey spawners
	num_spawned = 0
	max = rand(3,6)
	while(num_spawned < max)
		var/turf/unsimulated/jungle/J = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), src.z)
		if(!J || !J.bushes_spawn)
			continue
		animal_spawners.Add(new /obj/effect/landmark/animal_spawner/monkey(J))
		num_spawned++

	//create panther spawners
	num_spawned = 0
	max = rand(6,12)
	while(num_spawned < max)
		var/turf/unsimulated/jungle/J = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), src.z)
		if(!J || !istype(J) ||  !J.bushes_spawn)
			continue
		animal_spawners.Add(new /obj/effect/landmark/animal_spawner/panther(J))
		num_spawned++

	//create snake spawners
	num_spawned = 0
	max = rand(6,12)
	while(num_spawned < max)
		var/turf/unsimulated/jungle/J = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), src.z)
		if(!J || !istype(J) || !J.bushes_spawn)
			continue
		animal_spawners.Add(new /obj/effect/landmark/animal_spawner/snake(J))
		num_spawned++

	//create parrot spawners
	num_spawned = 0
	max = rand(3,6)
	while(num_spawned < max)
		var/turf/unsimulated/jungle/J = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), src.z)
		if(!J || !istype(J) ||  !J.bushes_spawn)
			continue
		animal_spawners.Add(new /obj/effect/landmark/animal_spawner/parrot(J))
		num_spawned++

#undef PATH_SPREAD_CHANCE_START
#undef PATH_SPREAD_CHANCE_LOSS_UPPER
#undef PATH_SPREAD_CHANCE_LOSS_LOWER

#undef RIVER_SPREAD_CHANCE_START
#undef RIVER_SPREAD_CHANCE_LOSS_UPPER
#undef RIVER_SPREAD_CHANCE_LOSS_LOWER

#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y
