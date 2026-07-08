/// Packed passability bits. null = unbaked / dirty. See code/__DEFINES/navmesh.dm for layout.
/turf/var/nav_pass = null
/// Lazy assoc: "[dir]" -> flat list of conditional blocker entries (numbers = pass_flags masks,
/// atom refs = evaluated live via CanAStarPass). Only present on turfs with conditional edges.
/turf/var/list/nav_blockers



///Marks this turf and any neighbors as dirty and queue them for baking
/turf/proc/nav_dirty()
	// Before the subsystem inits nothing is baked
	if(!SSnavmesh.initialized)
		return
	// Only auto-update important z-levels
	if(!SSnavmesh.auto_dirty_zlevels["[z]"])
		return
	nav_pass = null
	nav_blockers = null
	SSnavmesh.queue_turf_bake(src)
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(src, dir)
		if(neighbor)
			neighbor.nav_pass = null
			neighbor.nav_blockers = null
			SSnavmesh.queue_turf_bake(neighbor)



///Compute all directions of this turf for pathability
/turf/proc/nav_bake()
	var/packed = NAV_BAKED
	var/list/blockers = null

	for(var/dir in GLOB.cardinals)
		var/turf/dest = get_step(src, dir)
		if(isnull(dest))
			continue // edge of the world, no edge
		var/list/edge_blockers = list()
		packed |= nav_evaluate_edge(dir, dest, edge_blockers)
		if(length(edge_blockers))
			LAZYINITLIST(blockers)
			blockers["[dir]"] = edge_blockers

	nav_pass = packed
	nav_blockers = blockers

/*
* Classifies the outgoing edge from src to dest in direction `dir`, returning the OR of the relevant
* NAV_* bits for that dir and appending any conditional blocker entries to `edge_blockers`.
*/
/turf/proc/nav_evaluate_edge(dir, turf/dest, list/edge_blockers)
	// --- destination turf itself ---
	if(dest.density)
		return NONE // hard blocked, nobody passes
	// Baseline class passability of the destination turf, before contents.
	var/ground_ok = TRUE
	var/flight_ok = TRUE
	var/has_cond = FALSE
	switch(dest.pathing_pass_method)
		if(TURF_PATHING_PASS_NO)
			return NONE
		if(TURF_PATHING_PASS_PROC)
			// e.g. openspace: mover-dependent in a way our repless reps can't capture (its CanAStarPass
			// resolves requester_ref / can_z_move). Store the dest turf as a live conditional entry and
			// leave both class bits set (the "mover-independent / no wall" baseline). A* walks the entry
			// with the real mover, which resolves flying-vs-falling correctly.
			edge_blockers += dest
			has_cond = TRUE

	// border objects :(
	for(var/obj/border in src)
		if(!SSnavmesh.border_blocker_cache[border.type])
			continue
		if(!border.density && border.can_astar_pass == CANASTARPASS_DENSITY)
			continue
		if(nav_classify_atom(border, edge_blockers))
			has_cond = TRUE
		else
			if(ground_ok && !border.CanAStarPass(dir, SSnavmesh.ground_rep))
				ground_ok = FALSE
			if(flight_ok && !border.CanAStarPass(dir, SSnavmesh.flying_rep))
				flight_ok = FALSE

	// destination contents (reverse dir)
	var/reverse = REVERSE_DIR(dir)
	for(var/atom/movable/iter_object in dest)
		if(ismob(iter_object))
			continue // mobs are never baked; resolved live at execution time
		if(!iter_object.density && iter_object.can_astar_pass == CANASTARPASS_DENSITY)
			continue
		if(nav_classify_atom(iter_object, edge_blockers))
			has_cond = TRUE
		else
			if(ground_ok && !iter_object.CanAStarPass(reverse, SSnavmesh.ground_rep))
				ground_ok = FALSE
			if(flight_ok && !iter_object.CanAStarPass(reverse, SSnavmesh.flying_rep))
				flight_ok = FALSE

	var/bits = NONE
	if(ground_ok)
		bits |= NAV_GROUND(dir)
	if(flight_ok)
		bits |= NAV_FLIGHT(dir)
	if(has_cond)
		bits |= NAV_COND(dir)
	return bits

///Figure out if this is mover-dependent and we need to store the atom or if we just need the bitmask
/turf/proc/nav_classify_atom(atom/movable/blocker, list/edge_blockers)
	// Whitelisted pure pass-flag gates (tables, grilles) -> store the exact honoured pass_flag as a plain mask, so we can just check it cheaply
	var/mask = SSnavmesh.mask_whitelist_cache[blocker.type]
	if(mask)
		edge_blockers += mask
		return TRUE

	// Anything mover-dependent: access doors, ALWAYS_PROC atoms, generic pass_flags_self holders,
	// or an explicit escape-hatch type. Store the atom and evaluate live.
	if(istype(blocker, /obj/machinery/door) \
		|| blocker.can_astar_pass == CANASTARPASS_ALWAYS_PROC \
		|| (blocker.pass_flags_self & ~NAV_NON_PASS_FLAGS) \
		|| SSnavmesh.force_conditional_cache[blocker.type])
		edge_blockers += blocker
		return TRUE

	return FALSE
