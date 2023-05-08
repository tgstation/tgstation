///spawned stuff should float by the window and not hit the shuttle
#define SHUTTLE_EVENT_MISS_SHUTTLE 1 << 0
///spawned stuff should hit the shuttle
#define SHUTTLE_EVENT_HIT_SHUTTLE 1 << 1
///we should process with the shuttle subsystem
#define SHUTTLE_EVENT_CLEAR 2

///An event that can run during shuttle flight
/datum/shuttle_event
	///probability of this event to run from 0 to 100
	var/probability

	var/event_flags
	///Track if we're allowed to run, gets turned to TRUE when the activation timer hits
	var/active = FALSE
	///fraction of the escape timer at which we activate, 0 means we start running immediately
	///(so if activation timer is 0.2 and shuttle takes 3 minutes to get going, it will activate in 36 seconds)
	///We only care about the timer from the moment of launch, any speed changed afterwards are not worth dealing with
	var/activation_fraction = 0
	///when do we activate?
	var/activate_at
	///Our reference to the docking port and thus the shuttle
	var/obj/docking_port/port

/datum/shuttle_event/New(obj/docking_port/port, evacuation_duration)
	. = ..()

	src.port = port

	activate_at = world.time + evacuation_duration * activation_fraction

///We got activated
/datum/shuttle_event/proc/activate()
	return

///Process with the SShutle subsystem
/datum/shuttle_event/proc/process()
	. = TRUE

	if(!activate)
		if(world.time < activate_at)
			return
		active = TRUE
		. = activate()
