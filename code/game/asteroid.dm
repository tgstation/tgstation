var/global/list/spawned_surprises = list()

var/global/max_secret_rooms = 3

/* Le broken.
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
*/

proc/check_complex_placement(var/turf/T,var/size_x,var/size_y,var/ignore_walls=0)
	var/list/surroundings = list()

	surroundings |= range(7, locate(T.x,T.y,T.z))
	surroundings |= range(7, locate(T.x+size_x,T.y,T.z))
	surroundings |= range(7, locate(T.x,T.y+size_y,T.z))
	surroundings |= range(7, locate(T.x+size_x,T.y+size_y,T.z))

	if(locate(/area/mine/explored) in surroundings)			// +5s are for view range
		return 0

	if(locate(/turf/space) in surroundings)
		return 0

	/* /vg/: Allow combining rooms.
	if(locate(/area/asteroid/artifactroom) in surroundings)
		return 0

	if(locate(/turf/unsimulated/floor/asteroid) in surroundings)
		return 0
	*/

	// /vg/: Stop spawning shit inside of the vox hideout
	if(locate(/turf/simulated/wall) in surroundings && !ignore_walls)
		return 0
	return 1

proc/make_mining_asteroid_secret()
	var/turf/T = null
	var/sanity = 0
	var/list/turfs = null

	turfs = get_area_turfs(/area/mine/unexplored)

	if(!turfs.len)
		return 0

	while(1)
		sanity++
		if(sanity > 100)
			testing("Tried to place complex too many times.  Aborting.")
			return 0

		T=pick(turfs)

		var/complex_type=pick(mining_surprises)
		var/mining_surprise/complex = new complex_type

		if(complex.spawn_complex(T))
			spawned_surprises += complex
			return 1

	return 0


