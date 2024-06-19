///How many ticks to try to find a target before giving up.
#define CAMERA_TICK_LIMIT 10

/datum/trackable
	///Reference to the atom that owns us, used for tracking.
	var/atom/tracking_holder

	///What mob are we currently tracking, if any
	var/mob/living/tracked_mob
	///If we're currently rechecking our target's trackability in hopes of something changing
	var/rechecking = FALSE
	///How many times we've failed to locate our target.
	var/cameraticks = 0

	///List of all names that can be tracked.
	VAR_PRIVATE/list/names = list()
	///List of all namecounts for mobs with the exact same name, just in-case.
	VAR_PRIVATE/list/namecounts = list()
	///List of all humans trackable by cameras.
	VAR_PRIVATE/static/list/humans = list()
	///List of all non-humans trackable by cameras, split so humans take priority.
	VAR_PRIVATE/static/list/others = list()

/datum/trackable/New(atom/source)
	. = ..()
	tracking_holder = source
	RegisterSignal(tracking_holder, COMSIG_MOB_RESET_PERSPECTIVE, PROC_REF(perspective_reset))

/datum/trackable/Destroy(force)
	tracking_holder = null
	tracked_mob = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

///Generates a list of trackable people by name, returning a list of Humans + Non-Humans that can be tracked.
/datum/trackable/proc/find_trackable_mobs()
	RETURN_TYPE(/list)

	names.Cut()
	namecounts.Cut()

	humans.Cut()
	others.Cut()

	for(var/mob/living/living_mob as anything in GLOB.mob_living_list)
		if(!living_mob.can_track(usr))
			continue

		var/name = living_mob.name
		while(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		names.Add(name)
		namecounts[name] = 1

		if(ishuman(living_mob))
			humans[name] = WEAKREF(living_mob)
		else
			others[name] = WEAKREF(living_mob)

	var/list/targets = sort_list(humans) + sort_list(others)
	return targets

/// Takes a mob to track, resets our state and begins trying to follow it
/// Best we can at least
/datum/trackable/proc/set_tracked_mob(mob/living/track)
	set_rechecking(FALSE)
	if(tracked_mob)
		UnregisterSignal(tracked_mob, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE))
	if(track && !isliving(track))
		tracked_mob = null
		return
	tracked_mob = track
	if(tracked_mob)
		RegisterSignal(tracked_mob, COMSIG_QDELETING, PROC_REF(target_deleted))
		RegisterSignal(tracked_mob, COMSIG_MOVABLE_MOVED, PROC_REF(target_moved))
		RegisterSignal(tracked_mob, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(glide_size_changed))
		attempt_track()

/datum/trackable/proc/target_deleted(datum/source)
	SIGNAL_HANDLER
	reset_tracking()

/datum/trackable/proc/perspective_reset(atom/source)
	SIGNAL_HANDLER
	reset_tracking()

/datum/trackable/proc/target_moved(datum/source)
	SIGNAL_HANDLER
	if(attempt_track())
		return
	set_rechecking(TRUE)

/// Controls if we're processing to recheck the conditions that prevent tracking or not
/datum/trackable/proc/set_rechecking(should_check)
	if(should_check)
		START_PROCESSING(SSprocessing, src)
		cameraticks = initial(cameraticks)
		rechecking = TRUE
	else
		STOP_PROCESSING(SSprocessing, src)
		rechecking = FALSE

/datum/trackable/process()
	if(!rechecking)
		return PROCESS_KILL

	if(attempt_track())
		set_rechecking(FALSE)
		return

	if(cameraticks < CAMERA_TICK_LIMIT)
		if(!cameraticks)
			to_chat(tracking_holder, span_warning("Target is not near any active cameras. Attempting to reacquire..."))
		cameraticks++
		return

	to_chat(tracking_holder, span_warning("Unable to reacquire, cancelling track..."))
	reset_tracking()

/// Tries to track onto our target mob. Returns true if it succeeds, false otherwise
/datum/trackable/proc/attempt_track()
	if(!tracked_mob)
		reset_tracking()
		return FALSE

	if(!tracked_mob.can_track(tracking_holder))
		return FALSE
	// In case we've been checking
	set_rechecking(FALSE)
	SEND_SIGNAL(src, COMSIG_TRACKABLE_TRACKING_TARGET, tracked_mob)
	return TRUE

/datum/trackable/proc/glide_size_changed(datum/source, new_glide_size)
	SIGNAL_HANDLER
	SEND_SIGNAL(src, COMSIG_TRACKABLE_GLIDE_CHANGED, tracked_mob, new_glide_size)

/**
 * reset_tracking
 *
 * Resets our tracking
 */
/datum/trackable/proc/reset_tracking()
	set_tracked_mob(null)

/**
 * track_input
 *
 * Sets a mob as being tracked, will give a tgui input list to find targets to track.
 * Args:
 *  tracker - The person trying to track, used for feedback messages. This is not the same as tracking_holder
 */
/datum/trackable/proc/track_input(mob/living/tracker)
	if(!tracker || tracker.stat == DEAD)
		return

	var/target_name = tgui_input_list(tracker, "Select a target", "Tracking", find_trackable_mobs())
	if(!target_name || isnull(target_name))
		return
	var/datum/weakref/mob_ref = isnull(humans[target_name]) ? others[target_name] : humans[target_name]
	if(isnull(mob_ref))
		to_chat(tracker, span_notice("Target is not on or near any active cameras. Tracking failed."))
		return
	set_tracked_mob(mob_ref.resolve())

/**
 * track_name
 *
 * Sets a mob as being tracked, will track the passed in target name's target
 * Args:
 *  tracker - The person trying to track, used for feedback messages. This is not the same as tracking_holder
 *  tracked_mob_name - The person being tracked.
 */
/datum/trackable/proc/track_name(mob/living/tracker, tracked_mob_name)
	if(!tracker || tracker.stat == DEAD)
		return

	find_trackable_mobs() //this is in case the tracked mob is newly/no-longer in camera field of view.
	var/datum/weakref/mob_ref = isnull(humans[tracked_mob_name]) ? others[tracked_mob_name] : humans[tracked_mob_name]
	if(isnull(mob_ref))
		to_chat(tracker, span_notice("Target is not on or near any active cameras. Tracking failed."))
		return
	to_chat(tracker, span_notice("Now tracking [tracked_mob_name] on camera."))
	set_tracked_mob(mob_ref.resolve())

/**
 * track_mob
 *
 * Sets a mob as being tracked, will track the passed in target
 * Args:
 *  tracker - The person trying to track, used for feedback messages. This is not the same as tracking_holder
 *  tracked - The person being tracked.
 */
/datum/trackable/proc/track_mob(mob/living/tracker, mob/living/tracked)
	if(!tracker || tracker.stat == DEAD)
		return
	// Need to make sure the tracked mob is in our list
	track_name(tracker, tracked.name)

#undef CAMERA_TICK_LIMIT
