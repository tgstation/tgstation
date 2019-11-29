SUBSYSTEM_DEF(sun)
	name = "Sun"
	wait = 6 MINUTES
	flags = SS_NO_TICK_CHECK

	var/azimuth = 0 //clockwise, top-down rotation from 0 (north) to 359
	var/elevation = 0 //clockwise, vertical, side-on rotation from 90 (straight up) to -90 (straight down)

	//how much each rotation will rotate in degrees each fire
	var/azimuth_mod = 0
	var/elevation_mod = 0

/datum/controller/subsystem/sun/Initialize(start_timeofday)
	azimuth = rand(0, 359)
	elevation = rand(-90, 90)

	azimuth_mod = round((wait / (1 MINUTES)) * rand(50, 200)/100, 0.01) // 50% - 200% of standard rotation
	elevation_mod = round((wait / (1 MINUTES)) * rand(50, 200)/100, 0.01)
	if(prob(50))
		azimuth_mod *= -1
	if(prob(50))
		elevation_mod *= -1

	return ..()

/datum/controller/subsystem/sun/fire(resumed = FALSE)
	azimuth += azimuth_mod
	elevation += elevation_mod
	azimuth = round(azimuth, 0.01)
	elevation = round(elevation, 0.01)

	if(elevation > 90) //over the north pole
		elevation = 180 - elevation
		elevation_mod *= -1
		azimuth -= 180
	if(elevation < -90) //under the south pole
		elevation = -180 - elevation
		elevation_mod *= -1
		azimuth += 180

	if(azimuth >= 360)
		azimuth -= 360
	if(azimuth < 0)
		azimuth += 360

	complete_movement()

/datum/controller/subsystem/sun/proc/complete_movement()
	SEND_SIGNAL(src, COMSIG_SUN_MOVED, azimuth, elevation)

/datum/controller/subsystem/sun/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, azimuth) || var_name == NAMEOF(src, elevation))
		complete_movement()
