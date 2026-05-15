
/**
 * This proc uses A* to find the most optimal path between two turfs. Unlike JPS, it allows using a custom heuristic callback to change the
 * weights of nodes. A* will always return the most optimal path and will not fail to pathfind in cases where JPS will (directional blockers).
 *
 * Arguments:
 * * invoker: The movable atom that's trying to find the path
 * * end: What we're trying to path to. It doesn't matter if this is a turf or some other atom, we're gonna just path to the turf it's on anyway
 * * max_steps: The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * * mintargetdistance: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * access: A list representing what access we have and what doors we can open.
 * * simulated_only: Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * * skip_first: Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break movement for some creatures.
 * * use_diagonals: If you want the path to include diagonal steps. Set to FALSE for cardinal moves only.
 * * heuristic: A proc to call to determine how nodes are weighted. The higher the returned value, the less likely the pathfinder wants to traverse. 0 means invalid turf.
 */
/proc/astar_path_to(
	atom/movable/invoker,
	atom/end,
	max_steps = 30,
	mintargetdist,
	list/access,
	simulated_only = TRUE,
	turf/exclude,
	skip_first = TRUE,
	use_diagonals = TRUE,
	datum/callback/heuristic,
)
	var/list/hand_around = list()
	// We're guarenteed that list will be the first list in pathfinding_finished's argset because of how callback handles the arguments list
	var/datum/callback/await = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(__pathfinding_finished), hand_around))
	if(!SSpathfinder.astar_pathfind(invoker, end, max_steps, mintargetdist, access, simulated_only, exclude, skip_first, use_diagonals, await, heuristic))
		return list()

	UNTIL(length(hand_around))
	var/list/return_val = hand_around[1]
	if(!islist(return_val) || (QDELETED(invoker) || QDELETED(end))) // It's trash, just hand back empty to make it easy
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
 * * max_steps: The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * * mintargetdistance: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * age: How old a path map can be before we'll avoid reusing it. Use the defines found in [code/__DEFINES/path.dm], values larger then MAP_REUSE_SLOWEST will be discarded
 * * access: A list representing what access we have and what doors we can open.
 * * simulated_only: Whether we consider tur fs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * * skip_first: Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break movement for some creatures.
 */
/proc/get_swarm_path_to(atom/movable/requester, atom/end, max_steps = 30, mintargetdist, age = MAP_REUSE_INSTANT, access = list(), simulated_only = TRUE, turf/exclude, skip_first=TRUE)
	var/list/hand_around = list()
	// We're guaranteed that list will be the first list in pathfinding_finished's argset because of how callback handles the arguments list
	var/datum/callback/await = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(__pathfinding_finished), hand_around))
	if(!SSpathfinder.swarmed_pathfind(requester, end, max_steps, mintargetdist, age, access, simulated_only, exclude, skip_first, await))
		return list()

	UNTIL(length(hand_around))
	var/list/return_val = hand_around[1]
	if(!islist(return_val) || (QDELETED(requester) || QDELETED(end))) // It's trash, just hand back empty to make it easy
		return list()
	return return_val

/proc/get_sssp(atom/movable/requester, max_steps = 30, access = list(), simulated_only = TRUE, turf/exclude)
	var/list/hand_around = list()
	// We're guaranteed that list will be the first list in pathfinding_finished's argset because of how callback handles the arguments list
	var/datum/callback/await = list(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(__pathfinding_finished), hand_around))
	if(!SSpathfinder.build_map(requester, get_turf(requester), max_steps, access, simulated_only, exclude, await))
		return null

	UNTIL(length(hand_around))
	var/datum/path_map/return_val = hand_around[1]
	if(!istype(return_val, /datum/path_map) || (QDELETED(requester))) // It's trash, just hand back null to make it easy
		return null
	return return_val
