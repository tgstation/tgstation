/**
 * Day Night Presets are easy to use day/night cycles for certain maps, they are what is used to dictate the sky color.
 *
 * IMPORTANT: The timezones in this MUST all add up to 23, you cannot miss an hour!
 */
/datum/day_night_controller
	/// The maps that this preset should be loaded on
	var/load_map_name
	/// The timezones that this preset should have
	var/list/timezones = list()
	/// The timezones that this preset has loaded
	var/list/timezone_cache = list()
	/// A list of loaded areas
	var/list/area_cache = list()
	/// The mutable appearance that we apply to our areas
	var/mutable_appearance/area_appearance
	/// The affected Z level
	var/affected_z_level
	/// Our current timezone
	var/datum/timezone/current_timezone
	/// Our current luminosity
	var/current_luminosity = FALSE


/datum/day_night_controller/New(incoming_affected_z_level)
	if(!incoming_affected_z_level)
		return
	affected_z_level = incoming_affected_z_level
	update_affected_areas()
	load_timezones()

/**
 * Finds and saves all areas that this preset will affect
 */
/datum/day_night_controller/proc/update_affected_areas()
	SIGNAL_HANDLER

	// First we unregister all affected areas
	for(var/area/iterating_area as anything in area_cache)
		unregister_affected_area(iterating_area)

	area_cache.Cut()

	// Then we reregister all affected areas
	for(var/area/iterating_area as anything in get_areas(/area, TRUE))
		if(iterating_area.z != affected_z_level)
			continue
		if(!iterating_area.outdoors)
			continue
		if(iterating_area.underground)
			continue
		register_affected_area(iterating_area)

/**
 * Registers an area with the controller for updating.
 * Arguments:
 * * area_to_register - The area to register with the controller
 * Returns TRUE if it was successfully registered, otherwise FALSE if not.
 */
/datum/day_night_controller/proc/register_affected_area(area/area_to_register)
	if(area_to_register in area_cache)
		return FALSE
	area_cache += area_to_register
	area_to_register.update_day_night_turfs(TRUE)
	RegisterSignal(area_to_register, COMSIG_PARENT_QDELETING, .proc/unregister_affected_area)
	RegisterSignal(area_to_register, COMSIG_AREA_AFTER_SHUTTLE_MOVE, .proc/after_shuttle_move)
	area_to_register.RegisterSignal(src, COMSIG_DAY_NIGHT_CONTROLLER_LIGHT_UPDATE, /area.proc/apply_day_night_turfs)
	return TRUE

/**
 * Creates all of the desired timezone datums and caches them for later.
 */
/datum/day_night_controller/proc/load_timezones()
	for(var/iterating_timezone_type in timezones)
		timezone_cache += new iterating_timezone_type

/**
 * Removes an area from the controller
 * Arguments:
 * * area_to_unregister - The area that is to be unregistered from this controller
 */
/datum/day_night_controller/proc/unregister_affected_area(area/area_to_unregister)
	SIGNAL_HANDLER

	area_to_unregister.clear_adjacent_turfs()
	UnregisterSignal(area_to_unregister, COMSIG_PARENT_QDELETING)
	UnregisterSignal(area_to_unregister, COMSIG_AREA_AFTER_SHUTTLE_MOVE)
	area_to_unregister.UnregisterSignal(src, COMSIG_DAY_NIGHT_CONTROLLER_LIGHT_UPDATE)
	area_cache -= area_to_unregister

/datum/day_night_controller/proc/after_shuttle_move(area/area_to_check)
	SIGNAL_HANDLER

	if(area_to_check.z == affected_z_level)
		return

	unregister_affected_area(area_to_check)

/**
 * Gets the timezone that relates to the given hour
 * Arguments:
 * * hour - The hour at which we will be checking our timezones.
 * Returns the timezone datum.
 */
/datum/day_night_controller/proc/get_timezone(hour)
	for(var/datum/timezone/iterating_timezone as anything in timezone_cache)
		if((hour >= iterating_timezone.start_hour) && (hour <= iterating_timezone.end_hour))
			return iterating_timezone

/**
 * Applys the current timezone to all of the areas
 */
/datum/day_night_controller/proc/update_time(hour)
	current_timezone = get_timezone(hour)
	update_lighting(current_timezone.light_color, current_timezone.light_alpha)

/**
 * Calculates the delta between the current alpha and the next alpha
 */
/datum/day_night_controller/proc/calculate_alpha_delta(datum/timezone/starting_timezone, datum/timezone/next_timezone, hour)
	var/target_alpha_difference = next_timezone.light_alpha - starting_timezone.light_alpha
	var/time_difference = starting_timezone.start_hour - starting_timezone.end_hour
	var/run_time = hour - starting_timezone.start_hour
	var/percentage = run_time / time_difference
	var/alpha_to_set = (target_alpha_difference * percentage) + starting_timezone.light_alpha
	to_chat(world, alpha_to_set)
	return alpha_to_set

/**
 * Core proc to update the lighting of any affected areas and turfs
 */
/datum/day_night_controller/proc/update_lighting(light_color, alpha_to_set)
	SEND_SIGNAL(src, COMSIG_DAY_NIGHT_CONTROLLER_LIGHT_UPDATE, light_color, alpha_to_set)
	remove_effect_from_areas()
	update_area_appearance(light_color, alpha_to_set)
	set_area_luminosity(alpha_to_set)
	apply_effect_to_areas(light_color, alpha_to_set)

/**
 * Updates the current area appearance
 */
/datum/day_night_controller/proc/update_area_appearance(light_color, light_alpha)
	var/mutable_appearance/updated_appearance = mutable_appearance(
		'icons/effects/daynight_blend.dmi',
		"white",
		DAY_NIGHT_LIGHTING_LAYER,
		DAY_NIGHT_LIGHTING_LAYER,
		light_alpha
		)
	updated_appearance.color = light_color
	area_appearance = updated_appearance

/datum/day_night_controller/proc/remove_effect_from_areas()
	for(var/area/iterating_area as anything in area_cache)
		iterating_area.underlays -= area_appearance

/datum/day_night_controller/proc/apply_effect_to_areas(light_color, light_alpha)
	for(var/area/iterating_area as anything in area_cache)
		iterating_area.underlays += area_appearance

/datum/day_night_controller/proc/set_area_luminosity(light_alpha)
	var/luminosity = (light_alpha >= MINIMUM_LIGHT_FOR_LUMINOSITY) ? TRUE : FALSE
	current_luminosity = luminosity
	for(var/area/iterating_area as anything in area_cache)
		iterating_area.luminosity = luminosity

#define NORTH_JUNCTION NORTH //(1<<0)
#define SOUTH_JUNCTION SOUTH //(1<<1)
#define EAST_JUNCTION EAST  //(1<<2)
#define WEST_JUNCTION WEST  //(1<<3)
#define NORTHEAST_JUNCTION (1<<4)
#define SOUTHEAST_JUNCTION (1<<5)
#define SOUTHWEST_JUNCTION (1<<6)
#define NORTHWEST_JUNCTION (1<<7)


DEFINE_BITFIELD(smoothing_junction, list(
	"NORTH_JUNCTION" = NORTH_JUNCTION,
	"SOUTH_JUNCTION" = SOUTH_JUNCTION,
	"EAST_JUNCTION" = EAST_JUNCTION,
	"WEST_JUNCTION" = WEST_JUNCTION,
	"NORTHEAST_JUNCTION" = NORTHEAST_JUNCTION,
	"SOUTHEAST_JUNCTION" = SOUTHEAST_JUNCTION,
	"SOUTHWEST_JUNCTION" = SOUTHWEST_JUNCTION,
	"NORTHWEST_JUNCTION" = NORTHWEST_JUNCTION,
))

/area
	var/list/adjacent_day_night_turf_cache

/area/proc/initialize_day_night_adjacent_turfs()
	LAZYCLEARLIST(adjacent_day_night_turf_cache)
	LAZYINITLIST(adjacent_day_night_turf_cache)

	for(var/turf/iterated_turf in contents)
		var/bitfield = NONE
		for(var/bit_step in ALL_JUNCTION_DIRECTIONS)
			var/turf/target_turf
			switch(bit_step)
				if(NORTH_JUNCTION)
					target_turf = locate(iterated_turf.x, iterated_turf.y + 1, iterated_turf.z)
				if(SOUTH_JUNCTION)
					target_turf = locate(iterated_turf.x, iterated_turf.y - 1, iterated_turf.z)
				if(EAST_JUNCTION)
					target_turf = locate(iterated_turf.x + 1, iterated_turf.y, iterated_turf.z)
				if(WEST_JUNCTION)
					target_turf = locate(iterated_turf.x - 1, iterated_turf.y, iterated_turf.z)
				if(NORTHEAST_JUNCTION)
					if(bitfield & NORTH_JUNCTION || bitfield & EAST_JUNCTION)
						continue
					target_turf = locate(iterated_turf.x + 1, iterated_turf.y + 1, iterated_turf.z)
				if(SOUTHEAST_JUNCTION)
					if(bitfield & SOUTH_JUNCTION || bitfield & EAST_JUNCTION)
						continue
					target_turf = locate(iterated_turf.x + 1, iterated_turf.y - 1, iterated_turf.z)
				if(SOUTHWEST_JUNCTION)
					if(bitfield & SOUTH_JUNCTION || bitfield & WEST_JUNCTION)
						continue
					target_turf = locate(iterated_turf.x - 1, iterated_turf.y - 1, iterated_turf.z)
				if(NORTHWEST_JUNCTION)
					if(bitfield & NORTH_JUNCTION || bitfield & WEST_JUNCTION)
						continue
					target_turf = locate(iterated_turf.x - 1, iterated_turf.y + 1, iterated_turf.z)
			if(!target_turf)
				continue
			var/area/target_area = target_turf.loc
			if(target_area == src)
				continue
			if(!target_area.outdoors || target_area.underground)
				continue
			bitfield ^= bit_step

		if(!bitfield)
			continue
		adjacent_day_night_turf_cache[iterated_turf] = list(AREA_DAY_NIGHT_INDEX_BITFIELD, AREA_DAY_NIGHT_INDEX_APPEARANCE)
		adjacent_day_night_turf_cache[iterated_turf][AREA_DAY_NIGHT_INDEX_BITFIELD] = bitfield
		RegisterSignal(iterated_turf, COMSIG_PARENT_QDELETING, .proc/clear_adjacent_turf)

	UNSETEMPTY(adjacent_day_night_turf_cache)

/**
 * Completely clears any adjacent turfs from the area while removing the effect.
 */
/area/proc/clear_adjacent_turfs()
	for(var/turf/iterating_turf as anything in adjacent_day_night_turf_cache)
		clear_adjacent_turf(iterating_turf)
	adjacent_day_night_turf_cache = null

/area/proc/clear_adjacent_turf(turf/turf_to_clear)
	SIGNAL_HANDLER

	if(adjacent_day_night_turf_cache[turf_to_clear][AREA_DAY_NIGHT_INDEX_APPEARANCE])
		turf_to_clear.underlays -= adjacent_day_night_turf_cache[turf_to_clear][AREA_DAY_NIGHT_INDEX_APPEARANCE]
	adjacent_day_night_turf_cache -= turf_to_clear

/area/proc/apply_day_night_turfs(datum/day_night_controller/incoming_controller, light_color, light_alpha)
	SIGNAL_HANDLER

	for(var/turf/iterating_turf as anything in adjacent_day_night_turf_cache)
		var/mutable_appearance/appearance_to_add = mutable_appearance(
			'icons/effects/daynight_blend.dmi',
			"[adjacent_day_night_turf_cache[iterating_turf][AREA_DAY_NIGHT_INDEX_BITFIELD]]",
			DAY_NIGHT_LIGHTING_LAYER,
			LIGHTING_PLANE,
			light_alpha,
			RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			)
		appearance_to_add.color = light_color
		iterating_turf.underlays += appearance_to_add
		adjacent_day_night_turf_cache[iterating_turf][AREA_DAY_NIGHT_INDEX_APPEARANCE] = appearance_to_add

/area/proc/update_day_night_turfs(initialize_turfs = FALSE, search_for_controller = FALSE)
	if(search_for_controller)
		for(var/datum/day_night_controller/iterating_controller in SSday_night.cached_controllers)
			if(iterating_controller.affected_z_level == z)
				if(!iterating_controller.register_affected_area(src))
					initialize_turfs = TRUE
	if(adjacent_day_night_turf_cache)
		clear_adjacent_turfs()
	if(initialize_turfs)
		initialize_day_night_adjacent_turfs()

/area/Destroy()
	clear_adjacent_turfs()
	return ..()

// PRESETS
/datum/day_night_controller/icebox
	timezones = list(
		/datum/timezone/midnight,
		/datum/timezone/early_morning,
		/datum/timezone/morning,
		/datum/timezone/midday,
		/datum/timezone/early_evening,
		/datum/timezone/evening,
	)


