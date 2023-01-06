/// Queues and manages JPS pathfinding steps
SUBSYSTEM_DEF(pathfinder)
	name = "Pathfinder"
	init_order = INIT_ORDER_PATH
	priority = FIRE_PRIORITY_PATHFINDING
	/// List of pathfind datums we are currently trying to process
	var/list/datum/pathfind/active_pathing = list()
	/// List of pathfind datums being ACTIVELY processed. exists to make subsystem stats readable
	var/list/datum/pathfind/currentrun = list()
	var/static/space_type_cache

/datum/controller/subsystem/pathfinder/Initialize()
	space_type_cache = typecacheof(/turf/open/space)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/pathfinder/stat_entry(msg)
	msg = "P:[length(active_pathing)]"
	return ..()

// This is another one of those subsystems (hey lighting) in which one "Run" means fully processing a queue
// We'll use a copy for this just to be nice to people reading the mc panel
/datum/controller/subsystem/pathfinder/fire(resumed)
	if(!resumed)
		src.currentrun = active_pathing.Copy()

	// Dies of sonic speed from caching datum var reads
	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/datum/pathfind/path = currentrun[length(currentrun)]
		if(!path.search_step()) // Something's wrong
			path.early_exit()
			currentrun.len--
			continue
		if(MC_TICK_CHECK)
			return
		path.finished()
		// Next please
		currentrun.len--

/// Initiates a pathfind. Returns true if we're good, FALSE if something's failed
/datum/controller/subsystem/pathfinder/proc/pathfind(atom/movable/caller, atom/end, max_distance = 30, mintargetdist, id=null, simulated_only = TRUE, turf/exclude, skip_first=TRUE, diagonal_safety=TRUE, datum/callback/on_finish)
	var/datum/pathfind/path = new(caller, end, id, max_distance, mintargetdist, simulated_only, exclude, skip_first, diagonal_safety, on_finish)
	if(path.start())
		active_pathing += path
		return TRUE
	return FALSE
