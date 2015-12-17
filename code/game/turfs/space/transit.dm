/turf/space/transit
	icon_state = "black"
	dir = SOUTH

/turf/space/transit/horizontal
	dir = WEST

/turf/space/transit/Entered(atom/movable/AM, atom/OldLoc)
	if(!AM)
		return
	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	var/_z = rand(ZLEVEL_SPACEMIN,ZLEVEL_SPACEMAX)	//select a random space zlevel

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
/turf/space/transit/attackby()
	return

/turf/space/transit/New()
	update_icon()
	..()

/turf/space/transit/proc/update_icon()
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
