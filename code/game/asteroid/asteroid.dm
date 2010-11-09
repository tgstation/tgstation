proc/spawn_asteroid(var/atom/start_loc,var/type,var/size)//type: 0 or null - random, 1 - nothing,  2 - iron, 3 - silicon
	if(!size)
		size = pick(100;2,50;3,35;4,25;6,10;12)
	if(!type)
		type = pick(50;1,2,3)
//	world << "Asteroid size: [size]; Asteroid type: [type]"
	if(start_loc.x - size < 3 || start_loc.x + size >= world.maxx - 3 || start_loc.y - size < 3 || start_loc.y + size > world.maxy -3)
		return 0
	var/list/turfs = circlerange(start_loc,size)
	for(var/turf/T in turfs)
		var/dist = get_dist(start_loc,T)
		if(prob(100-(dist*rand(2,4))))//I'm terrible at generating random things.
			var/turf/simulated/wall/asteroid/A
			if(type > 1 && prob(25))
				switch(type)
					if(2)
						A = new /turf/simulated/wall/asteroid/iron(T)
					if(3)
						A = new /turf/simulated/wall/asteroid/silicon(T)
			else
				A = new /turf/simulated/wall/asteroid(T)
			A.opacity = 0
			A.sd_NewOpacity(1)
/*
	if(max_secret_rooms && size == 12)
		var/x_len = rand(4,12)
		var/y_len = pick(4,12)
		var/st_l = locate(start_loc.x-round(x_len/2),start_loc.y-round(y_len/2),start_loc.z)
		spawn_room(st_l,x_len,y_len)
		max_secret_rooms--
*/
	return 1

/proc/populate_w_asteroids(var/z,var/density)
	if(!density)
		density = pick(10,20,40)
	while(density)
		var/x = rand(1,world.maxx)
		var/y = rand(1,world.maxy)
//		world << "Asteroid coords: [x], [y], [z]"
		var/start_loc = locate(x,y,z)
		if(spawn_asteroid(start_loc))
			density--
	return


/datum/game_mode/proc/setup_sectors()
	world << "\blue \b Randomizing space sectors."
	var/list/sectors = list(1,3,4,0,0,0,0,0,0)
	var/length = sectors.len/3
	global_map = new/list(length,length)//3x3 map
	var/x
	var/y

	for(x=1,x<=length,x++)
		for(y=1,y<=length,y++)
			var/sector
			if(sectors.len)
				sector = pick(sectors)
				sectors -= sector
				if(sector == 0)
					sector = ++world.maxz
					populate_w_asteroids(sector)
				global_map[x][y] = sector
			else
				break
	world << "\blue \b Randomization complete."
/*
	//debug
	for(x=1,x<=global_map.len,x++)
		var/list/y_arr = global_map[x]
		for(y=1,y<=y_arr.len,y++)
			var/t = ""
			switch(y_arr[y])
				if(1) t = "SS13"
				if(3) t = "AI Satellite"
				if(4) t = "Derelict"
				else t = "Empty Cold Space"
			world << "Global map [x] - [y] contains [t] (Z = [y_arr[y]])"
	//debug
*/
	return

/datum/game_mode/proc/spawn_exporation_packs()
	for (var/obj/landmark/L in world)
		if (L.tag == "landmark*ExplorationPack")
			new /obj/item/weapon/storage/explorers_box(L.loc)
			del(L)
	return


proc/spawn_room(var/atom/start_loc,var/x_size,var/y_size,var/wall,var/floor)
	var/list/room_turfs = list("walls"=list(),"floors"=list())

	world << "Room spawned at [start_loc.x],[start_loc.y],[start_loc.z]"
	if(!wall)
		wall = pick(/turf/simulated/wall/r_wall,/turf/simulated/wall)
	if(!floor)
		floor = pick(/turf/simulated/floor,/turf/simulated/floor/engine)

	for(var/x = 0,x<x_size,x++)
		for(var/y = 0,y<y_size,y++)
			var/turf/T
			var/cur_loc = locate(start_loc.x+x,start_loc.y+y,start_loc.z)
			if(x == 0 || x==x_size-1 || y==0 || y==y_size-1)
				T = new wall(cur_loc)
				room_turfs["walls"] += T
			else
				T = new floor(cur_loc)
				room_turfs["floors"] += T
	return room_turfs


var/global/max_secret_rooms = 3


