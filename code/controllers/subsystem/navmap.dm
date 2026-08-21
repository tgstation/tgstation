SUBSYSTEM_DEF(navmap)
	name = "Navmap"
	ss_flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	/// Baseline movers used to bake static ground and flying edges.
	var/datum/can_pass_info/ground_rep
	var/datum/can_pass_info/flying_rep
	var/list/bake_queue = list()
	var/list/currentrun
	var/currentrun_index = 1
	var/list/border_blocker_cache
	var/list/mask_whitelist_cache
	var/list/force_conditional_cache
	var/list/auto_dirty_ztraits = list(ZTRAIT_STATION, ZTRAIT_MINING)
	var/alist/auto_dirty_zlevels = alist()
	var/list/space_type_cache
	/// Layered navigation groups and z-level lookup.
	var/alist/nav_groups = alist()
	var/alist/z_to_nav_layer = alist()
	var/topology_generation = 0
	var/topology_rebuild_in_progress = FALSE
	var/alist/nav_links = alist()
	/// Cross-z links indexed by their source turf for the DM fallback search.
	var/alist/nav_links_by_source = alist()
	var/next_nav_link_id = 1

/// Initializes bake representatives, blocker caches, and existing z-level data.
/datum/controller/subsystem/navmap/Initialize()
	ground_rep = new /datum/can_pass_info(null, null, no_id = TRUE)
	ground_rep.movement_type = GROUND

	flying_rep = new /datum/can_pass_info(null, null, no_id = TRUE)
	flying_rep.movement_type = FLYING

	border_blocker_cache = typecacheof(list(
		/obj/structure/window,
		/obj/machinery/door/window,
		/obj/structure/railing,
		/obj/machinery/door/firedoor/border_only,
	))
	mask_whitelist_cache = list()
	for(var/table_type in typesof(/obj/structure/table))
		mask_whitelist_cache[table_type] = PASSTABLE
	for(var/grille_type in typesof(/obj/structure/grille))
		mask_whitelist_cache[grille_type] = PASSGRILLE
	force_conditional_cache = typecacheof(list(
		/obj/structure/girder,
		/obj/structure/thing_boss_spike,
	))

	space_type_cache = typecacheof(/turf/open/space)
	rebuild_topology()
	sync_native_state()

	for(var/z in 1 to world.maxz)
		prebake_z(z)

	for(var/z in SSmapping.levels_by_any_trait(auto_dirty_ztraits))
		auto_dirty_zlevels[z] = TRUE
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, PROC_REF(on_new_zlevel))

	return SS_INIT_SUCCESS

/// Preserves baked and nav-link state when the subsystem is replaced.
/datum/controller/subsystem/navmap/Recover()
	ss_flags |= SS_NO_INIT
	initialized = SSnavmap.initialized
	ground_rep = SSnavmap.ground_rep
	flying_rep = SSnavmap.flying_rep
	bake_queue = SSnavmap.bake_queue
	currentrun = SSnavmap.currentrun
	currentrun_index = SSnavmap.currentrun_index
	border_blocker_cache = SSnavmap.border_blocker_cache
	mask_whitelist_cache = SSnavmap.mask_whitelist_cache
	force_conditional_cache = SSnavmap.force_conditional_cache
	auto_dirty_zlevels = SSnavmap.auto_dirty_zlevels
	space_type_cache = SSnavmap.space_type_cache
	nav_groups = SSnavmap.nav_groups
	z_to_nav_layer = SSnavmap.z_to_nav_layer
	topology_generation = SSnavmap.topology_generation
	nav_links = SSnavmap.nav_links
	nav_links_by_source = SSnavmap.nav_links_by_source
	next_nav_link_id = SSnavmap.next_nav_link_id

/// Enables automatic dirtying for a newly relevant z-level.
/datum/controller/subsystem/navmap/proc/on_new_zlevel(datum/source, datum/space_level/new_level)
	SIGNAL_HANDLER
	for(var/trait in auto_dirty_ztraits)
		if(new_level.traits[trait])
			auto_dirty_zlevels[new_level.z_value] = TRUE
			break
	rebuild_topology()
	if(!topology_rebuild_in_progress)
		sync_native_state()
	// This signal handler must not block while prebaking a full z-level.
	INVOKE_ASYNC(src, PROC_REF(prebake_z), new_level.z_value)

/// Rebuilds the stable group/layer mapping consumed by native multi-z searches.
/datum/controller/subsystem/navmap/proc/rebuild_topology()
	if(topology_rebuild_in_progress)
		return
	topology_rebuild_in_progress = TRUE
	var/alist/seen_groups = alist()
	nav_groups = alist()
	z_to_nav_layer = alist()
	for(var/z in 1 to world.maxz)
		var/list/stack = SSmapping.get_connected_levels(z)
		if(!length(stack))
			stack = list(z)
		// Sort numerically so native layer order matches z order.
		var/list/ordered = sort_list(stack.Copy(), GLOBAL_PROC_REF(cmp_numeric_asc))
		var/group_id = ordered[1]
		if(seen_groups[group_id])
			continue
		seen_groups[group_id] = TRUE
		var/list/group_levels = list()
		for(var/index in 1 to length(ordered))
			var/level = ordered[index]
			group_levels += level
			z_to_nav_layer[level] = list("group" = group_id, "layer" = index - 1)
		nav_groups[group_id] = group_levels
	topology_generation++
	topology_rebuild_in_progress = FALSE

/// Publishes the current z-level topology to the native cache.
/datum/controller/subsystem/navmap/proc/publish_topology()
	var/list/flat = list()
	for(var/group_id in nav_groups)
		var/list/group_levels = nav_groups[group_id]
		for(var/index in 1 to length(group_levels))
			flat += list(group_id, index - 1, group_levels[index])
	var/success = navmap_pathfinder_topology_update(topology_generation, flat)
	return success

/// Re-publishes native topology and links when state is stale.
/datum/controller/subsystem/navmap/proc/sync_native_state()
	if(!topology_rebuild_in_progress && world.maxz > 0 && (!topology_generation || !length(z_to_nav_layer)))
		rebuild_topology()
	if(!navmap_pathfinder_available())
		return FALSE
	var/list/native_state = navmap_pathfinder_state()
	var/valid_link_count = 0
	for(var/id in nav_links)
		var/datum/nav_link/link = nav_links[id]
		if(!QDELETED(link) && link.source && link.destination)
			valid_link_count++
	if(native_state \
		&& (topology_generation || !world.maxz) \
		&& native_state["generation"] == topology_generation \
		&& native_state["z_count"] == length(z_to_nav_layer) \
		&& native_state["layer_count"] == length(z_to_nav_layer) \
		&& native_state["link_count"] == valid_link_count)
		return TRUE
	var/topology_success = publish_topology()
	var/links_success = topology_success && sync_nav_links()
	if(!topology_success || !links_success)
		return FALSE
	return TRUE

/// Registers a reusable transition and publishes its endpoints to the native cache.
/datum/controller/subsystem/navmap/proc/register_nav_link(datum/nav_link/link)
	if(!link.id)
		link.id = next_nav_link_id++
	nav_links[link.id] = link
	if(!nav_links_by_source[link.source])
		nav_links_by_source[link.source] = alist()
	nav_links_by_source[link.source][link.id] = link
	topology_generation++
	sync_native_state()
	return link.id

/// Removes a transition and republishes the native link cache.
/datum/controller/subsystem/navmap/proc/unregister_nav_link(datum/nav_link/link)
	if(link.id && nav_links[link.id] == link)
		nav_links[link.id] = null
		nav_links.Remove(link.id)
		var/alist/source_links = nav_links_by_source[link.source]
		if(source_links)
			source_links[link.id] = null
			if(!length(source_links))
				nav_links_by_source[link.source] = null
		topology_generation++
		sync_native_state()

/// Publishes all currently valid navigation links.
/datum/controller/subsystem/navmap/proc/sync_nav_links()
	var/list/flat = list()
	for(var/id in nav_links)
		var/datum/nav_link/link = nav_links[id]
		if(QDELETED(link) || !link.source || !link.destination)
			continue
		flat += list(link.id, link.source.x, link.source.y, link.source.z, link.destination.x, link.destination.y, link.destination.z, link.cost)
	var/success = navmap_pathfinder_links_update(flat)
	return success

/// Native callback for side-effect-free, mover-specific link eligibility.
/proc/navmap_pathfinder_link_can_plan(id, datum/can_pass_info/pass_info)
	var/datum/nav_link/link = SSnavmap.nav_links[id]
	return link && !QDELETED(link) && link.can_plan(pass_info)

/// Checks whether two turfs are connected by z-levels and links.
/datum/controller/subsystem/navmap/proc/groups_reachable(turf/start, turf/goal)
	var/list/start_layer = z_to_nav_layer[start?.z]
	var/list/goal_layer = z_to_nav_layer[goal?.z]
	if(!start_layer || !goal_layer)
		return FALSE
	if(start_layer["group"] == goal_layer["group"])
		return TRUE
	var/alist/adjacency = alist()
	for(var/id in nav_links)
		var/datum/nav_link/link = nav_links[id]
		var/list/source_layer = z_to_nav_layer[link.source?.z]
		var/list/destination_layer = z_to_nav_layer[link.destination?.z]
		if(!source_layer || !destination_layer)
			continue
		if(!adjacency[source_layer["group"]])
			adjacency[source_layer["group"]] = list()
		adjacency[source_layer["group"]] += destination_layer["group"]
	var/list/visited = list(start_layer["group"])
	var/list/frontier = list(start_layer["group"])
	while(length(frontier))
		var/group = frontier[1]
		frontier.Cut(1, 2)
		for(var/neighbor in adjacency[group])
			if(neighbor == goal_layer["group"])
				return TRUE
			if(!(neighbor in visited))
				visited += neighbor
				frontier += neighbor
	return FALSE

/// Reports the number of turfs waiting to bake.
/datum/controller/subsystem/navmap/stat_entry(msg)
	var/pending = length(bake_queue) + max(length(currentrun) - currentrun_index + 1, 0)
	msg = "Dirty:[pending]"
	return ..()

/// Bakes queued turfs until the tick budget is exhausted.
/datum/controller/subsystem/navmap/fire(resumed)
	if(currentrun_index > length(currentrun))
		if(!length(bake_queue))
			can_fire = FALSE
			return
		currentrun = bake_queue
		bake_queue = list()
		currentrun_index = 1

	while(currentrun_index <= length(currentrun))
		var/turf/baking_turf = currentrun[currentrun_index]
		currentrun_index++
		if(!QDELETED(baking_turf))
			baking_turf.turf_flags &= ~NAV_QUEUED
			baking_turf.nav_bake()
		if(MC_TICK_CHECK)
			return

/// Queues a dirty turf once for asynchronous baking.
/datum/controller/subsystem/navmap/proc/queue_turf_bake(turf/queued_turf)
	if(queued_turf.turf_flags & NAV_QUEUED)
		return
	queued_turf.turf_flags |= NAV_QUEUED
	bake_queue += queued_turf
	if(!can_fire)
		can_fire = TRUE

/// Bakes and bulk-publishes every non-space turf on a z-level.
/datum/controller/subsystem/navmap/proc/prebake_z(z_level)
	var/count = 0
	var/list/navmap_batch = list()
	for(var/turf/baking_turf as anything in Z_TURFS(z_level))
		baking_turf.nav_bake(skip_navmap_push = TRUE)
		navmap_batch += list(baking_turf.x, baking_turf.y, baking_turf.z, baking_turf.nav_pass)
		count++
		CHECK_TICK
	if(length(navmap_batch))
		navmap_pathfinder_bulk_update(navmap_batch)
	return count
