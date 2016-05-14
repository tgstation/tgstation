/turf/space/transit
	var/pushdirection // push things that get caught in the transit tile this direction

/turf/space/transit/New()
	if(loc)
		var/area/A = loc
		A.area_turfs += src
	var/dira=""
	var/i=0
	switch(pushdirection)
		if(SOUTH) // North to south
			dira="ns"
			i=1+(abs((x^2)-y)%15) // Vary widely across X, but just decrement across Y

		if(NORTH) // South to north  I HAVE NO IDEA HOW THIS WORKS I'M SORRY.  -Probe
			dira="ns"
			i=1+(abs((x^2)-y)%15) // Vary widely across X, but just decrement across Y

		if(WEST) // East to west
			dira="ew"
			i=1+(((y^2)+x)%15) // Vary widely across Y, but just increment across X

		if(EAST) // West to east
			dira="ew"
			i=1+(((y^2)-x)%15) // Vary widely across Y, but just increment across X


		/*
		if(NORTH) // South to north (SPRITES DO NOT EXIST!)
			dira="sn"
			i=1+(((x^2)+y)%15) // Vary widely across X, but just increment across Y

		if(EAST) // West to east (SPRITES DO NOT EXIST!)
			dira="we"
			i=1+(abs((y^2)-x)%15) // Vary widely across X, but just increment across Y
		*/

		else
			icon_state="black"
	if(icon_state != "black")
		icon_state = "speedspace_[dira]_[i]"

/turf/space/transit/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 0)
	return ..(N, tell_universe, 1, allow)

//Overwrite because we dont want people building rods in space.
/turf/space/transit/attackby(obj/O as obj, mob/user as mob)
	return

/turf/space/transit/canBuildCatwalk()
	return BUILD_FAILURE

/turf/space/transit/canBuildLattice()
	return BUILD_FAILURE

/turf/space/transit/canBuildPlating()
	return BUILD_SILENT_FAILURE

/turf/space/transit/north // moving to the north

	pushdirection = SOUTH  // south because the space tile is scrolling south
	icon_state="debug-north"

/turf/space/transit/south // moving to the south

	pushdirection = NORTH
	icon_state="debug-south"

/turf/space/transit/east // moving to the east

	pushdirection = WEST
	icon_state="debug-east"

/turf/space/transit/west // moving to the west

	pushdirection = EAST
	icon_state="debug-west"


