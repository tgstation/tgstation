// all air alarms, vents, sensors, and scrubbers in area are connected via m̶a̶g̶i̶c̶  bluespess
// TODO: Refactor to use NTNet once https://github.com/tgstation/tgstation/pull/53368 is done
/area
	var/datum/airalarm_control/air_control

/area/proc/ensure_air_control(initial_control_type = /datum/airalarm_control)
	if(!air_control)
		air_control = new initial_control_type(src)
