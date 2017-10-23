/datum/space_level
	var/name = "Your config settings failed, you need to fix this for the datum space levels to work"
	var/zpos
	var/list/flags	// We'll use this to keep track of whether you can teleport/etc

	// Map transition stuff
	var/list/neighbours
	// # How this level connects with others. See __MAP_DEFINES.dm for defines
	// It's UNAFFECTED by default because none of the space turfs are normally linked up
	// so we don't need to rebuild transitions if an UNAFFECTED level is requested
	var/linkage = UNAFFECTED
	// # imaginary placements on the grid - these reflect the point it is linked to
	var/xi
	var/yi
	var/list/transit_north
	var/list/transit_south
	var/list/transit_east
	var/list/transit_west

	var/list/direction_cache

/datum/space_level/New(z, new_name, transition_type = SELFLOOPING, list/traits = list())
	transit_north = list()
	transit_south = list()
	transit_east = list()
	transit_west = list()
	neighbours = list()
	direction_cache = list()
	name = new_name
	zpos = z
	flags = traits.Copy()
	build_space_destination_arrays()
	set_linkage(transition_type)

/datum/space_level/Destroy()
	CheckRemoveFromLinkageMap()
	SSmapping.unbuilt_space_transitions -= src
	return ..()

/datum/space_level/proc/build_space_destination_arrays()
// We skip `add_to_transit` here because we want to skip the checks in order to save time
	// Bottom border
	var/_zpos = src.zpos
	for(var/turf/open/space/S in block(locate(1, 1,  _zpos), locate(world.maxx, TRANSITIONEDGE + 1, _zpos)))
		transit_south |= S

	// Top border
	for(var/turf/open/space/S in block(locate(1, world.maxy, _zpos), locate(world.maxx, world.maxy - TRANSITIONEDGE - 1, _zpos)))
		transit_north |= S

	// Left border
	for(var/turf/open/space/S in block(locate(1, TRANSITIONEDGE+1, _zpos), locate(TRANSITIONEDGE + 1, world.maxy - TRANSITIONEDGE - 2, _zpos)))
		transit_west |= S

	// Right border
	for(var/turf/open/space/S in block(locate(world.maxx - TRANSITIONEDGE - 1, TRANSITIONEDGE + 1, _zpos), locate(world.maxx, world.maxy - TRANSITIONEDGE - 2, _zpos)))
		transit_east |= S

/datum/space_level/proc/add_to_transit(turf/open/space/S)
	if(S.y <= TRANSITIONEDGE)
		transit_south |= S
		return

	// Top border
	if(S.y >= (world.maxy - TRANSITIONEDGE - 1))
		transit_north |= S
		return

	// Left border
	if(S.x <= TRANSITIONEDGE)
		transit_west |= S
		return

	// Right border
	if(S.x >= (world.maxx - TRANSITIONEDGE - 1))
		transit_east |= S

/datum/space_level/proc/remove_from_transit(turf/open/space/S)
	if(S.y <= TRANSITIONEDGE)
		transit_south -= S
		return

	// Top border
	if(S.y >= (world.maxy - TRANSITIONEDGE - 1))
		transit_north -= S
		return

	// Left border
	if(S.x <= TRANSITIONEDGE)
		transit_west -= S
		return

	// Right border
	if(S.x >= (world.maxx - TRANSITIONEDGE - 1))
		transit_east -= S

/datum/space_level/proc/apply_transition(turf/open/space/S)
	if(SSmapping.unbuilt_space_transitions[src])
		return // Let SSmapping handle this one
	switch(linkage)
		if(UNAFFECTED)
			S.remove_transitions()
		if(SELFLOOPING,CROSSLINKED)
			var/datum/space_level/E = get_connection()
			if(S in transit_north)
				E = get_connection("[NORTH]")
				S.set_transition_north(E.zpos)
			if(S in transit_south)
				E = get_connection("[SOUTH]")
				S.set_transition_south(E.zpos)
			if(S in transit_east)
				E = get_connection("[EAST]")
				S.set_transition_east(E.zpos)
			if(S in transit_west)
				E = get_connection("[WEST]")
				S.set_transition_west(E.zpos)

/datum/space_level/proc/return_turfs()
	return block(locate(1, 1, zpos), locate(world.maxx, world.maxy, zpos))

/datum/space_level/proc/CheckRemoveFromLinkageMap()
	if(linkage == CROSSLINKED)
		var/datum/spacewalk_grid/linkage_map = SSmapping.linkage_map
		if(linkage_map)
			remove_from_space_network(linkage_map)

/datum/space_level/proc/set_linkage(transition_type)
	if(linkage == transition_type)
		return
	// Remove ourselves from the linkage map if we were cross-linked
	CheckRemoveFromLinkageMap()

	SSmapping.unbuilt_space_transitions[src] = TRUE
	linkage = transition_type
	switch(transition_type)
		if(UNAFFECTED)
			reset_connections()
		if(SELFLOOPING)
			link_to_self() // `link_to_self` is defined in space_transitions.dm
		if(CROSSLINKED)
			add_to_space_network(SSmapping.linkage_map)
