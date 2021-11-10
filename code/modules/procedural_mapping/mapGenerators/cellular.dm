// Very Simple Cellular Automata generators
// Mostly for better caves
// Should probably move these up and refactor modules so these can be mixed with other ones

/datum/map_generator/ca
	var/list/b_rule = list() // 0 -> 1, 1 -> 1
	var/list/s_rule = list() // 0 -> 0, 1 -> 1
	var/iterations = 1
	var/loop_edges = 0
	var/edge_value = 1 //if loop_edges = 0
	var/list/old_state
	var/list/current_state
	var/width = 10
	var/height = 10
	var/list/type_map = list(/turf/open/floor/plating, /turf/closed/wall)
	var/turf/start = null

/datum/map_generator/ca/defineRegion(turf/Start, turf/End, replace = 0)
	. = ..()

	var/min_x = min(Start.x,End.x)
	var/max_x = max(Start.x,End.x)
	var/min_y = min(Start.y,End.y)
	var/max_y = max(Start.y,End.y)
	width = max_x - min_x
	height = max_y - min_y

	//We assume 2D everywhere anyway
	start = locate(min_x,min_y,Start.z)

/datum/map_generator/ca/proc/initialize()
	old_state = new/list(width)
	for(var/x in 1 to width)
		old_state[x] = new/list(height)
		for(var/y in 1 to height)
			old_state[x][y] = rand(0,1)

	current_state = old_state.Copy()

/datum/map_generator/ca/generate()
	//Abandon all hope for efficency all who enter here
	//Maybe some less basic implemetation later, but this is just simple admin tool
	initialize()

	for(var/generation in 1 to iterations)
		for(var/x in 1 to width)
			for(var/y in 1 to height)
				current_state[x][y] = apply_rule(x, y)
		//copy state over
		old_state = current_state.Copy()

	for(var/x in 1 to width)
		for(var/y in 1 to height)
			var/turf/T = locate(start.x+x-1,start.y+y-1,start.z)
			if(T)
				T.ChangeTurf(type_map[current_state[x][y]+1])

/datum/map_generator/ca/proc/apply_rule(x, y)
	var/value = 0
	for(var/dist_x in -1 to 1)
		for(var/dist_y in -1 to 1)
			var/n_x = x+dist_x
			var/n_y = y+dist_y
			if(n_x < 1 || n_x > width || n_y <1 || n_y > height)
				if(loop_edges)
					if(n_x < 1)
						n_x = width
					else if(n_x > width)
						n_x = 1
					if(n_y < 1)
						n_y = height
					else if(n_y > height)
						n_y = 1
				else
					value += edge_value
					continue
			value += old_state[n_x][n_y]
	value -= old_state[x][y]

	if(value in b_rule)
		return 1
	if(value in s_rule)
		return old_state[x][y]
	return 0

/datum/map_generator/ca/caves
	b_rule = list(5,6,7,8)
	s_rule = list(4)
	type_map = list(/turf/open/floor/plating/asteroid/basalt, /turf/closed/mineral/volcanic)
	iterations = 5

/datum/map_generator/ca/maze
	b_rule = list(3)
	s_rule = list(1,2,3,4,5)
	iterations = 20
	edge_value = 0
