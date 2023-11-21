///How many ticks to try to find a target before giving up.
#define CAMERA_TICK_LIMIT 10

/datum/trackable
	///Boolean on whether or not we are currently trying to track something.
	var/tracking = FALSE
	///Reference to the atom that owns us, used for tracking.
	var/atom/tracking_holder

	///If there is a mob currently being tracked, this will be the weakref to it.
	var/datum/weakref/tracked_mob
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
	RegisterSignal(tracking_holder, COMSIG_MOB_RESET_PERSPECTIVE, PROC_REF(cancel_target_tracking))

/datum/trackable/Destroy(force, ...)
	tracking_holder = null
	tracked_mob = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/trackable/process()
	var/mob/living/tracked_target = tracked_mob?.resolve()
	if(!tracked_target || !tracking)
		set_tracking(FALSE)
		return

	if(tracked_target.can_track(tracking_holder))
		cameraticks = initial(cameraticks)
		SEND_SIGNAL(tracking_holder, COMSIG_TRACKABLE_TRACKING_TARGET, tracked_target)
		return

	if(cameraticks < CAMERA_TICK_LIMIT)
		if(!cameraticks)
			to_chat(tracking_holder, span_warning("Target is not near any active cameras. Attempting to reacquire..."))
		cameraticks++
		return

	to_chat(tracking_holder, span_warning("Unable to reacquire, cancelling track..."))
	cameraticks = initial(cameraticks)
	set_tracking(FALSE)

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

///Toggles whether or not we're tracking something. Arg is whether it's on or off.
/datum/trackable/proc/set_tracking(on = FALSE)
	if(on)
		START_PROCESSING(SSprocessing, src)
		tracking = TRUE
	else
		STOP_PROCESSING(SSprocessing, src)
		tracking = FALSE
		tracked_mob = null

///Called by Signals, used to cancel tracking of a target.
/datum/trackable/proc/cancel_target_tracking(atom/source)
	SIGNAL_HANDLER
	set_tracking(FALSE)

/**
 * set_tracked_mob
 *
 * Sets a mob as being tracked, if a target is already provided then it will track that directly,
 * otherwise it will give a tgui input list to find targets to track.
 * Args:
 *  tracker - The person trying to track, used for feedback messages. This is not the same as tracking_holder
 *  tracked_mob_name - (Optional) The person being tracked, to skip the input list.
 */
/datum/trackable/proc/set_tracked_mob(mob/living/tracker, tracked_mob_name)
	if(!tracker || tracker.stat == DEAD)
		return

	if(tracked_mob_name)
		find_trackable_mobs() //this is in case the tracked mob is newly/no-longer in camera field of view.
		tracked_mob = isnull(humans[tracked_mob_name]) ? others[tracked_mob_name] : humans[tracked_mob_name]
		if(isnull(tracked_mob))
			to_chat(tracker, span_notice("Target is not on or near any active cameras. Tracking failed."))
			return
		to_chat(tracker, span_notice("Now tracking [tracked_mob_name] on camera."))
	else
		var/target_name = tgui_input_list(tracker, "Select a target", "Tracking", find_trackable_mobs())
		if(!target_name || isnull(target_name))
			return
		tracked_mob = isnull(humans[target_name]) ? others[target_name] : humans[target_name]

	set_tracking(TRUE)

#undef CAMERA_TICK_LIMIT
