// Sound tokens, a datumized handler for spatial sound.
// Uses the spatial grid to track clients in range and add them as listeners
// Updated by the SSsound_tokens subsystem every tick when requested by client so that if the source or listener moves, the sound updates accordingly.
/datum/sound_token
	/// The atom playing the sound.
	var/atom/source
	/// k:v list of mob : sound status
	var/list/listeners = list()

	/// Sound maximum range
	var/range
	/// Sound volume
	var/volume
	/// Sound falloff
	var/falloff_exponent
	/// Sound falloff distance
	var/falloff_distance

	/// The master copy of the playing sound.
	var/sound/sound
	/// Null sound for cancelling the sound entirely.
	var/sound/null_sound

	/// Status of the playing sound
	var/sound_status = NONE
	/// The channel being used.
	var/sound_channel
	/// world.time when the sound started (or when the sound file was last changed). Used to calculate playback offset for new listeners.
	var/start_time
	/// Duration of the current sound file in deciseconds. Used to wrap offset for looping sounds.
	var/sound_duration
	/// Cell tracker managing spatial grid cells within range of the source. The wizards say this is the fastest.
	var/datum/cell_tracker/cell_tracker

/datum/sound_token/New(atom/_source, _sound, _range = 10, _volume = 50, _falloff_exponent = SOUND_FALLOFF_EXPONENT, _falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE)
	source = _source
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(source_deleted))
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(source_moved))
	RegisterSignal(source, COMSIG_ENTER_AREA, PROC_REF(on_enter_area))

	range = _range
	volume = _volume
	falloff_exponent = _falloff_exponent
	falloff_distance = _falloff_distance

	update_sound(_sound)

	null_sound = sound(channel = sound_channel)

	cell_tracker = new /datum/cell_tracker(range, range)
	update_tracked_cells()

	RegisterSignal(SSdcs, COMSIG_GLOB_PLAYER_LOGIN, PROC_REF(player_login))
	RegisterSignal(SSdcs, COMSIG_GLOB_PLAYER_LOGOUT, PROC_REF(player_logout))

/datum/sound_token/Destroy(force, ...)
	for(var/listener in listeners)
		remove_listener(listener)

	listeners = null
	source = null
	return ..()

///Lets us update the sound to a new one.
/datum/sound_token/proc/update_sound(_sound, start_playing = FALSE)
	sound = sound(_sound)
	if(!sound_channel)
		sound_channel = SSsounds.reserve_sound_channel_for_datum(src)
	sound.channel = sound_channel
	sound_duration = SSsounds.get_sound_length(_sound)
	start_time = REALTIMEOFDAY
	if(start_playing)
		force_update_all_listeners(FALSE)

/// Updates the data of a listener, or adds them if they are not present.
/datum/sound_token/proc/add_or_update_listener(mob/listener_mob)
	if(isnull(listeners[listener_mob]))
		add_listener(listener_mob)
	else
		update_listener(listener_mob)

/// Adds a listener to the sound.
/datum/sound_token/proc/add_listener(mob/listener_mob)
	if(!isnull(listeners[listener_mob]))
		return FALSE

	if(!listener_mob.client || isnewplayer(listener_mob))
		return

	listeners[listener_mob] = NONE
	listener_mob.client.sound_tokens += src
	RegisterSignal(listener_mob, COMSIG_QDELETING, PROC_REF(listener_deleted))
	RegisterSignals(listener_mob, list(SIGNAL_ADDTRAIT(TRAIT_DEAF), SIGNAL_REMOVETRAIT(TRAIT_DEAF)), PROC_REF(listener_deafness_update))
	update_listener(listener_mob, FALSE)
	return TRUE

/// Remove a listener from the sound.
/datum/sound_token/proc/remove_listener(mob/listener_mob)

	listeners -= listener_mob

	if(listener_mob.client)
		listener_mob.client.sound_tokens -= src

	UnregisterSignal(listener_mob, list(COMSIG_QDELETING, SIGNAL_ADDTRAIT(TRAIT_DEAF),SIGNAL_REMOVETRAIT(TRAIT_DEAF)))
	SEND_SOUND(listener_mob, null_sound)

/datum/sound_token/proc/update_listener(mob/listener_mob, update_sound = TRUE)
	if(QDELETED(src))
		return
	if(isnull(listeners[listener_mob]))
		return

	var/turf/source_turf = get_turf(source)
	var/turf/listener_turf = get_turf(listener_mob)

	if(!source_turf || !listener_turf)
		return

	var/is_muted = listeners[listener_mob] & SOUND_MUTE
	var/should_be_muted = FALSE

	if(source_turf.z != listener_turf.z)
		should_be_muted = TRUE

	var/distance = get_dist(source_turf, listener_turf)
	if(distance > range)
		should_be_muted = TRUE
		if(should_be_muted && is_muted)
			return

	should_be_muted ||= HAS_TRAIT(listener_mob, TRAIT_DEAF)
	if(should_be_muted && is_muted)
		return

	set_listener_status(listener_mob, should_be_muted ? SOUND_MUTE : NONE)
	send_listener_sound(listener_mob, update_sound)

/datum/sound_token/proc/send_listener_sound(mob/listener_mob, update_sound)
	PRIVATE_PROC(TRUE)

	sound.status = SOUND_STREAM|sound_status|listeners[listener_mob]
	if(update_sound)
		sound.status |= SOUND_UPDATE
	else
		sound.offset = calculate_offset()

	if(sound.status & SOUND_MUTE)
		SEND_SOUND(listener_mob, sound)
		return

	if(!listener_mob.playsound_local(get_turf(source), vol = volume, falloff_exponent = falloff_exponent, channel = sound_channel, sound_to_use = sound, max_distance = range, falloff_distance = falloff_distance, use_reverb = TRUE))
		sound.status = SOUND_UPDATE|SOUND_MUTE
		SEND_SOUND(listener_mob, sound)
	sound.offset = null

/datum/sound_token/proc/update_all_listeners()
	for(var/mob/listener_mob in listeners)
		if(listener_mob.client)
			SSsound_tokens.clients_needing_update[listener_mob.client] = TRUE

/datum/sound_token/proc/force_update_all_listeners(update_sound = TRUE)
	for(var/mob/listener_mob in listeners)
		if(listener_mob.client)
			update_listener(listener_mob, update_sound)

/// Setter for volume
/datum/sound_token/proc/set_volume(new_volume, update_listeners = TRUE)
	volume = new_volume
	if(update_listeners)
		update_all_listeners()

/// Set the status of a listener. Does not update the sound.
/datum/sound_token/proc/set_listener_status(mob/listener_mob, new_status)
	if(isnull(listeners[listener_mob]))
		return

	listeners[listener_mob] = new_status

/// Respond to TRAIT_DEAF addition/removal
/datum/sound_token/proc/listener_deafness_update(atom/movable/source)
	SIGNAL_HANDLER
	update_listener(source)

/datum/sound_token/proc/listener_deleted(datum/source)
	SIGNAL_HANDLER
	remove_listener(source)

/// Respond to any mob in the world being logged into. Only adds if the mob is within range.
/datum/sound_token/proc/player_login(datum/source, mob/player)
	SIGNAL_HANDLER
	var/turf/player_turf = get_turf(player)
	var/turf/source_turf = get_turf(src.source)
	if(!player_turf || !source_turf)
		return
	if(player_turf.z != source_turf.z)
		return
	if(get_dist(source_turf, player_turf) > range)
		return
	add_or_update_listener(player)

/// Respond to any cliented mob becoming uncliented
/datum/sound_token/proc/player_logout(datum/source, mob/player)
	SIGNAL_HANDLER
	remove_listener(player)

/// If the sound source moves, update tracked cells then refresh all listener positions.
/datum/sound_token/proc/source_moved()
	SIGNAL_HANDLER
	update_tracked_cells()
	update_all_listeners()

/datum/sound_token/proc/source_deleted()
	SIGNAL_HANDLER

	qdel(src)

///Update env when source is entering new area
/datum/sound_token/proc/on_enter_area(datum/source, area/area_to_register)
	SIGNAL_HANDLER
	set_new_environment(area_to_register.sound_environment || SOUND_ENVIRONMENT_NONE)

/datum/sound_token/proc/set_new_environment(new_env)
	if(sound.environment == new_env)
		return
	sound.environment = new_env
	update_all_listeners()

///Calculates the offset to give the sound for people who start hearing it mid-play
/datum/sound_token/proc/calculate_offset()
	var/elapsed = REALTIMEOFDAY - start_time
	var/freq_factor = (sound.frequency || 100) / 100
	var/pitch_factor = (sound.pitch || 100) / 100
	var/offset = elapsed * freq_factor * pitch_factor
	return offset

///Update tracked cells; happens on movement. We need to check if anyone is now out of cell range and kick them out.
/datum/sound_token/proc/update_tracked_cells()
	if(!get_turf(source))
		return

	var/list/new_and_old = cell_tracker.recalculate_cells(get_turf(source))
	var/list/datum/spatial_grid_cell/added_cells = new_and_old[1]
	var/list/datum/spatial_grid_cell/removed_cells = new_and_old[2]

	for(var/datum/spatial_grid_cell/cell as anything in removed_cells)
		UnregisterSignal(cell, list(SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS),))

	// Remove listeners whose mob is no longer in any remaining member cell
	if(removed_cells.len)
		for(var/mob/listener_mob as anything in listeners)
			var/still_in_range = FALSE
			for(var/datum/spatial_grid_cell/cell as anything in cell_tracker.member_cells)
				if(listener_mob in cell.client_contents)
					still_in_range = TRUE
					break
			if(!still_in_range)
				remove_listener(listener_mob)

	for(var/datum/spatial_grid_cell/cell as anything in added_cells)
		RegisterSignal(cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_cell_client_entered))
		RegisterSignal(cell, SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_cell_client_exited))
		for(var/mob/listener_mob as anything in cell.client_contents)
			add_or_update_listener(listener_mob)

/// Signal handler for SPATIAL_GRID_CELL_ENTERED on tracked cells. Adds newly arriving mobs as listeners.
/datum/sound_token/proc/on_cell_client_entered(datum/source, list/entering_mobs)
	SIGNAL_HANDLER

	for(var/mob/listener_mob as anything in entering_mobs)
		if(!isnull(listeners[listener_mob])) // already added
			continue
		add_or_update_listener(listener_mob)

/// Signal handler for SPATIAL_GRID_CELL_EXITED on tracked cells. Removes mobs who have left all member cells.
/datum/sound_token/proc/on_cell_client_exited(datum/source, list/exiting_mobs)
	SIGNAL_HANDLER
	for(var/mob/listener_mob as anything in exiting_mobs)
		var/still_in_range = FALSE
		if(SSspatial_grid.get_cell_of(listener_mob) in cell_tracker.member_cells)
			still_in_range = TRUE

		if(!still_in_range)
			remove_listener(listener_mob)
