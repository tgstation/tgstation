/// The mob is deaf
#define MUTE_DEAF (1<<0)
/// The mob is out of range of the sound
#define MUTE_RANGE (1<<1)
/// The mob muted their volume preference for this sound
#define MUTE_VOLUME (1<<1)

/datum/threed_sound
	var/atom/parent
	var/sound/our_sound
	var/sound_path
	var/list/mob/starting_listeners
	var/can_add_new_listeners = TRUE
	var/list/mob/listeners = list()
	var/volume = 50
	var/sound_range
	var/x_cutoff
	var/z_cutoff
	var/our_channel
	var/sound_length = 5 SECONDS
	var/deletion_timer
	var/preference_volume
	var/preference_signal
	var/falloff_distance
	var/falloff_exponent
	var/pressure_affected = TRUE

/datum/threed_sound/New(atom/new_parent, sound/new_sound, list/current_listeners, can_add_new_listeners = FALSE, volume = 50, sound_range = SOUND_RANGE, sound_length = 5 SECONDS, channel, preference_volume, preference_signal, falloff_exponent = SOUND_FALLOFF_EXPONENT, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, pressure_affected = TRUE)
	if(!ismovable(new_parent) && !isturf(new_parent))
		stack_trace("[type] created on non-turf or non-movable: [new_parent ? "[new_parent] ([new_parent.type])" : "null"])")
		qdel(src)
		return

	parent = new_parent
	our_sound = new_sound
	src.can_add_new_listeners = can_add_new_listeners
	src.volume = volume
	src.sound_range = sound_range
	src.sound_length = sound_length
	our_channel = channel
	src.preference_volume = preference_volume
	src.preference_signal = preference_signal
	src.falloff_distance = falloff_distance
	src.falloff_exponent = falloff_exponent
	src.pressure_affected = pressure_affected

	if(isnull(sound_range))
		src.sound_range = world.view
	var/list/worldviewsize = getviewsize(src.sound_range)
	x_cutoff = ceil(worldviewsize[1] / 2)
	z_cutoff = ceil(worldviewsize[2] / 2)
	for(var/listener in current_listeners)
		if(!ismob(listener))
			current_listeners -= current_listeners
			continue
		register_listener(listener)
	starting_listeners = current_listeners

	RegisterSignal(parent, COMSIG_ENTER_AREA, PROC_REF(on_enter_area))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(parent_delete))
	deletion_timer = addtimer(CALLBACK(src, PROC_REF(delete_self)), sound_length, TIMER_STOPPABLE | TIMER_DELETE_ME)

/datum/threed_sound/proc/delete_self()
	qdel(src)

/datum/threed_sound/Destroy()
	unlisten_all()
	deltimer(deletion_timer)
	parent = null
	our_sound = null
	return ..()

/datum/threed_sound/proc/parent_delete(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/**
 * Sets the sound's range to a new value. This can be a number or a view size string "XxY".
 * Then updates any mobs listening to it.
 */
/datum/threed_sound/proc/set_sound_range(new_range)
	if(sound_range == new_range)
		return
	sound_range = new_range
	var/list/worldviewsize = getviewsize(sound_range)
	x_cutoff = ceil(worldviewsize[1] / 2)
	z_cutoff = ceil(worldviewsize[2] / 2)
	update_all()

/**
 * Sets the sound's environment to a new value.
 * Then updates any mobs listening to it.
 */
/datum/threed_sound/proc/set_new_environment(new_env)
	if(!our_sound || our_sound.environment == new_env)
		return
	our_sound.environment = new_env
	update_all()

/datum/threed_sound/proc/unlisten_all()
	for(var/mob/listening as anything in listeners)
		deregister_listener(listening)
	our_sound = null

/datum/threed_sound/proc/update_all()
	for(var/mob/listening as anything in listeners)
		update_listener(listening)

/datum/threed_sound/proc/start_music()
	for(var/mob/nearby in hearers(sound_range, parent))
		register_listener(nearby)

/datum/threed_sound/proc/get_active_listeners()
	var/list/all_listeners = list()
	for(var/mob/listener as anything in listeners)
		if(listeners[listener] & SOUND_MUTE)
			continue
		all_listeners += listener
	return all_listeners

/datum/threed_sound/proc/register_listener(mob/new_listener)
	PROTECTED_PROC(TRUE)

	if(!(new_listener in listeners))
		RegisterSignal(new_listener, COMSIG_QDELETING, PROC_REF(listener_deleted))

		if(isnull(new_listener.client))
			RegisterSignal(new_listener, COMSIG_MOB_LOGIN, PROC_REF(listener_login))
			return
		if(preference_signal)
			RegisterSignals(new_listener, list(COMSIG_MOVABLE_MOVED, preference_signal), PROC_REF(listener_moved))
		else
			RegisterSignal(new_listener, COMSIG_MOVABLE_MOVED, PROC_REF(listener_moved))

		RegisterSignals(new_listener, list(SIGNAL_ADDTRAIT(TRAIT_DEAF), SIGNAL_REMOVETRAIT(TRAIT_DEAF)), PROC_REF(listener_deaf))
	listeners[new_listener] = NONE
	if(preference_volume)
		var/pref_volume = new_listener.client?.prefs.read_preference(preference_volume)
		if(HAS_TRAIT(new_listener, TRAIT_DEAF) || !pref_volume)
			listeners[new_listener] |= SOUND_MUTE

	if(HAS_TRAIT(new_listener, TRAIT_DEAF))
		listeners[new_listener] |= SOUND_MUTE

	update_listener(new_listener)
	listeners[new_listener] |= SOUND_UPDATE

/datum/threed_sound/proc/listener_deleted(mob/source)
	SIGNAL_HANDLER
	deregister_listener(source)

/datum/threed_sound/proc/listener_moved(mob/source)
	SIGNAL_HANDLER
	update_listener(source)

/datum/threed_sound/proc/listener_login(mob/source)
	SIGNAL_HANDLER
	deregister_listener(source)
	register_listener(source)

/datum/threed_sound/proc/listener_deaf(mob/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(source, TRAIT_DEAF))
		listeners[source] |= SOUND_MUTE
	else if(!unmute_listener(source, MUTE_DEAF))
		return
	update_listener(source)


/datum/threed_sound/proc/unmute_listener(mob/listener, reason)
	reason = ~reason

	if((reason & MUTE_DEAF) && HAS_TRAIT(listener, TRAIT_DEAF))
		return FALSE
	if(preference_volume)
		var/pref_volume = listener.client?.prefs.read_preference(preference_volume)
		if((reason & MUTE_VOLUME) && !pref_volume)
			return FALSE

	if(reason & MUTE_RANGE)
		var/turf/sound_turf = get_turf(parent)
		var/turf/listener_turf = get_turf(listener)
		if(isnull(sound_turf) || isnull(listener_turf))
			return FALSE
		if(sound_turf.z != listener_turf.z)
			return FALSE
		if(abs(sound_turf.x - listener_turf.x) > x_cutoff)
			return FALSE
		if(abs(sound_turf.y - listener_turf.y) > z_cutoff)
			return FALSE

	listeners[listener] &= ~SOUND_MUTE
	return TRUE

/datum/threed_sound/proc/deregister_listener(mob/no_longer_listening)
	PROTECTED_PROC(TRUE)

	listeners -= no_longer_listening
	no_longer_listening.stop_sound_channel(our_channel)
	if(preference_signal)
		UnregisterSignal(no_longer_listening, list(
			COMSIG_MOB_LOGIN,
			COMSIG_QDELETING,
			COMSIG_MOVABLE_MOVED,
			preference_signal,
			SIGNAL_ADDTRAIT(TRAIT_DEAF),
			SIGNAL_REMOVETRAIT(TRAIT_DEAF),
		))
	else
		UnregisterSignal(no_longer_listening, list(
			COMSIG_MOB_LOGIN,
			COMSIG_QDELETING,
			COMSIG_MOVABLE_MOVED,
			SIGNAL_ADDTRAIT(TRAIT_DEAF),
			SIGNAL_REMOVETRAIT(TRAIT_DEAF),
		))

/datum/threed_sound/proc/update_listener(mob/listener)
	PROTECTED_PROC(TRUE)
	our_sound.status = listeners[listener] || NONE
	var/turf/sound_turf = get_turf(parent)
	var/turf/listener_turf = get_turf(listener)
	if(isnull(sound_turf) || isnull(listener_turf)) // ??
		our_sound.x = 0
		our_sound.z = 0

	else if(sound_turf.z != listener_turf.z)
		listeners[listener] |= SOUND_MUTE

	else
		if(preference_volume)
			var/pref_volume = listener.client?.prefs.read_preference(preference_volume)
			if(!pref_volume)
				listeners[listener] |= SOUND_MUTE
			else
				unmute_listener(listener, MUTE_VOLUME)
				our_sound.volume = volume * (pref_volume/100)
		// keep in mind sound XYZ is different to world XYZ. sound +-z = world +-y
		var/new_x = sound_turf.x - listener_turf.x
		var/new_z = sound_turf.y - listener_turf.y

		if((abs(new_x) > x_cutoff || abs(new_z) > z_cutoff))
			listeners[listener] |= SOUND_MUTE

		else if(listeners[listener] & SOUND_MUTE)
			unmute_listener(listener, MUTE_RANGE)

		our_sound.x = new_x
		our_sound.z = new_z
	var/original_volume = our_sound.volume
	var/calculated_volume = original_volume - CALCULATE_SOUND_VOLUME(original_volume, get_dist(sound_turf, listener_turf), sound_range, falloff_distance, falloff_exponent)
	if(pressure_affected)
		//Atmosphere affects sound
		var/pressure_factor = 1
		var/datum/gas_mixture/hearer_env = listener_turf.return_air()
		var/datum/gas_mixture/source_env = sound_turf.return_air()

		if(hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
			if(pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //space
			pressure_factor = 0

		if(get_dist(sound_turf, listener_turf) <= 1)
			pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

		calculated_volume *= pressure_factor
	if(calculated_volume < SOUND_AUDIBLE_VOLUME_MIN || get_dist(sound_turf, listener_turf) > sound_range)
		our_sound.volume = 0
	else
		our_sound.volume = calculated_volume
	SEND_SOUND(listener, our_sound)
	our_sound.volume = original_volume

/datum/threed_sound/proc/on_moved(datum/source, ...)
	SIGNAL_HANDLER
	update_all()

/datum/threed_sound/proc/on_enter_area(datum/source, area/area_to_register)
	SIGNAL_HANDLER
	set_new_environment(area_to_register.sound_environment || SOUND_ENVIRONMENT_NONE)

#undef MUTE_DEAF
#undef MUTE_RANGE

/obj/item/threed_sound_test
	name = "fuck"
	desc = "lmao"
	icon = 'icons/obj/machines/music.dmi'
	icon_state = "jukebox"
	var/datum/threed_sound/threed_sound
	var/our_channel
	var/sound/new_sound

/obj/item/threed_sound_test/Initialize(mapload)
	. = ..()
	var/list/listeners = get_hearers_in_view(7, src)
	our_channel = SSsounds.random_available_channel()
	new_sound = sound(
		'sound/machines/tram/other_line_processed.ogg',
		FALSE,
		0,
		our_channel,
		100
	)
	for(var/mob/listener in listeners)
		listener.playsound_local(
			turf_source = get_turf(src),
			vol = 100,
			vary = FALSE,
			channel = our_channel,
			sound_to_use = new_sound
		)
	threed_sound = new(
		src,
		new_sound,
		listeners,
		FALSE,
		100,
		3,
		12 SECONDS,
		our_channel,
		/datum/preference/numeric/volume/sound_tts_volume,
		COMSIG_MOB_TTS_VOLUME_PREFERENCE_APPLIED
	)

/obj/item/threed_sound_test/attack_self(mob/user)
	. = ..()
	if(QDELETED(threed_sound))
		threed_sound = null
	if(!threed_sound)
		var/list/listeners = get_hearers_in_view(7, src)
		for(var/mob/listener in listeners)
			listener.playsound_local(
				turf_source = get_turf(src),
				vol = 100,
				vary = FALSE,
				channel = our_channel,
				sound_to_use = new_sound
			)
		threed_sound = new(
			src,
			new_sound,
			listeners,
			FALSE,
			100,
			3,
			12 SECONDS,
			our_channel,
			/datum/preference/numeric/volume/sound_tts_volume,
			COMSIG_MOB_TTS_VOLUME_PREFERENCE_APPLIED
		)
