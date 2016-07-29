<<<<<<< HEAD
/turf/open/space/transit
	icon_state = "black"
	dir = SOUTH
	baseturf = /turf/open/space/transit

/turf/open/space/transit/south
	dir = SOUTH

/turf/open/space/transit/north
	dir = NORTH

/turf/open/space/transit/horizontal
	dir = WEST

/turf/open/space/transit/west
	dir = WEST

/turf/open/space/transit/east
	dir = EAST

/turf/open/space/transit/Entered(atom/movable/AM, atom/OldLoc)
	if(!AM)
		return
	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	var/list/possible_transtitons = list()
	var/k = 1
	for(var/a in map_transition_config)
		if(map_transition_config[a] == CROSSLINKED) // Only pick z-levels connected to station space
			possible_transtitons += k
		k++
	var/_z = pick(possible_transtitons)

	//now select coordinates for a border turf
	var/_x
	var/_y
	switch(dir)
		if(SOUTH)
			_x = rand(min,max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min,max)
		if(EAST)
			_x = min
			_y = rand(min,max)
		else
			_x = rand(min,max)
			_y = min

	var/turf/T = locate(_x, _y, _z)
	AM.loc = T
	AM.newtonian_move(dir)




//Overwrite because we dont want people building rods in space.
/turf/open/space/transit/attackby()
	return

/turf/open/space/transit/New()
	update_icon()
	..()

/turf/open/space/transit/update_icon()
	var/p = 9
	var/angle = 0
	var/state = 1
	switch(dir)
		if(NORTH)
			angle = 180
			state = ((-p*x+y) % 15) + 1
			if(state < 1)
				state += 15
		if(EAST)
			angle = 90
			state = ((x+p*y) % 15) + 1
		if(WEST)
			angle = -90
			state = ((x-p*y) % 15) + 1
			if(state < 1)
				state += 15
		else
			state =	((p*x+y) % 15) + 1

	icon_state = "speedspace_ns_[state]"
	transform = turn(matrix(), angle)
=======
/turf/space/transit
	plane = PLANE_TURF
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


>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
