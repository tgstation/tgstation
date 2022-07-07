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
	/// A list of areas that are not affected directly, but still have turf adjacency
	var/list/unaffected_area_cache = list()
	/// The mutable appearance that we apply to our areas
	var/mutable_appearance/area_appearance
	/// The affected Z level - Ideally, we will eventually be using a more robust system for loaded planets and such.
	var/affected_z_level
	/// Our current luminosity
	var/current_luminosity = FALSE
	/// Lookup table for the colors for each hour, 24 hour format starting at 0.
	var/list/color_lookup_table = list()
	/// Lookup table for the alpha values for each hour, 24 hour format starting at 0.
	var/list/alpha_lookup_table = list()


/datum/day_night_controller/New(incoming_affected_z_level)
	if(!incoming_affected_z_level)
		return
	affected_z_level = incoming_affected_z_level
	get_affected_areas()
	load_timezones()
	compile_transitions()

/**
 * Simple proc to get the areas that are affected by this controller
 */
/datum/day_night_controller/proc/get_affected_areas()
	for(var/area/iterating_area as anything in get_areas(/area, TRUE))
		if(iterating_area.z != affected_z_level)
			continue
		if(iterating_area.underground)
			continue
		if(!iterating_area.outdoors)
			register_unaffected_area(iterating_area)
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
	RegisterSignal(area_to_register, COMSIG_PARENT_QDELETING, .proc/unregister_affected_area)
	return TRUE

/**
 * Removes an affected area from the controller and clears up references.
 * Arguments:
 * * area_to_unregister - The area that is to be unregistered from this controller
 */
/datum/day_night_controller/proc/unregister_affected_area(area/area_to_unregister)
	SIGNAL_HANDLER

	UnregisterSignal(area_to_unregister, COMSIG_PARENT_QDELETING)
	area_cache -= area_to_unregister

/**
 * Registers an area that is not affected by the lighting updates, but will be checked for turf adjacency.
 * Arguments:
 * * area_to_register - The area that is to be registered
 * Returns TRUE if it was successfully registered, otherwise FALSE if not.
 */
/datum/day_night_controller/proc/register_unaffected_area(area/area_to_register)
	if(area_to_register in unaffected_area_cache)
		return FALSE
	unaffected_area_cache += area_to_register
	area_to_register.update_day_night_turfs(TRUE)
	area_to_register.RegisterSignal(src, COMSIG_DAY_NIGHT_CONTROLLER_LIGHT_UPDATE, /area.proc/apply_day_night_turfs)
	RegisterSignal(area_to_register, COMSIG_PARENT_QDELETING, .proc/unregister_unaffected_area)
	RegisterSignal(area_to_register, COMSIG_AREA_AFTER_SHUTTLE_MOVE, .proc/after_shuttle_move)
	return TRUE

/**
 * Removes an unaffected turf from the controller and clears up references.
 * * Arguments:
 * * area_to_unregister - The area that is to be unregistered from this controller
 */
/datum/day_night_controller/proc/unregister_unaffected_area(area/area_to_unregister)
	SIGNAL_HANDLER

	area_to_unregister.clear_adjacent_turfs()
	area_to_unregister.UnregisterSignal(src, COMSIG_DAY_NIGHT_CONTROLLER_LIGHT_UPDATE)
	UnregisterSignal(area_to_unregister, COMSIG_AREA_AFTER_SHUTTLE_MOVE)
	unaffected_area_cache -= area_to_unregister

/**
 * Called after a shuttle moves from a registered area, checks to see if the new level is different from ours.
 */
/datum/day_night_controller/proc/after_shuttle_move(area/area_to_check)
	SIGNAL_HANDLER

	if(area_to_check.z == affected_z_level)
		return

	unregister_affected_area(area_to_check)


/**
 * Creates all of the desired timezone datums and caches them for later.
 */
/datum/day_night_controller/proc/load_timezones()
	for(var/iterating_timezone_type in timezones)
		timezone_cache += new iterating_timezone_type

/**
 * Gets the timezone that relates to the given hour
 * Arguments:
 * * hour - The hour at which we will be checking our timezones.
 * Returns the timezone datum.
 */
/datum/day_night_controller/proc/get_timezone(hour)
	var/timezone_to_return
	for(var/datum/timezone/iterating_timezone as anything in timezone_cache)
		if((hour >= iterating_timezone.start_hour) && (hour <= iterating_timezone.end_hour))
			timezone_to_return = iterating_timezone
	if(!timezone_to_return)
		CRASH("Critical error while finding a timezone in slot [hour] for [type]!")
	return timezone_to_return

/**
 * Applys the current timezone to all of the areas according to the lookup tables and hour.
 * Arguments:
 * * hour - The index to use in our lookup tables.
 */
/datum/day_night_controller/proc/update_time(hour)
	update_lighting(color_lookup_table["[hour]"], alpha_lookup_table["[hour]"])

/**
 * The core proc that should always be used when updating the lighting of this day/night controller.
 */
/datum/day_night_controller/proc/update_lighting(light_color, alpha_to_set)
	SEND_SIGNAL(src, COMSIG_DAY_NIGHT_CONTROLLER_LIGHT_UPDATE, light_color, alpha_to_set)
	remove_effect_from_areas()
	update_area_appearance(light_color, alpha_to_set)
	set_area_luminosity(alpha_to_set)
	apply_effect_to_areas()

/**
 * Builds a new apppearance based off of the light color and alpha values for use later.
 * Arguments:
 * * light_color - The color that we will set the mutable appearance to.
 * * light_alpha - The alpha that we will set the mutable appearance to.
 * Note: We use mutable appearances as this is the most efficent way to render lighting effects onto areas, using the light update method
 * is just not fast enough.
 */
/datum/day_night_controller/proc/update_area_appearance(light_color, light_alpha)
	var/mutable_appearance/updated_appearance = mutable_appearance(
		'icons/effects/daynight_blend.dmi',
		"white",
		DAY_NIGHT_LIGHTING_LAYER,
		LIGHTING_PLANE,
		light_alpha
		)
	updated_appearance.color = light_color
	area_appearance = updated_appearance

/**
 * Removes the current mutable appearance from all of the affected areas underlays.
 */
/datum/day_night_controller/proc/remove_effect_from_areas()
	for(var/area/iterating_area as anything in area_cache)
		iterating_area.underlays -= area_appearance

/**
 * Applies the current mutable appearance to all of the affected areas underlays.
 */
/datum/day_night_controller/proc/apply_effect_to_areas()
	for(var/area/iterating_area as anything in area_cache)
		iterating_area.underlays += area_appearance

/**
 * Intelligently sets the luminosity of our areas providing the light alpha is above the minimum amount of light.
 * Arguments:
 * * light_alpha - The new alpha that we are going to be setting.
 */
/datum/day_night_controller/proc/set_area_luminosity(light_alpha)
	var/luminosity = (light_alpha >= MINIMUM_ALPHA_FOR_LUMINOSITY) ? TRUE : FALSE
	current_luminosity = luminosity
	for(var/area/iterating_area as anything in area_cache)
		iterating_area.luminosity = luminosity

/**
 * Compiles a lookup table using the loaded timezones for each hour so we can reference it later when switching to said hour.
 */
/datum/day_night_controller/proc/compile_transitions()
	var/hour_index = 0 // We start at 0 as this is 24hr time
	var/datum/timezone/current_iterating_timezone
	var/transition_value = 0
	for(var/i in 1 to 24)
		var/datum/timezone/check_timezone = get_timezone(hour_index)
		if(current_iterating_timezone != check_timezone)
			current_iterating_timezone = check_timezone
			transition_value = 0
		var/datum/timezone/next_timezone = get_timezone(current_iterating_timezone.end_hour == 23 ? 0 : current_iterating_timezone.end_hour + 1)
		var/segments = (current_iterating_timezone.end_hour - current_iterating_timezone.start_hour)
		transition_value += (1 / segments)
		var/transition_color = BlendRGB(current_iterating_timezone.light_color, next_timezone.light_color, transition_value)
		var/transition_alpha = (current_iterating_timezone.light_alpha * (1 - transition_value)) + (next_timezone.light_alpha * (0 + transition_value))
		color_lookup_table["[hour_index]"] = transition_color
		alpha_lookup_table["[hour_index]"] = transition_alpha
		hour_index++

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
