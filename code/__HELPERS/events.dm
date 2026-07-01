#define UNLIT_AREA_BRIGHTNESS 0.2

/**
 * Finds us a generic maintenance spawn location.
 *
 * Goes through the list of the generic mainteance landmark locations, checking for atmos safety if required, and returns
 * a valid turf. Returns MAP_ERROR if no valid locations are present.
 * Returns nothing and alerts admins if no valid points are found. Keep this in mind
 * when using this helper.
 */

/proc/find_maintenance_spawn(atmos_sensitive = FALSE, require_darkness = FALSE)
	var/list/possible_spawns = list()
	for(var/spawn_location in GLOB.generic_maintenance_landmarks)
		var/turf/spawn_turf = get_turf(spawn_location)

		if(atmos_sensitive && !is_safe_turf(spawn_turf))
			continue

		if(require_darkness && spawn_turf.get_lumcount() > UNLIT_AREA_BRIGHTNESS)
			continue

		possible_spawns += spawn_turf

	if(!length(possible_spawns))
		return null

	return pick(possible_spawns)

/**
 * Finds us a generic spawn location in space.
 *
 * Goes through the list of the space carp spawn locations, picks from the list, and
 * returns that turf. Returns MAP_ERROR if no landmarks are found.
 */

/proc/find_space_spawn()
	var/list/possible_spawns = list()
	for(var/obj/effect/landmark/carpspawn/spawn_location in GLOB.landmarks_list)
		if(!isturf(spawn_location.loc))
			stack_trace("Carp spawn found not on a turf: [spawn_location.type] on [isnull(spawn_location.loc) ? "null" : spawn_location.loc.type]")
			continue
		possible_spawns += get_turf(spawn_location)

	if(!length(possible_spawns))
		return null

	return pick(possible_spawns)

/// Finds us all suitable vent spawn locations on the station.
/proc/find_vent_spawns()
	var/list/vents = list()
	var/list/vent_pumps = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump)
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent as anything in vent_pumps)
		if(QDELETED(temp_vent))
			continue
		if(!is_station_level(temp_vent.loc.z) || temp_vent.welded)
			continue
		var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
		if(!temp_vent_parent)
			continue
		// Stops antagonists getting stuck in small networks.
		// See: Security, Virology
		if(length(temp_vent_parent.other_atmos_machines) <= 20)
			continue
		vents += temp_vent
	return vents

/proc/force_event(event_typepath, cause)
	var/datum/round_event_control/our_event = locate(event_typepath) in SSevents.control
	if(!our_event)
		CRASH("Attempted to force event [event_typepath], but the event path could not be found!")
	our_event.run_event(event_cause = cause)

/proc/force_event_async(event_typepath, cause)
	var/datum/round_event_control/our_event = locate(event_typepath) in SSevents.control
	if(!our_event)
		CRASH("Attempted to force event [event_typepath], but the event path could not be found!")
	INVOKE_ASYNC(our_event, TYPE_PROC_REF(/datum/round_event_control, run_event), event_cause = cause)

/proc/force_event_after(event_typepath, cause, duration)
	var/datum/round_event_control/our_event = locate(event_typepath) in SSevents.control
	if(!our_event)
		CRASH("Attempted to force event [event_typepath], but the event path could not be found!")
	addtimer(CALLBACK(our_event, TYPE_PROC_REF(/datum/round_event_control, run_event), FALSE, null, FALSE, cause), duration)

//Request a color in line with the current holiday or station traits of the station (or not if RANDOM/RAINBOW patterns are used.
/proc/request_decoration_colors(atom/thing_to_color, pattern, skip_station_trait = FALSE)
	switch(pattern)
		if(PATTERN_RANDOM)
			return "#[random_short_color()]"
		if(PATTERN_RAINBOW)
			return get_decoration_color_from_pattern(thing_to_color, PATTERN_DEFAULT, PRIDE_FLAG_COLORS)

	if(!skip_station_trait)
		for(var/datum/station_trait/trait in SSstation.station_traits)
			var/decal_color = trait.get_decal_color(thing_to_color, pattern || PATTERN_DEFAULT)
			if(decal_color)
				return decal_color

	for(var/holiday_key in GLOB.holidays)
		var/datum/holiday/holiday_real = GLOB.holidays[holiday_key]
		if(!holiday_real.holiday_colors)
			continue
		return holiday_real.get_holiday_colors(thing_to_color, pattern)

/// Proc to return colors for recoloring atoms based on a pattern and the position of the atom. Primarily used by holidays
/proc/get_decoration_color_from_pattern(atom/thing_to_color, pattern = PATTERN_DEFAULT, list/colors)
	if(!length(colors))
		return
	switch(pattern)
		if(PATTERN_DEFAULT)
			return colors[(thing_to_color.y % colors.len) + 1]
		if(PATTERN_VERTICAL_STRIPE)
			return colors[(thing_to_color.x % colors.len) + 1]

#undef UNLIT_AREA_BRIGHTNESS
