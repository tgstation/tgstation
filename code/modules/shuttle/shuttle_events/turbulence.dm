/// Repeat the "buckle in or fall over" event a couple times
/datum/shuttle_event/turbulence
	name = "Turbulence"
	event_probability = 5
	activation_fraction = 0.1
	/// Minimum time to wait between periods of turbulence
	var/minimum_interval = 20 SECONDS
	/// Maximum time to wait between periods of turbulence
	var/maximum_interval = 50 SECONDS
	/// Time until we should shake again
	COOLDOWN_DECLARE(turbulence_cooldown)
	/// How long do we give people to get buckled?
	var/warning_interval = 2 SECONDS

/datum/shuttle_event/turbulence/activate()
	. = ..()
	minor_announce("Please note, we are entering an area of subspace turbulence. For your own safety, \
		please fasten your belts and remain seated until the vehicle comes to a complete stop.",
		title = "Emergency Shuttle", alert = TRUE)
	COOLDOWN_START(src, turbulence_cooldown, rand(5 SECONDS, 20 SECONDS)) // Reduced interval after the announcement

/datum/shuttle_event/turbulence/event_process()
	. = ..()
	if (!.)
		return
	if (!COOLDOWN_FINISHED(src, turbulence_cooldown))
		return
	COOLDOWN_START(src, turbulence_cooldown, rand(minimum_interval, maximum_interval))
	shake()
	addtimer(CALLBACK(src, PROC_REF(knock_down)), warning_interval, TIMER_DELETE_ME)

/// Warn players to get buckled
/datum/shuttle_event/turbulence/proc/shake()
	var/list/mobs = mobs_in_area_type(list(/area/shuttle/escape))
	for(var/mob/living/mob as anything in mobs)
		var/shake_intensity = mob.buckled ? 0.25 : 1
		if(mob.client)
			shake_camera(mob, 3 SECONDS, shake_intensity)

/// Knock them down
/datum/shuttle_event/turbulence/proc/knock_down()
	if (SSshuttle.emergency.mode != SHUTTLE_ESCAPE)
		return // They docked
	var/list/mobs = mobs_in_area_type(list(/area/shuttle/escape)) // Not very efficient but check again in case someone was outdoors
	for(var/mob/living/mob as anything in mobs)
		if(mob.buckled)
			continue
		mob.Paralyze(3 SECONDS, ignore_canstun = TRUE)
