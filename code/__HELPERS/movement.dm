/// PIXEL define for general use with pixel movement(converting turf x and y values and dist values to pixel dist)
#define PIXEL_TILE_SIZE 32

/// Returns the direction from thingA to thingB in degrees
/// EAST is 0 and goes counter clockwise
#define GET_DEG(thingA, thingB) ATAN2(thingB.true_y() - thingA.true_y(), thingB.true_x() - thingA.true_x())

/// Use this instead of get_dir when things can be on the same turf
#define GET_PIXELDIR(thingA, thingB) (get_dir(thingA, thingB) || angle2dir(GET_DEG(thingA, thingB)))

/**
  * Walk for a set amount of time
  *
  * Makes the movable walk in the direction passed as direct
  * until the time defined in until expires
  * Arguments:
  * * thing - movable that will walk
  * * direct - Direction to walk in
  * * lag - Delay in world ticks between movement(from BYOND ref)
  * * speed - Speed to move, in pixels.(from BYOND ref)
  * * until - how long to move before stopping
  */
/proc/walk_for(atom/movable/thing, direct, lag, speed, until)
	set waitfor = FALSE
	walk(thing, direct, lag, speed)
	stoplag(until)
	walk(thing, NONE)

/**
  * Moves the reference at an angle
  *
  * Useful for more precise movements though
  * if you want even more accuracy and handling for rounding
  * use degstepprojectile
  * Arguments:
  * * thing - Movable that will move at an angle
  * * deg - Angle to move in
  * * dist - Distance in pixels to move
  */
/proc/degstep(atom/movable/thing, deg, dist)
	var/x = thing.step_x
	var/y = thing.step_y
	var/turf/place = thing.loc
	x += dist * sin(deg)
	y += dist * cos(deg)
	return thing.Move(place, get_dir(thing.loc, place), x, y)

/**
  * Moves the reference at an angle, more accurate than degstep
  *
  * Useful for the most precise movements like with projectiles
  * compensates for rounding errors, credit to Kaiochao for the logic
  * relevant byond post: http://www.byond.com/forum/post/1544790
  * Arguments:
  * * thing - Movable that will move at an angle
  * * deg - Angle to move in
  * * dist - Distance in pixels to move
  */
/proc/degstepprojectile(atom/movable/thing, deg, dist)
	var/turf/place = thing.loc
	var/rx
	var/ry
	var/x = dist * sin(deg)
	var/y = dist * cos(deg)
	if(x)
		thing.fx += x
		rx = round(thing.fx, 1)
		thing.fx -= rx
	if(y)
		thing.fy += y
		ry = round(thing.fy, 1)
		thing.fy -= ry
	var/ss = thing.step_size
	thing.step_size = max(1, abs(rx), abs(ry))
	. = (rx || ry) ? thing.Move(place, get_dir(thing.loc, place), thing.step_x + rx, thing.step_y + ry) : TRUE
	thing.step_size = ss

/**
  * Returns the closest turf to the movable
  *
  * This proc gets all the turfs that the movable is touching
  * and compares them by their pixel distance to the movable
  * Arguments:
  * * AM - movable that we need to find the closest turf to
  */
/proc/nearest_turf(atom/movable/AM)
	RETURN_TYPE(/turf)
	var/lowest_diff = 0
	var/turf/lowest = get_turf(AM)
	for(var/turf/T in AM.locs)
		var/diff = bounds_dist(AM, T)
		if(diff < lowest_diff)
			lowest_diff = diff
			lowest = T
	return lowest
