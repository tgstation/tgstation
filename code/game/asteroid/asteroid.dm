var/global/max_secret_rooms = 6




proc/spawn_asteroid(var/turf/start_loc,var/type,var/size,var/richness)//type: 0 or null - random, 1 - nothing,  2 - iron, 3 - silicon
	if(!size)
		size = pick(100;2,50;3,35;4,25;6,10;12)
	if(start_loc.x - size < 5 || start_loc.x + size >= world.maxx - 5 || start_loc.y - size < 5 || start_loc.y + size > world.maxy -5)
		return 0
	if(!type)
		type = pick(50;1,2,3)
	if(!richness)
		richness = rand(10,40)
//	world << "Asteroid size: [size]; Asteroid type: [type]"
	var/list/turfs = circlerangeturfs(start_loc,size)
	if(!islist(turfs) || isemptylist(turfs))
		return 0
	var/area/asteroid/AstAr = new
	AstAr.name = "Asteroid #[start_loc.x][start_loc.y][start_loc.z]"
	for(var/turf/T in turfs)
		var/dist = get_dist(start_loc,T)
		if(abs(GaussRand(dist))<size) //prob(100-(dist*rand(2,4))))//I'm terrible at generating random things.
			var/turf/simulated/wall/asteroid/A
			if(type > 1 && prob(richness))
				switch(type)
					if(2)
						A = new /turf/simulated/wall/asteroid/iron(T)
					if(3)
						A = new /turf/simulated/wall/asteroid/silicon(T)
			else
				A = new /turf/simulated/wall/asteroid(T)
			A.opacity = 0
			A.sd_NewOpacity(1)
			AstAr.contents += A

	if(max_secret_rooms && size >= 10)
		var/x_len = rand(4,size)
		var/y_len = pick(4,size)
		var/st_l = locate(start_loc.x-round(x_len/2),start_loc.y-round(y_len/2),start_loc.z)
		if(st_l)
			spawn_room(st_l,x_len,y_len)
			max_secret_rooms--

	return 1

/proc/populate_w_asteroids(var/z,var/density=null)
	if(!density)
		density = pick(10,20,40)
	while(density)
		var/x = rand(1,world.maxx)
		var/y = rand(1,world.maxy)
//		world << "Asteroid coords: [x], [y], [z]"
		var/start_loc = locate(x,y,z)
		if(start_loc && spawn_asteroid(start_loc))
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
	for (var/obj/effect/landmark/L in world)
		if (L.tag == "landmark*ExplorationPack")
			new /obj/item/weapon/storage/explorers_box(L.loc)
			del(L)
	return


proc/spawn_room(var/atom/start_loc,var/x_size,var/y_size,var/wall,var/floor , var/clean = 0 , var/name)
	var/list/room_turfs = list("walls"=list(),"floors"=list())

	//world << "Room spawned at [start_loc.x],[start_loc.y],[start_loc.z]"
	if(!wall)
		wall = pick(/turf/simulated/wall/r_wall,/turf/simulated/wall,/obj/effect/alien/resin)
	if(!floor)
		floor = pick(/turf/simulated/floor,/turf/simulated/floor/engine)

	for(var/x = 0,x<x_size,x++)
		for(var/y = 0,y<y_size,y++)
			var/turf/T
			var/cur_loc = locate(start_loc.x+x,start_loc.y+y,start_loc.z)
			if(clean)
				for(var/O in cur_loc)
					del(O)

			var/area/asteroid/artifactroom/A = new
			if(name)
				A.name = name
			else
				A.name = "Artifact Room #[start_loc.x][start_loc.y][start_loc.z]"



			if(x == 0 || x==x_size-1 || y==0 || y==y_size-1)
				if(wall == /obj/effect/alien/resin)
					T = new floor(cur_loc)
					new /obj/effect/alien/resin(T)
				else
					T = new wall(cur_loc)
					room_turfs["walls"] += T
			else
				T = new floor(cur_loc)
				room_turfs["floors"] += T

			A.contents += T


	return room_turfs


proc/admin_spawn_room_at_pos()
	var/wall
	var/floor
	var/x = input("X position","X pos",usr.x)
	var/y = input("Y position","Y pos",usr.y)
	var/z = input("Z position","Z pos",usr.z)
	var/x_len = input("Desired length.","Length",5)
	var/y_len = input("Desired width.","Width",5)
	var/clean = input("Delete existing items in area?" , "Clean area?", 0)
	switch(alert("Wall type",null,"Reinforced wall","Regular wall","Resin wall"))
		if("Reinforced wall")
			wall=/turf/simulated/wall/r_wall
		if("Regular wall")
			wall=/turf/simulated/wall
		if("Asteroid wall")
			wall=/turf/simulated/wall/asteroid
		if("Resin wall")
			wall=/obj/effect/alien/resin
	switch(alert("Floor type",null,"Regular floor","Reinforced floor"))
		if("Regular floor")
			floor=/turf/simulated/floor
		if("Reinforced floor")
			floor=/turf/simulated/floor/engine
	if(x && y && z && wall && floor && x_len && y_len)
		spawn_room(locate(x,y,z),x_len,y_len,wall,floor,clean)
	return






proc/make_mining_asteroid_secret(var/size = 5)
	var/valid = 0
	var/turf/T = null
	var/sanity = 0
	var/list/room = null

	while(!valid)
		valid = 1
		sanity++
		if(sanity > 100)
			return 0


		T=pick(get_area_turfs(/area/mine/unexplored))
		if(!T)
			return 0

		var/list/surroundings = list()

		surroundings += range(7, locate(T.x,T.y,T.z))
		surroundings += range(7, locate(T.x+size,T.y,T.z))
		surroundings += range(7, locate(T.x,T.y+size,T.z))
		surroundings += range(7, locate(T.x+size,T.y+size,T.z))

		if(locate(/area/mine/explored) in surroundings)			// +5s are for view range
			valid = 0
			continue

		if(locate(/turf/space) in surroundings)
			valid = 0
			continue

		if(locate(/area/asteroid/artifactroom) in surroundings)
			valid = 0
			continue

	if(!T)
		return 0

	room = spawn_room(T,size,size,,,1)

	if(room)
		T = pick(room["floors"])
		if(T)
			var/surprise = null
			valid = 0
			while(!valid)
				surprise = pick(space_surprises)
				if(surprise in spawned_surprises)
					if(prob(20))
						valid++
					else
						continue
				else
					valid++

			spawned_surprises.Add(surprise)
			new surprise(T)

	return 1


