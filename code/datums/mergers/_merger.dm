#define MERGERS_DEBUG FALSE

/// A datum that tracks a type or types of objects in a cluster
/datum/merger
	/// The unique ID for this merger datum, adjacent merg groups with the same id will combine
	var/id
	/// The types allowed to be in this merge group
	var/list/merged_typecache
	/// Optional proc to call on potential members, return true to allow merge
	var/attempt_merge_proc

	/// The arbitrary "owner" member of the merge group
	var/atom/origin
	/// Assoc list of all members in the group -> dirs from them to their connected nighbors
	var/list/members = list()

#if MERGERS_DEBUG
	var/debug_color
#endif

/datum/merger/New(id, list/merged_typecache, atom/origin, attempt_merge_proc)
#if MERGERS_DEBUG
	debug_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
#endif
	src.id = id
	src.merged_typecache = merged_typecache
	src.origin = origin
	src.attempt_merge_proc = attempt_merge_proc
	Refresh()

/datum/merger/Destroy(force)
	for(var/atom/thing as anything in members)
		RemoveMember(thing)
	return ..()

/datum/merger/proc/RemoveMember(atom/thing, clean=TRUE)
	SEND_SIGNAL(thing, COMSIG_MERGER_REMOVING, src)
	UnregisterSignal(thing, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(thing, COMSIG_QDELETING)
	if(!thing.mergers)
		return
	thing.mergers -= id
	if(clean && !length(thing.mergers))
		thing.mergers = null
	members -= thing
	origin = null
	if(origin == thing && length(members))
		origin = pick(members)

/datum/merger/proc/AddMember(atom/thing, connected_dir) // note that this fires for the origin of the merger as well
	SEND_SIGNAL(thing, COMSIG_MERGER_ADDING, src)
	RegisterSignal(thing, COMSIG_MOVABLE_MOVED, PROC_REF(QueueRefresh))
	RegisterSignal(thing, COMSIG_QDELETING, PROC_REF(HandleMemberDel))
	if(!thing.mergers)
		thing.mergers = list()
	else if(thing.mergers[id])
		var/datum/merger/other_merger = thing.mergers[id]
		other_merger.RemoveMember(thing)
		if(!thing.mergers)
			thing.mergers = list()

	thing.mergers[id] = src
	members[thing] = connected_dir
	if(!origin)
		origin = thing

#if MERGERS_DEBUG
	thing.add_atom_colour(debug_color, ADMIN_COLOUR_PRIORITY)
	if(SSatoms.initialized != INITIALIZATION_INNEW_MAPLOAD)
		sleep(1 SECONDS)
#endif

/datum/merger/proc/HandleMemberDel(atom/source)
	SIGNAL_HANDLER
	RemoveMember(source)
	QueueRefresh()

/datum/merger/proc/QueueRefresh()
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(Refresh)), 1, TIMER_UNIQUE)

/datum/merger/proc/Refresh()
	// List of turf -> list(interesting dir, found matching atoms)
	var/list/found_turfs = list()
	if(origin)
		var/turf/starting = get_turf(origin)
		check_turf(starting, found_turfs, NONE)
	for(var/i = 1; i <= length(found_turfs), i++)
		var/turf/focus = found_turfs[i]
		var/list/focus_packet = found_turfs[focus]
		var/dirs_checked = focus_packet[MERGE_TURF_PACKET_DIR]
		for(var/dir in GLOB.cardinals)
			if(dirs_checked & dir)
				continue
			var/turf/location = get_step(focus, dir)
			if(!location)
				continue
			if(!check_turf(location, found_turfs, dir))
				if(QDELETED(src))
					return
				continue
			focus_packet[MERGE_TURF_PACKET_DIR] |= dir

	// Now that we have an idea of our connecting directions, build the fresh members list
	var/list/fresh_members = list()
	for(var/turf/location as anything in found_turfs)
		var/list/turf_packet = found_turfs[location]
		var/connected_dirs = turf_packet[MERGE_TURF_PACKET_DIR]
		for(var/datum/member as anything in turf_packet[MERGE_TURF_PACKET_ATOMS])
			fresh_members[member] = connected_dirs

	var/list/leaving_members = members - fresh_members
	for(var/atom/thing as anything in leaving_members)
		RemoveMember(thing)

	var/list/joining_members = fresh_members - members
	for(var/atom/thing as anything in joining_members)
		AddMember(thing, joining_members[thing])

	// They may not need a full update but the connected dirs could change
	for(var/atom/thing as anything in fresh_members)
		members[thing] = fresh_members[thing]

	SEND_SIGNAL(src, COMSIG_MERGER_REFRESH_COMPLETE, leaving_members, joining_members)

	if(!length(members))
		qdel(src)

// Checks to see if the passed in location contains something interesting to us. If it does, return TRUE, otherwise return false
// If it is interesting, we add it to our processing list
/datum/merger/proc/check_turf(turf/location, list/found_turfs, asking_from)
	var/found_something = FALSE
	// if asking_from is invalid (like if it's 0), we get a random output. that's bad, let's check for falsyness
	var/us_to_them = asking_from && REVERSE_DIR(asking_from)

	if(found_turfs[location])
		found_turfs[location][MERGE_TURF_PACKET_DIR] |= us_to_them
		return TRUE

	for(var/atom/movable/thing as anything in location)
		if(!merged_typecache[thing.type])
			continue
		if(attempt_merge_proc && !call(thing, attempt_merge_proc)(src, found_turfs))
			continue
		if(thing.mergers && thing.mergers[id] != src)
			var/datum/merger/existing = thing.mergers[id]
			qdel(src)
			existing.Refresh()
			return FALSE
		if(!found_turfs[location])
			found_turfs[location] = list(us_to_them, list())
		found_turfs[location][MERGE_TURF_PACKET_ATOMS] += thing
		found_something = TRUE

	return found_something

#undef MERGERS_DEBUG
