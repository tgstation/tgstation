/datum/playsound/proc/get_listeners()
	RETURN_TYPE(/list/mob)
	ASSERT(isnull(source) || (istype(source) && !isarea(source)), "invalid type of source atom passed to [type]")

	if(islist(direct_listeners))
		return direct_listeners

	if(source == GLOBAL_SOUND)
		return GLOB.player_list - GLOB.new_player_list

	var/turf/source_location = get_turf(source)

	// grab the initial candidates
	var/list/mob/candidates = ignore_walls ? get_hearers_in_range(range, source_location) : get_hearers_in_view(range, source_location)

	if(source_location && z_traversal_allowed)
		// now go through and move up and down z levels. going across a z level incurrs a 25% reduction in range for
		var/effective_range = round(range * z_traversal_modifier)
		var/turf/source_above = GET_TURF_ABOVE(source_location)
		while(!isnull(source_above) && effective_range > 2)
			if(!ignore_walls && !istransparentturf(source_above))
				break
			candidates += ignore_walls ? get_hearers_in_range(effective_range, source_above) : get_hearers_in_view(effective_range, source_above)
			source_above = GET_TURF_ABOVE(source_above)
			effective_range = round(effective_range * z_traversal_modifier)

		effective_range = round(range * z_traversal_modifier)
		var/turf/source_below = GET_TURF_BELOW(source_location)
		while(!isnull(source_below) && effective_range > 2)
			if(!ignore_walls && !istransparentturf(source_below))
				break
			candidates += ignore_walls ? get_hearers_in_range(effective_range, source_below) : get_hearers_in_view(effective_range, source_below)
			source_below = GET_TURF_BELOW(source_below)
			effective_range = round(effective_range * z_traversal_modifier)

	return candidates

/datum/playsound/proc/play()
	if(wait)
		var/old_wait = wait
		wait = 0
		addtimer(CALLBACK(src, PROC_REF(play)), old_wait, TIMER_DELETE_ME|TIMER_CLIENT_TIME)
		return

	start_time = world.time
	if(!channel)
		channel = SSsounds.random_available_channel()

	var/list/mob/listeners = list()
	for(var/mob/listening_mob in get_listeners())
		if(source == GLOBAL_SOUND) // if the sound is global, don't spend time calculating local sound properties
			SEND_SOUND(listening_mob, sound)
			listeners += listening_mob
			continue

		var/sound/local_sound = calculate_mob_local_sound(listening_mob)
		if(!local_sound)
			continue
		SEND_SOUND(listening_mob, local_sound)
		listeners += listening_mob

	. = listeners
	qdel(src) // qdel the sound after it's done being sent to all listeners

/// Updates a mob's local sound. Position, Falloff, blah blah blah.
/// Does NOT resend the entire sound we just tell the client to update it via flags.
/datum/playsound/proc/update_local_mob_sound(mob/mob, sound/update_target = null)
	if(source == GLOBAL_SOUND)
		CRASH("Attempted to call [__PROC__] on a global sound.")

	var/turf/source_turf = get_turf(source)
	if(source_turf == null)
		return null

	var/turf/mob_turf = get_turf(mob)
	if(mob_turf == null)
		return null

	if(mob.client == null || !mob.can_hear())
		return null

	var/mob_x = mob_turf.x
	var/mob_y = mob_turf.y
	var/mob_z = mob_turf.z
	var/source_x = source_turf.x
	var/source_y = source_turf.y
	var/source_z = source_turf.z

	var/sound/sound_update = update_target || sound(channel = channel)
	if(!update_target)
		sound_update.status = SOUND_UPDATE

	var/effective_distance
	if(mob_z == source_z)
		effective_distance = get_dist_euclidean(mob_turf, source_turf)
	else // not the same z level, use the penalty modifier
		effective_distance = get_dist_euclidean(mob_turf, locate(source_x, source_y, mob_z))
		effective_distance *= ((z_traversal_modifier / 1) ** abs(mob_z - source_z))
	// https://www.desmos.com/calculator/sqdfl8ipgf
	sound_update.volume = volume - ((max(effective_distance - falloff_distance, 0) ** (1 / falloff_exponent)) / ((max(range, effective_distance) - falloff_distance) ** (1 / falloff_exponent)) * volume)

	if(atmospherics_affected)
		// this ignores the fact that you can have multiple different gas mixtures inbetween the source and the mob
		// if you want to implement that be my guest

		var/pressure_factor = 1
		var/datum/gas_mixture/hearer_env = mob_turf.return_air()
		var/datum/gas_mixture/source_env = source_turf.return_air()

		if(hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
			if(pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else
			pressure_factor = 0
		if(effective_distance <= 1)
			pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound
		sound_update.volume *= pressure_factor

	if(sound_update.volume <= 0)
		return null

	sound_update.x = source_x - mob_x
	sound_update.z = source_y - mob_y
	sound_update.y = (source_z - mob_z) * 5 // misnomer, spatial grid is xzy instead of xyz
	sound_update.falloff = effective_distance || 1

	return sound_update

/datum/playsound/proc/calculate_mob_local_sound(mob/mob)
	if(!mob.client || !mob.can_hear())
		return
	var/sound/local_sound = sound(sound)
	local_sound.wait = 0
	local_sound.channel = channel

	if(vary)
		local_sound.frequency = get_rand_frequency()
	else
		local_sound.frequency = frequency

	if(mob.sound_environment_override != SOUND_ENVIRONMENT_NONE)
		local_sound.environment = mob.sound_environment_override
	else
		var/area/mob_area = get_area(mob)
		local_sound.environment = mob_area.sound_environment

	if(use_reverb && local_sound.environment != SOUND_ENVIRONMENT_NONE)
		local_sound.echo[3] = 0
		local_sound.echo[4] = 0

	return update_local_mob_sound(mob, update_target = local_sound)
