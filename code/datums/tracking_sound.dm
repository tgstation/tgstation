GLOBAL_LIST_EMPTY_TYPED(sound_spatial_trackers, /datum/sound_spatial_tracker)

/// A sound source that tracks listeners and the source of the sound.
/datum/sound_spatial_tracker
	/// The channel of the sound played, tracked here to easily update listeners.
	var/channel
	/// world.timeofday we started playing the sound.
	var/start_time
	/// The atom playing the sound.
	var/atom/source
	/// The range of the sound.
	var/range
	/// The arguments passed to playsound_local.
	var/list/playsound_local_args
	/// The listeners of the sound.
	var/list/mob/listeners = list()
	/// The spatial tracker for the sound.
	var/datum/cell_tracker/spatial_tracker
	/// Set to true if we were able to track sound length for self deletion.
	var/qdel_scheduled = FALSE

/datum/sound_spatial_tracker/New(source, channel, range, sound_length, playsound_local_args)
	src.source = source
	start_time = world.timeofday
	src.channel = channel
	src.range = range
	src.playsound_local_args = playsound_local_args
	GLOB.sound_spatial_trackers["[channel]"] = src
	spatial_tracker = new(range, range)
	update_spatial_tracker()
	if(sound_length)
		schedule_qdel(sound_length)
	return ..()

/datum/sound_spatial_tracker/proc/schedule_qdel(length)
	QDEL_IN(src, length)
	qdel_scheduled = TRUE

/datum/sound_spatial_tracker/Destroy(force, ...)
	source = null
	playsound_local_args.Cut()
	for(var/mob/listener as anything in listeners)
		release_listener(listener)
	listeners.Cut()
	GLOB.sound_spatial_trackers -= "[channel]"
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
	if(listener in listeners)
		return
	RegisterSignal(listener, COMSIG_MOVABLE_MOVED, PROC_REF(on_listener_moved))
	listeners[listener] = TRUE

/datum/sound_spatial_tracker/proc/release_listener(mob/listener)
	if(!(listener in listeners))
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

	var/expected_offset = (world.timeofday - start_time) * 0.1
	if(!qdel_scheduled && !isnull(existing_sound)) // couldn't do it before, but we can now
		schedule_qdel((existing_sound.len - expected_offset) + 1)

	var/list/new_args = playsound_local_args.Copy()
	new_args["turf_source"] = get_turf(source)

	var/sound/new_sound = sound(new_args["soundin"])
	new_sound.offset = (world.timeofday - start_time) * 0.1
	new_args["sound_to_use"] = new_sound

	listener.playsound_local(arglist(new_args))

/datum/sound_spatial_tracker/proc/on_listener_moved(mob/movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(update_listener), movable)

/datum/sound_spatial_tracker/proc/entered_cell(datum/cell, list/entered_contents)
	SIGNAL_HANDLER
	for(var/mob/listener as anything in entered_contents)
		link_to_listener(listener)

/datum/sound_spatial_tracker/proc/left_cell(datum/cell, list/left_contents)
	SIGNAL_HANDLER
	for(var/mob/listener as anything in left_contents)
		release_listener(listener)

/mob/verb/TEST_SPATIAL_SOUND(obj/target as obj in view())
	playsound(target, 'sound/magic/clockwork/ark_activation_sequence.ogg', vol = 100, use_spatial_tracking = TRUE)
