/// The maximum amount of turfs that can be processed in a single tick regardless of
/// the number of turfs determined by turf_weather_chance and turf_thunder_chance
/// increasing this too high can result in severe lag so please be careful
#define MAX_TURFS_PER_TICK 500

/**
 * Causes weather to occur on a z level in certain area types
 *
 * The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.
 * Weather always occurs on different z levels at different times, regardless of weather type.
 * Can have custom durations, targets, and can automatically protect indoor areas.
 *
 */

/datum/weather
	/// name of weather
	var/name = "space wind"
	/// description of weather
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."
	/// The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_message = span_warning("The wind begins to pick up.")
	/// How long from the beginning of the telegraph until the weather begins
	var/telegraph_duration = 30 SECONDS
	/// The sound file played to everyone on an affected z-level
	var/telegraph_sound
	/// Volume of the telegraph sound
	var/telegraph_sound_vol
	/// The overlay applied to all tiles on the z-level
	var/telegraph_overlay

	/// Displayed in chat once the weather begins in earnest
	var/weather_message = span_userdanger("The wind begins to blow ferociously!")
	/// How long the weather lasts once it begins
	var/weather_duration = 2 MINUTES
	/// See above - this is the lowest possible duration
	var/weather_duration_lower = 2 MINUTES
	/// See above - this is the highest possible duration
	var/weather_duration_upper = 2.5 MINUTES
	/// The sound played to everyone on an affected z-level when weather is occuring (does not loop)
	var/weather_sound
	/// Area overlay while the weather is occuring
	var/weather_overlay
	/// Color to apply to the area while weather is occuring
	var/weather_color = null

	/// Displayed once the weather is over
	var/end_message = span_danger("The wind relents its assault.")
	/// How long the "wind-down" graphic will appear before vanishing entirely
	var/end_duration = 30 SECONDS
	/// Sound that plays while weather is ending
	var/end_sound
	/// Volume of the sound that plays while weather is ending
	var/end_sound_vol
	/// Area overlay while weather is ending
	var/end_overlay

	/// Types of area to affect
	var/area_type = /area/space
	/// Areas to be affected by the weather, calculated when the weather begins
	var/list/impacted_areas = list()
	/// A weighted list of areas impacted by weather, where weights reflect the total turf count in each area.
	var/list/impacted_areas_weighted = list()
	/// The total number of turfs impacted by weather across all z-levels and areas.
	var/total_impacted_turfs = 0
	/// Areas affected by weather have their blend modes changed
	var/list/impacted_areas_blend_modes = list()
	/// Areas that are protected and excluded from the affected areas.
	var/list/protected_areas = list()
	/// The list of z-levels that this weather is actively affecting
	var/impacted_z_levels
	/// A weighted list of z-levels impacted by weather, where weights reflect the total turf count on each level
	var/list/impacted_z_levels_weighted = list()

	/// Since it's above everything else, this is the layer used by default.
	var/overlay_layer = AREA_LAYER
	/// Plane for the overlay
	var/overlay_plane = WEATHER_PLANE
	/// Used by mobs (or movables containing mobs, such as enviro bags) to prevent them from being affected by the weather.
	var/immunity_type
	/// If this bit of weather should also draw an overlay that's uneffected by lighting onto the area
	/// Taken from weather_glow.dmi
	var/use_glow = TRUE
	/// List of all overlays to apply to our turfs
	var/list/overlay_cache

	/// The stage of the weather, from 1-4
	var/stage = END_STAGE

	/// Weight amongst other eligible weather. If zero, will never happen randomly.
	var/probability = 0
	/// The z-level trait to affect when run randomly or when not overridden.
	var/target_trait = ZTRAIT_STATION
	/// For barometers to know when the next storm will hit
	var/next_hit_time = 0
	/// The chance, per tick, a turf will have weather effects applied to it. This is a decimal value, 1.00 = 100%, 0.50 = 50%, etc.
	/// Recommend setting this low near 0.01 (results in 1 in 100 affected turfs having weather reagents applied per tick)
	var/turf_weather_chance = 0.01
	/// The chance, per tick, a turf will have a thunder strike applied to it. This is a decimal value, 1.00 = 100%, 0.50 = 50%, etc.
	/// Recommend setting this really low near 0.001 (results in 1 in 1000 affected turfs having thunder strikes applied per tick)
	var/turf_thunder_chance = THUNDER_CHANCE_AVERAGE // does nothing without the WEATHER_THUNDER weather_flag
	/// The calculated amount of turfs that get weather effects processed each tick (this gets calculated do not manually set this var)
	var/weather_turfs_per_tick = 0
	/// The calculated amount of turfs that get thunder effects processed each tick (this gets calculated do not manually set this var)
	var/thunder_turfs_per_tick = 0
	/// Color to apply to thunder while weather is occuring
	var/thunder_color = null

	/// List of weather bitflags that determines effects (see \code\__DEFINES\weather.dm)
	var/weather_flags = NONE

	/// List of current mobs being processed by weather
	var/list/current_mobs = list()
	/// The weather turf counter to keep track of how many turfs we have processed so far
	var/turf_iteration = 0
	/// The weather thunder counter to keep track of how much thunder we have processed so far
	var/thunder_iteration = 0
	/// Index of the current section our weather subsystem is processing from our subsystem_tasks
	var/task_index = 1
	/// The list of allowed tasks our weather subsystem is allowed to process (determined by weather_flags)
	var/list/subsystem_tasks = list()

	/// The temperature of our weather that is applied to weather reagents and mobs using adjust_bodytemperature()
	var/weather_temperature = T20C

	/// A list (supports regular, nested, and weighted) of possible reagents that will rain down from the sky.
	/// Only one of these will be selected to be used as the reagent
	var/list/whitelist_weather_reagents
	/// A list of reagents that are forbidden from being selected when there is no
	/// whitelist and the reagents are randomized
	var/list/blacklist_weather_reagents
	/// The selected reagent that will be rained down
	var/datum/reagent/weather_reagent
	/// The actual atom that holds our reagents that is held in nullspace
	var/obj/effect/abstract/weather_reagent_holder

/datum/weather/New(z_levels, list/weather_data)
	..()

	impacted_z_levels = z_levels
	area_type = weather_data?["area"] || area_type
	weather_flags = weather_data?["weather_flags"] || weather_flags
	turf_thunder_chance = isnull(weather_data?["thunder_chance"]) ? turf_thunder_chance : weather_data?["thunder_chance"]

	var/datum/reagent/custom_reagent = weather_data?["reagent"]
	var/reagent_id
	if(custom_reagent)
		reagent_id = custom_reagent
	else if(whitelist_weather_reagents)
		reagent_id = pick_weight_recursive(whitelist_weather_reagents)
	else if(blacklist_weather_reagents) // randomized
		reagent_id = get_random_reagent_id(blacklist_weather_reagents)

	if(reagent_id)
		weather_reagent = find_reagent_object_from_type(reagent_id)
		weather_color = weather_reagent.color
		weather_reagent_holder = new(null) // spawns in nullspace
		weather_reagent_holder.create_reagents(WEATHER_REAGENT_VOLUME, NO_REACT)
		weather_reagent_holder.reagents.add_reagent(reagent_id, WEATHER_REAGENT_VOLUME)
		weather_reagent_holder.reagents.set_temperature(weather_temperature)

	if(weather_flags & (WEATHER_MOBS))
		subsystem_tasks += SSWEATHER_MOBS
	if(weather_flags & (WEATHER_TURFS))
		subsystem_tasks += SSWEATHER_TURFS
	if(weather_flags & (WEATHER_THUNDER))
		subsystem_tasks += SSWEATHER_THUNDER

	setup_weather_areas()
	setup_weather_turfs()

/datum/weather/Destroy()
	QDEL_NULL(weather_reagent_holder)
	return ..()

/**
 * Telegraphs the beginning of the weather on the impacted z levels
 *
 * Sends sounds and details to mobs in the area
 * Calculates duration and hit areas, and makes a callback for the actual weather to start
 *
 */
/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return
	stage = STARTUP_STAGE
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(type), src)

	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	SSweather.processing |= src
	update_areas()
	if(telegraph_duration)
		send_alert(telegraph_message, telegraph_sound, telegraph_sound_vol)
	addtimer(CALLBACK(src, PROC_REF(start)), telegraph_duration)

/datum/weather/proc/setup_weather_areas()
	var/list/affectareas = list()
	for(var/area/selected_area as anything in get_areas(area_type))
		affectareas += selected_area
	for(var/area/protected_area as anything in protected_areas)
		affectareas -= get_areas(protected_area)
	for(var/area/affected_area as anything in affectareas)
		if(!(weather_flags & WEATHER_INDOORS) && !affected_area.outdoors)
			continue

		for(var/z in impacted_z_levels)
			var/total_turfs = length(affected_area.turfs_by_zlevel) >= z && length(affected_area.turfs_by_zlevel[z])
			if(!total_turfs)
				continue

			impacted_areas |= affected_area

			if(!(weather_flags & (WEATHER_THUNDER|WEATHER_TURFS)))
				continue

			var/z_string = num2text(z)
			if(!impacted_z_levels_weighted[z_string])
				impacted_z_levels_weighted[z_string] = 0
			if(!impacted_areas_weighted[z_string])
				impacted_areas_weighted[z_string] = list()

			impacted_z_levels_weighted[z_string] += total_turfs
			impacted_areas_weighted[z_string][affected_area] = total_turfs
			total_impacted_turfs += total_turfs

/// Selects a turf impacted by weather, if available, otherwise returns null
/datum/weather/proc/pick_turf()
	var/z_string = pick_weight_recursive(impacted_z_levels_weighted)
	var/area/selected_area = pick_weight_recursive(impacted_areas_weighted[z_string])
	var/z = text2num(z_string)
	var/list/available_turfs = selected_area.get_turfs_by_zlevel(z)
	// Areas or turfs may change during weather events. For example, a shuttle
	// landing and departing might leave an area in 'impacted_areas' but without
	// turfs on the expected z-level, resulting in an empty 'available_turfs' list.
	if(length(available_turfs))
		return pick(available_turfs)
	return

/datum/weather/proc/setup_weather_turfs()
	if(!(weather_flags & (WEATHER_TURFS|WEATHER_THUNDER)))
		return
	if(!total_impacted_turfs)
		return

	if(weather_flags & (WEATHER_TURFS))
		weather_turfs_per_tick = total_impacted_turfs * turf_weather_chance
		weather_turfs_per_tick = min(weather_turfs_per_tick, MAX_TURFS_PER_TICK)
	if(weather_flags & (WEATHER_THUNDER))
		thunder_turfs_per_tick = total_impacted_turfs * turf_thunder_chance
		thunder_turfs_per_tick = min(thunder_turfs_per_tick, MAX_TURFS_PER_TICK)

/**
 * Starts the actual weather and effects from it
 *
 * Updates area overlays and sends sounds and messages to mobs to notify them
 * Begins dealing effects from weather to mobs in the area
 *
 */
/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_START(type), src)
	stage = MAIN_STAGE
	update_areas()
	send_alert(weather_message, weather_sound)
	if(!(weather_flags & (WEATHER_ENDLESS)))
		addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)
	for(var/area/impacted_area as anything in impacted_areas)
		SEND_SIGNAL(impacted_area, COMSIG_WEATHER_BEGAN_IN_AREA(type), src)

/**
 * Weather enters the winding down phase, stops effects
 *
 * Updates areas to be in the winding down phase
 * Sends sounds and messages to mobs to notify them
 *
 */
/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_WINDDOWN(type), src)
	stage = WIND_DOWN_STAGE
	update_areas()
	send_alert(end_message, end_sound, end_sound_vol)
	addtimer(CALLBACK(src, PROC_REF(end)), end_duration)

/**
 * Fully ends the weather
 *
 * Effects no longer occur and area overlays are removed
 * Removes weather from processing completely
 *
 */
/datum/weather/proc/end()
	if(stage == END_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(type), src)
	stage = END_STAGE
	SSweather.processing -= src
	update_areas()
	for(var/area/impacted_area as anything in impacted_areas)
		SEND_SIGNAL(impacted_area, COMSIG_WEATHER_ENDED_IN_AREA(type), src)

// handles sending all alerts
/datum/weather/proc/send_alert(alert_msg, alert_sfx, alert_sfx_vol = 100)
	for(var/z_level in impacted_z_levels)
		for(var/mob/player as anything in SSmobs.clients_by_zlevel[z_level])
			if(!can_get_alert(player))
				continue
			if(alert_msg)
				to_chat(player, alert_msg)
			if(alert_sfx)
				player.stop_sound_channel(CHANNEL_WEATHER)
				SEND_SOUND(player, sound(alert_sfx, channel = CHANNEL_WEATHER, volume = alert_sfx_vol))

// the checks for if a mob should receive alerts, returns TRUE if can
/datum/weather/proc/can_get_alert(mob/player)
	var/turf/mob_turf = get_turf(player)
	return !isnull(mob_turf)

/**
 * Returns TRUE if the living mob can be affected by the weather
 */
/datum/weather/proc/can_weather_act_mob(mob/living/mob_to_check)
	var/turf/mob_turf = get_turf(mob_to_check)

	if(!mob_turf)
		return

	if(!(mob_turf.z in impacted_z_levels))
		return

	if(!(mob_turf.loc in impacted_areas))
		return

	var/atom/to_check = mob_to_check
	while(!isturf(to_check))
		if(recursive_weather_protection_check(to_check))
			return
		to_check = to_check.loc
	return TRUE

/**
 * Returns TRUE if the atom should protect itself or its contents from weather
 */
/datum/weather/proc/recursive_weather_protection_check(atom/to_check)
	return HAS_TRAIT(to_check, TRAIT_WEATHER_IMMUNE) || (immunity_type && HAS_TRAIT(to_check, immunity_type))

/**
 * Returns TRUE if the turf can be affected by the weather
 */
/datum/weather/proc/can_weather_act_turf(turf/valid_weather_turf)
	// applying weather effects to solid walls is a waste since nothing will happen
	if(isclosedturf(valid_weather_turf))
		return
	// same logic for space and openspace turfs
	if(is_space_or_openspace(valid_weather_turf))
		return
	// solid windows are also worth skipping
	var/obj/structure/window/window = locate() in valid_weather_turf
	if(window?.fulltile)
		return

	return TRUE

/**
 * Affects the mob with whatever the weather does
 */
/datum/weather/proc/weather_act_mob(mob/living/living)
	var/temperature_delta = weather_temperature - living.bodytemperature
	if(iscarbon(living))
		var/mob/living/carbon/carbon_living = living
		var/insulation_flag = !(weather_flags & WEATHER_TEMPERATURE_BYPASS_CLOTHING)
		carbon_living.adjust_bodytemperature(temperature_delta, use_insulation=insulation_flag, use_steps=TRUE)
	else // stolen from carbon/adjust_bodytemperature() which should really be universally applied to living/adjust_bodytemperature()
		// Use the bodytemp divisors to get the change step, with max step size
		temperature_delta = (temperature_delta > 0) ? (temperature_delta / BODYTEMP_HEAT_DIVISOR) : (temperature_delta / BODYTEMP_COLD_DIVISOR)
		// Clamp the results to the min and max step size
		temperature_delta = (temperature_delta > 0) ? min(temperature_delta, BODYTEMP_HEATING_MAX) : max(temperature_delta, BODYTEMP_COOLING_MAX)
		living.adjust_bodytemperature(temperature_delta)

	if(!weather_reagent || !weather_reagent_holder || living.IsObscured())
		return

	if(istype(weather_reagent, /datum/reagent/water))
		living.wash()

	weather_reagent_holder.reagents.expose(living, TOUCH)

/**
 * Affects the turf with whatever the weather does
 */
/datum/weather/proc/weather_act_turf(turf/open/weather_turf)
	if(!weather_reagent || !weather_reagent_holder)
		return

	weather_reagent_holder.reagents.expose(weather_turf, TOUCH, TURF_REAGENT_VOLUME_MULTIPLIER)
	for(var/atom/thing as anything in weather_turf)
		if(thing.IsObscured() || isliving(thing))
			continue

		weather_reagent_holder.reagents.expose(thing, TOUCH, TURF_REAGENT_VOLUME_MULTIPLIER)

		// Time for the sophisticated art of catching sky-booze
		if(!is_reagent_container(thing))
			continue

		var/obj/item/reagent_containers/container = thing
		if(!container.is_open_container() || container.reagents.holder_full())
			continue

		container.reagents.add_reagent(weather_reagent.type, WEATHER_REAGENT_VOLUME, TURF_REAGENT_VOLUME_MULTIPLIER)

	if(istype(weather_reagent, /datum/reagent/water))
		weather_turf.wash(CLEAN_ALL, TRUE)

/**
 * Affects the turf with thunder
 */
/datum/weather/proc/thunder_act_turf(turf/open/weather_turf)
	var/obj/effect/temp_visual/thunderbolt/thunder = new(weather_turf)
	thunder.flash_lighting_fx(6, 2, duration = thunder.duration)

	if(thunder_color)
		thunder.color = thunder_color

	for(var/mob/living/hit_mob in weather_turf)
		to_chat(hit_mob, span_userdanger("You've been struck by lightning!"))
		hit_mob.electrocute_act(50, "thunder", flags = SHOCK_TESLA|SHOCK_NOGLOVES)

	for(var/obj/hit_thing in weather_turf)
		if(QDELETED(hit_thing)) // stop, it's already dead
			continue
		if(!hit_thing.uses_integrity)
			continue
		if(hit_thing.invisibility != INVISIBILITY_NONE)
			continue
		if(HAS_TRAIT(hit_thing, TRAIT_UNDERFLOOR))
			continue
		hit_thing.take_damage(20, BURN, ENERGY, FALSE)
	playsound(weather_turf, 'sound/effects/magic/lightningbolt.ogg', 100, extrarange = 10, falloff_distance = 10)
	weather_turf.visible_message(span_danger("A thunderbolt strikes [weather_turf]!"))
	explosion(weather_turf, light_impact_range = 1, flame_range = 1, silent = TRUE, adminlog = FALSE)

/**
 * Updates the overlays on impacted areas
 */
/datum/weather/proc/update_areas()
	var/list/new_overlay_cache = generate_overlay_cache()
	for(var/area/impacted as anything in impacted_areas)
		if(length(overlay_cache))
			impacted.overlays -= overlay_cache
			if(impacted_areas_blend_modes[impacted])
				// revert the blend mode to the old state
				impacted.blend_mode = impacted_areas_blend_modes[impacted]
				impacted_areas_blend_modes[impacted] = null
		if(length(new_overlay_cache))
			impacted.overlays += new_overlay_cache
			// only change the blend mode if it's not default or overlay
			if(impacted.blend_mode > BLEND_OVERLAY)
				// save the old blend mode state
				impacted_areas_blend_modes[impacted] = impacted.blend_mode
				impacted.blend_mode = BLEND_OVERLAY

	overlay_cache = new_overlay_cache

/// Returns a list of visual offset -> overlays to use
/datum/weather/proc/generate_overlay_cache()
	// We're ending, so no overlays at all
	if(stage == END_STAGE)
		return list()

	var/weather_state = ""
	switch(stage)
		if(STARTUP_STAGE)
			weather_state = telegraph_overlay
		if(MAIN_STAGE)
			weather_state = weather_overlay
		if(WIND_DOWN_STAGE)
			weather_state = end_overlay

	// Use all possible offsets
	// Yes this is a bit annoying, but it's too slow to calculate and store these from turfs, and it shouldn't (I hope) look weird
	var/list/gen_overlay_cache = list()
	for(var/offset in 0 to SSmapping.max_plane_offset)
		// Note: what we do here is effectively apply two overlays to each area, for every unique multiz layer they inhabit
		// One is the base, which will be masked by lighting. the other is "glowing", and provides a nice contrast
		// This method of applying one overlay per z layer has some minor downsides, in that it could lead to improperly doubled effects if some have alpha
		// I prefer it to creating 2 extra plane masters however, so it's a cost I'm willing to pay
		// LU
		if(use_glow)
			var/mutable_appearance/glow_overlay = mutable_appearance('icons/effects/glow_weather.dmi', weather_state, overlay_layer, null, WEATHER_GLOW_PLANE, 100, offset_const = offset)
			glow_overlay.color = weather_color
			gen_overlay_cache += glow_overlay

		var/mutable_appearance/new_weather_overlay = mutable_appearance('icons/effects/weather_effects.dmi', weather_state, overlay_layer, plane = overlay_plane, offset_const = offset)
		new_weather_overlay.color = weather_color
		gen_overlay_cache += new_weather_overlay

	return gen_overlay_cache

#undef MAX_TURFS_PER_TICK
