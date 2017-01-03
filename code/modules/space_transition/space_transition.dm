//This is a simple 3 by 3 grid working off the corpse of the space torus. The donut is dead, cube has been avenged!

#define Z_LEVEL_NORTH 		"1"
#define Z_LEVEL_SOUTH 		"2"
#define Z_LEVEL_EAST 		"4"
#define Z_LEVEL_WEST 		"8"


var/list/z_levels_list = list()

/datum/space_level
	var/name = "Your config settings failed, you need to fix this for the datum space levels to work"
	var/list/neigbours = list()
	var/z_value = 1 //actual z placement
	var/linked = SELFLOOPING
	var/xi
	var/yi   //imaginary placements on the grid

/datum/space_level/New(transition_type)
	linked = transition_type
	if(linked == SELFLOOPING)
		neigbours = list()
		var/list/L = list(Z_LEVEL_NORTH,Z_LEVEL_SOUTH,Z_LEVEL_EAST,Z_LEVEL_WEST)
		for(var/A in L)
			neigbours[A] = src

/datum/space_level/proc/set_neigbours(list/L)
	for(var/datum/point/P in L)
		if(P.x == xi)
			if(P.y == yi+1)
				neigbours[Z_LEVEL_NORTH] = P.spl
				P.spl.neigbours[Z_LEVEL_SOUTH] = src
			else if(P.y == yi-1)
				neigbours[Z_LEVEL_SOUTH] = P.spl
				P.spl.neigbours[Z_LEVEL_NORTH] = src
		else if(P.y == yi)
			if(P.x == xi+1)
				neigbours[Z_LEVEL_EAST] = P.spl
				P.spl.neigbours[Z_LEVEL_WEST] = src
			else if(P.x == xi-1)
				neigbours[Z_LEVEL_WEST] = P.spl
				P.spl.neigbours[Z_LEVEL_EAST] = src

/datum/point          //this is explicitly utilitarian datum type made specially for the space map generation and are absolutely unusable for anything else
	var/list/neigbours = list()
	var/x
	var/y
	var/datum/space_level/spl

/datum/point/New(nx, ny, list/point_grid)
	if(!point_grid)
		qdel(src)
		return
	var/list/L = point_grid[1]
	if(nx > point_grid.len || ny > L.len)
		qdel(src)
		return
	x = nx
	y = ny
	if(point_grid[x][y])
		return
	point_grid[x][y] = src

/datum/point/proc/set_neigbours(list/grid)
	var/max_X = grid.len
	var/list/max_Y = grid[1]
	max_Y = max_Y.len
	neigbours.Cut()
	if(x+1 <= max_X)
		neigbours |= grid[x+1][y]
	if(x-1 >= 1)
		neigbours |= grid[x-1][y]
	if(y+1 <= max_Y)
		neigbours |= grid[x][y+1]
	if(y-1 >= 1)
		neigbours |= grid[x][y-1]

/proc/setup_map_transitions() //listamania
	var/list/SLS = list()
	var/datum/space_level/D
	var/conf_set_len = map_transition_config.len
	var/k = 1
	for(var/A in map_transition_config)
		D = new(map_transition_config[A])
		D.name = A
		D.z_value = k
		if(D.linked != CROSSLINKED)
			z_levels_list["[D.z_value]"] = D
		else
			SLS.Add(D)
		k++
	var/list/point_grid[conf_set_len*2+1][conf_set_len*2+1]
	var/list/grid = list()
	var/datum/point/P
	for(var/i = 1, i<=conf_set_len*2+1, i++)
		for(var/j = 1, j<=conf_set_len*2+1, j++)
			P = new/datum/point(i,j, point_grid)
			point_grid[i][j] = P
			grid.Add(P)
	for(var/datum/point/pnt in grid)
		pnt.set_neigbours(point_grid)
	P = point_grid[conf_set_len+1][conf_set_len+1]
	var/list/possible_points = list()
	var/list/used_points = list()
	grid.Cut()
	while(SLS.len)
		D = pick_n_take(SLS)
		D.xi = P.x
		D.yi = P.y
		P.spl = D
		possible_points |= P.neigbours
		used_points |= P
		possible_points.Remove(used_points)
		D.set_neigbours(used_points)
		P = pick(possible_points)
		grid["[D.z_value]"] = D

	for(var/A in z_levels_list)
		grid[A] = z_levels_list[A]

	//Lists below are pre-calculated values arranged in the list in such a way to be easily accessable in the loop by the counter
	//Its either this or madness with lotsa math

	var/list/x_pos_beginning = list(1, 1, world.maxx - TRANSITIONEDGE, 1)  //x values of the lowest-leftest turfs of the respective 4 blocks on each side of zlevel
	var/list/y_pos_beginning = list(world.maxy - TRANSITIONEDGE, 1, TRANSITIONEDGE, TRANSITIONEDGE)  //y values respectively
	var/list/x_pos_ending = list(world.maxx, world.maxx, world.maxx, TRANSITIONEDGE)	//x values of the highest-rightest turfs of the respective 4 blocks on each side of zlevel
	var/list/y_pos_ending = list(world.maxy, TRANSITIONEDGE, world.maxy - TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)	//y values respectively
	var/list/x_pos_transition = list(1, 1, TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)		//values of x for the transition from respective blocks on the side of zlevel, 1 is being translated into turfs respective x value later in the code
	var/list/y_pos_transition = list(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2, 1, 1)		//values of y for the transition from respective blocks on the side of zlevel, 1 is being translated into turfs respective y value later in the code

	for(var/zlevelnumber = 1, zlevelnumber<=grid.len, zlevelnumber++)
		D = grid["[zlevelnumber]"]
		if(!D)
			CRASH("[zlevelnumber] position has no space level datum.")
		if(!(D.neigbours.len))
			continue
		for(var/side = 1, side<5, side++)
			var/turf/beginning = locate(x_pos_beginning[side], y_pos_beginning[side], zlevelnumber)
			var/turf/ending = locate(x_pos_ending[side], y_pos_ending[side], zlevelnumber)
			var/list/turfblock = block(beginning, ending)
			var/dirside = 2**(side-1)
			var/zdestination = zlevelnumber
			if(D.neigbours["[dirside]"] && D.neigbours["[dirside]"] != D)
				D = D.neigbours["[dirside]"]
				zdestination = D.z_value
			else
				dirside = turn(dirside, 180)
				while(D.neigbours["[dirside]"] && D.neigbours["[dirside]"] != D)
					D = D.neigbours["[dirside]"]
				zdestination = D.z_value
			D = grid["[zlevelnumber]"]
			for(var/turf/open/space/S in turfblock)
				S.destination_x = x_pos_transition[side] == 1 ? S.x : x_pos_transition[side]
				S.destination_y = y_pos_transition[side] == 1 ? S.y : y_pos_transition[side]
				S.destination_z = zdestination
				//S.maptext = "[zdestination]" // for debugging

	for(var/A in grid)
		z_levels_list[A] = grid[A]

#undef Z_LEVEL_NORTH
#undef Z_LEVEL_SOUTH
#undef Z_LEVEL_EAST
#undef Z_LEVEL_WEST
