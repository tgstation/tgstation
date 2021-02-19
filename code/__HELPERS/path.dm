/**
 * This file contains the stuff you need for using JPS (Jump Point Search) pathing, an alternative to A* that skips
 * over large numbers of uninteresting tiles resulting in much quicker pathfinding solutions.
 */

/**
 * This is the proc you use whenever you want to have pathfinding more complex than "try stepping towards the thing"
 *
 * Arguments:
 * * caller: The movable atom that's trying to find the path
 * * end: What we're trying to path to. It doesn't matter if this is a turf or some other atom, we're gonna just path to the turf it's on anyway
 * * maxnodes: The maximum number of nodes the returned path can be (0 = infinite)
 * * maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
 * * mintargetdistance: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * id: An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
 * * simulated_only: Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 */
/proc/get_path_to(caller, end, maxnodes, maxnodedepth = 30, mintargetdist, id=null, simulated_only = TRUE, turf/exclude)
	if(!get_turf(end))
		return

	var/l = SSpathfinder.mobs.getfree(caller)
	while(!l)
		stoplag(3)
		l = SSpathfinder.mobs.getfree(caller)

	var/list/path
	var/datum/pathfind/pathfind_datum = new(caller, end, id, maxnodes, maxnodedepth, mintargetdist, simulated_only, exclude)
	path = pathfind_datum.start_search()
	qdel(pathfind_datum)

	SSpathfinder.mobs.found(l)
	if(!path)
		path = list()
	return path

/**
 * A helper macro to see if it's possible to step from the first turf into the second one, minding things like door access and directional windows.
 * Note that this can only be used inside the [datum/pathfind][pathfind datum] since it uses variables from said datum
 * If you really want to optimize things, optimize this, cuz this gets called a lot
 */
#define CAN_STEP(cur_turf, next) (next && !next.density && cur_turf.Adjacent(next) && !(simulated_only && SSpathfinder.space_type_cache[next.type]) && !cur_turf.LinkBlockedWithAccess(next,caller, id) && (next != avoid))
/// Another helper macro for JPS, for telling when a node has forced neighbors that need expanding
#define STEP_NOT_HERE_BUT_THERE(cur_turf, dirA, dirB) ((!CAN_STEP(cur_turf, get_step(cur_turf, dirA)) && CAN_STEP(cur_turf, get_step(cur_turf, dirB))))

/// Enumerator for the starting turf's sources value, so we know when we've hit the beginning when unwinding at the end
#define PATH_START	-1


/// The JPS Node datum represents a turf that we find interesting enough to add to the open list and possibly search for new tiles from
/datum/jps_node
	/// The turf associated with this node
	var/turf/tile
	/// The node we just came from
	var/datum/jps_node/previous_node
	/// The A* node weight (f_value = number_of_tiles + heuristic)
	var/f_value
	/// The A* node heuristic (a rough estimate of how far we are from the goal)
	var/heuristic
	/// How many steps it's taken to get here from the start (currently pulling double duty as steps taken & cost to get here, since all moves incl diagonals cost 1 rn)
	var/number_tiles
	/// How many steps it took to get here from the last node
	var/jumps
	/// Nodes store the endgoal so they can process their heuristic without a reference to the pathfind datum
	var/turf/node_goal

/datum/jps_node/New(turf/our_tile, datum/jps_node/previous_node, jumps_taken, turf/incoming_goal)
	tile = our_tile
	previous_node = previous_node
	jumps = jumps_taken
	if(previous_node)
		number_tiles = previous_node.number_tiles + jumps
		node_goal = previous_node.node_goal
	else
		number_tiles = 0
		node_goal = incoming_goal

	heuristic = get_dist(tile, node_goal)
	f_value = number_tiles + heuristic

/// The datum used to handle the JPS pathfinding, completely self-contained
/datum/pathfind
	/// The thing that we're actually trying to path for
	var/atom/movable/caller
	/// The turf where we started at
	var/turf/start
	/// The turf we're trying to path to (note that this won't track a moving target)
	var/turf/end
	/// The open list/stack we pop nodes out from
	var/datum/heap/path/open
	/// An assoc list that matches turfs (the key) to their nodes if said turf has one
	var/list/open_associative
	/**
	 * An assoc list that serves as the closed list & tracks what turfs came from where. Key is the turf, and the value is what turf it came from
	 *
	 * Nodes are only created & added to the heap/open_associative once a turf is found "interesting", but due to recursion, we may not know it's interesting until we finish processing its children.
	 * Inserting to this list is cheaper than making a node datum + inserting into the heap, so everything goes in here immediately, and what we use to recreate the path at the end
	 */
	var/list/sources
	/// The list we compile at the end if successful to pass back
	var/list/path

	// general pathfinding vars/args
	/// An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
	var/obj/item/card/id/id
	/// How far away we have to get to the end target before we can call it quits
	var/mintargetdist = 0
	/// I don't know what this does vs maxnodes, but they limit how far we can search before giving up on a path
	var/maxnodedepth = 30
	/// I don't know what this does vs maxnodedepth, but they limit how far we can search before giving up on a path
	var/maxnodes = 30
	/// The proc we use to tell the distance between two turfs. Currently ignored in favor of get_dist/get_dist
	///var/dist = /turf/proc/Distance
	/// Do we only worry about turfs with simulated atmos, most notably things that aren't space?
	var/simulated_only
	/// Did we succeed?
	var/success = FALSE
	/// A specific turf we're avoiding
	var/turf/avoid

/datum/pathfind/New(atom/movable/caller, atom/goal, id, maxnodes, maxnodedepth, mintargetdist, simulated_only, avoid)
	src.caller = caller
	end = get_turf(goal)
	open = new()
	open_associative = new() //open list for node check
	sources = new() //open list for node check
	src.id = id
	src.maxnodes = maxnodes
	src.maxnodedepth = maxnodedepth
	src.mintargetdist = mintargetdist
	src.simulated_only = simulated_only
	src.avoid = avoid

/// The proc you use to start the search, returns FALSE if it's invalid, an empty list if no path could be found, or a valid path to the target
/datum/pathfind/proc/start_search()
	start = get_turf(caller)
	if(!start || !end)
		stack_trace("Invalid A* start or destination")
		return FALSE
	if(start.z != end.z || start == end ) //no pathfinding between z levels
		return FALSE
	if(maxnodes) //if start turf is farther than maxnodes from end turf, no need to do anything
		maxnodedepth = maxnodes

	//initialization
	var/datum/jps_node/current_processed_node = new (start, null, 0, end)
	open.insert(current_processed_node)
	open_associative[start] = current_processed_node
	sources[start] = PATH_START
	//then run the main loop
	while(!open.is_empty() && !path)
		if(!caller)
			return
		current_processed_node = open.pop() //get the lower f_value turf in the open list

		if((maxnodedepth)&&(current_processed_node.number_tiles > maxnodedepth))//if too many steps, don't process that path
			continue

		var/turf/current_turf = current_processed_node.tile
		for(var/scan_direction in list(EAST, WEST, NORTH, SOUTH))
			lateral_scan_spec(current_turf, scan_direction)

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
			diag_scan_spec(current_turf, scan_direction)

		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5 * length(path)))
			path.Swap(i, length(path) - i + 1)
	open_associative = null //cleaning after us
	sources = null
	return path

/// Called when we've hit the goal with the node that represents the last tile, then sets the path var to that path so it can be returned by [datum/pathfind/proc/start_search]
/datum/pathfind/proc/unwind_path(datum/jps_node/unwind_node)
	success = unwind_node.tile == end
	path = new()
	var/turf/iter_turf = unwind_node.tile
	path.Add(iter_turf)

	var/list/b = list(iter_turf)
	var/turf/goal_turf = sources[iter_turf]
	while(goal_turf && goal_turf != PATH_START)
		b.Add(goal_turf)
		while(iter_turf != goal_turf)
			var/turf/next_turf = get_step_towards(iter_turf, goal_turf)
			iter_turf = next_turf
			path.Add(iter_turf)
		goal_turf = sources[iter_turf]

/// For performing a scan in a given lateral direction
/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jps_node/unwind_node = open_associative[original_turf]
	while(!unwind_node)
		var/turf/older = sources[original_turf]
		if(!older)
			CRASH("JPS error: Lateral scan couldn't find a home node")
		unwind_node = open_associative[older]

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(path) // lazy way to force out when done, do better
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf))
			return

		var/closeenough
		if(mintargetdist)
			closeenough = (get_dist(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			var/datum/jps_node/final_node = new(current_turf, unwind_node, steps_taken)
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf]) // already visited, essentially in the closed list
			return
		else
			sources[current_turf] = original_turf

		if(unwind_node.number_tiles + steps_taken > maxnodedepth)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?

		switch(heading)
			if(NORTH)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST))
					interesting = TRUE
			if(SOUTH)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST))
					interesting = TRUE
			if(EAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
			if(WEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE

		if(interesting)
			var/datum/jps_node/newnode = new(current_turf, unwind_node, steps_taken)
			open_associative[current_turf] = newnode
			open.insert(newnode)
			return

/// For performing a scan in a given diagonal direction
/datum/pathfind/proc/diag_scan_spec(turf/original_turf, heading)
	var/steps_taken = 0
	var/datum/jps_node/unwind_node = open_associative[original_turf]
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(!unwind_node)
		var/turf/older = sources[original_turf]
		if(!older)
			CRASH("JPS error: Diagonal scan couldn't find a home node")
		unwind_node = open_associative[older]

	while(TRUE)
		if(path) // lazy way to force out when done, do better
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf))
			return

		var/closeenough
		if(mintargetdist)
			closeenough = (get_dist(current_turf, end) <= mintargetdist)
		if(current_turf == end || closeenough)
			var/datum/jps_node/final_node = new(current_turf,unwind_node, steps_taken)
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf]) // already visited, essentially in the closed list
			return
		else
			sources[current_turf] = original_turf

		if(unwind_node.number_tiles + steps_taken > maxnodedepth)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?

		switch(heading)
			if(NORTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE
				else
					lateral_scan_spec(current_turf, WEST)
					lateral_scan_spec(current_turf, NORTH)
			if(NORTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
				else
					lateral_scan_spec(current_turf, EAST)
					lateral_scan_spec(current_turf, NORTH)
			if(SOUTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST))
					interesting = TRUE
					return
				else
					lateral_scan_spec(current_turf, SOUTH)
					lateral_scan_spec(current_turf, WEST)
			if(SOUTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST))
					interesting = TRUE
				else
					lateral_scan_spec(current_turf, SOUTH)
					lateral_scan_spec(current_turf, EAST)

		if(interesting)
			var/datum/jps_node/newnode = new(current_turf, unwind_node, steps_taken)
			open_associative[current_turf] = newnode
			open.insert(newnode)
			return

#undef PATH_START
#undef CAN_STEP
#undef STEP_NOT_HERE_BUT_THERE

// and then the rest are holdovers from the A* file

// These two defines are used for turf adjacency directional window nonsense
#define MASK_ODD 85
#define MASK_EVEN 170

/**
 * Returns adjacent turfs to this turf that are reachable, in all 8 directions
 *
 * Arguments:
 * * caller: The atom, if one exists, being used for mobility checks to see what tiles it can reach
 * * ID: An ID card that decides if we can gain access to doors that would otherwise block a turf
 * * simulated_only: Do we only worry about turfs with simulated atmos, most notably things that aren't space?
*/
/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/list/L = new()
	var/turf/T
	var/static/space_type_cache = typecacheof(/turf/open/space)

	for(var/iter_dir in GLOB.alldirs)
		T = get_step(src,iter_dir)
		if(!T || (simulated_only && space_type_cache[T.type]))
			continue
		if(!T.density && !LinkBlockedWithAccess(T,caller, ID))
			L.Add(T)
	return L

//Returns adjacent turfs in cardinal directions that are reachable via atmos
/turf/proc/reachableAdjacentAtmosTurfs()
	return atmos_adjacent_turfs

/turf/proc/LinkBlockedWithAccess(turf/T, caller, ID)
	var/adir = get_dir(src, T)
	var/rdir = ((adir & MASK_ODD)<<1)|((adir & MASK_EVEN)>>1)
	for(var/obj/structure/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return TRUE
	for(var/obj/machinery/door/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return TRUE
	for(var/obj/O in T)
		if(!O.CanAStarPass(ID, rdir, caller))
			return TRUE

	return FALSE

#undef MASK_ODD
#undef MASK_EVEN
