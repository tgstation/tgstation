//This is realisation of the working torus-looping randomized-per-round space map, this kills the cube

#define Z_LEVEL_NORTH 		"1"
#define Z_LEVEL_SOUTH 		"2"
#define Z_LEVEL_EAST 		"4"
#define Z_LEVEL_WEST 		"8"


var/list/z_levels_list = list()

/datum/space_level
	var/name = "Your config settings failed, you need to fix this for the datum space levels to work"
	var/list/neigbours
	var/z_value = 1 //actual z placement
	var/linked = 1
	var/xi
	var/yi   //imaginary placements on the grid

/datum/space_level/New()
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


//config/space_levels.txt is where you define your zlevel datum names, their connection to actual z levels and if you want them connected to one another or not
//Grammar: Name;z value;linked/unlinked
//Name is the name of the datum, just for the sake of it
//z value is to what actual map z level this datum is pointing
//linked/unlinked decide if you want the z level in the general map or not, for example centcomm is not reachable
//Each entry must be separated with a single empty line, no spaces outside the name
//No comments in the file allowed

/proc/setup_map_transitions() //listamania
	var/list/SLS = file2list("config/space_levels.txt", "\n\n")
	var/datum/space_level/D
	var/list/config_settings[SLS.len][]
	for(var/A in SLS)
		config_settings[SLS.Find(A)] = text2list(A, ";")
	var/conf_set_len = SLS.len
	SLS.Cut()
	for(var/A in config_settings)
		D = new()
		D.name = A[1]
		D.z_value = text2num(A[2])
		if(A[3] != "linked")
			D.linked = 0
			z_levels_list["[D.z_value]"] = D
		else
			SLS.Add(D)
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
	P = point_grid[conf_set_len][conf_set_len]
	var/list/possible_points = list()
	var/list/used_points = list()
	grid.Cut()
	while(SLS.len)
		D = pick(SLS)
		SLS.Remove(D)
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

	for(var/turf/space/S in world) //Define the transistions of the z levels
		if(S.x <= TRANSITIONEDGE)
			D = grid["[S.z]"]
			if(D.neigbours[Z_LEVEL_WEST] != D)
				D = D.neigbours[Z_LEVEL_WEST]
				S.destination_z = D.z_value
			else
				while(D.neigbours[Z_LEVEL_EAST] != D)
					D = D.neigbours[Z_LEVEL_EAST]
				S.destination_z = D.z_value
			S.destination_x = world.maxx - TRANSITIONEDGE - 2
			S.destination_y = S.y

		if(S.x >= (world.maxx - TRANSITIONEDGE - 1))
			D = grid["[S.z]"]
			if(D.neigbours[Z_LEVEL_EAST] != D)
				D = D.neigbours[Z_LEVEL_EAST]
				S.destination_z = D.z_value
			else
				while(D.neigbours[Z_LEVEL_WEST] != D)
					D = D.neigbours[Z_LEVEL_WEST]
				S.destination_z = D.z_value
			S.destination_x = TRANSITIONEDGE + 2
			S.destination_y = S.y

		if(S.y <= TRANSITIONEDGE)
			D = grid["[S.z]"]
			if(D.neigbours[Z_LEVEL_SOUTH] != D)
				D = D.neigbours[Z_LEVEL_SOUTH]
				S.destination_z = D.z_value
			else
				while(D.neigbours[Z_LEVEL_NORTH] != D)
					D = D.neigbours[Z_LEVEL_NORTH]
				S.destination_z = D.z_value
			S.destination_x = S.x
			S.destination_y = world.maxy - TRANSITIONEDGE - 2

		if(S.y >= (world.maxy - TRANSITIONEDGE - 1))
			D = grid["[S.z]"]
			if(D.neigbours[Z_LEVEL_NORTH] != D)
				D = D.neigbours[Z_LEVEL_NORTH]
				S.destination_z = D.z_value
			else
				while(D.neigbours[Z_LEVEL_SOUTH] != D)
					D = D.neigbours[Z_LEVEL_SOUTH]
				S.destination_z = D.z_value
			S.destination_x = S.x
			S.destination_y = TRANSITIONEDGE + 2

	for(var/A in grid)
		z_levels_list[A] = grid[A]

#undef Z_LEVEL_NORTH
#undef Z_LEVEL_SOUTH
#undef Z_LEVEL_EAST
#undef Z_LEVEL_WEST