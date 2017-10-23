// Populate our space level list
// and prepare space transitions
/datum/controller/subsystem/mapping/proc/InitializeZManager()
	if(z_list)	//subsystem/Recover or badminnery, no need
		return
	
	z_list = list()
	levels_by_name = list()
	heaps = list()

	var/list/default_map_traits = DEFAULT_MAP_TRAITS

	if(default_map_traits.len != world.maxz)
		WARNING("More or less map attributes pre-defined than existent z levels - [default_map_traits.len] vs [world.maxz]. Ignoring the larger")
		if(default_map_traits.len > world.maxz)
			default_map_traits.Cut(world.maxz + 1, default_map_traits.len + 1)
		
	// First take care of "Official" z levels, without visiting levels outside of the list
	for(var/I in 1 to default_map_traits.len)
		var/list/features = default_map_traits[I]
		var/name = features[DL_NAME]
		var/datum/space_level/S = new(I, name, features[DL_LINKAGE], features[DL_ATTRS])
		z_list += S
		levels_by_name[name] = S

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
	var/zkey = "[our_z]"
	UNTIL(!zs_being_cleared || !zs_being_cleared[zkey])
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
	var/our_z = z_list.len
	var/datum/space_level/S = get_zlev(our_z)
	z_list.Cut(our_z, our_z + 1)
	levels_by_name -= S.name
	CleanTurfs(S.return_turfs())
	qdel(S)

/// all turfs must be on the same zlevel
/datum/controller/subsystem/mapping/proc/CleanTurfs(list/turfs)
	set waitfor = FALSE
	LAZYINITLIST(zs_being_cleared)
	var/turf/first = turfs[1]
	var/z_key = "[first.z]"
	var/list/zbc = zs_being_cleared
	++zbc[z_key]
	stoplag(1)	//since we KNOW this will take a while, start sleeping so we don't hold up the caller
	for(var/I in turfs)
		qdel(I, TRUE)
		CHECK_TICK
	if(!--zbc[z_key])
		zbc -= z_key
		if(!zbc.len)
			zs_being_cleared = null

// An internally-used proc used for heap-zlevel management
/datum/controller/subsystem/mapping/proc/add_new_heap()
	return add_new_zlevel("Heap level #[z_list.len + 1]", UNAFFECTED, list(BLOCK_TELEPORT, ADMIN_LEVEL), /datum/space_level/heap)

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

/// TRAIT stuff

/datum/controller/subsystem/mapping/proc/check_level_has_trait(z, list/traits)
	for(var/I in traits)
		if(check_level_trait(z, I))
			return TRUE
	return FALSE

/datum/controller/subsystem/mapping/proc/check_level_has_all_traits(z, list/traits)
	for(var/I in traits)
		if(!check_level_trait(z, I))
			return FALSE
	return TRUE

/datum/controller/subsystem/mapping/proc/check_level_trait(z, trait)
	if(!z)
		return FALSE
	var/list/trait_list
	if(z_list)
		var/datum/space_level/S = get_zlev(z)
		trait_list = S.flags
	else
		var/list/default_map_traits = DEFAULT_MAP_TRAITS
		trait_list = default_map_traits[z]
		trait_list = trait_list[DL_ATTRS]
	return trait_list[trait] ? TRUE : FALSE

/datum/controller/subsystem/mapping/proc/levels_by_trait(trait)
	. = list()
	var/list/_z_list = z_list
	for(var/A in _z_list)
		var/datum/space_level/S = A
		if(S.flags[trait])
			. |= S.zpos

/datum/controller/subsystem/mapping/proc/levels_by_traits(z, list/traits)
	. = list()
	for(var/I in traits)
		. |= levels_by_trait(I)

/datum/controller/subsystem/mapping/proc/level_name_to_num(name)
	var/datum/space_level/S = get_zlev_by_name(name)
	return S.zpos
