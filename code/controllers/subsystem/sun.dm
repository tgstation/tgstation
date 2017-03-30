var/datum/controller/subsystem/sun/SSsun

/datum/controller/subsystem/sun
	name = "Sun"
	wait = 600
	init_order = 2
	flags = SS_NO_TICK_CHECK|SS_NO_INIT
	var/angle
	var/dx
	var/dy
	var/rate
	var/list/solars	= list()

/datum/controller/subsystem/sun/New()
	NEW_SS_GLOBAL(SSsun)

	angle = rand (0,360)			// the station position to the sun is randomised at round start
	rate = rand(50,200)/100			// 50% - 200% of standard rotation
	if(prob(50))					// same chance to rotate clockwise than counter-clockwise
		rate = -rate

/datum/controller/subsystem/sun/stat_entry(msg)
	..("P:[solars.len]")

/datum/controller/subsystem/sun/fire()
	angle = (360 + angle + rate * 6) % 360	 // increase/decrease the angle to the sun, adjusted by the rate

	// now calculate and cache the (dx,dy) increments for line drawing
	var/s = sin(angle)
	var/c = cos(angle)

	// Either "abs(s) < abs(c)" or "abs(s) >= abs(c)"
	// In both cases, the greater is greater than 0, so, no "if 0" check is needed for the divisions

	if(abs(s) < abs(c))
		dx = s / abs(c)
		dy = c / abs(c)
	else
		dx = s / abs(s)
		dy = c / abs(s)

	//now tell the solar control computers to update their status and linked devices
	for(var/obj/machinery/power/solar_control/SC in solars)
		if(!SC.powernet)
			solars.Remove(SC)
			continue
		SC.update()







