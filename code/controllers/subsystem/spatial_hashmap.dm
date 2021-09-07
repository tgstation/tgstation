SUBSYSTEM_DEF(spatial_hashmap)
	can_fire = FALSE
	init_order = INIT_ORDER_HASHMAP
	name = "Spatial Hashmap"

	var/list/hashmaps_by_z_level = list()

/datum/controller/subsystem/spatial_hashmap/Initialize(start_timeofday)
	. = ..()
	var/cells_per_side = world.maxx / HASHMAP_CELLSIZE //assume world.maxx == world.maxy
	for(var/datum/space_level/z_level as anything in SSmapping.z_list)
		var/list/new_hashmap = list(HASHMAP_CONTENTS_TYPE_HEARING = list(), HASHMAP_CONTENTS_TYPE_CLIENTS = list())//this might do the byond loop unlayering thing
		hashmaps_by_z_level += list(new_hashmap)//new/datum/z_level_hashmap(z_level.z_value)
		for(var/hashmap_type in new_hashmap)
			for(var/y in 1 to cells_per_side)
				new_hashmap[hashmap_type] += list(list())//new_hashmap[hashmap_type] += list(list()) //might actually be faster due to list creation
				for(var/x in 1 to cells_per_side)
					new_hashmap[hashmap_type][y] += list(list())//new_hashmap[hashmap_type][y] += list(list())

/**
 * searches through the hashmap cells intersecting center + range radius and returns the added contents that are also in view
 * much faster than iterating through view() to find what you want for things that arent that common
 */
/datum/controller/subsystem/spatial_hashmap/proc/find_hashmap_contents_in_view(type, atom/center, range, ignore_visibility = FALSE)//should probably just be a global proc but w/e
	var/turf/center_turf = get_turf(center)
	var/list/hashmap = hashmaps_by_z_level[center_turf.z]

	if(range <= 0) //dont use us for single turf looping just look through the turf yourself
		CRASH("/datum/z_level_hashmap/proc/find_hashmap_contents_in_view() was given a range less than or equal to 0! range: [range]")

	if(type != HASHMAP_CONTENTS_TYPE_CLIENTS && type != HASHMAP_CONTENTS_TYPE_HEARING)
		return

	var/list/typed_hashmap = hashmap[type]

	var/x = center_turf.x//TODOKYLER: rename to center_x and center_y
	var/y = center_turf.y

	var/list/contents_to_return = list()

	var/static/hashmap_cells_per_axis = world.maxx / HASHMAP_CELLSIZE//im going to assume this doesnt change at runtime

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((x - range) / HASHMAP_CELLSIZE, 1), 1)
	var/min_y = max(CEILING((y - range) / HASHMAP_CELLSIZE, 1), 1)

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((x + range) / HASHMAP_CELLSIZE, 1), hashmap_cells_per_axis)
	var/max_y = min(CEILING((y + range) / HASHMAP_CELLSIZE, 1), hashmap_cells_per_axis)

	for(var/y_cell_index in min_y to max_y)
		var/list/hashmap_row = typed_hashmap[y_cell_index]
		contents_to_return += hashmap_row.Copy(min_x, max_x)
		//using Copy(min_x, max_x) is about ~4x faster than iterating a second time through min_x to max_x

	var/has_contents_in_range = FALSE
	//now that we have the first list of things to return, filter for things with line of sight to x and y
	for(var/atom/movable/movable_to_check as anything in contents_to_return)
		if(get_dist(center_turf, get_turf(movable_to_check)) <= range)
			has_contents_in_range = TRUE
			break
		contents_to_return -= movable_to_check

	if(!has_contents_in_range || ignore_visibility)
		return contents_to_return

	var/old_lum = center_turf.luminosity
	center_turf.luminosity = 6
	contents_to_return &= view(range, center_turf)//SOMEHOW this isnt the largest cost in this proc
	//(subset of things in view) &= view(range) has very little scaling cost if the subset list is <= 100 things, at that point is nearly identical
	//to the cost of for(var/atom/movable/movable in view(range, turf)) with no expensive stuff inside the for loop
	center_turf.luminosity = old_lum
	return contents_to_return

/datum/controller/subsystem/spatial_hashmap/proc/find_hashmap_contents_in_view_no_view(type, atom/center, range)//should probably just be a global proc but w/e
	var/turf/center_turf = get_turf(center)
	var/list/hashmap = hashmaps_by_z_level[center_turf.z]

	if(range <= 0) //dont use us for single turf looping just look through the turf yourself
		CRASH("/datum/z_level_hashmap/proc/find_hashmap_contents_in_view() was given a range less than or equal to 0! range: [range]")

	if(type != HASHMAP_CONTENTS_TYPE_CLIENTS && type != HASHMAP_CONTENTS_TYPE_HEARING)
		return

	var/list/typed_hashmap = hashmap[type]

	var/x = center_turf.x//TODOKYLER: rename to center_x and center_y
	var/y = center_turf.y

	var/list/contents_to_return = list()

	var/static/hashmap_cells_per_axis = world.maxx / HASHMAP_CELLSIZE//im going to assume this doesnt change at runtime

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((x - range) / HASHMAP_CELLSIZE, 1), 1)
	var/min_y = max(CEILING((y - range) / HASHMAP_CELLSIZE, 1), 1)

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((x + range) / HASHMAP_CELLSIZE, 1), hashmap_cells_per_axis)
	var/max_y = min(CEILING((y + range) / HASHMAP_CELLSIZE, 1), hashmap_cells_per_axis)

	for(var/y_cell_index in min_y to max_y)
		var/list/hashmap_row = typed_hashmap[y_cell_index]
		contents_to_return += hashmap_row.Copy(min_x, max_x)
		//using Copy(min_x, max_x) is about ~4x faster than iterating a second time through min_x to max_x

	if(!length(contents_to_return))
		return

	/*var/has_contents_in_range = FALSE
	//now that we have the first list of things to return, filter for things with line of sight to x and y
	for(var/atom/movable/movable_to_check as anything in contents_to_return)
		if(get_dist(center_turf, get_turf(movable_to_check)) <= range)
			has_contents_in_range = TRUE
			break
		contents_to_return -= movable_to_check

	if(!has_contents_in_range)
		return

	*/

	var/old_lum = center_turf.luminosity
	center_turf.luminosity = 6
	contents_to_return &= view(range, center_turf)//SOMEHOW this isnt the largest cost in this proc
	//(subset of things in view) &= view(range) has very little scaling cost if the subset list is <= 100 things, at that point is nearly identical
	//to the cost of for(var/atom/movable/movable in view(range, turf)) with no expensive stuff inside the for loop
	center_turf.luminosity = old_lum
	return contents_to_return

/atom/proc/benchmark_hashmap_searches(seconds = 4, range = 10)
	var/iterations = 0
	var/duration = seconds SECONDS
	var/turf/our_turf = get_turf(src)
	var/end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		SSspatial_hashmap.find_hashmap_contents_in_view(HASHMAP_CONTENTS_TYPE_HEARING, src, range)
		iterations++

	message_admins("SSspatial_hashmap/proc/find_hashmap_contents_in_view(arg, src, [range]) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		SSspatial_hashmap.find_hashmap_contents_in_view_no_view(HASHMAP_CONTENTS_TYPE_HEARING, src, range)
		iterations++

	message_admins("SSspatial_hashmap/proc/find_hashmap_contents_in_view_no_view(arg, src, [range]) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		view(10, our_turf)
		iterations++

	message_admins("view(10, turf) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		view(3, our_turf)
		iterations++

	message_admins("view(3, turf) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

/atom/proc/benchmark_hashmap(seconds = 2, range = 10)
	var/iterations = 0
	var/duration = seconds SECONDS

	//var/list/x_range = list(max(CEILING((x - range) / HASHMAP_CELLSIZE, 1), 1), min(CEILING((x + range) / HASHMAP_CELLSIZE, 1), world.maxx / HASHMAP_CELLSIZE))
	//var/list/y_range = list(max(CEILING((y - range) / HASHMAP_CELLSIZE, 1), 1), min(CEILING((y + range) / HASHMAP_CELLSIZE, 1), world.maxx / HASHMAP_CELLSIZE))

	var/list/non_assoc_list = list()
	var/list/assoc_fake_non_assoc_list = list()

	var/list/iter_non_assoc_list = list()
	var/list/iter_assoc_list = list()

	for(var/i in 1 to 10000)
		iter_non_assoc_list += i
		iter_assoc_list["[i]"] = i

	for(var/y in 1 to 50)
		non_assoc_list += list(list())
		assoc_fake_non_assoc_list["[y]"] = list()
		for(var/x in 1 to 50)
			non_assoc_list[y] += list(list(100))//list(list(100),list(100),list(100),list(100)...50x),list(list(100),...),...50x
			assoc_fake_non_assoc_list["[y]"]["[x]"] = list(100)

	var/end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		SSspatial_hashmap.find_hashmap_contents_in_view(HASHMAP_CONTENTS_TYPE_HEARING, src, range)
		iterations++

	message_admins("SSspatial_hashmap/proc/find_hashmap_contents_in_view(arg, src, [range]) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		SSspatial_hashmap.find_hashmap_contents_in_view_no_view(HASHMAP_CONTENTS_TYPE_HEARING, src, range)
		iterations++

	message_admins("SSspatial_hashmap/proc/find_hashmap_contents_in_view_no_view(arg, src, [range]) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	var/turf/our_turf = get_turf(src)
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		view(10, our_turf)
		iterations++

	message_admins("view(10, turf) was able to complete [iterations] iterations in [seconds] seconds!")
	var/list/our_range_raw = range(10, our_turf)

	for(var/filter_size in 1 to 101 step 10)
		var/random_offset = rand(0, 20)
		var/list/filtered_initial_range = our_range_raw.Copy(1 + random_offset, filter_size + random_offset)
		iterations = 0
		end_time = world.timeofday + duration

		while(world.timeofday < end_time)

			filtered_initial_range &= view(10, our_turf)
			iterations++

		message_admins("filtered_initial_range (length [filter_size]) &= view(10, our_turf) was able to complete [iterations] iterations in [seconds] seconds!")

	while(world.timeofday < end_time)
		for(var/atom/movable/movable in view(10,our_turf))
			var/i = 1
		iterations++

	message_admins("iterating over all the movables in view(10,turf) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	var/list/non_assoc_output = list()
	var/list/assoc_output = list()
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		for(var/y in 12 to 16)
			for(var/x in 12 to 16)
				non_assoc_output += non_assoc_list[y][x]

		iterations++

	message_admins("going through 16 cells of a non associative list and adding the cells to an output list was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		for(var/y in 12 to 16)
			for(var/x in 12 to 16)
				assoc_output += assoc_fake_non_assoc_list["[y]"]["[x]"]

		iterations++

	message_admins("going through 16 cells of an associative list with number strings as associative indexes and adding the cells to an output list was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	non_assoc_output.Cut()
	assoc_output.Cut()
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		non_assoc_output.Cut()
		for(var/y in 12 to 16)
			var/list/hashmap_row = non_assoc_list[y]
			non_assoc_output += hashmap_row.Copy(12,16)

		iterations++

	message_admins("going through 4 columns of a non associative list and adding a copied 4 cells to an output list was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		get_hearers_in_view_old(10, src)
		iterations++

	message_admins("get_hearers_in_view_old(10, src) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		get_hearers_in_view_hashmap(10, src)
		iterations++

	message_admins("get_hearers_in_view_hashmap(10, src) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		block(locate(x-10, y-10, z), locate(x+10, y+10, z))
		iterations++

	message_admins("block(locate(x-10, y-10, z), locate(x+10, y+10, z)) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		var/turf/turfies = get_turf(src)//get_step(turf, get_dir(turf, target))
		iterations++

	message_admins("turf_var = get_turf(src) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		var/turf/turfies = locate(x,y,z)
		iterations++

	message_admins("turf_var = locate(x,y,z) was able to complete [iterations] iterations in [seconds] seconds!")
	iterations = 0
	var/static/list/closed_typecache = typecacheof(/turf/closed)
	var/list/targets = list()
	//get a random set of targets in range(10,src) and use get_step(src, get_dir(target)) until you reach their turf, continuing if any of the inbetween turfs are closed
	for(var/atom/movable/movable in our_range_raw)
		if(movable in view(10, our_turf))
			continue
		if(length(targets) >= 50)
			break
		targets += movable
	for(var/atom/movable/movable in view(10, our_turf))
		if(length(targets) >= 100)
			break
		targets += movable
	var/list/output_list = list()
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		output_list.Cut()
		for(var/atom/movable/target as anything in targets)
			var/turf/target_turf = get_turf(target)
			if(target_turf == our_turf)
				output_list += target_turf
				continue
			var/turf/inbetween_turf = get_step(target_turf, get_dir(our_turf, target_turf))
			if(inbetween_turf == target_turf)
				output_list += target_turf
				continue
			if(!inbetween_turf.opacity)//this turf is closed and opaque so we cant see it
				continue

		iterations++

	var/false_entries = 0
	for(var/atom/movable/movable as anything in output_list)
		var/old_lum = our_turf.luminosity
		our_turf.luminosity = 6
		if(!(movable in view(10, our_turf)))
			false_entries++
		our_turf.luminosity = old_lum

	message_admins("the turf search algorithm [!false_entries ? "was completely accurate" : "had [false_entries] false positives"] and was able to do [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

/atom/proc/benchmark_target_search(seconds = 2)
	var/iterations = 0
	var/duration = seconds SECONDS
	var/turf/our_turf = get_turf(src)
	var/end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		view(10, our_turf)
		iterations++

	message_admins("view(10, turf) was able to complete [iterations] iterations in [seconds] seconds!")
	var/list/our_range_raw = range(10, our_turf)

	for(var/filter_size in 1 to 101 step 10)
		var/random_offset = rand(0, 20)
		var/list/filtered_initial_range = our_range_raw.Copy(1 + random_offset, filter_size + random_offset)
		iterations = 0
		end_time = world.timeofday + duration

		while(world.timeofday < end_time)

			filtered_initial_range &= view(10, our_turf)
			iterations++

		message_admins("filtered_initial_range (length [filter_size]) &= view(10, our_turf) was able to complete [iterations] iterations in [seconds] seconds!")

	var/list/targets = list()
	//get a random set of targets in range(10,src) and use get_step(src, get_dir(target)) until you reach their turf, continuing if any of the inbetween turfs are closed
	for(var/atom/movable/movable in our_range_raw)
		if(movable in view(10, our_turf))
			continue
		if(length(targets) >= 50)
			break
		targets += movable
	for(var/atom/movable/movable in view(10, our_turf))
		if(length(targets) >= 100)
			break
		targets += movable
	var/list/output_list = list()
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		output_list.Cut()
		for(var/atom/movable/target as anything in targets)
			//var/end_found = FALSE
			var/turf/target_turf = get_turf(target)
			if(target_turf == our_turf)
				output_list += target
				continue
			var/turf/inbetween_turf = our_turf
			while(TRUE)
				inbetween_turf = get_step(inbetween_turf, get_dir(inbetween_turf, target_turf))
				if(inbetween_turf == target_turf)
					output_list += target
					break
				if(inbetween_turf.opacity)//this turf is opaque so we cant see through it
					break

		iterations++

	var/false_entries = 0
	for(var/atom/movable/movable as anything in output_list)
		var/old_lum = our_turf.luminosity
		our_turf.luminosity = 6
		if(!(movable in view(10, our_turf)))
			false_entries++
		our_turf.luminosity = old_lum

	message_admins("the turf search algorithm [!false_entries ? "was completely accurate" : "had [false_entries] false positives"] and was able to do [iterations] iterations in [seconds] seconds!")
	iterations = 0
	var/list/initial_targets = targets.Copy()
	end_time = world.timeofday + duration

	while(world.timeofday < end_time)
		initial_targets = targets.Copy()
		initial_targets &= view(10, our_turf)
		iterations++

	var/both_are_equal = TRUE
	for(var/atom/movable/movable as anything in initial_targets)
		if(!(movable in output_list))
			both_are_equal = FALSE
			break

	message_admins("targets &= view(10, our_tuirf) [both_are_equal ? "has the same output as the turf search algorith" : "had a different output as the turf search algorithm"] and was able to do [iterations] iterations in [seconds] seconds!")
	iterations = 0
	end_time = world.timeofday + duration

///get the hashmap cell encomapassing targets coordinates and of the specified type
/datum/controller/subsystem/spatial_hashmap/proc/get_cell_of(atom/target, type)
	var/turf/target_turf = get_turf(target)

	var/list/hashmap = hashmaps_by_z_level[target_turf.z][type]

	var/list/cell_to_return = hashmap[CEILING(target_turf.y / HASHMAP_CELLSIZE, 1)][CEILING(target_turf.x / HASHMAP_CELLSIZE, 1)]
	return cell_to_return

/datum/z_level_hashmap
	///associative list of all /datum/spatial_hashmap_cell's for this z level, of the form: list("[x][y] = cell at those coordinates")
	var/list/cells = list()

	var/z_level

/datum/z_level_hashmap/New(z_level)
	. = ..()
	src.z_level = z_level
	var/cells_per_side = world.maxx / HASHMAP_CELLSIZE //assume world.maxx == world.maxy
	//var/starting_offset = CEILING(HASHMAP_CELLSIZE/2, 1)
	for(var/y in 1 to cells_per_side)
		cells["[y]"] = list()
		for(var/x in 1 to cells_per_side)
			//var/cell_x = 1 + x * HASHMAP_CELLSIZE //this generates the COORDINATES of a cell
			//var/cell_y = 1 + y * HASHMAP_CELLSIZE //note that this isnt used
			cells["[y]"]["[x]"] = list(HASHMAP_CONTENTS_TYPE_HEARING = list(), HASHMAP_CONTENTS_TYPE_CLIENTS = list())//new/datum/spatial_hashmap_cell(x, y) //1,1 | 1,2 | 1,3 | 1,4 | 1,5 | 1,6 | 1,7 ...

/datum/z_level_hashmap/proc/get_cell_by_coordinates(atom/point)
	var/turf/point_turf = get_turf(point)
	var/cell_x = CEILING(point_turf.x / HASHMAP_CELLSIZE, 1) //251 / 5 = 50.2 ceil(50.2) = 51
	var/cell_y = CEILING(point_turf.y / HASHMAP_CELLSIZE, 1) //1 / 5 = 0.2 ceil(0.2) = 1

	return cells["[cell_y]"]["[cell_x]"]

/**
 * finds all hashmap cells in range of the specified coordinates
 * then outputs all of the specified contents type of the cells that are in range that arent blocked by walls
 */
/datum/z_level_hashmap/proc/find_hashmap_contents_in_view(type, atom/center, range)
	if(range < 0) //dont use us for single turf looping just look through the turf yourself TODOKYLER: actually enforce this
		CRASH("/datum/z_level_hashmap/proc/find_hashmap_contents_in_view() was given a range less than or equal to 0! range: [range]")

	var/turf/center_turf = get_turf(center)
	if(!center_turf)
		CRASH("no turf for the center argument given to find_hashmap_contents_in_view()!")

	var/x = center_turf.x//rename to center_x and center_y
	var/y = center_turf.y

	//var/list/intersecting_cells = list()
	var/list/contents_to_return = list()

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((x - range) / HASHMAP_CELLSIZE, 1), 1)
	var/min_y = max(CEILING((y - range) / HASHMAP_CELLSIZE, 1), 1)

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((x + range) / HASHMAP_CELLSIZE, 1), world.maxx / HASHMAP_CELLSIZE)
	var/max_y = min(CEILING((y + range) / HASHMAP_CELLSIZE, 1), world.maxx / HASHMAP_CELLSIZE)

	for(var/y_cell_index in min_y to max_y)
		for(var/x_cell_index in min_x to max_x)
			var/datum/spatial_hashmap_cell/cell = cells["[x_cell_index],[y_cell_index]"]
			if(!cell)
				stack_trace("there is no hashmap cell at index [x_cell_index],[y_cell_index] for z level [z_level]!")
				continue
			switch(type)//this is dumb but whatever, this is why cells shouldnt exist and should just be nested associative list in the cells list
				if(HASHMAP_CONTENTS_TYPE_HEARING)
					if(length(cell.hearing_contents))
						contents_to_return += cell.hearing_contents
				if(HASHMAP_CONTENTS_TYPE_CLIENTS)
					if(length(cell.client_contents))
						contents_to_return += cell.client_contents

	var/has_contents_in_range = FALSE
	//now that we have the first list of things to return, filter for things with line of sight to x and y
	for(var/atom/movable/movable_to_check as anything in contents_to_return)
		if(get_dist(center_turf, get_turf(movable_to_check)) <= range)
			has_contents_in_range = TRUE
			break

	if(!has_contents_in_range)
		return

	var/old_lum = center_turf.luminosity
	center_turf.luminosity = 6
	contents_to_return &= view(range, center_turf)
	center_turf.luminosity = old_lum
	return contents_to_return

/datum/spatial_hashmap_cell
	///our x index in the list of cells
	var/cell_x
	///our y index in the list of cells
	var/cell_y

	//every data point in a hashmap cell is separated by usecase TODOKYLER: maybe make this not lazy?

	///every hearing sensitive movable inside this cell
	var/list/hearing_contents
	///every client possessed movable inside this cell
	var/list/client_contents

/datum/spatial_hashmap_cell/New(cell_x, cell_y)
	. = ..()
	src.cell_x = cell_x
	src.cell_y = cell_y

//TODOKYLER: might be worth it to instead attach an element to hashmappable objects that does this due to proc call overhead stacking with each parent call
/turf/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!LAZYLEN(arrived.important_recursive_contents) || !(arrived.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] || arrived.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
		return
	//this is turf/Entered so we know both arrived and us have nonzero coords but we dont know if old_loc does
	if(old_loc?.z == z && CEILING(old_loc.x / HASHMAP_CELLSIZE, 1) == CEILING(x / HASHMAP_CELLSIZE, 1) && CEILING(old_loc.y / HASHMAP_CELLSIZE, 1) == CEILING(y / HASHMAP_CELLSIZE, 1))
		return //both the old location and the new one are in the same hashmap cell

	var/list/our_cell

	if(LAZYACCESS(arrived.important_recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS))
		our_cell = SSspatial_hashmap.get_cell_of(src, RECURSIVE_CONTENTS_CLIENT_MOBS)
		our_cell += arrived.important_recursive_contents[HASHMAP_CONTENTS_TYPE_CLIENTS]

	if(LAZYACCESS(arrived.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE))
		our_cell = SSspatial_hashmap.get_cell_of(src, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
		our_cell += arrived.important_recursive_contents[HASHMAP_CONTENTS_TYPE_HEARING]

/turf/Exited(atom/movable/gone, direction)
	. = ..()
	if(!LAZYLEN(gone.important_recursive_contents) || !(gone.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] || gone.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
		return
	var/turf/gone_turf = get_turf(gone)
	//this is turf/Exited so we know we have nonzero coords but we dont know if gone has nonzero coords
	if(gone_turf == src || gone_turf?.z == z && CEILING(gone_turf.x / HASHMAP_CELLSIZE, 1) == CEILING(x / HASHMAP_CELLSIZE, 1) && CEILING(gone_turf.y / HASHMAP_CELLSIZE, 1) == CEILING(y / HASHMAP_CELLSIZE, 1))
		return //both the old location and the new one are in the same hashmap cell

	var/list/our_cell

	if(gone.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		our_cell = SSspatial_hashmap.get_cell_of(src, RECURSIVE_CONTENTS_CLIENT_MOBS)
		our_cell -= gone.important_recursive_contents[HASHMAP_CONTENTS_TYPE_CLIENTS]

	if(gone.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])
		our_cell = SSspatial_hashmap.get_cell_of(src, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
		our_cell -= gone.important_recursive_contents[HASHMAP_CONTENTS_TYPE_HEARING]
