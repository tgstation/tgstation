
// Basic transit tubes. Straight pieces, curved sections,
//  and basic splits/joins (no routing logic).
// Mappers: you can use "Generate Instances from Icon-states"
//  to get the different pieces.
/obj/structure/transit_tube
	icon = 'icons/obj/pipes/transit_tube.dmi'
	icon_state = "E-W"
	density = 1
	layer = 3.1
	anchored = 1.0
	var/list/tube_dirs = null
	var/exit_delay = 2
	var/enter_delay = 1

	// alldirs in global.dm is the same list of directions, but since
	//  the specific order matters to get a usable icon_state, it is
	//  copied here so that, in the unlikely case that alldirs is changed,
	//  this continues to work.
	var/global/list/tube_dir_list = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)


// When destroyed by explosions, properly handle contents.
obj/structure/transit_tube/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/AM in contents)
				AM.loc = loc
				AM.ex_act(severity++)

			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/AM in contents)
					AM.loc = loc
					AM.ex_act(severity++)

				qdel(src)
				return
		if(3.0)
			return


/obj/structure/transit_tube/New(loc)
	..(loc)

	if(tube_dirs == null)
		init_dirs()


// Called to check if a pod should stop upon entering this tube.
/obj/structure/transit_tube/proc/should_stop_pod(pod, from_dir)
	return 0

// Called when a pod stops in this tube section.
/obj/structure/transit_tube/proc/pod_stopped(pod, from_dir)
	return


// Returns a /list of directions this tube section can connect to.
//  Tubes that have some sort of logic or changing direction might
//  override it with additional logic.
/obj/structure/transit_tube/proc/directions()
	return tube_dirs



/obj/structure/transit_tube/proc/has_entrance(from_dir)
	from_dir = turn(from_dir, 180)

	for(var/direction in directions())
		if(direction == from_dir)
			return 1

	return 0



/obj/structure/transit_tube/proc/has_exit(in_dir)
	for(var/direction in directions())
		if(direction == in_dir)
			return 1

	return 0



// Searches for an exit direction within 45 degrees of the
//  specified dir. Returns that direction, or 0 if none match.
/obj/structure/transit_tube/proc/get_exit(in_dir)
	var/near_dir = 0
	var/in_dir_cw = turn(in_dir, -45)
	var/in_dir_ccw = turn(in_dir, 45)

	for(var/direction in directions())
		if(direction == in_dir)
			return direction

		else if(direction == in_dir_cw)
			near_dir = direction

		else if(direction == in_dir_ccw)
			near_dir = direction

	return near_dir


// Return how many BYOND ticks to wait before entering/exiting
//  the tube section. Default action is to return the value of
//  a var, which wouldn't need a proc, but it makes it possible
//  for later tube types to interact in more interesting ways
//  such as being very fast in one direction, but slow in others
/obj/structure/transit_tube/proc/exit_delay(pod, to_dir)
	return exit_delay

/obj/structure/transit_tube/proc/enter_delay(pod, to_dir)
	return enter_delay


// Parse the icon_state into a list of directions.
// This means that mappers can use Dream Maker's built in
//  "Generate Instances from Icon-states" option to get all
//  variations. Additionally, as a separate proc, sub-types
//  can handle it more intelligently.
/obj/structure/transit_tube/proc/init_dirs()
	if(icon_state == "auto")
		// Additional delay, for map loading.
		spawn(1)
			init_dirs_automatic()

	else
		tube_dirs = parse_dirs(icon_state)

		if(copytext(icon_state, 1, 3) == "D-" || findtextEx(icon_state, "Pass"))
			density = 0




// Initialize dirs by searching for tubes that do/might connect
//  on nearby turfs. Create corner pieces if nessecary.
// Pick two directions, preferring tubes that already connect
//  to loc, or other auto tubes if there aren't enough connections.
/obj/structure/transit_tube/proc/init_dirs_automatic()
	var/list/connected = list()
	var/list/connected_auto = list()

	for(var/direction in tube_dir_list)
		var/location = get_step(loc, direction)
		for(var/obj/structure/transit_tube/tube in location)
			if(tube.directions() == null && tube.icon_state == "auto")
				connected_auto += direction
				break

			else if(turn(direction, 180) in tube.directions())
				connected += direction
				break

	connected += connected_auto

	tube_dirs = select_automatic_dirs(connected)

	if(length(tube_dirs) == 2 && tube_dir_list.Find(tube_dirs[1]) > tube_dir_list.Find(tube_dirs[2]))
		tube_dirs.Swap(1, 2)

	generate_automatic_corners(tube_dirs)
	select_automatic_icon_state(tube_dirs)



// Given a list of directions, look a pair that forms a 180 or
//  135 degree angle, and return a list containing the pair.
//  If none exist, return list(connected[1], turn(connected[1], 180)
/obj/structure/transit_tube/proc/select_automatic_dirs(connected)
	if(length(connected) < 1)
		return list()

	for(var/i = 1, i <= length(connected), i++)
		for(var/j = i + 1, j <= length(connected), j++)
			var/d1 = connected[i]
			var/d2 = connected[j]

			if(d1 == turn(d2, 135) || d1 == turn(d2, 180) || d1 == turn(d2, 225))
				return list(d1, d2)

	return list(connected[1], turn(connected[1], 180))



/obj/structure/transit_tube/proc/select_automatic_icon_state(directions)
	if(length(directions) == 2)
		icon_state = "[dir2text_short(directions[1])]-[dir2text_short(directions[2])]"



// Look for diagonal directions, generate the decorative corners in each.
/obj/structure/transit_tube/proc/generate_automatic_corners(directions)
	for(var/direction in directions)
		if(direction == 5 || direction == 6 || direction == 9 || direction == 10)
			if(direction & NORTH)
				create_automatic_decorative_corner(get_step(loc, NORTH), direction ^ 3)

			else
				create_automatic_decorative_corner(get_step(loc, SOUTH), direction ^ 3)

			if(direction & EAST)
				create_automatic_decorative_corner(get_step(loc, EAST), direction ^ 12)

			else
				create_automatic_decorative_corner(get_step(loc, WEST), direction ^ 12)



// Generate a corner, if one doesn't exist for the direction on the turf.
/obj/structure/transit_tube/proc/create_automatic_decorative_corner(location, direction)
	var/state = "D-[dir2text_short(direction)]"

	for(var/obj/structure/transit_tube/tube in location)
		if(tube.icon_state == state)
			return

	var/obj/structure/transit_tube/tube = new(location)
	tube.icon_state = state
	tube.init_dirs()



// Uses a list() to cache return values. Since they should
//  never be edited directly, all tubes with a certain
//  icon_state can just reference the same list. In theory,
//  reduces memory usage, and improves CPU cache usage.
//  In reality, I don't know if that is quite how BYOND works,
//  but it is probably safer to assume the existence of, and
//  rely on, a sufficiently smart compiler/optimizer.
/obj/structure/transit_tube/proc/parse_dirs(text)
	var/global/list/direction_table = list()

	if(text in direction_table)
		return direction_table[text]

	var/list/split_text = text2list(text, "-")

	// If the first token is D, the icon_state represents
	//  a purely decorative tube, and doesn't actually
	//  connect to anything.
	if(split_text[1] == "D")
		direction_table[text] = list()
		return null

	var/list/directions = list()

	for(var/text_part in split_text)
		var/direction = text2dir_extended(text_part)

		if(direction > 0)
			directions += direction

	direction_table[text] = directions
	return directions



// A copy of text2dir, extended to accept one and two letter
//  directions, and to clearly return 0 otherwise.
/obj/structure/transit_tube/proc/text2dir_extended(direction)
	switch(uppertext(direction))
		if("NORTH", "N")
			return 1
		if("SOUTH", "S")
			return 2
		if("EAST", "E")
			return 4
		if("WEST", "W")
			return 8
		if("NORTHEAST", "NE")
			return 5
		if("NORTHWEST", "NW")
			return 9
		if("SOUTHEAST", "SE")
			return 6
		if("SOUTHWEST", "SW")
			return 10
		else
	return 0



// A copy of dir2text, which returns the short one or two letter
//  directions used in tube icon states.
/obj/structure/transit_tube/proc/dir2text_short(direction)
	switch(direction)
		if(1)
			return "N"
		if(2)
			return "S"
		if(4)
			return "E"
		if(8)
			return "W"
		if(5)
			return "NE"
		if(6)
			return "SE"
		if(9)
			return "NW"
		if(10)
			return "SW"
		else
	return
