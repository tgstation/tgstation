var/global/datum/sun/sun

/datum/sun
	var/angle
	var/dx
	var/dy
	var/list/solars // For debugging purposes, references solars_list at the constructor.

	// Replacement for var/counter to force the sun to move every X IC minutes.
	// To prevent excess server load the server only updates the sun's sight lines by minute(s).
	// 300 is 30 seconds.
	var/updatePer = 600

	var/nextTime
	var/lastAngle = 0
	var/rotationRate = 1 //A pretty average way of setting up station rotation direction AND absolute speed

/datum/sun/New()

	solars = solars_list
	nextTime = updatePer

	rotationRate = rand(850, 1150) / 1000 //Slight deviation, no more than 15 %, budget orbital stabilization system
	if(prob(50))
		rotationRate = -rotationRate

/*
 * Calculate the sun's position given the time of day.
 */
/datum/sun/proc/calc_position()
	var/time = world.time
	angle = ((rotationRate * time / 100) % 360 + 360) % 360

	if(angle != lastAngle)
		var/obj/machinery/power/solar/panel/tracker/T
		for(T in solars_list)
			if(!T.powernet)
				solars_list.Remove(T)
				continue

			T.set_angle(angle)
		lastAngle = angle

	if(world.time < nextTime)
		return

	nextTime += updatePer

	// Now calculate and cache the (dx,dy) increments for line drawing.
	var/si = sin(angle)
	var/co = cos(angle)

	if(!co)
		dx = 0
		dy = si
	else if (abs(si) < abs(co))
		dx = si / abs(co)
		dy = co / abs(co)
	else
		dx = si / abs(si)
		dy = co / abs(si)

	var/obj/machinery/power/solar/panel/S

	for(S in solars_list)
		if(!S.powernet)
			solars_list.Remove(S)

		if(S.control)
			occlusion(S)

//For a solar panel, trace towards sun to see if we're in shadow.

/datum/sun/proc/occlusion(const/obj/machinery/power/solar/panel/S)
	var/ax = S.x //Start at the solar panel.
	var/ay = S.y
	var/i
	var/turf/T

	for(i = 1 to 256) //No tiles shall stay unchecked. Since the loop stops when it hit level boundaries or opaque blocks, this can't cause too much problems
		ax += dx //Do step
		ay += dy

		T = locate(round(ax, 0.5), round(ay, 0.5), S.z)

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy) // Not obscured if we reach the edge.
			break
		if(T.opacity) //Opaque objects block light.
			S.obscured = 1
			return

	S.obscured = 0 //If hit the edge or stepped 20 times, not obscured.
	S.update_solar_exposure()