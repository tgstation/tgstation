/**
  * Any unsorted global procs that help when locating turfs,  via
  * casting rays out in specified directions etc
  */

/**
  * Returns the turf offset from a given atom by the given dx and dy
  * parameters
  *
  * This proc is bound to the map edges so will not overrun them
  *
  * Arguments:
  * * atom/A the atom to calculate the offset from (the source)
  * * dx, how many steps on the map grid to go in the x direction
  * * dy, how many steps on the map grid to go in the y direction
  */
/proc/get_offset_target_turf(atom/A, dx, dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

/**
  * Get turfs on the edge of a bounding box
  *
  * Gets the turfs on the edge of a bounding box of
  * given x and y height/width that surround the passed
  * in source atom, uses [proc/get_offset_target_turf]
  * internally so will be bounded by map edges
  *
  * Arguments:
  * * atom/A the atom to place the box around
  * * radius_x radius of the box in the x dimension
  * * radius_y the radius of the box in the y dimension
  */
/proc/get_bounding_turfs(atom/A, radius_x, radius_y)
	start_x = A.x - radius_x
	end_x = A.x + radius_x
	start_y = A.y - radius_y
	end_y = A.y + radius_y
	var/list/turfs = list()

	//Go along the y axis from start x
	for(var/y = start_y; y <= end_y; y++)
		turfs |= get_offset_target_turf(A, start_x, y)

	//Go along the y axis from end x
	for(var/y = start_y; y <= end_y; y++)
		turfs |= get_offset_target_turf(A, end_x, y)

	// Go along the x axis from start y
	for(var/x = start_x; x <= end_x; x++)
		turfs |= get_offset_target_turf(A, x, start_y)

	// Go along the x axis from end y
	for(var/x = start_x; x <= end_x; x++)
		turfs |= get_offset_target_turf(A, x, end_y)

	return turfs

/**
  * Get ranged target turf, but with direct targets as opposed to directions
  *
  * Starts at atom A and gets the exact angle between A and target
  * Moves from A with that angle, Range amount of times, until it stops, bound to map size
  * Arguments:
  * * A - Initial Firer / Position
  * * target - Target to aim towards
  * * range - Distance of returned target turf from A
  * * offset - Angle offset, 180 input would make the returned target turf be in the opposite direction
  */
/proc/get_ranged_target_turf_direct(atom/A, atom/target, range, offset)
	var/angle = ATAN2(target.x - A.x, target.y - A.y)
	if(offset)
		angle += offset
	var/turf/T = get_turf(A)
	for(var/i in 1 to range)
		var/turf/check = locate(A.x + cos(angle) * i, A.y + sin(angle) * i, A.z)
		if(!check)
			break
		T = check

	return T

/**
  * Returns the turf offset from A in the given direction at the given range
  *
  * Result is bounded to the map size and the range used is non pythagorean
  *
  * Arguments:
  * * atom/A the source of the ray
  * * direction The direction the ray should go in
  * * range The max rang ethe ray should travel
  */
/proc/get_ranged_target_turf(atom/A, direction, range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	else if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	else if(direction & WEST) //if you have both EAST and WEST in the provided direction, then you're gonna have issues
		x = max(1, x - range)

	return locate(x,y,A.z)

/**
  * Return the turf located at the edge of the map from this atom in the specified direction
  *
  * This is used for the mass driver, see [/proc/get_ranged_target_turf] for a version that stops after a given travel distance
  *
  * Arguments:
  * * atom/A the source of the ray
  * * direction the direction the ray should travel in
  */
/proc/get_edge_target_turf(atom/A, direction)
	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH|EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = world.maxy
	else if(direction & SOUTH) //you should not have both NORTH and SOUTH in the provided direction
		y = 1
	if(direction & EAST)
		x = world.maxx
	else if(direction & WEST)
		x = 1
	if(direction in GLOB.diagonals) //let's make sure it's accurately-placed for diagonals
		var/lowest_distance_to_map_edge = min(abs(x - A.x), abs(y - A.y))
		return get_ranged_target_turf(A, direction, lowest_distance_to_map_edge)
	return locate(x,y,A.z)

/**
  * Get all the turfs in a line between two atoms
  *
  * Uses the Bresenham line drawing algorithim, with some optimisation for speed
  *
  * Arguments:
  * * atom/M the source atom
  * * atom/N the atom the ray should head for
  */
/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs = abs(dx)//Absolute value of x distance
	var/dyabs = abs(dy)
	var/sdx = SIGN(dx)	//Sign of x distance (+ or -)
	var/sdy = SIGN(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line


//Returns location. Returns null if no location was found.
/**
  * Calculate a teleport step in the direction a mob is facing with a given distance
  *
  * This also has allowances for "errors" to occur that offset the target turf by a box bound
  *
  * Arguments:
  * * turf/location the start of the teleport
  * * mob/target the mob being teleported
  * * density should the proc take into account dense things in the way
  * * errorx how much the target should be off by on the x dimension
  * * errory how much the target should be off by on the y dimension
  * * eoffsetx how much offset from the target turf on the x axis the edge of the error box should be (can be negative)
  * * eoffsety how much offset from the target turf on the y axis the edge of the error box should be (can be negative)
  */
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = FALSE, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are separate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx,location.y+diry,location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset),(destination.y+yoffset),location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror,center.y+b1yerror,location.z), locate(center.x+b2xerror,center.y+b2yerror,location.z) ))
				if(density&&T.density)
					continue//If density was specified.
				if(T.x>world.maxx || T.x<1)
					continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)
					continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else
				return

		else//Same deal here.
			if(density&&destination.density)
				return
			if(destination.x>world.maxx || destination.x<1)
				return
			if(destination.y>world.maxy || destination.y<1)
				return
	else
		return

	return destination

/**
  * Get the cardinal direction between to atoms
  *
  * Will get the most accurate cardinal dir
  *
  * Arguments:
  * * atom/A the first atom
  * * atom/B the second atom
  */
/proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

/*
 * Gets the turf this atom's *ICON* appears to inhabit
 *
 * It takes into account:
 * * Pixel_x/y
 * * Matrix x/y
 *
 * NOTE: if your atom has non-standard bounds then this proc
 * will handle it, but:
 * if the bounds are even, then there are an even amount of "middle" *& * turfs, the one to the EAST, NORTH, or BOTH is picked
 * (this may seem bad, but you're atleast as close to the center of the * atom as possible, better than byond's default loc being all the way * off)
 *
 * if the bounds are odd, the true middle turf of the atom is returned
 *
 * Arguments:
 * * atom/AM the atom to find the pixel turf for
 */
/proc/get_turf_pixel(atom/AM)
	if(!istype(AM))
		return

	//Find AM's matrix so we can use it's X/Y pixel shifts
	var/matrix/M = matrix(AM.transform)

	var/pixel_x_offset = AM.pixel_x + M.get_x_shift()
	var/pixel_y_offset = AM.pixel_y + M.get_y_shift()

	//Irregular objects
	var/icon/AMicon = icon(AM.icon, AM.icon_state)
	var/AMiconheight = AMicon.Height()
	var/AMiconwidth = AMicon.Width()
	if(AMiconheight != world.icon_size || AMiconwidth != world.icon_size)
		pixel_x_offset += ((AMiconwidth/world.icon_size)-1)*(world.icon_size*0.5)
		pixel_y_offset += ((AMiconheight/world.icon_size)-1)*(world.icon_size*0.5)

	//DY and DX
	var/rough_x = round(round(pixel_x_offset,world.icon_size)/world.icon_size)
	var/rough_y = round(round(pixel_y_offset,world.icon_size)/world.icon_size)

	//Find coordinates
	var/turf/T = get_turf(AM) //use AM's turfs, as it's coords are the same as AM's AND AM's coords are lost if it is inside another atom
	if(!T)
		return null
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

/**
  * Calculates the distance between two atoms in pixels
  *
  * Arguments:
  * * atom/A the source atom
  * * atom/B the target atom
  * * centered - count from turf edge to edge, defaults to true
  */
/proc/getPixelDistance(atom/A, atom/B, centered = TRUE)
	if(!istype(A)||!istype(B))
		return 0
	. = bounds_dist(A, B) + sqrt((((A.pixel_x+B.pixel_x)**2) + ((A.pixel_y+B.pixel_y)**2)))
	if(centered)
		. += wo

/**
  * Convert a screen loc text entry to a turf location
  *
  * Given a turf the client is on and the client, calculate a turf that * the user has clicked on from the screenloc of the mouse param
  * appears unused at this time.
  *
  * Arguments:
  * * text - the mouse parameters
  * * turf/origin where the clicking user is located
  * * client/C the client that did the click
  */
/proc/screen_loc2turf(text, turf/origin, client/C)
	if(!text)
		return null
	var/tZ = splittext(text, ",")
	var/tX = splittext(tZ[1], "-")
	var/tY = text2num(tX[2])
	tX = splittext(tZ[2], "-")
	tX = text2num(tX[2])
	tZ = origin.z
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = clamp(origin.x + round(actual_view[1] / 2) - tX, 1, world.maxx)
	tY = clamp(origin.y + round(actual_view[2] / 2) - tY, 1, world.maxy)
	return locate(tX, tY, tZ)

/**
  * Return TRUE if an atom faces another atom
  *
  * Compares the source atoms dir, the clockwise dir of A and the anticlockwise dir of the dir returned by get_dir(B,A), if one of them is a match, then A is facing B
  *
  * Arguments:
  * * atom/A the source atom
  * * atom/B the target atom
  */
/proc/is_A_facing_B(atom/A,atom/B)
	if(!istype(A) || !istype(B))
		return FALSE
	if(isliving(A))
		var/mob/living/LA = A
		if(!(LA.mobility_flags & MOBILITY_STAND))
			return FALSE
	var/goal_dir = get_dir(A,B)
	var/clockwise_A_dir = turn(A.dir, -45)
	var/anticlockwise_A_dir = turn(A.dir, 45)

	if(A.dir == goal_dir || clockwise_A_dir == goal_dir || anticlockwise_A_dir == goal_dir)
		return TRUE
	return FALSE

//ultra range (no limitations on distance, faster than range for distances > 8); including areas drastically decreases performance
/**
  * A range proc useful in some circumstances
  *
  * Has no limitations on distance, is faster than range for distances > 8 (2020 not proven by any data, but is used widely in codebase), including areas drastically decreases performance
  *
  * Arguments:
  * * dist the distance of the range call
  * * atom/center where the "range" should come from
  * * orange should this mimic the orange builtin
  * * areas should this include areas
  */
/proc/urange(dist=0, atom/center=usr, orange=0, areas=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/V in turfs)
		var/turf/T = V
		. += T
		. += T.contents
		if(areas)
			. |= T.loc

/**
  * Spiral range
  *
  * Like range, but with no limitations on the distance and returns
  * atoms in the order found when spiralling out from the center
  *
  * Arguments:
  * * dist the distance to range check
  * * center the location to start from
  * * orange should this act like the orange builtin
  */
/proc/spiral_range(dist=0, center=usr, orange=0)
	var/list/L = list()
	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	if(!orange)
		L += t_center
		L += t_center.contents

	if(!dist)
		return L


	var/turf/T
	var/y
	var/x
	var/c_dist = 1


	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents
		c_dist++

	return L

//similar function to RANGE_TURFS(), but will search spiralling outwards from the center (like the above, but only turfs)

/**
  * Spiral range for turfs
  *
  * Like spiral_range, but returns only
  * turfs
  *
  * Arguments:
  * * dist the distance to range check
  * * center the location to start from
  * * orange should this act like the orange builtin
  * * outlist pre seed the returned turfs with an outside list
  * * tick_checked should this proc yield if there is no more time left in the tick
  */
/proc/spiral_range_turfs(dist=0, center=usr, orange=0, list/outlist = list(), tick_checked)
	outlist.Cut()
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/L = outlist
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++
		if(tick_checked)
			CHECK_TICK

	return L

