//Solar tracker

//Machine that tracks the sun and reports it's direction to the solar controllers
//As long as this is working, solar panels on same powernet will track automatically

/obj/machinery/power/tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon = 'power.dmi'
	icon_state = "tracker"
	anchored = 1
	density = 1
	directwired = 1

	var/sun_angle = 0		// sun angle as set by sun datum


	// called by datum/sun/calc_position() as sun's angle changes
	proc/set_angle(var/angle)
		sun_angle = angle

		//set icon dir to show sun illumination
		dir = turn(NORTH, -angle - 22.5)	// 22.5 deg bias ensures, e.g. 67.5-112.5 is EAST

		// check we can draw power
		if(stat & NOPOWER)
			return

		// find all solar controls and update them
		// currently, just update all controllers in world
		// ***TODO: better communication system using network
		if(powernet)
			for(var/obj/machinery/power/solar_control/C in powernet.nodes)
				C.tracker_update(angle)


	// timed process
	// make sure we can draw power from the powernet
	process()
		var/avail = surplus()

		if(avail > 500)
			add_load(500)
			stat &= ~NOPOWER
		else
			stat |= NOPOWER

	// override power change to do nothing since we don't care about area power
	power_change()
		return