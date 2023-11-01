/// The listener offset gap, used as an offset for the offset to ensure that the offset is never at or below 0.
/// You may ask why this is so high, and thats because SEND_SOUND will wait for the client to acknowledge the sound before continuing
/// Which means that we can have a negative offset if the client has a high latency.
#define LISTENER_OFFSET_GAP 99
/// The listener offset for a listener that hasn't been calculated yet.
#define LISTENER_OFFSET_UNKNOWN -LISTENER_OFFSET_GAP
/// Gets the listener offset for a listener.
#define LISTENER_OFFSET_GET(listener) (listeners[listener] - LISTENER_OFFSET_GAP)
/// Sets the listener offset for a listener.
#define LISTENER_OFFSET_SET(listener, offset) (listeners[listener] = offset + LISTENER_OFFSET_GAP)

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

	/// null sound datum used to stop the sound on a client; stored to prevent constant generation
	var/sound/null_sound

	/// world.timeofday we started playing the sound.
	var/start_time

	/// sound length
	var/sound_length

	/// The listeners of the sound.
	var/list/mob/listeners = list()

	/// Mobs who have left any cells we care about
	var/list/mob/leavers = list()

	/// The spatial tracker for the sound.
	var/datum/cell_tracker/spatial_tracker

	/// List of cells we're tracking
	var/list/cells = list()

	/// Set to true if we were able to track sound length for self deletion.
	var/qdel_scheduled = FALSE

	/// Map of client ckeys to their expected offset, offset
	var/list/client_offsets = list()

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
	src.sound = sound(file = sound, channel = channel)
	src.base_volume = base_volume
	src.falloff_exponent = falloff_exponent
	src.channel = channel
	src.pressure_affected = pressure_affected
	src.max_distance = max_distance
	src.falloff_distance = falloff_distance
	src.use_reverb = use_reverb

	start_time = REALTIMEOFDAY
	SSsounds.register_spatial_tracker(src)
	spatial_tracker = new(max_distance, max_distance)
	update_spatial_tracker()
	src.sound_length = sound_length
	if(sound_length)
		schedule_qdel(sound_length)
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(source_gone))
	return ..()

/datum/sound_spatial_tracker/Destroy(force, ...)
	SSsounds.unregister_spatial_tracker(src)
	release_all_listeners()
	spatial_tracker = null
	source = null
	cells.Cut()
	return ..()

/datum/sound_spatial_tracker/process(seconds_per_tick)
	if(!length(leavers))
		return
	release_all_listeners(leavers)
	leavers.Cut()

/// Go through and check our location for spatial grid changes
/datum/sound_spatial_tracker/proc/update_spatial_tracker()
	var/list/new_and_old_cells = spatial_tracker.recalculate_cells(get_turf(source))
	for(var/datum/spatial_grid_cell/new_cell as anything in new_and_old_cells[1])
		RegisterSignal(new_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(entered_cell))
		RegisterSignal(new_cell, SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(exited_cell))
		for(var/mob/listener as anything in new_cell.client_contents)
			link_to_listener(listener)
		cells[new_cell] = TRUE
	for(var/datum/spatial_grid_cell/old_cell as anything in new_and_old_cells[2])
		UnregisterSignal(old_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS))
		UnregisterSignal(old_cell, SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS))
		for(var/mob/listener as anything in old_cell.client_contents)
			release_listener(listener)
		cells -= old_cell
	for(var/mob/listener as anything in listeners)
		update_listener(listener)

/datum/sound_spatial_tracker/proc/on_source_moved()
	SIGNAL_HANDLER
	update_spatial_tracker()

/// Helper to send a null sound to a listener; which stops it from playing.
/datum/sound_spatial_tracker/proc/stop_sound_for(mob/listener)
	null_sound ||= sound(null, channel = channel)
	SEND_SOUND(listener, null_sound)

/datum/sound_spatial_tracker/proc/update_listener(mob/listener)
	set waitfor = FALSE
	// special note for debuggers,
	// having a breakpoint here will cause the logic to break as the offset won't take into account the time it takes to step through this proc

	if(isnull(listener.client))
		release_listener(listener)
		return

	if(get_dist(listener, source) > max_distance)
		stop_sound_for(listener)
		return

	var/expected_offset = (REALTIMEOFDAY - start_time)
	var/listener_offset = LISTENER_OFFSET_GET(listener)
	if(listener_offset == LISTENER_OFFSET_UNKNOWN)
		var/sound/existing_sound = null
		for(var/sound/playing as anything in listener.client?.SoundQuery())
			if(playing.channel != channel)
				continue
			existing_sound = playing
			break

		if(!isnull(existing_sound))
			if(!sound_length)
				sound_length = existing_sound.len * 10
				schedule_qdel(sound_length - expected_offset)

			listener_offset = expected_offset - (existing_sound.offset * 10)
			LISTENER_OFFSET_SET(listener, listener_offset)

	// we got here even though the sound is supposed to be stopped
	if(sound_length && (expected_offset >= sound_length))
		qdel(src)
		if(qdel_scheduled)
			deltimer(qdel_scheduled)
		return

	// offset by the amount of deciseconds we expect the client to take to recieve the message
	// remember that sound.offset is seconds based
	sound.offset = (expected_offset + listener_offset) * 0.1
	listener.playsound_local(
		get_turf(source),
		vol = base_volume,
		falloff_exponent = falloff_exponent,
		channel = channel,
		pressure_affected = pressure_affected,
		max_distance = max_distance,
		falloff_distance = falloff_distance,
		use_reverb = use_reverb,
		sound_to_use = sound,
	)

/// Sets up a listener to be tracked by this datum.
/datum/sound_spatial_tracker/proc/link_to_listener(mob/listener)
	if(listeners[listener])
		return
	RegisterSignal(listener, COMSIG_MOVABLE_MOVED, PROC_REF(on_listener_moved))
	LISTENER_OFFSET_SET(listener, LISTENER_OFFSET_UNKNOWN)

/// Release a specific listener.
/datum/sound_spatial_tracker/proc/release_listener(mob/listener)
	if(!listeners[listener])
		return
	listeners -= listener
	UnregisterSignal(listener, COMSIG_MOVABLE_MOVED)
	if(isnull(listener.client))
		return
	stop_sound_for(listener)

/// Release all listeners from the given list; if no list is specified, release all listeners.
/datum/sound_spatial_tracker/proc/release_all_listeners(list/going)
	going ||= listeners
	for(var/mob/listener as anything in going)
		release_listener(listener)

/datum/sound_spatial_tracker/proc/exited_cell(datum/cell, list/exited_contents)
	SIGNAL_HANDLER
	for(var/mob/listener as anything in exited_contents)
		if(cells[SSspatial_grid.get_cell_of(listener)])
			continue
		leavers[listener] = TRUE
		stop_sound_for(listener)

/datum/sound_spatial_tracker/proc/entered_cell(datum/cell, list/entered_contents)
	SIGNAL_HANDLER
	for(var/mob/listener as anything in entered_contents)
		link_to_listener(listener)

/datum/sound_spatial_tracker/proc/on_listener_moved(mob/movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(update_listener), movable)

/// Schedules a qdel if not already scheduled.
/datum/sound_spatial_tracker/proc/schedule_qdel(length)
	if(qdel_scheduled)
		return
	qdel_scheduled = QDEL_IN_STOPPABLE(src, length)

/datum/sound_spatial_tracker/proc/source_gone()
	SIGNAL_HANDLER
	qdel(src)

#undef LISTENER_OFFSET_UNKNOWN
#undef LISTENER_OFFSET_GAP
#undef LISTENER_OFFSET_GET
#undef LISTENER_OFFSET_SET
