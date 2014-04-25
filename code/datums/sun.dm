#define SOLAR_UPDATE_TIME 600 //duration between two updates of the whole sun/solars positions

/datum/sun
	var/angle
	var/dx
	var/dy
	var/rate
	var/list/solars			// for debugging purposes, references solars_list at the constructor
	var/solar_next_update	// last time the sun position was checked and adjusted

/datum/sun/New()

	solars = solars_list
	rate = rand(50,200)/100			// 50% - 200% of standard rotation
	if(prob(50))					// same chance to rotate clockwise than counter-clockwise
		rate = -rate
	solar_next_update = world.time	// init the timer
	angle = rand (0,360)			// the station position to the sun is randomised at round start

// calculate the sun's position given the time of day
// at the standard rate (100%) the angle is increase/decreased by 6 degrees every minute.
// a full rotation thus take a game hour in that case
/datum/sun/proc/calc_position()

	if(world.time < solar_next_update) //if less than 60 game secondes have passed, do nothing
		return;

	angle = (360 + angle + rate * 6) % 360	 // increase/decrease the angle to the sun, adjusted by the rate

	solar_next_update += SOLAR_UPDATE_TIME // since we updated the angle, set the proper time for the next loop

	// now calculate and cache the (dx,dy) increments for line drawing

	var/s = sin(angle)
	var/c = cos(angle)

	// Either "abs(s) < abs(c)" or "abs(s) >= abs(c)"
	// In both cases, the greater is greater than 0, so, no "if 0" check is needed for the divisions

	if( abs(s) < abs(c))

		dx = s / abs(c)
		dy = c / abs(c)

	else
		dx = s/abs(s)
		dy = c / abs(s)


	for(var/obj/machinery/power/M in solars_list)

		if(!M.powernet)
			solars_list.Remove(M)
			continue

		// Solar Tracker
		if(istype(M, /obj/machinery/power/tracker))
			var/obj/machinery/power/tracker/T = M
			T.set_angle(angle)

		// Solar Control
		else if(istype(M, /obj/machinery/power/solar_control))
			var/obj/machinery/power/solar_control/C = M
			if(C.track == 1) //if manual tracking...
				C.tracker_update() //...update the position (not passing an angle, it is handled internally for manual tracking)

		// Solar Panel
		else if(istype(M, /obj/machinery/power/solar))
			var/obj/machinery/power/solar/S = M
			if(S.control)
				occlusion(S)


// for a solar panel, trace towards sun to see if we're in shadow
/datum/sun/proc/occlusion(var/obj/machinery/power/solar/S)

	var/ax = S.x		// start at the solar panel
	var/ay = S.y
	var/turf/T = null

	for(var/i = 1 to 20)		// 20 steps is enough
		ax += dx	// do step
		ay += dy

		T = locate( round(ax,0.5),round(ay,0.5),S.z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)		// not obscured if we reach the edge
			break

		if(T.density)			// if we hit a solid turf, panel is obscured
			S.obscured = 1
			return

	S.obscured = 0		// if hit the edge or stepped 20 times, not obscured
	S.update_solar_exposure()




