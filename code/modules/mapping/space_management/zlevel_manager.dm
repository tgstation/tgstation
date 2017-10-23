// Populate our space level list
// and prepare space transitions
/datum/controller/subsystem/mapping/proc/InitializeZManager()
	if(z_list)	//subsystem/Recover or badminnery, no need
		return
	
	z_list = list()
	levels_by_name = list()
	heaps = list()
	unbuilt_space_transitions = list()
	linkage_map = new

	var/list/default_map_traits = DEFAULT_MAP_TRAITS

	if(default_map_traits.len > world.maxz)
		WARNING("More map attributes pre-defined than existent z levels - [num_official_z_levels]. Ignoring extras")
		default_map_traits.Cut(world.maxz + 1, default_map_traits.len + 1)
		
	// First take care of "Official" z levels, without visiting levels outside of the list
	for(var/F in default_map_traits)
		var/list/features = F
		var/name = features[DL_NAME]

		var/datum/space_level/S = new(k, name, features[DL_LINKAGE], features[DL_ATTRS])
		z_list += S
		levels_by_name[name] = S

	// Then, we take care of unmanaged z levels
	// They get the default linkage of SELFLOOPING
	for(var/i in default_map_traits.len to world.maxz)
		z_list += new /datum/space_level(i)

/datum/controller/subsystem/mapping/proc/get_zlev(z)
	. = z_list[z]
	if(!.)
		CRASH("Unmanaged z level: '[z]'")

/datum/controller/subsystem/mapping/proc/get_zlev_by_name(A)
	. = levels_by_name[A]
	if(!.)
		CRASH("Non-existent z level: '[A]'")

/datum/controller/subsystem/mapping/proc/rename_level(z, new_name)
	var/datum/space_level/S = get_zlev(z)
	levels_by_name -= S.name
	S.name = new_name
	levels_by_name[new_name] = S

/datum/controller/subsystem/mapping/proc/add_trait(z, trait)
	var/datum/space_level/S = get_zlev(z)
	S.flags[trait] = TRUE

/datum/controller/subsystem/mapping/proc/remove_trait(z, trait)
	var/datum/space_level/S = get_zlev(z)
	S.flags -= trait

/**
*
*	SPACE ALLOCATION
*
*/

// For when you need the z-level to be at a certain point
/datum/controller/subsystem/mapping/proc/increase_max_zlevel_to(new_maxz)
	while(z_list.len < new_maxz)
		add_new_zlevel("Anonymous Z level [world.maxz + 1]")

// Increments the max z-level by one
// For convenience's sake returns the z-level added
/datum/controller/subsystem/mapping/proc/add_new_zlevel(name, linkage = SELFLOOPING, traits = list(BLOCK_TELEPORT), z_type = /datum/space_level)
	if(levels_by_name[name])
		CRASH("Name already in use: [name]")
	var/our_z = z_list.len + 1
	if(world.maxz < our_z)
		++world.maxz
	var/datum/space_level/S = new z_type(our_z, name, transition_type = linkage, traits = traits)
	levels_by_name[name] = S
	z_list += S
	return our_z

/datum/controller/subsystem/mapping/proc/cut_levels_downto(new_maxz)
	while(z_list.len > new_maxz)
		kill_topmost_zlevel()

// Decrements the max z-level by one
// not normally used, but hey the swapmap loader wanted it
// Also probably a worse idea than just emptying out levels when needed
/datum/controller/subsystem/mapping/proc/kill_topmost_zlevel()
	var/our_z = zlist.len
	var/datum/space_level/S = get_zlev(our_z)
	z_list.Cut(our_z, our_z + 1)
	levels_by_name -= S.name
	CleanTurfs(S.return_turfs())
	qdel(S)

/datum/controller/subsystem/mapping/proc/CleanTurfs(list/turfs)
	set waitfor = FALSE
	stoplag(1)	//since we KNOW this will take a while, start sleeping so we don't hold up the caller
	for(var/I in turfs)
		qdel(I, TRUE)
		CHECK_TICK

// An internally-used proc used for heap-zlevel management
/datum/controller/subsystem/mapping/proc/add_new_heap()
	return add_new_zlevel("Heap level #[zlist.len + 1]", UNAFFECTED, list(BLOCK_TELEPORT, ADMIN_LEVEL), /datum/space_level/heap)

// This is what you can call to allocate a section of space
// Later, I'll add an argument to let you define the flags on the region
/datum/controller/subsystem/mapping/proc/allocate_space(width, height)
	if(width > world.maxx || height > world.maxy)
		throw EXCEPTION("Too much space requested! \[[width],[height]\]")
	if(!LAZYLEN(heaps))
		LAZYADD(heaps, add_new_heap())
	var/datum/space_level/heap/our_heap
	var/weve_got_vacancy = 0
	for(our_heap in heaps)
		weve_got_vacancy = our_heap.request(width, height)
		if(weve_got_vacancy)
			break // We're sticking with the present value of `our_heap` - it's got room
		// This loop will also run out if no vacancies are found

	if(!weve_got_vacancy)
		our_heap = add_new_heap()
		heaps += our_heap
	return our_heap.allocate(width, height)
