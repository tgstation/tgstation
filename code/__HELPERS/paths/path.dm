/**
 * This is the proc you use whenever you want to have pathfinding more complex than "try stepping towards the thing".
 * If no path was found, returns an empty list, which is important for bots like medibots who expect an empty list rather than nothing.
 * It will yield until a path is returned, using magic
 *
 * Arguments:
 * * requester: The movable atom that's trying to find the path
 * * end: What we're trying to path to. It doesn't matter if this is a turf or some other atom, we're gonna just path to the turf it's on anyway
 * * max_distance: The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * * mintargetdistance: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * access: A list representing what access we have and what doors we can open.
 * * simulated_only: Whether we consider tur fs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * * skip_first: Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break movement for some creatures.
 * * diagonal_handling: defines how we handle diagonal moves. see __DEFINES/path.dm
 */
/proc/get_path_to(atom/movable/requester, atom/end, max_distance = 30, mintargetdist, access=list(), simulated_only = TRUE, turf/exclude, skip_first=TRUE, diagonal_handling=DIAGONAL_REMOVE_CLUNKY)
	var/list/hand_around = list()
	// We're guaranteed that list will be the first list in pathfinding_finished's argset because of how callback handles the arguments list
	var/datum/callback/await = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around))
	if(!SSpathfinder.pathfind(requester, end, max_distance, mintargetdist, access, simulated_only, exclude, skip_first, diagonal_handling, await))
		return list()

	UNTIL(length(hand_around))
	var/list/return_val = hand_around[1]
	if(!islist(return_val) || (QDELETED(requester) || QDELETED(end))) // It's trash, just hand back empty to make it easy
		return list()
	return return_val

/**
 * POTENTIALLY cheaper version of get_path_to
 * This proc generates a path map for the end atom's turf, which allows us to cheaply do pathing operations "at" it
 * Generation is significantly SLOWER then get_path_to, but if many things are/might be pathing at something then it is much faster
 * Runs the risk of returning an suboptimal or INVALID PATH if the delay between map creation and use is too long
 *
 * If no path was found, returns an empty list, which is important for bots like medibots who expect an empty list rather than nothing.
 * It will yield until a path is returned, using magic
 *
 * Arguments:
 * * requester: The movable atom that's trying to find the path
 * * end: What we're trying to path to. It doesn't matter if this is a turf or some other atom, we're gonna just path to the turf it's on anyway
 * * max_distance: The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * * mintargetdistance: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * age: How old a path map can be before we'll avoid reusing it. Use the defines found in [code/__DEFINES/path.dm], values larger then MAP_REUSE_SLOWEST will be discarded
 * * access: A list representing what access we have and what doors we can open.
 * * simulated_only: Whether we consider tur fs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * * skip_first: Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break movement for some creatures.
 */
/proc/get_swarm_path_to(atom/movable/requester, atom/end, max_distance = 30, mintargetdist, age = MAP_REUSE_INSTANT, access = list(), simulated_only = TRUE, turf/exclude, skip_first=TRUE)
	var/list/hand_around = list()
	// We're guaranteed that list will be the first list in pathfinding_finished's argset because of how callback handles the arguments list
	var/datum/callback/await = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around))
	if(!SSpathfinder.swarmed_pathfind(requester, end, max_distance, mintargetdist, age, access, simulated_only, exclude, skip_first, await))
		return list()

	UNTIL(length(hand_around))
	var/list/return_val = hand_around[1]
	if(!islist(return_val) || (QDELETED(requester) || QDELETED(end))) // It's trash, just hand back empty to make it easy
		return list()
	return return_val

/proc/get_sssp(atom/movable/requester, max_distance = 30, access = list(), simulated_only = TRUE, turf/exclude)
	var/list/hand_around = list()
	// We're guaranteed that list will be the first list in pathfinding_finished's argset because of how callback handles the arguments list
	var/datum/callback/await = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pathfinding_finished), hand_around))
	if(!SSpathfinder.build_map(requester, get_turf(requester), max_distance, access, simulated_only, exclude, await))
		return null

	UNTIL(length(hand_around))
	var/datum/path_map/return_val = hand_around[1]
	if(!istype(return_val, /datum/path_map) || (QDELETED(requester))) // It's trash, just hand back null to make it easy
		return null
	return return_val

/// Uses funny pass by reference bullshit to take the output created by pathfinding, and insert it into a return list
/// We'll be able to use this return list to tell a sleeping proc to continue execution
/proc/pathfinding_finished(list/return_list, hand_back)
	// We use += here to behave nicely with lists
	return_list += LIST_VALUE_WRAP_LISTS(hand_back)

/// The datum used to handle the JPS pathfinding, completely self-contained
/datum/pathfind
	/// The turf we started at
	var/turf/start

	// general pathfinding vars/args
	/// Limits how far we can search before giving up on a path
	var/max_distance = 30
	/// Space is big and empty, if this is TRUE then we ignore pathing through unsimulated tiles
	var/simulated_only
	/// A specific turf we're avoiding, like if a mulebot is being blocked by someone t-posing in a doorway we're trying to get through
	var/turf/avoid
	/// The callbacks to invoke when we're done working, passing in the completed product
	/// Invoked in order
	var/list/datum/callback/on_finish
	/// Datum that holds the canpass info of this pathing attempt. This is what CanAstarPass sees
	var/datum/can_pass_info/pass_info

/datum/pathfind/Destroy(force)
	. = ..()
	SSpathfinder.active_pathing -= src
	SSpathfinder.currentrun -= src
	hand_back(null)
	avoid = null

/**
 * "starts" off the pathfinding, by storing the values this datum will need to work later on
 *  returns FALSE if it fails to setup properly, TRUE otherwise
 */
/datum/pathfind/proc/start()
	if(!start)
		stack_trace("Invalid pathfinding start")
		return FALSE
	return TRUE

/**
 * search_step() is the workhorse of pathfinding. It'll do the searching logic, and will slowly build up a path
 * returns TRUE if everything is stable, FALSE if the pathfinding logic has failed, and we need to abort
 */
/datum/pathfind/proc/search_step()
	return TRUE

/**
 * early_exit() is called when something goes wrong in processing, and we need to halt the pathfinding NOW
 */
/datum/pathfind/proc/early_exit()
	hand_back(null)
	qdel(src)

/**
 * Cleanup pass for the pathfinder. This tidies up the path, and fufills the pathfind's obligations
 */
/datum/pathfind/proc/finished()
	qdel(src)

/**
 * Call to return a value to whoever spawned this pathfinding work
 * Will fail if it's already been called
 */
/datum/pathfind/proc/hand_back(value)
	for(var/datum/callback/finished as anything in on_finish)
		finished.Invoke(value)
	on_finish = null

/**
 * Processes a path (list of turfs), removes any diagonal moves that would lead to a weird bump
 *
 * path - The path to process down
 * pass_info - Holds all the info about what this path attempt can go through
 * simulated_only - If we are not allowed to pass space turfs
 * avoid - A turf to be avoided
 */
/proc/remove_clunky_diagonals(list/path, datum/can_pass_info/pass_info, simulated_only, turf/avoid)
	if(length(path) < 2)
		return path
	var/list/modified_path = list()

	for(var/i in 1 to length(path) - 1)
		var/turf/current_turf = path[i]
		modified_path += current_turf
		var/turf/next_turf = path[i+1]
		var/movement_dir = get_dir(current_turf, next_turf)
		if(!(movement_dir & (movement_dir - 1))) //cardinal movement, no need to verify
			continue
		//If the first diagonal movement step is invalid (north/south), replace with a sidestep first, with an implied vertical step in next_turf
		var/vertical_only = movement_dir & (NORTH|SOUTH)
		if(!CAN_STEP(current_turf,get_step(current_turf, vertical_only), simulated_only, pass_info, avoid))
			modified_path += get_step(current_turf, movement_dir & ~vertical_only)
	modified_path += path[length(path)]

	return modified_path

/**
 * Processes a path (list of turfs), removes any diagonal moves
 *
 * path - The path to process down
 * pass_info - Holds all the info about what this path attempt can go through
 * simulated_only - If we are not allowed to pass space turfs
 * avoid - A turf to be avoided
 */
/proc/remove_diagonals(list/path, datum/can_pass_info/pass_info, simulated_only, turf/avoid)
	if(length(path) < 2)
		return path
	var/list/modified_path = list()

	for(var/i in 1 to length(path) - 1)
		var/turf/current_turf = path[i]
		modified_path += current_turf
		var/turf/next_turf = path[i+1]
		var/movement_dir = get_dir(current_turf, next_turf)
		if(!(movement_dir & (movement_dir - 1))) //cardinal movement, no need to verify
			continue
		var/vertical_only = movement_dir & (NORTH|SOUTH)
		// If we can't go directly north/south, we will first go to the side,
		if(!CAN_STEP(current_turf,get_step(current_turf, vertical_only), simulated_only, pass_info, avoid))
			modified_path += get_step(current_turf, movement_dir & ~vertical_only)
		else // Otherwise, we'll first go north/south, then to the side
			modified_path += get_step(current_turf, vertical_only)
	modified_path += path[length(path)]

	return modified_path

/**
 * For seeing if we can actually move between 2 given turfs while accounting for our access and the requester's pass_flags
 *
 * Assumes destinantion turf is non-dense - check and shortcircuit in code invoking this proc to avoid overhead.
 * Makes some other assumptions, such as assuming that unless declared, non dense objects will not block movement.
 * It's fragile, but this is VERY much the most expensive part of pathing, so it'd better be fast
 *
 * Arguments:
 * * destination_turf - Where are we going from where we are?
 * * pass_info - Holds all the info about what this path attempt can go through
*/
/turf/proc/LinkBlockedWithAccess(turf/destination_turf, datum/can_pass_info/pass_info)
	if(destination_turf.x != x && destination_turf.y != y) //diagonal
		var/in_dir = get_dir(destination_turf,src) // eg. northwest (1+8) = 9 (00001001)
		var/first_step_direction_a = in_dir & 3 // eg. north   (1+8)&3 (0000 0011) = 1 (0000 0001)
		var/first_step_direction_b = in_dir & 12 // eg. west   (1+8)&12 (0000 1100) = 8 (0000 1000)

		for(var/first_step_direction in list(first_step_direction_a,first_step_direction_b))
			var/turf/midstep_turf = get_step(destination_turf,first_step_direction)
			var/way_blocked = midstep_turf.density || LinkBlockedWithAccess(midstep_turf, pass_info) || midstep_turf.LinkBlockedWithAccess(destination_turf, pass_info)
			if(!way_blocked)
				return FALSE
		return TRUE
	var/actual_dir = get_dir(src, destination_turf)

	/// These are generally cheaper than looping contents so they go first
	switch(destination_turf.pathing_pass_method)
		// This is already assumed to be true
		//if(TURF_PATHING_PASS_DENSITY)
		//	if(destination_turf.density)
		//		return TRUE
		if(TURF_PATHING_PASS_PROC)
			if(!destination_turf.CanAStarPass(actual_dir, pass_info))
				return TRUE
		if(TURF_PATHING_PASS_NO)
			return TRUE

	var/static/list/directional_blocker_cache = typecacheof(list(/obj/structure/window, /obj/machinery/door/window, /obj/structure/railing, /obj/machinery/door/firedoor/border_only))
	// Source border object checks
	for(var/obj/border in src)
		if(!directional_blocker_cache[border.type])
			continue
		if(!border.density && border.can_astar_pass == CANASTARPASS_DENSITY)
			continue
		if(!border.CanAStarPass(actual_dir, pass_info))
			return TRUE

	// Destination blockers check
	var/reverse_dir = get_dir(destination_turf, src)
	for(var/obj/iter_object in destination_turf)
		// This is an optimization because of the massive call count of this code
		if(!iter_object.density && iter_object.can_astar_pass == CANASTARPASS_DENSITY)
			continue
		if(!iter_object.CanAStarPass(reverse_dir, pass_info))
			return TRUE
	return FALSE

// Could easily be a struct if/when we get that
/**
 * Holds all information about what an atom can move through
 * Passed into CanAStarPass to provide context for a pathing attempt
 *
 * Also used to check if using a cached path_map is safe
 * There are some vars here that are unused. They exist to cover cases where requester_ref is used
 * They're the properties of requester_ref used in those cases.
 * It's kinda annoying, but there's some proc chains we can't convert to this datum
 */
/datum/can_pass_info
	/// If we have no id, public airlocks are walls
	var/no_id = FALSE

	/// What we can pass through. Mirrors /atom/movable/pass_flags
	var/pass_flags = NONE
	/// What access we have, airlocks, windoors, etc
	var/list/access = null
	/// What sort of movement do we have. Mirrors /atom/movable/movement_type
	var/movement_type = NONE
	/// Are we being thrown?
	var/thrown = FALSE
	/// Are we anchored
	var/anchored = FALSE

	/// Are we a ghost? (they have effectively unique pathfinding)
	var/is_observer = FALSE
	/// Are we a living mob?
	var/is_living = FALSE
	/// Are we a bot?
	var/is_bot = FALSE
	/// Can we ventcrawl?
	var/can_ventcrawl = FALSE
	/// What is the size of our mob
	var/mob_size = null
	/// Is our mob incapacitated
	var/incapacitated = FALSE
	/// Is our mob incorporeal
	var/incorporeal_move = FALSE
	/// If our mob has a rider, what does it look like
	var/datum/can_pass_info/rider_info = null
	/// If our mob is buckled to something, what's it like
	var/datum/can_pass_info/buckled_info = null

	/// Do we have gravity
	var/has_gravity = TRUE
	/// Pass information for the object we are pulling, if any
	var/datum/can_pass_info/pulling_info = null

	/// Cameras have a lot of BS can_z_move overrides
	/// Let's avoid this
	var/camera_type

	/// Weakref to the requester used to generate this info
	/// Should not use this almost ever, it's for context and to allow for proc chains that
	/// Require a movable
	var/datum/weakref/requester_ref = null

/datum/can_pass_info/New(atom/movable/construct_from, list/access, no_id = FALSE, call_depth = 0)
	// No infiniloops
	if(call_depth > 10)
		return
	if(access)
		src.access = access.Copy()
	src.no_id = no_id

	if(isnull(construct_from))
		return

	src.requester_ref = WEAKREF(construct_from)
	src.pass_flags = construct_from.pass_flags
	src.movement_type = construct_from.movement_type
	src.thrown = !!construct_from.throwing
	src.anchored = construct_from.anchored
	src.has_gravity = construct_from.has_gravity()
	if(ismob(construct_from))
		var/mob/living/mob_construct = construct_from
		src.incapacitated = mob_construct.incapacitated
		if(mob_construct.buckled)
			src.buckled_info = new(mob_construct.buckled, access, no_id, call_depth + 1)
	if(isobserver(construct_from))
		src.is_observer = TRUE
	if(isliving(construct_from))
		var/mob/living/living_construct = construct_from
		src.is_living = TRUE
		src.can_ventcrawl = HAS_TRAIT(living_construct, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(living_construct, TRAIT_VENTCRAWLER_NUDE)
		src.mob_size = living_construct.mob_size
		src.incorporeal_move = living_construct.incorporeal_move
	if(iseyemob(construct_from))
		src.camera_type = construct_from.type
	src.is_bot = isbot(construct_from)

	if(construct_from.pulling)
		src.pulling_info = new(construct_from.pulling, access, no_id, call_depth + 1)

/// List of vars on /datum/can_pass_info to use when checking two instances for equality
GLOBAL_LIST_INIT(can_pass_info_vars, GLOBAL_PROC_REF(can_pass_check_vars))

/proc/can_pass_check_vars()
	var/datum/can_pass_info/lamb = new()
	var/datum/isaac = new()
	var/list/altar = assoc_to_keys(lamb.vars - isaac.vars)
	// Don't compare against calling atom, it's not relevant here
	altar -= "requester_ref"
	ASSERT("requester_ref" in lamb.vars, "requester_ref var was not found in /datum/can_pass_info, why are we filtering for it?")
	// We will bespoke handle pulling_info
	altar -= "pulling_info"
	ASSERT("pulling_info" in lamb.vars, "pulling_info var was not found in /datum/can_pass_info, why are we filtering for it?")
	return altar

/datum/can_pass_info/proc/compare_against(datum/can_pass_info/check_against)
	for(var/comparable_var in GLOB.can_pass_info_vars)
		if(!(vars[comparable_var] ~= check_against.vars[comparable_var]))
			return FALSE
	if(!pulling_info != !check_against.pulling_info)
		return FALSE
	if(pulling_info && !pulling_info.compare_against(check_against.pulling_info))
		return FALSE
	return TRUE
