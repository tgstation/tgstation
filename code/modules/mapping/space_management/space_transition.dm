/datum/space_level/proc/set_linkage(new_linkage)
	linkage = new_linkage
	if(linkage == SELFLOOPING)
		neigbours = list(TEXT_NORTH,TEXT_SOUTH,TEXT_EAST,TEXT_WEST)
		for(var/A in neigbours)
			neigbours[A] = src

/datum/space_level/proc/set_neigbours(list/L)
	for(var/datum/space_transition_point/P in L)
		if(P.x == xi)
			if(P.y == yi+1)
				neigbours[TEXT_NORTH] = P.spl
				P.spl.neigbours[TEXT_SOUTH] = src
			else if(P.y == yi-1)
				neigbours[TEXT_SOUTH] = P.spl
				P.spl.neigbours[TEXT_NORTH] = src
		else if(P.y == yi)
			if(P.x == xi+1)
				neigbours[TEXT_EAST] = P.spl
				P.spl.neigbours[TEXT_WEST] = src
			else if(P.x == xi-1)
				neigbours[TEXT_WEST] = P.spl
				P.spl.neigbours[TEXT_EAST] = src

#define CHORDS_TO_1D(x, y, grid_diameter) ((x) + ((y) - 1) * (grid_diameter))
/datum/space_transition_point          //this is explicitly utilitarian datum type made specially for the space map generation and are absolutely unusable for anything else
	var/list/neigbours = list()
	var/x
	var/y
	var/datum/space_level/spl

/datum/space_transition_point/New(nx, ny, list/grid)
	if(!grid)
		qdel(src)
		return
	var/grid_diameter = sqrt(length(grid))
	if(nx > grid_diameter || ny > grid_diameter)
		stack_trace("Attempted to set a position outside the size of [grid_diameter]")
		qdel(src)
		return
	x = nx
	y = ny
	var/position = CHORDS_TO_1D(x, y, grid_diameter)
	if(grid[position])
		return
	grid[position] = src

/datum/space_transition_point/proc/set_neigbours(list/grid, size)
	neigbours.Cut()

	if(x+1 <= size)
		neigbours |= grid[CHORDS_TO_1D(x+1, y, size)]
	if(x-1 >= 1)
		neigbours |= grid[CHORDS_TO_1D(x-1, y, size)]
	if(y+1 <= size)
		neigbours |= grid[CHORDS_TO_1D(x, y + 1, size)]
	if(y-1 >= 1)
		neigbours |= grid[CHORDS_TO_1D(x, y - 1, size)]

/datum/controller/subsystem/mapping/proc/setup_map_transitions() //listamania
	var/list/transition_levels = list()
	var/list/cached_z_list = z_list
	for(var/datum/space_level/level as anything in cached_z_list)
		if (level.linkage == CROSSLINKED)
			transition_levels.Add(level)

	var/grid_diameter = (length(transition_levels) * 2) + 1
	var/list/grid = new /list(grid_diameter ** 2)

	var/datum/space_transition_point/point
	for(var/x in 1 to grid_diameter)
		for(var/y in 1 to grid_diameter)
			point = new/datum/space_transition_point(x, y, grid)
			grid[CHORDS_TO_1D(x, y, grid_diameter)] = point
	for(point as anything in grid)
		point.set_neigbours(grid, grid_diameter)

	var/center = round(grid_diameter / 2)
	point = grid[CHORDS_TO_1D(grid_diameter, center, center)]
	grid.Cut()

	var/list/transition_pick = transition_levels.Copy()
	var/list/possible_points = list()
	var/list/used_points = list()
	while(transition_pick.len)
		var/datum/space_level/level = pick_n_take(transition_pick)
		level.xi = point.x
		level.yi = point.y
		point.spl = level
		possible_points |= point.neigbours
		used_points |= point
		possible_points.Remove(used_points)
		level.set_neigbours(used_points)
		point = pick(possible_points)
		CHECK_TICK

	// Now that we've handed out neighbors, we're gonna handle an edge case
	// Need to check if all our levels have neighbors in all directions
	// If they don't, we'll make them wrap all the way around to the other side of the grid
	for(var/direction in GLOB.cardinals)
		var/dir = "[direction]"
		var/inverse = "[turn(direction, 180)]"
		for(var/datum/space_level/level as anything in transition_levels)
			// If we have something in this dir that isn't just us, continue on
			if(level.neigbours[dir] && level.neigbours[dir] != level)
				continue
			var/datum/space_level/head = level
			while(head.neigbours[inverse] && head.neigbours[inverse] != head)
				head = head.neigbours[inverse]

			// Alllright we've landed on someone who we can wrap around onto safely, let's make that connection yeah?
			head.neigbours[inverse] = level
			level.neigbours[dir] = head

	//Lists below are pre-calculated values arranged in the list in such a way to be easily accessable in the loop by the counter
	//Its either this or madness with lotsa math
	var/inner_max_x = world.maxx - TRANSITIONEDGE
	var/inner_max_y = world.maxy - TRANSITIONEDGE
	var/list/x_pos_beginning = list(1, 1, inner_max_x, 1)  //x values of the lowest-leftest turfs of the respective 4 blocks on each side of zlevel
	var/list/y_pos_beginning = list(inner_max_y, 1, 1 + TRANSITIONEDGE, 1 + TRANSITIONEDGE)  //y values respectively
	var/list/x_pos_ending = list(world.maxx, world.maxx, world.maxx, 1 + TRANSITIONEDGE) //x values of the highest-rightest turfs of the respective 4 blocks on each side of zlevel
	var/list/y_pos_ending = list(world.maxy, 1 + TRANSITIONEDGE, inner_max_y, inner_max_y) //y values respectively
	var/list/x_pos_transition = list(1, 1, TRANSITIONEDGE + 2, inner_max_x - 1) //values of x for the transition from respective blocks on the side of zlevel, 1 is being translated into turfs respective x value later in the code
	var/list/y_pos_transition = list(TRANSITIONEDGE + 2, inner_max_y - 1, 1, 1) //values of y for the transition from respective blocks on the side of zlevel, 1 is being translated into turfs respective y value later in the code

	for(var/datum/space_level/level as anything in cached_z_list)
		if(!level.neigbours.len)
			continue
		var/zlevelnumber = level.z_value
		for(var/side in 1 to 4)
			var/turf/beginning = locate(x_pos_beginning[side], y_pos_beginning[side], zlevelnumber)
			var/turf/ending = locate(x_pos_ending[side], y_pos_ending[side], zlevelnumber)
			var/list/turfblock = block(beginning, ending)
			var/dirside = 2**(side-1)
			var/x_target = x_pos_transition[side] == 1 ? 0 : x_pos_transition[side]
			var/y_target = y_pos_transition[side] == 1 ? 0 : y_pos_transition[side]
			var/datum/space_level/neighbor = level.neigbours["[dirside]"]
			var/zdestination = neighbor.z_value

			for(var/turf/open/space/S in turfblock)
				S.destination_x = x_target || S.x
				S.destination_y = y_target || S.y
				S.destination_z = zdestination

				// Mirage border code
				var/mirage_dir
				if(S.x == 1 + TRANSITIONEDGE)
					mirage_dir |= WEST
				else if(S.x == inner_max_x)
					mirage_dir |= EAST
				if(S.y == 1 + TRANSITIONEDGE)
					mirage_dir |= SOUTH
				else if(S.y == inner_max_y)
					mirage_dir |= NORTH
				if(!mirage_dir)
					continue

				var/turf/place = locate(S.destination_x, S.destination_y, zdestination)
				S.AddComponent(/datum/component/mirage_border, place, mirage_dir)

#undef CHORDS_TO_1D
