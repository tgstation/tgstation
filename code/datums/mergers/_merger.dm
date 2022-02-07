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
	/// A list of all members in the group
	var/list/members = list()

#if MERGERS_DEBUG
	var/debug_color
#endif

	/// Signals in members to trigger a refresh
	var/static/list/refresh_signals = list(COMSIG_MOVABLE_MOVED)

/datum/merger/New(id, list/merged_typecache, atom/origin, attempt_merge_proc)
#if MERGERS_DEBUG
	debug_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
#endif
	src.id = id
	src.merged_typecache = merged_typecache
	src.origin = origin
	src.attempt_merge_proc = attempt_merge_proc
	Refresh()

/datum/merger/Destroy(force, ...)
	for(var/atom/thing as anything in members)
		RemoveMember(thing)
	return ..()

/datum/merger/proc/RemoveMember(atom/thing, clean=TRUE)
	SEND_SIGNAL(thing, COMSIG_MERGER_REMOVING, src)
	UnregisterSignal(thing, refresh_signals)
	UnregisterSignal(thing, COMSIG_PARENT_QDELETING)
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
	RegisterSignal(thing, refresh_signals, .proc/QueueRefresh)
	RegisterSignal(thing, COMSIG_PARENT_QDELETING, .proc/HandleMemberDel)
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
	addtimer(CALLBACK(src, .proc/Refresh), 1, TIMER_UNIQUE)

/datum/merger/proc/Refresh()
	var/list/tips = list()
	var/list/checked_turfs = list()
	var/list/new_members = list()
	if(origin)
		tips[origin] = NORTH|EAST|SOUTH|WEST
		new_members[origin] = NONE
	while(length(tips))
		var/atom/focus = tips[length(tips)]
		var/dirs_to_check = tips[focus]
		tips.len--
		for(var/dir in GLOB.cardinals)
			if(!(dirs_to_check & dir))
				continue
			var/turf/location = get_step(focus, dir)
			if(!location || checked_turfs[location])
				continue
			checked_turfs[location] = TRUE
			for(var/i in location)
				var/atom/movable/thing = i
				if(!merged_typecache[thing.type])
					continue
				if(attempt_merge_proc && !call(thing, attempt_merge_proc)(src, new_members))
					continue
				if(thing.mergers && thing.mergers[id] != src)
					var/datum/merger/existing = thing.mergers[id]
					qdel(src)
					existing.Refresh()
					return
				new_members[focus] |= dir // This is not a list, value of the members list is a bitfield of dirs
				var/next_dirs = turn(dir, 180)
				new_members[thing] |= next_dirs
				next_dirs = ~next_dirs
				var/existing = tips[thing] || (NORTH|EAST|SOUTH|WEST)
				tips[thing] = existing & next_dirs

	var/list/leaving_members = members - new_members
	for(var/atom/thing as anything in leaving_members)
		RemoveMember(thing)

	var/list/joining_members = new_members - members
	for(var/atom/thing as anything in joining_members)
		AddMember(thing, joining_members[thing])

	// They may not need a full update but the connected dirs could change
	for(var/atom/thing as anything in new_members)
		members[thing] = new_members[thing]

	SEND_SIGNAL(src, COMSIG_MERGER_REFRESH_COMPLETE, leaving_members, joining_members)

	if(!length(members))
		qdel(src)

#undef MERGERS_DEBUG
