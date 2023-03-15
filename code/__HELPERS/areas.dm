#define BP_MAX_ROOM_SIZE 300

GLOBAL_LIST_INIT(typecache_powerfailure_safe_areas, typecacheof(/area/station/engineering/main, \
															    /area/station/engineering/supermatter, \
															    /area/station/engineering/atmospherics_engine, \
															    /area/station/ai_monitored/turret_protected/ai))

// Gets an atmos isolated contained space
// Returns an associative list of turf|dirs pairs
// The dirs are connected turfs in the same space
// break_if_found is a typecache of turf/area types to return false if found
// Please keep this proc type agnostic. If you need to restrict it do it elsewhere or add an arg.
/proc/detect_room(turf/origin, list/break_if_found, max_size=INFINITY)
	if(origin.blocks_air)
		return list(origin)

	. = list()
	var/list/checked_turfs = list()
	var/list/found_turfs = list(origin)
	while(length(found_turfs))
		var/turf/sourceT = found_turfs[1]
		found_turfs.Cut(1, 2)
		var/dir_flags = checked_turfs[sourceT]
		for(var/dir in GLOB.alldirs)
			if(length(.) > max_size)
				return
			if(dir_flags & dir) // This means we've checked this dir before, probably from the other turf
				continue
			var/turf/checkT = get_step(sourceT, dir)
			if(!checkT)
				continue
			checked_turfs[sourceT] |= dir
			checked_turfs[checkT] |= turn(dir, 180)
			.[sourceT] |= dir
			.[checkT] |= turn(dir, 180)
			if(break_if_found[checkT.type] || break_if_found[checkT.loc.type])
				return FALSE
			var/static/list/cardinal_cache = list("[NORTH]"=TRUE, "[EAST]"=TRUE, "[SOUTH]"=TRUE, "[WEST]"=TRUE)
			if(!cardinal_cache["[dir]"] || !TURFS_CAN_SHARE(sourceT, checkT))
				continue
			found_turfs += checkT // Since checkT is connected, add it to the list to be processed

/**
 * Create an atmos zone (Think ZAS), similiar to [proc/detect_room] but it ignores walls and turfs which are non-[atmos_can_pass]
 *
 * Arguments
 * source - the turf which to find all connected atmos turfs
 * range - the max range to check
 *
 * Returns a list of turfs, which is an area of isolated atmos
 */
/proc/create_atmos_zone(turf/source, range = INFINITY)
	var/counter = 1 // a counter which increment each loop
	var/loops = 0
	if(source.blocks_air)
		return
	var/list/connected_turfs = list(source)
	. = connected_turfs
	while(length(connected_turfs))
		var/list/turf/adjacent_turfs = list(
			get_step(connected_turfs[counter], NORTH),
			get_step(connected_turfs[counter], SOUTH),
			get_step(connected_turfs[counter], EAST),
			get_step(connected_turfs[counter], WEST)
		)// get a tile in each cardinal direction at once and add that to the list
		for(var/turf/valid_turf in adjacent_turfs)//loop through the list and check for atmos adjacency
			var/turf/reference_turf = connected_turfs[counter]
			if(valid_turf in connected_turfs)//if the turf is already added, skip
				loops += 1
				continue
			if(length(connected_turfs) >= range)
				return
			if(TURFS_CAN_SHARE(reference_turf, valid_turf))
				loops = 0
				connected_turfs |= valid_turf//add that to the original list
		if(loops >= 7)//if the loop has gone 7 consecutive times with no new turfs added, return the result. Number is arbitrary, subject to change
			return
		counter += 1 //increment by one so the next loop will start at the next position in the list

/proc/create_area(mob/creator)
	// Passed into the above proc as list/break_if_found
	var/static/list/area_or_turf_fail_types = typecacheof(list(
		/turf/open/space,
		/area/shuttle,
		))
	// Ignore these areas and dont let people expand them. They can expand into them though
	var/static/list/blacklisted_areas = typecacheof(list(
		/area/space,
		))
	var/list/turfs = detect_room(get_turf(creator), area_or_turf_fail_types, BP_MAX_ROOM_SIZE*2)
	if(!turfs)
		to_chat(creator, span_warning("The new area must be completely airtight and not a part of a shuttle."))
		return
	if(length(turfs) > BP_MAX_ROOM_SIZE)
		to_chat(creator, span_warning("The room you're in is too big. It is [length(turfs) >= BP_MAX_ROOM_SIZE *2 ? "more than 100" : ((length(turfs) / BP_MAX_ROOM_SIZE)-1)*100]% larger than allowed."))
		return
	var/list/areas = list("New Area" = /area)
	for(var/i in 1 to length(turfs))
		var/area/place = get_area(turfs[i])
		if(blacklisted_areas[place.type])
			continue
		if(!place.requires_power || (place.area_flags & NOTELEPORT) || (place.area_flags & HIDDEN_AREA))
			continue // No expanding powerless rooms etc
		areas[place.name] = place
	var/area_choice = tgui_input_list(creator, "Choose an area to expand or make a new area", "Area Expansion", areas)
	if(isnull(area_choice))
		to_chat(creator, span_warning("No choice selected. The area remains undefined."))
		return
	area_choice = areas[area_choice]

	var/area/newA
	var/area/oldA = get_area(get_turf(creator))
	if(!isarea(area_choice))
		var/str = tgui_input_text(creator, "New area name", "Blueprint Editing", max_length = MAX_NAME_LEN)
		if(!str)
			return
		newA = new area_choice
		newA.setup(str)
		newA.has_gravity = oldA.has_gravity
	else
		newA = area_choice

	for(var/turf/thing as anything in turfs)
		thing.change_area(thing.loc, newA)

	newA.reg_in_areas_in_z()

	if(!isarea(area_choice) && newA.static_lighting)
		newA.create_area_lighting_objects()

	var/list/firedoors = oldA.firedoors
	for(var/door in firedoors)
		var/obj/machinery/door/firedoor/FD = door
		FD.CalculateAffectingAreas()

	SEND_GLOBAL_SIGNAL(COMSIG_AREA_CREATED, newA, oldA, creator)
	to_chat(creator, span_notice("You have created a new area, named [newA.name]. It is now weather proof, and constructing an APC will allow it to be powered."))
	creator.log_message("created a new area: [AREACOORD(creator)] (previously \"[oldA.name]\")", LOG_GAME)
	return TRUE

#undef BP_MAX_ROOM_SIZE

/proc/require_area_resort()
	GLOB.sortedAreas = null

/// Returns a sorted version of GLOB.areas, by name
/proc/get_sorted_areas()
	if(!GLOB.sortedAreas)
		GLOB.sortedAreas = sortTim(GLOB.areas.Copy(), /proc/cmp_name_asc)
	return GLOB.sortedAreas

//Takes: Area type as a text string from a variable.
//Returns: Instance for the area in the world.
/proc/get_area_instance_from_text(areatext)
	if(istext(areatext))
		areatext = text2path(areatext)
	return GLOB.areas_by_type[areatext]

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype, subtypes=TRUE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/areas = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/area/area_to_check as anything in GLOB.areas)
			if(cache[area_to_check.type])
				areas += area_to_check
	else
		for(var/area/area_to_check as anything in GLOB.areas)
			if(area_to_check.type == areatype)
				areas += area_to_check
	return areas

/// Iterates over all turfs in the target area and returns the first non-dense one
/proc/get_first_open_turf_in_area(area/target)
	if(!target)
		return
	for(var/turf/turf in target)
		if(!turf.density)
			return turf

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype, target_z = 0, subtypes=FALSE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null
	// Pull out the areas
	var/list/areas_to_pull = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/area/area_to_check as anything in GLOB.areas)
			if(!cache[area_to_check.type])
				continue
			areas_to_pull += area_to_check
	else
		for(var/area/area_to_check as anything in GLOB.areas)
			if(area_to_check.type != areatype)
				continue
			areas_to_pull += area_to_check

	// Now their turfs
	var/list/turfs = list()
	for(var/area/pull_from as anything in areas_to_pull)
		var/list/our_turfs = pull_from.get_contained_turfs()
		if(target_z == 0)
			turfs += our_turfs
		else
			for(var/turf/turf_in_area as anything in our_turfs)
				if(target_z == turf_in_area.z)
					turfs += turf_in_area
	return turfs


///Takes: list of area types
///Returns: all mobs that are in an area type
/proc/mobs_in_area_type(list/area/checked_areas)
	var/list/mobs_in_area = list()
	for(var/mob/living/mob as anything in GLOB.mob_living_list)
		if(QDELETED(mob))
			continue
		for(var/area in checked_areas)
			if(istype(get_area(mob), area))
				mobs_in_area += mob
				break
	return mobs_in_area
