/datum/map_zone
	var/name = "Map Zone"
	var/id
	/// Is the mapzone currently used by a overmap encounter?
	var/taken = FALSE
	/// List of all z levels this map zone contains
	var/list/z_levels = list()

/datum/map_zone/New(passed_name)
	if(!isnull(passed_name))
		name = passed_name
	SSovermap.map_zones += src
	id = SSovermap.map_zones.len
	. = ..()

/datum/map_zone/Destroy()
	SSovermap.map_zones -= src
	return ..()

/// Clears all of what's inside the z levels managed by the mapzone.
/datum/map_zone/proc/clear_reservation()
	for(var/datum/space_level/zlevel as anything in z_levels)
		zlevel.clear_reservation()

/datum/map_zone/proc/add_space_level(datum/space_level/level)
	z_levels += level

/datum/map_zone/proc/get_mind_mobs()
	. = list()
	for(var/datum/space_level/zlevel as anything in z_levels)
		. += zlevel.get_mind_mobs()

/datum/space_level
	var/low_x
	var/low_y
	var/high_x
	var/high_y

/datum/space_level/proc/get_mind_mobs()
	. = list()
	for(var/mob/living/living_mob as anything in GLOB.mob_living_list)
		if(!living_mob.mind || living_mob.stat == DEAD)
			continue
		if(living_mob.z == z_value)
			. += living_mob

/datum/space_level/proc/get_block()
	low_x = 1
	low_y = 1
	high_x = world.maxx
	high_y = world.maxy
	return block(locate(low_x,low_y,z_value), locate(high_x,high_y,z_value))

/datum/space_level/proc/clear_reservation()
	var/area/space_area = GLOB.areas_by_type[world.area]

	var/list/turf/block_turfs = get_block()

	for(var/turf/turf as anything in block_turfs)
		// don't waste time trying to qdelete the lighting object
		for(var/datum/thing in (turf.contents - turf.lighting_object))
			qdel(thing)
			// DO NOT CHECK_TICK HERE. IT CAN CAUSE ITEMS TO GET LEFT BEHIND
			// THIS IS REALLY IMPORTANT FOR CONSISTENCY. SORRY ABOUT THE LAG SPIKE

	for(var/turf/turf as anything in block_turfs)
		// Reset turf
		turf.empty(RESERVED_TURF_TYPE, RESERVED_TURF_TYPE, null, CHANGETURF_IGNORE_AIR|CHANGETURF_DEFER_CHANGE)
		// Reset area
		var/area/old_area = get_area(turf)
		space_area.contents += turf
		turf.change_area(old_area, space_area)
		CHECK_TICK

	for(var/turf/turf as anything in block_turfs)
		turf.AfterChange(CHANGETURF_IGNORE_AIR|CHANGETURF_RECALC_ADJACENT)

		// we don't need to smooth anything in the reserve, because it's empty, nor do we need to check its starlight.
		// only the sides need to do that. this saved ~4-5% of reservation clear times in testing
		if(turf.x != low_x && turf.x != high_x && turf.y != low_y && turf.y != high_y)
			continue

		QUEUE_SMOOTH(turf)
		QUEUE_SMOOTH_NEIGHBORS(turf)
		CHECK_TICK

/datum/space_level/proc/fill_in(turf/turf_type, area/area_override)
	var/area/area_to_use = null
	if(area_override)
		if(ispath(area_override))
			area_to_use = new area_override
		else
			area_to_use = area_override

	if(area_to_use)
		for(var/turf/iterated_turf as anything in get_block())
			var/area/old_area = get_area(iterated_turf)
			area_to_use.contents += iterated_turf
			iterated_turf.change_area(old_area, area_to_use)
			CHECK_TICK
			if(QDELETED(src))
				return

	if(turf_type)
		for(var/turf/iterated_turf as anything in get_block())
			iterated_turf.ChangeTurf(turf_type, turf_type)
			CHECK_TICK
			if(QDELETED(src))
				return
