/obj/machinery/power/solar/panel/tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon_state = "tracker"
	var/sun_angle = 0 // sun angle as set by sun datum
	tracker = 1

// called by datum/sun/calc_position() as sun's angle changes
/obj/machinery/power/solar/panel/tracker/proc/set_angle(angle)
	sun_angle = angle

	//Set icon dir to show sun illumination
	dir = turn(NORTH, -angle - 22.5)	//22.5 deg bias ensures, e.g. 67.5-112.5 is EAST

	//Check we can draw power
	if(stat & NOPOWER)
		return

	//Find all solar controls and update them
	//Currently, just update all controllers in world
	// ***TODO: better communication system using network
	for(var/obj/machinery/power/solar/control/C in getPowernetNodes())
		if(get_dist(C, src) < SOLAR_MAX_DIST)
			C.tracker_update(angle)

// make sure we can draw power from the powernet
/obj/machinery/power/solar/panel/tracker/process()
	var/avail = surplus()

	if(avail > 500)
		add_load(500)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

// tracker Electronic
/obj/item/weapon/tracker_electronics
	name = "tracker electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = 2.0