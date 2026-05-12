// Sound tokens, a datumized handler for spatial sound.
// Creating a sound token registers all connected clients to the sound, so that they are in sync
// Even if someone enters the range of the sound after it has started.
// Updated by the SSsound_tokens subsystem every tick, so that if the source or listener moves, the sound updates accordingly.
/datum/sound_token
	/// The atom playing the sound.
	var/atom/source
	/// k:v list of mob : sound status
	var/list/listeners

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

	listeners = list()

	for(var/mob/listener_mob in GLOB.player_list)
		add_or_update_listener(listener_mob)

	SSsound_tokens.playing_sound_tokens[src] = TRUE

	RegisterSignal(SSdcs, COMSIG_GLOB_PLAYER_LOGIN, PROC_REF(player_login))
	RegisterSignal(SSdcs, COMSIG_GLOB_PLAYER_LOGOUT, PROC_REF(player_logout))

/datum/sound_token/Destroy(force, ...)
 	UnregisterSignal(SSdcs, list(
 		COMSIG_GLOB_PLAYER_LOGIN,
 		COMSIG_GLOB_PLAYER_LOGOUT,
 	))
 	if(source)
 		UnregisterSignal(source, list(
 			COMSIG_QDELETING,
 			COMSIG_MOVABLE_MOVED,
 			COMSIG_ENTER_AREA,
 		))


	var/listener_list = listeners.Copy()
	for(var/listener in listener_list)
		remove_listener(listener)

	listeners = null
	source = null
	SSsound_tokens.playing_sound_tokens -= src
	return ..()

///Lets us update the sound to a new one.
/datum/sound_token/proc/update_sound(_sound, start_playing = FALSE)
	sound = sound(_sound)
	if(!sound_channel)
		sound_channel = SSsounds.reserve_sound_channel_for_datum(src)
	sound.channel = sound_channel
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
	RegisterSignal(listener_mob, COMSIG_QDELETING, PROC_REF(listener_deleted))
	RegisterSignals(listener_mob, list(SIGNAL_ADDTRAIT(TRAIT_DEAF), SIGNAL_REMOVETRAIT(TRAIT_DEAF)), PROC_REF(listener_deafness_update))
	update_listener(listener_mob, FALSE)
	return TRUE

/// Remove a listener from the sound.
/datum/sound_token/proc/remove_listener(mob/listener_mob)
	if(isnull(listeners[listener_mob]))
 		return

	listeners -= listener_mob

	if(QDELETED(listener_mob))
 		return

	UnregisterSignal(listener_mob, list(COMSIG_QDELETING, SIGNAL_ADDTRAIT(TRAIT_DEAF),SIGNAL_REMOVETRAIT(TRAIT_DEAF)))
	SEND_SOUND(listener_mob, null_sound)

/datum/sound_token/proc/update_listener(mob/listener_mob, update_sound = TRUE)
	var/turf/source_turf = get_turf(source)
	var/turf/listener_turf = get_turf(listener_mob)

	var/is_muted = listeners[listener_mob] & SOUND_MUTE
	var/should_be_muted = FALSE
	if(!source_turf || !listener_turf)
		should_be_muted = TRUE
		if(should_be_muted && is_muted)
			return

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

	if(sound.status & SOUND_MUTE)
		SEND_SOUND(listener_mob, sound)
		return

	if(!listener_mob.playsound_local(get_turf(source), vol = volume, falloff_exponent = falloff_exponent, channel = sound_channel, sound_to_use = sound, max_distance = range, falloff_distance = falloff_distance, use_reverb = TRUE))
		sound.status = SOUND_UPDATE|SOUND_MUTE
		SEND_SOUND(listener_mob, sound)

/datum/sound_token/proc/update_all_listeners()
	for(var/mob/listener_mob in listeners)
		if(listener_mob.client)
			listener_mob.client.needs_sound_token_update = TRUE

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

/// Respond to any mob in the world being logged into.
/datum/sound_token/proc/player_login(datum/source, mob/player)
	SIGNAL_HANDLER
	add_or_update_listener(player)

/// Respond to any cliented mob becoming uncliented
/datum/sound_token/proc/player_logout(datum/source, mob/player)
	SIGNAL_HANDLER
	remove_listener(player)

/// If the sound source moves, update all listeners.
/datum/sound_token/proc/source_moved()
	SIGNAL_HANDLER
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
