GLOBAL_LIST_INIT_TYPED(sound_spatial_trackers, /datum/sound_spatial_tracker, new /list(SOUND_CHANNEL_MAX))

/// A sound source that tracks listeners and the source of the sound.
/datum/sound_spatial_tracker
	// vars for playsound_local passthrough
	var/atom/source
	var/sound/sound // this one is only for restarting a sound if the client loses it
	var/base_volume
	var/falloff_exponent
	var/channel
	var/pressure_affected
	var/max_distance
	var/falloff_distance
	var/use_reverb

	/// world.timeofday we started playing the sound.
	var/start_time

	/// sound length
	var/sound_length

	/// The listeners of the sound.
	var/list/mob/listeners = list()

	/// Mobs who have left the cell
	var/list/mob/leavers = list()

	/// The spatial tracker for the sound.
	var/datum/cell_tracker/spatial_tracker

	/// Set to true if we were able to track sound length for self deletion.
	var/qdel_scheduled = FALSE

/datum/sound_spatial_tracker/New(
	source,
	sound,
	base_volume,
	falloff_exponent,
	channel,
	pressure_affected,
	max_distance,
	falloff_distance,
	use_reverb,
	sound_length,
)
	src.source = source
	src.sound = sound
	src.base_volume = base_volume
	src.falloff_exponent = falloff_exponent
	src.channel = channel
	src.pressure_affected = pressure_affected
	src.max_distance = max_distance
	src.falloff_distance = falloff_distance
	src.use_reverb = use_reverb

	start_time = REALTIMEOFDAY
	GLOB.sound_spatial_trackers[channel] = src
	spatial_tracker = new(max_distance, max_distance)
	update_spatial_tracker()
	src.sound_length = sound_length
	if(sound_length)
		schedule_qdel(sound_length)
	return ..()

/datum/sound_spatial_tracker/proc/schedule_qdel(length)
	if(qdel_scheduled)
		return
	qdel_scheduled = QDEL_IN_STOPPABLE(src, length)

/datum/sound_spatial_tracker/Destroy(force, ...)
	source = null
	for(var/mob/listener as anything in listeners)
		release_listener(listener)
	listeners.Cut()
	if(GLOB.sound_spatial_trackers[channel] == src)
		GLOB.sound_spatial_trackers[channel] = null
	spatial_tracker = null
	return ..()

/datum/sound_spatial_tracker/proc/on_source_moved()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(update_spatial_tracker))

/datum/sound_spatial_tracker/proc/update_spatial_tracker()
	var/list/new_and_old_cells = spatial_tracker.recalculate_cells(get_turf(source))
	for(var/datum/spatial_grid_cell/new_cell as anything in new_and_old_cells[1])
		RegisterSignal(new_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(entered_cell))
		for(var/mob/listener as anything in new_cell.client_contents)
			link_to_listener(listener)
	for(var/datum/spatial_grid_cell/old_cell as anything in new_and_old_cells[2])
		UnregisterSignal(old_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS))
		for(var/mob/listener as anything in old_cell.client_contents)
			release_listener(listener)

/datum/sound_spatial_tracker/proc/link_to_listener(mob/listener)
	if(listeners[listener])
		return
	RegisterSignal(listener, COMSIG_MOVABLE_MOVED, PROC_REF(on_listener_moved))
	listeners[listener] = TRUE

/datum/sound_spatial_tracker/proc/release_listener(mob/listener)
	if(!listeners[listener])
		return
	listeners -= listener
	UnregisterSignal(listener, COMSIG_MOVABLE_MOVED)
	if(isnull(listener.client))
		return
	var/sound/null_sound = sound(null, channel = channel)
	SEND_SOUND(listener.client, null_sound)

/datum/sound_spatial_tracker/proc/update_listener(mob/listener)
	var/sound/existing_sound = null
	for(var/sound/playing as anything in listener.client?.SoundQuery())
		if(playing.channel != channel)
			continue
		existing_sound = playing

	var/expected_offset = (REALTIMEOFDAY - start_time) * 0.1
	if(sound_length && (expected_offset >= sound_length))
		qdel(src)
		if(qdel_scheduled)
			deltimer(qdel_scheduled)
		return

	if(!isnull(existing_sound) && !sound_length) // couldn't do it before, but we can now
		sound_length = existing_sound.len * 10
		schedule_qdel(sound_length - expected_offset)

	var/sound/sound_to_use = existing_sound || sound(sound)
	if(isnull(existing_sound)) // starting over from no sound, so we need to guess the offset
		sound_to_use.offset = expected_offset
	listener.playsound_local(
		get_turf(source),
		vol = base_volume,
		falloff_exponent = falloff_exponent,
		channel = channel,
		pressure_affected = pressure_affected,
		max_distance = max_distance,
		falloff_distance = falloff_distance,
		use_reverb = use_reverb,
		sound_to_use = sound_to_use,
	)

/datum/sound_spatial_tracker/proc/on_listener_moved(mob/movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(update_listener), movable)

/datum/sound_spatial_tracker/proc/entered_cell(datum/cell, list/entered_contents)
	SIGNAL_HANDLER
	for(var/mob/listener as anything in entered_contents)
		link_to_listener(listener)

/mob/verb/TEST_SPATIAL_SOUND(obj/target as obj in view())
	playsound(target, 'sound/magic/clockwork/ark_activation_sequence.ogg', vol = 100, use_spatial_tracking = TRUE)
