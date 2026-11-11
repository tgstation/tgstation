SUBSYSTEM_DEF(navmap)
	name = "Navmap"
	ss_flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
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
	/// Startup dirties keyed by "x,y,z", since turfs can be replaced.
	var/alist/startup_dirty_turfs = alist()
	/// Startup dirties being baked. Kept across subsystem recovery.
	var/alist/startup_dirty_currentrun = alist()
	/// Terrain cost changes collected during startup.
	var/alist/startup_dirty_costs = alist()
	var/alist/startup_dirty_generation = alist()
	var/alist/startup_dirty_turf_refs = alist()
	var/alist/startup_dirty_ref_zlevels = alist()
	var/alist/startup_baked_generation = alist()
	var/alist/startup_baked_turfs = alist()
	/// Native updates waiting to be sent during startup.
	var/list/startup_publication_batch = list()
	/// True until startup changes have been baked.
	var/startup_finalization_pending = TRUE
	/// True while generating a station bake file.
	var/generating_station_navmap = FALSE
	/// Layered navigation groups and z-level lookup.
	var/alist/nav_groups = alist()
	var/alist/z_to_nav_layer = alist()
	var/topology_generation = 0
	/// Changes when turf terrain-cost flags or their passability dependencies are invalidated.
	var/nav_cost_generation = 0
	/// Nonzero terrain costs and later changes, keyed by coordinate.
	var/alist/published_nav_cost_flags = alist()
	/// Weighted DM fallback searches that have consumed terrain costs.
	var/list/datum/pathfind/navmap/active_cost_searches = list()
	var/topology_rebuild_in_progress = FALSE
	var/alist/nav_links = alist()
	/// Navigation links indexed by their source turf for the DM fallback search.
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
	for(var/z in SSmapping.levels_by_any_trait(auto_dirty_ztraits))
		auto_dirty_zlevels[z] = TRUE

	#ifdef NAVMAP_BAKE_GENERATION
	generating_station_navmap = TRUE
	if(!export_station_navmap())
		CRASH("Navmap bake generation failed for [SSmapping.current_map.map_name]")
	return SS_INIT_SUCCESS
	#endif

	var/alist/restored_station_levels = try_restore_station_navmap()

	for(var/z in 1 to world.maxz)
		if(restored_station_levels?[z])
			continue
		if(auto_dirty_zlevels[z])
			prebake_z(z)

	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, PROC_REF(on_new_zlevel))
	flush_startup_dirty_turfs()
	startup_finalization_pending = FALSE

	return SS_INIT_SUCCESS

/// Preserves baked navigation-link state when the subsystem is replaced.
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
	startup_dirty_turfs = SSnavmap.startup_dirty_turfs
	startup_dirty_currentrun = SSnavmap.startup_dirty_currentrun
	startup_dirty_costs = SSnavmap.startup_dirty_costs
	startup_dirty_generation = SSnavmap.startup_dirty_generation
	startup_dirty_turf_refs = SSnavmap.startup_dirty_turf_refs
	startup_dirty_ref_zlevels = SSnavmap.startup_dirty_ref_zlevels
	startup_baked_generation = SSnavmap.startup_baked_generation
	startup_baked_turfs = SSnavmap.startup_baked_turfs
	startup_publication_batch = SSnavmap.startup_publication_batch
	startup_finalization_pending = SSnavmap.startup_finalization_pending
	generating_station_navmap = SSnavmap.generating_station_navmap
	nav_groups = SSnavmap.nav_groups
	z_to_nav_layer = SSnavmap.z_to_nav_layer
	topology_generation = SSnavmap.topology_generation
	nav_cost_generation = SSnavmap.nav_cost_generation
	published_nav_cost_flags = SSnavmap.published_nav_cost_flags
	active_cost_searches = SSnavmap.active_cost_searches
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
	// The level still needs its content loaded. Bake turfs as they change or are used.

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

/// Re-publishes native topology and navigation links when state is stale.
/datum/controller/subsystem/navmap/proc/sync_native_state()
	if(!topology_rebuild_in_progress && world.maxz > 0 && (!topology_generation || !length(z_to_nav_layer)))
		rebuild_topology()
	if(!navmap_pathfinder_available())
		return FALSE
	var/list/native_state = navmap_pathfinder_state()
	var/valid_nav_link_count = 0
	for(var/id in nav_links)
		var/datum/nav_link/nav_link = nav_links[id]
		if(!QDELETED(nav_link) && nav_link.source && nav_link.destination)
			valid_nav_link_count++
	if(native_state \
		&& (topology_generation || !world.maxz) \
		&& native_state["generation"] == topology_generation \
		&& native_state["links_generation"] == topology_generation \
		&& native_state["z_count"] == length(z_to_nav_layer) \
		&& native_state["layer_count"] == length(z_to_nav_layer) \
		&& native_state["nav_link_count"] == valid_nav_link_count)
		return TRUE
	var/topology_success = publish_topology()
	var/nav_links_success = topology_success && sync_nav_links(topology_generation)
	if(!topology_success || !nav_links_success)
		return FALSE
	return TRUE

/// Registers a reusable transition and publishes its endpoints to the native cache.
/datum/controller/subsystem/navmap/proc/register_nav_link(datum/nav_link/nav_link)
	if(!nav_link.id)
		nav_link.id = next_nav_link_id++
	nav_links[nav_link.id] = nav_link
	if(!nav_links_by_source[nav_link.source])
		nav_links_by_source[nav_link.source] = alist()
	nav_links_by_source[nav_link.source][nav_link.id] = nav_link
	topology_generation++
	sync_native_state()
	return nav_link.id

/// Removes a transition and republishes the native navigation-link cache.
/datum/controller/subsystem/navmap/proc/unregister_nav_link(datum/nav_link/nav_link)
	if(nav_link.id && nav_links[nav_link.id] == nav_link)
		nav_links[nav_link.id] = null
		nav_links.Remove(nav_link.id)
		var/alist/source_links = nav_links_by_source[nav_link.source]
		if(source_links)
			source_links[nav_link.id] = null
			if(!length(source_links))
				nav_links_by_source[nav_link.source] = null
		topology_generation++
		sync_native_state()

/// Publishes all currently valid navigation links.
/datum/controller/subsystem/navmap/proc/sync_nav_links(generation)
	var/list/flat = list()
	for(var/id in nav_links)
		var/datum/nav_link/nav_link = nav_links[id]
		if(QDELETED(nav_link) || !nav_link.source || !nav_link.destination)
			continue
		flat += list(nav_link.id, nav_link.source.x, nav_link.source.y, nav_link.source.z, nav_link.destination.x, nav_link.destination.y, nav_link.destination.z, nav_link.cost)
	var/success = navmap_pathfinder_links_update(generation, flat)
	return success

/// Publishes effective turf cost flags and notifies fallback searches using changed groups.
/datum/controller/subsystem/navmap/proc/publish_nav_cost_flags(turf/tile, effective_flags)
	var/alist/z_flags = published_nav_cost_flags[tile.z]
	if(!z_flags)
		if(!effective_flags)
			return
		z_flags = alist()
		published_nav_cost_flags[tile.z] = z_flags
	var/alist/y_flags = z_flags[tile.y]
	if(!y_flags)
		if(!effective_flags)
			return
		y_flags = alist()
		z_flags[tile.y] = y_flags
	var/previous_flags = y_flags[tile.x]
	if(isnull(previous_flags) && !effective_flags)
		return
	var/old_flags = isnull(previous_flags) ? 0 : previous_flags
	if(old_flags != effective_flags)
		var/changed_flags = old_flags ^ effective_flags
		nav_cost_generation++
		for(var/datum/pathfind/navmap/search as anything in active_cost_searches)
			search.nav_cost_flags_changed(tile, changed_flags)
	y_flags[tile.x] = effective_flags

/// Native callback for side-effect-free, mover-specific link eligibility.
/proc/navmap_pathfinder_link_can_plan(id, datum/can_pass_info/pass_info)
	var/datum/nav_link/nav_link = SSnavmap.nav_links[id]
	return nav_link && !QDELETED(nav_link) && nav_link.can_plan(pass_info)

/// Checks whether two turfs are connected by z-levels and navigation links.
/datum/controller/subsystem/navmap/proc/groups_reachable(turf/start, turf/goal)
	var/list/start_layer = z_to_nav_layer[start?.z]
	var/list/goal_layer = z_to_nav_layer[goal?.z]
	if(!start_layer || !goal_layer)
		return FALSE
	if(start_layer["group"] == goal_layer["group"])
		return TRUE
	var/alist/adjacency = alist()
	for(var/id in nav_links)
		var/datum/nav_link/nav_link = nav_links[id]
		var/list/source_layer = z_to_nav_layer[nav_link.source?.z]
		var/list/destination_layer = z_to_nav_layer[nav_link.destination?.z]
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
	var/list/navmap_batch = list()
	var/count = 0
	for(var/turf/baking_turf as anything in Z_TURFS(z_level))
		var/effective_cost_flags = baking_turf.nav_bake(skip_navmap_push = TRUE)
		if(startup_dirty_ref_zlevels[z_level])
			mark_startup_turf_baked(baking_turf)
		navmap_batch += list(baking_turf.x, baking_turf.y, baking_turf.z, baking_turf.nav_pass, effective_cost_flags)
		count++
		if(length(navmap_batch) >= 5000)
			publish_startup_navmap_batch(navmap_batch)
			navmap_batch.Cut()
			CHECK_TICK
	if(length(navmap_batch))
		publish_startup_navmap_batch(navmap_batch)
	return count

/// Sends a batch to the native cache.
/datum/controller/subsystem/navmap/proc/publish_startup_navmap_batch(list/navmap_batch)
	navmap_pathfinder_bulk_update(navmap_batch)

/// Hashes the loaded map config and DMM files.
/datum/controller/subsystem/navmap/proc/current_map_fingerprint()
	var/datum/map_config/map_config = SSmapping.current_map
	if(!map_config || !map_config.config_filename || !fexists(map_config.config_filename))
		return null
	var/config_text = file2text(map_config.config_filename)
	if(!config_text)
		return null
	var/material = "[md5(config_text)]|[map_config.map_path]|[json_encode(map_config.map_file)]|[json_encode(map_config.traits)]|[map_config.height_autosetup]|[world.maxx]x[world.maxy]"
	var/list/map_files = islist(map_config.map_file) ? map_config.map_file : list(map_config.map_file)
	for(var/map_file in map_files)
		var/map_path = "_maps/[map_config.map_path]/[map_file]"
		if(!fexists(map_path))
			return null
		var/map_text = file2text(map_path)
		if(!map_text)
			return null
		material += "|[map_file]:[md5(map_text)]"
		CHECK_TICK
	return md5(material)

/// Loads and checks the station bake before restoring it.
/datum/controller/subsystem/navmap/proc/try_restore_station_navmap()
	var/list/station_levels = sort_list(SSmapping.levels_by_trait(ZTRAIT_STATION).Copy(), GLOBAL_PROC_REF(cmp_numeric_asc))
	if(!length(station_levels))
		return null
	var/map_fingerprint = current_map_fingerprint()
	if(!map_fingerprint)
		log_world("Navmap bake cache unavailable for [SSmapping.current_map.map_name]: could not fingerprint loaded map inputs")
		return null
	var/list/index = read_navmap_json("build/navmaps/index.json")
	if(!islist(index))
		log_world("Navmap bake cache unavailable for [SSmapping.current_map.map_name]: missing or bad index")
		return null
	var/cache_path = index?[map_fingerprint]
	if(!istext(cache_path) || copytext(cache_path, 1, length("build/navmaps/") + 1) != "build/navmaps/")
		log_world("Navmap bake cache unavailable for [SSmapping.current_map.map_name]; using normal baking")
		return null
	if(findtext(cache_path, "..") || copytext(cache_path, length(cache_path) - length(".navmap.json") + 1) != ".navmap.json")
		log_world("Navmap bake cache rejected for [SSmapping.current_map.map_name]: invalid cache path")
		return null
	var/list/cache = read_navmap_json(cache_path)
	if(!islist(cache))
		log_world("Navmap bake cache unavailable for [SSmapping.current_map.map_name]: missing or bad data")
		return null
	var/cache_map_config = cache["map_config"]
	if(cache["format_version"] != 1 \
		|| cache["bake_rules_version"] != NAVMAP_BAKE_RULES_VERSION \
		|| cache["map_fingerprint"] != map_fingerprint \
		|| !istext(cache_map_config) \
		|| replacetext(cache_map_config, "\\", "/") != replacetext(SSmapping.current_map.config_filename, "\\", "/"))
		log_world("Navmap bake cache rejected for [SSmapping.current_map.map_name]: incompatible or invalid manifest")
		return null
	var/list/layers = cache["layers"]
	if(!islist(layers) || length(layers) != length(station_levels))
		log_world("Navmap bake cache rejected for [SSmapping.current_map.map_name]: station layer count differs")
		return null
	var/alist/restored_levels = alist()
	for(var/layer_index in 1 to length(layers))
		var/z_level = station_levels[layer_index]
		if(!restore_station_navmap_layer(z_level, layers[layer_index]))
			// Fall back if restoration fails despite the checks above.
			log_world("Navmap bake cache restore failed for [SSmapping.current_map.map_name]; falling back to a full station bake")
			return null
		restored_levels[z_level] = TRUE
	return restored_levels

/// Reads a saved navmap or its index.
/datum/controller/subsystem/navmap/proc/read_navmap_json(path)
	var/contents = file2text(path)
	if(!contents)
		return null
	var/list/decoded = json_decode(contents)
	return islist(decoded) ? decoded : null

/// Checks a layer's size and palette before restoring its tiles.
/datum/controller/subsystem/navmap/proc/navmap_cache_layer_valid(list/layer)
	if(!islist(layer) || layer["width"] != world.maxx || layer["height"] != world.maxy)
		return FALSE
	var/list/palette = layer["palette"]
	var/list/runs = layer["runs"]
	if(!islist(palette) || !length(palette) || !islist(runs) || !length(runs))
		return FALSE
	var/allowed_nav = NAV_BAKED | NAV_GROUND(NORTH | SOUTH | EAST | WEST | UP | DOWN) | NAV_FLIGHT(NORTH | SOUTH | EAST | WEST | UP | DOWN) | NAV_COND(NORTH | SOUTH | EAST | WEST | UP | DOWN) | NAV_SIMULATED
	var/allowed_cost = NAV_COST_LAVA | NAV_COST_MAINTENANCE | NAV_COST_HALLWAY
	for(var/value in palette)
		CHECK_TICK
		if(isnull(value))
			continue
		if(!islist(value) || length(value) != 2 || !isnum(value[1]) || value[1] != round(value[1]) || !(value[1] & NAV_BAKED) || (value[1] & ~allowed_nav) || (value[1] & NAV_COND(NORTH | SOUTH | EAST | WEST | UP | DOWN)) || !isnum(value[2]) || value[2] != round(value[2]) || value[2] < 0 || (value[2] & ~allowed_cost))
			return FALSE
	return TRUE

/// Checks one run as it is read from the cache.
/datum/controller/subsystem/navmap/proc/navmap_cache_run_valid(list/run, palette_length)
	if(!islist(run) || length(run) != 2)
		return FALSE
	var/run_length = run[1]
	var/palette_index = run[2]
	return isnum(run_length) && run_length > 0 && run_length == round(run_length) && isnum(palette_index) && palette_index == round(palette_index) && palette_index >= 0 && palette_index < palette_length

/// Restores a station layer and queues turfs that need baking.
/datum/controller/subsystem/navmap/proc/restore_station_navmap_layer(z_level, list/layer)
	if(!navmap_cache_layer_valid(layer))
		return FALSE
	var/list/palette = layer["palette"]
	var/list/runs = layer["runs"]
	var/run_index = 1
	if(!navmap_cache_run_valid(runs[run_index], length(palette)))
		return FALSE
	var/run_left = runs[1][1]
	var/palette_index = runs[1][2] + 1
	var/list/navmap_batch = list()
	var/vertical_mask = NAV_GROUND(UP | DOWN) | NAV_FLIGHT(UP | DOWN) | NAV_COND(UP | DOWN)
	for(var/y in 1 to world.maxy)
		for(var/x in 1 to world.maxx)
			var/turf/tile = locate(x, y, z_level)
			if(!tile)
				return FALSE
			var/list/value = palette[palette_index]
			var/turf_key = "[x],[y],[z_level]"
			var/has_newer_bake = tile.nav_pass && (tile.nav_pass & NAV_BAKED)
			var/has_changed_record = startup_dirty_turfs[turf_key] || has_newer_bake
			var/effective_cost_flags = tile.get_nav_cost_flags()
			if(isnull(value) || has_changed_record)
				if(!has_newer_bake)
					tile.nav_pass = null
					tile.nav_blockers = null
				queue_startup_dirty_coordinate(x, y, z_level)
				navmap_batch += list(x, y, z_level, 0, effective_cost_flags)
			else
				var/packed = value[1] & ~vertical_mask
				for(var/dir in list(UP, DOWN))
					var/turf/vertical_destination = get_step_multiz(tile, dir)
					if(vertical_destination && tile.zPassOut(dir) && vertical_destination.zPassIn(dir))
						packed |= NAV_FLIGHT(dir)
				tile.nav_pass = packed
				tile.nav_blockers = null
				publish_nav_cost_flags(tile, effective_cost_flags)
				navmap_batch += list(x, y, z_level, packed, effective_cost_flags)
			run_left--
			if(!run_left)
				run_index++
				if(run_index <= length(runs))
					if(!navmap_cache_run_valid(runs[run_index], length(palette)))
						return FALSE
					run_left = runs[run_index][1]
					palette_index = runs[run_index][2] + 1
			if(length(navmap_batch) >= 5000)
				publish_startup_navmap_batch(navmap_batch)
				navmap_batch.Cut()
				CHECK_TICK
		// Send pending records before other code can change these turfs.
		if(length(navmap_batch))
			publish_startup_navmap_batch(navmap_batch)
			navmap_batch.Cut()
		CHECK_TICK
	if(run_left || run_index <= length(runs))
		return FALSE
	return TRUE

/// Saves static station edges, marking turfs that need baking at startup.
/datum/controller/subsystem/navmap/proc/export_station_navmap()
	var/map_config_path = world.params[NAVMAP_BAKE_SOURCE_CONFIG_PARAMETER] || SSmapping.current_map.config_filename
	var/list/path_parts = splittext(replacetext(map_config_path, "\\", "/"), "/")
	var/config_name = replacetext(path_parts[length(path_parts)], ".json", "")
	#ifdef NAVMAP_BAKE_RAW_OUTPUT
	var/output_path = "build/navmaps/[config_name].raw.json"
	#else
	var/output_path = "build/navmaps/[config_name].navmap.json"
	#endif
	var/list/station_levels = sort_list(SSmapping.levels_by_trait(ZTRAIT_STATION).Copy(), GLOBAL_PROC_REF(cmp_numeric_asc))
	if(!length(station_levels))
		return FALSE
	var/list/layers = list()
	for(var/z_level in station_levels)
		var/alist/unsafe = alist()
		for(var/y in 1 to world.maxy)
			for(var/x in 1 to world.maxx)
				var/index = ((y - 1) * world.maxx) + x
				var/turf/tile = locate(x, y, z_level)
				if(!tile)
					return FALSE
				if(tile.pathing_pass_method != TURF_PATHING_PASS_DENSITY || turf_has_nav_relevant_contents(tile))
					unsafe[index] = TRUE
					for(var/dir in GLOB.cardinals)
						var/turf/neighbor = get_step(tile, dir)
						if(neighbor)
							unsafe[((neighbor.y - 1) * world.maxx) + neighbor.x] = TRUE
			CHECK_TICK
		var/list/values = list()
		for(var/y in 1 to world.maxy)
			for(var/x in 1 to world.maxx)
				var/index = ((y - 1) * world.maxx) + x
				var/turf/tile = locate(x, y, z_level)
				if(unsafe[index])
					values += list(list("rebake" = TRUE))
					continue
				tile.nav_bake(skip_navmap_push = TRUE)
				var/packed = tile.nav_pass
				if(length(tile.nav_blockers) || (packed & NAV_COND(NORTH | SOUTH | EAST | WEST | UP | DOWN)))
					unsafe[index] = TRUE
					for(var/dir in GLOB.cardinals)
						var/turf/neighbor = get_step(tile, dir)
						if(neighbor)
							unsafe[((neighbor.y - 1) * world.maxx) + neighbor.x] = TRUE
				var/vertical_mask = NAV_GROUND(UP | DOWN) | NAV_FLIGHT(UP | DOWN) | NAV_COND(UP | DOWN)
				values += list(list(packed & ~vertical_mask, tile.get_nav_cost_flags()))
			CHECK_TICK
		// Use a marker while building the palette, then write it as JSON null.
		var/list/palette = list(list("rebake" = TRUE))
		var/alist/palette_lookup = alist()
		palette_lookup["rebake"] = 0
		var/list/runs = list()
		var/previous_palette_index = -1
		var/run_length = 0
		for(var/index in 1 to length(values))
			var/palette_key
			if(unsafe[index] || values[index]["rebake"])
				palette_key = "rebake"
			else
				palette_key = "[values[index][1]],[values[index][2]]"
			var/current_palette_index = palette_lookup[palette_key]
			if(isnull(current_palette_index))
				palette += list(values[index])
				current_palette_index = length(palette) - 1
				palette_lookup[palette_key] = current_palette_index
			if(current_palette_index == previous_palette_index)
				run_length++
			else
				if(run_length)
					runs += list(list(run_length, previous_palette_index))
				previous_palette_index = current_palette_index
				run_length = 1
		if(run_length)
			runs += list(list(run_length, previous_palette_index))
		layers += list(list("height" = world.maxy, "palette" = palette, "runs" = runs, "width" = world.maxx))
	var/map_fingerprint = current_map_fingerprint()
	if(!map_fingerprint)
		return FALSE
	var/list/output = list(
		"bake_rules_version" = NAVMAP_BAKE_RULES_VERSION,
		"format_version" = 1,
		"layers" = layers,
		"map_config" = map_config_path,
		"map_fingerprint" = map_fingerprint,
	)
	var/output_text = replacetext(json_encode(output), json_encode(list("rebake" = TRUE)), "null")
	#ifdef NAVMAP_BAKE_RAW_OUTPUT
	fdel(output_path)
	text2file(output_text, output_path)
	#else
	var/index_path = "build/navmaps/index.json"
	var/index_text = file2text(index_path)
	var/list/index = index_text ? json_decode(index_text) : list()
	if(!islist(index))
		return FALSE
	for(var/fingerprint in index.Copy())
		if(index[fingerprint] == output_path)
			index -= fingerprint
	index[map_fingerprint] = output_path
	rustg_file_write(output_text + "\n", output_path)
	rustg_file_write(json_encode(sort_list(index)) + "\n", index_path)
	log_world("Saved navmap to [output_path]")
	#endif
	return fexists(output_path)

/// Checks for contents that can affect navigation.
/datum/controller/subsystem/navmap/proc/turf_has_nav_relevant_contents(turf/tile)
	for(var/atom/movable/content as anything in tile)
		if(NAV_RELEVANT(content))
			return TRUE
	return FALSE

/// Queues a turf and affected neighbours by their coordinates.
/datum/controller/subsystem/navmap/proc/record_startup_dirty_turf(turf/tile)
	if(!tile || !is_auto_dirty_zlevel(tile.z))
		return
	record_startup_dirty_coordinate(tile)
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(tile, dir)
		if(neighbor)
			record_startup_dirty_coordinate(neighbor)
	for(var/dir in list(UP, DOWN))
		var/turf/neighbor = get_step_multiz(tile, dir)
		if(!neighbor)
			continue
		record_startup_dirty_coordinate(neighbor)
		if(neighbor.pathing_pass_method == TURF_PATHING_PASS_PROC)
			neighbor.nav_dirty_vertical_dependents()

/// Queues a turf and clears its old navigation data.
/datum/controller/subsystem/navmap/proc/record_startup_dirty_coordinate(turf/tile)
	if(!is_auto_dirty_zlevel(tile.z))
		return
	var/key = "[tile.x],[tile.y],[tile.z]"
	queue_startup_dirty_coordinate(tile.x, tile.y, tile.z)
	startup_dirty_generation[key] = (startup_dirty_generation[key] || 0) + 1
	startup_dirty_turf_refs[tile] = key
	startup_dirty_ref_zlevels[tile.z] = TRUE
	if(!initialized)
		return
	tile.nav_pass = null
	tile.nav_blockers = null
	navmap_pathfinder_update(tile.x, tile.y, tile.z, 0, tile.get_nav_cost_flags())

/// Queues terrain cost changes made during startup.
/datum/controller/subsystem/navmap/proc/record_startup_cost_dirty(turf/tile)
	if(tile && is_auto_dirty_zlevel(tile.z))
		var/key = "[tile.x],[tile.y],[tile.z]"
		queue_startup_dirty_coordinate(tile.x, tile.y, tile.z)
		startup_dirty_costs[key] = TRUE
		startup_dirty_generation[key] = (startup_dirty_generation[key] || 0) + 1
		startup_dirty_turf_refs[tile] = key
		startup_dirty_ref_zlevels[tile.z] = TRUE

/// Queues startup work only on the auto spots
/datum/controller/subsystem/navmap/proc/queue_startup_dirty_coordinate(x, y, z_level)
	if(!is_auto_dirty_zlevel(z_level))
		return
	startup_dirty_turfs["[x],[y],[z_level]"] = TRUE

/// Checks whether a level uses the automatic bake policy.
/datum/controller/subsystem/navmap/proc/is_auto_dirty_zlevel(z_level)
	return auto_dirty_zlevels[z_level] || SSmapping.level_trait(z_level, ZTRAIT_STATION) || SSmapping.level_trait(z_level, ZTRAIT_MINING)

/// Remembers a bake only when this coordinate is already dirty.
/datum/controller/subsystem/navmap/proc/mark_startup_turf_baked(turf/tile)
	var/key = startup_dirty_turf_refs[tile]
	if(!key)
		return
	var/generation = startup_dirty_generation[key]
	if(isnull(generation))
		return
	startup_baked_generation[key] = generation
	startup_baked_turfs[key] = tile

/// Bakes turfs changed during startup..
/datum/controller/subsystem/navmap/proc/flush_startup_dirty_turfs()
	while(length(startup_dirty_turfs) || length(startup_dirty_currentrun) || length(startup_dirty_costs))
		for(var/cost_key in startup_dirty_costs)
			startup_dirty_turfs[cost_key] = TRUE
		startup_dirty_costs.Cut()
		if(!length(startup_dirty_currentrun))
			for(var/turf_key in startup_dirty_turfs.Copy())
				startup_dirty_currentrun[turf_key] = TRUE
				startup_dirty_turfs.Remove(turf_key)
		for(var/turf_key in startup_dirty_currentrun.Copy())
			startup_dirty_currentrun.Remove(turf_key)
			var/list/coordinates = splittext(turf_key, ",")
			if(length(coordinates) != 3)
				continue
			var/turf/tile = locate(text2num(coordinates[1]), text2num(coordinates[2]), text2num(coordinates[3]))
			if(!tile)
				continue
			if(!is_auto_dirty_zlevel(tile.z))
				continue
			var/generation = startup_dirty_generation[turf_key]
			if(!isnull(generation) && startup_baked_generation[turf_key] == generation && startup_baked_turfs[turf_key] == tile)
				continue
			tile.turf_flags &= ~NAV_QUEUED
			var/effective_cost_flags = tile.nav_bake(skip_navmap_push = TRUE)
			mark_startup_turf_baked(tile)
			startup_publication_batch += list(tile.x, tile.y, tile.z, tile.nav_pass, effective_cost_flags)
			if(length(startup_publication_batch) >= 5000)
				publish_startup_navmap_batch(startup_publication_batch)
				startup_publication_batch.Cut()
			CHECK_TICK
		if(length(startup_publication_batch))
			publish_startup_navmap_batch(startup_publication_batch)
			startup_publication_batch.Cut()
	startup_dirty_generation.Cut()
	startup_dirty_turf_refs.Cut()
	startup_dirty_ref_zlevels.Cut()
	startup_baked_generation.Cut()
	startup_baked_turfs.Cut()

