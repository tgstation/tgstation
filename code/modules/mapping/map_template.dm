/datum/map_template
	var/name = "Default Template Name"
	var/width = 0				//all these are for SOUTH!
	var/height = 0
	var/zdepth = 1
	var/mappath
	var/loaded = 0 // Times loaded this round
	var/datum/parsed_map/cached_map
	var/keep_cached_map = FALSE
	var/default_annihilate = FALSE
	var/list/ztraits				//zlevel traits for load_new_z

/datum/map_template/New(path = null, rename = null, cache = FALSE)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath, cache)
	if(rename)
		name = rename

/datum/map_template/Destroy()
	QDEL_NULL(cached_map)
	return ..()

/datum/map_template/proc/preload_size(path = mappath, force_cache = FALSE)
	if(cached_map)
		return cached_map.parsed_bounds
	var/datum/parsed_map/parsed = new(file(path))
	var/bounds = parsed?.parsed_bounds
	if(bounds)
		width = bounds[MAP_MAXX] - bounds[MAP_MINX] + 1
		height = bounds[MAP_MAXY] - bounds[MAP_MINY] + 1
		zdepth = bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1
		if(force_cache || keep_cached_map)
			cached_map = parsed
	return bounds

/datum/map_template/proc/get_parsed_bounds()
	return preload_size(mappath)

/datum/map_template/proc/get_last_loaded_bounds()
	if(cached_map)
		return cached_map.bounds
	return get_parsed_bounds()

/datum/map_template/proc/get_last_loaded_turf_block()
	if(!cached_map)
		CRASH("Improper use of get_last_loaded_turf_block, no cached_map.")
	var/list/B = cached_map.bounds
	return block(locate(B[MAP_MINX], B[MAP_MINY], B[MAP_MINZ]), locate(B[MAP_MAXX], B[MAP_MAXY], B[MAP_MAXZ]))

/datum/map_template/proc/get_size(orientation = SOUTH)
	if(!width || !height || !zdepth)
		preload_size(mappath)
	var/rotate = (orientation & (NORTH|SOUTH)) != NONE
	if(rotate)
		return list(height, width, zdepth)
	return list(width, height, zdepth)

/datum/parsed_map/proc/initTemplateBounds()
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()
	var/list/area/areas = list()

	var/list/turfs = block(	locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
							locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ]))
	var/list/border = block(locate(max(bounds[MAP_MINX]-1, 1),			max(bounds[MAP_MINY]-1, 1),			 bounds[MAP_MINZ]),
							locate(min(bounds[MAP_MAXX]+1, world.maxx),	min(bounds[MAP_MAXY]+1, world.maxy), bounds[MAP_MAXZ])) - turfs
	for(var/L in turfs)
		var/turf/B = L
		atoms += B
		areas |= B.loc
		for(var/A in B)
			atoms += A
			if(istype(A, /obj/structure/cable))
				cables += A
				continue
			if(istype(A, /obj/machinery/atmospherics))
				atmos_machines += A
	for(var/L in border)
		var/turf/T = L
		T.air_update_turf(TRUE) //calculate adjacent turfs along the border to prevent runtimes

	SSmapping.reg_in_areas_in_z(areas)
	SSatoms.InitializeAtoms(atoms)
	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

/datum/map_template/proc/load_new_z(orientation = SOUTH, list/ztraits = src.ztraits || list(ZTRAIT_AWAY = TRUE), centered = TRUE)
	var/x = centered? max(round((world.maxx - width) / 2), 1) : 1
	var/y = centered? max(round((world.maxy - height) / 2), 1) : 1

	var/datum/space_level/level = SSmapping.add_new_zlevel(name, ztraits)
	var/datum/parsed_map/parsed = load_map(file(mappath), x, y, level.z_value, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop = TRUE, orientation = orientation)
	var/list/bounds = parsed.bounds
	if(!bounds)
		return FALSE

	repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	parsed.initTemplateBounds()
	smooth_zlevel(world.maxz)
	log_game("Z-level [name] loaded at [x],[y],[world.maxz]")
	on_map_loaded(world.maxz, parsed.bounds)

	return level

//Override for custom behavior
/datum/map_template/proc/on_map_loaded(z, list/bounds)
	loaded++

/**
  * Proc to trigger a load at a specific area. Calls on_map_loaded(T.z, loaded_bounds) afterwards.
  *
  * @params
  * * turf/T - Turf to load at
  * * centered - Center at T or load with the bottomright corner being at T
  * * orientation - SOUTH is default, anything else rotates the map to face it with the point of reference being the map itself is facing south by default. Cardinals only, don't be a 4head and put in multiple flags. It won't work or be pretty if you try.
  * * annihilate - Should we destroy stuff in our bounds while loading
  * * force_cache - Should we force the parsed shuttle to cache instead of being GC'd post loading if it wasn't going to be cached by default
  * * rotate_placement_to_orientation - Has no effect if centered. Should we rotate where we load it around the turf we're loading at? Used for stuff like engine submaps when the station is rotated.
  *
  */
/datum/map_template/proc/load(turf/T, centered = FALSE, orientation = SOUTH, annihilate = default_annihilate, force_cache = FALSE, rotate_placement_to_orientation = FALSE)
	var/old_T = T
	if(centered)
		T = locate(T.x - round(((orientation & (NORTH|SOUTH))? width : height) / 2) , T.y - round(((orientation & (NORTH|SOUTH)) ? height : width) / 2) , T.z) // %180 catches East/West (90,270) rotations on true, North/South (0,180) rotations on false
	else if(rotate_placement_to_orientation && (orientation != SOUTH))
		var/newx = T.x
		var/newy = T.y
		if(orientation == NORTH)
			newx -= width
			newy -= height - 1
		else if(orientation == WEST)
			newy -= width
		else if(orientation == EAST)
			newx -= height - 1
		// eh let's not silently fail.
		if(!ISINRANGE(newx, 1, world.maxx) || !ISINRANGE(newy, 1, world.maxy))
			stack_trace("Warning: Rotation placed a map template load spot ([COORD(T)]) out of bounds of the game world. Clamping to world borders, this might cause issues.")
		T = locate(clamp(newx, 1, world.maxx), clamp(newy, 1, world.maxy), T.z)
	if(!T)
		return
	if(T.x+width-1 > world.maxx)
		return
	if(T.y+height-1 > world.maxy)
		return

	var/list/border = block(locate(max(T.x - 1, 1), max(T.y - 1, 1), T.z),
		locate(min(T.x + width + 1, world.maxx), min(T.y + height + 1, world.maxy), T.z))
	for(var/i in border)
		var/turf/turf_to_disable = i
		SSair.remove_from_active(turf_to_disable) //stop processing turfs along the border to prevent runtimes, we return it in initTemplateBounds()
		turf_to_disable.atmos_adjacent_turfs?.Cut()

	if(annihilate == MAP_TEMPLATE_ANNIHILATE_PRELOAD)
		annihilate_bounds(old_T, centered, orientation)

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	var/is_cached = cached_map
	var/datum/parsed_map/parsed = is_cached || new(file(mappath))
	cached_map = (force_cache || keep_cached_map) ? parsed : is_cached
	if(!parsed.load(T.x, T.y, T.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=TRUE, orientation = orientation, annihilate_tiles = (annihilate == MAP_TEMPLATE_ANNIHILATE_LOADING)))
		return
	var/list/bounds = parsed.bounds
	if(!bounds)
		return

	if(!SSmapping.loading_ruins) //Will be done manually during mapping ss init
		repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	parsed.initTemplateBounds()

	log_game("[name] loaded at [T.x],[T.y],[T.z]")
	on_map_loaded(T.z, parsed.bounds)

	return bounds

//This, get_affected_turfs, and load() calculations for bounds/center can probably be optimized. Later.
/datum/map_template/proc/annihilate_bounds(turf/origin, centered = FALSE, orientation = SOUTH)
	var/deleted_atoms = 0
	log_world("Annihilating objects in map loading location.")
	var/list/turfs_to_clean = get_affected_turfs(origin, centered, orientation)
	if(turfs_to_clean.len)
		var/list/kill_these = list()
		for(var/i in turfs_to_clean)
			var/turf/T = i
			kill_these += T.contents
		for(var/i in kill_these)
			qdel(i)
			CHECK_TICK
			deleted_atoms++
	log_world("Annihilated [deleted_atoms] objects.")

//for your ever biggening badminnery kevinz000
//❤ - Cyberboss
/proc/load_new_z_level(file, name, orientation, list/ztraits)
	var/datum/map_template/template = new(file, name)
	return template.load_new_z(orientation, ztraits)

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE, orientation = SOUTH)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(((orientation & (NORTH|SOUTH))? width : height) / 2), placement.y - round(((orientation & (NORTH|SOUTH))? height : width) / 2), placement.z) // %180 catches East/West (90,270) rotations on true, North/South (0,180) rotations on false
		if(corner)
			placement = corner
	return block(placement, locate(placement.x + ((orientation & (NORTH|SOUTH)) ? width : height) - 1, placement.y + ((orientation & (NORTH|SOUTH))? height : width) - 1, placement.z))
