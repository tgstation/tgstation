/**
 * A backwards depth-limited breadth-first-search to see if the target is
 * logically "in" anything adjacent to us.
 */
/atom/movable/proc/has_direct_access_to(atom/ultimate_target, depth = INVENTORY_DEPTH)
	if(!ismovable(ultimate_target))
		return loc == ultimate_target
	var/atom/movable/checking_movable = ultimate_target
	var/list/procesing_locs = checking_movable.get_locs()
	var/list/next_locs = list()
	for(var/i in 1 to depth)
		for(var/atom/checking_loc as anything in procesing_locs) // If it's a turf it has reached the end of the line.
			if(checking_loc == src || checking_loc == loc)
				return TRUE
			if(!ismovable(checking_loc)) // Turfs are the end of the line.
				continue
			checking_movable = checking_loc
			next_locs += checking_movable.get_locs()
		if(!length(next_locs))
			return FALSE
		procesing_locs = next_locs
		next_locs = list()
	return FALSE


/**
 * Whether a click can go through unimpeded.
 * Works inside storages up to the delimited depth for adjacent locations.
 * Works for reach using euclidian distances (cardinal and diagonal moves are not the same)
 */
/atom/movable/proc/can_reach(atom/ultimate_target, depth = INVENTORY_DEPTH, reach = 1)
	if(!isturf(loc) || reach < 1)
		return has_direct_access_to(ultimate_target, depth)

	if(!isturf(ultimate_target) && !isturf(ultimate_target.loc))
		var/checked_direct_access = FALSE // No need to check twice.
		var/atom/movable/movable_target = ultimate_target
		for(var/atom/movable/target_loc as anything in movable_target.get_locs())
			switch(get_dist(src, target_loc))
				if(-1) //Error condition, see the get_dist() reference.
					if(src == target_loc)
						return TRUE
				if(0)
					if(!checked_direct_access)
						if(has_direct_access_to(ultimate_target, depth))
							return TRUE // Same turf or inside source.
						checked_direct_access = TRUE
				if(1)
					if(target_loc.Adjacent(src, depth - 1))
						return TRUE // One turf away.
		return FALSE

	if(reach == 1) // Too close, just check for adjacency.
		if(ismovable(ultimate_target))
			var/atom/movable/movable_target = ultimate_target
			for(var/atom/movable/target_loc as anything in movable_target.get_locs())
				if(target_loc.Adjacent(src))
					return TRUE
			return FALSE
		return ultimate_target.Adjacent(src)

	if(round(GET_DIST_EUCLIDEAN(src, ultimate_target)) > reach)
		return FALSE // Too far away, no need to waste time calculating the path.

	var/turf/source_turf = get_turf(src)
	var/turf/target_turf = get_turf(ultimate_target)
	return source_turf.euclidian_reach(target_turf, reach) == target_turf


/**
 * The ranged version of Adjacent().
 * Uses euclidian distances for diagonal movements.
 * Can be repurposed for usage of other euclidian ranges.
 */
/turf/proc/euclidian_reach(turf/target, reach = 2)
	if(reach < 2)
		CRASH("Use Adjacent() instead of this proc for ranges such as [reach]")
	if(target.z != z) // Multi-z support could be added, but it's not here yet.
		return src // Maybe return an error code instead?
	if(get_dist(src, target) < 2) // Let's not waste time if the distance is so small.
		return Adjacent(target) ? target : src

	var/movement_dir = get_dir(src, target)

	if(!ISDIAGONALDIR(movement_dir)) // Simple case, let's not bother with complex checks.
		return do_cardinal_reach(target, movement_dir, reach)

	var/dir_angle = round(Get_Angle(src, target), 1)

	if(dir_angle % 45 == 0) // Perfectly diagonal. We don't have to check for zero because cardinals were already checked.
		return do_ordinal_reach(target, movement_dir, reach)
	
	return do_sloping_reach(target, movement_dir, reach, dir_angle)


#define CAN_CLICK_THROUGH(source, goal) (source.ClickCross(get_dir(source, goal), TRUE) && goal.ClickCross(get_dir(goal, source), TRUE))


/// Avoid calling this directly unless you also guarantee the safety checks euclidian_reach() does.
/turf/proc/do_cardinal_reach(turf/target, movement_dir, reach)
	var/turf/last_processed_turf = src
	for(var/i in 1 to reach)
		var/turf/next_turf = get_step(last_processed_turf, movement_dir)
		if(!CAN_CLICK_THROUGH(last_processed_turf, next_turf))
			return last_processed_turf
		last_processed_turf = next_turf
	return last_processed_turf


// (sin(45) * 32), rounded.
#define ORDINAL_PIXELS_MOVE 27

/// Avoid calling this directly unless you also guarantee the safety checks euclidian_reach() does.
/turf/proc/do_ordinal_reach(turf/target, movement_dir, reach)
	var/turf/last_processed_turf = src

	var/horizontal_dir = movement_dir & (EAST|WEST)
	var/vertical_dir = movement_dir & (NORTH|SOUTH)

	// If we move at multiples of 45 degree angles we can move through either cardinal neighbor to ge to the diagonal one.
	// However, if one cardinal is blocked we should remember it, to avoid zig-zag movement.
	var/cardinal_blocked = NONE
	
	var/pixels_travelled = 32 // We start at the edge of the turf.
	for(var/i in 1 to reach)
		pixels_travelled += ORDINAL_PIXELS_MOVE
		if(pixels_travelled < 33)
			continue // Didn't manage to change turf.
		var/turf/next_turf = get_step(last_processed_turf, movement_dir)
		var/valid_routes = 0
		if(!(cardinal_blocked & horizontal_dir))
			var/turf/horizontal_step = get_step(last_processed_turf, horizontal_dir)
			if(CAN_CLICK_THROUGH(last_processed_turf, horizontal_step) && CAN_CLICK_THROUGH(horizontal_step, next_turf))
				valid_routes++
			else
				cardinal_blocked |= horizontal_dir
		if(!(cardinal_blocked & vertical_dir))
			var/turf/vertical_step = get_step(last_processed_turf, vertical_dir)
			if(CAN_CLICK_THROUGH(last_processed_turf, vertical_step) && CAN_CLICK_THROUGH(vertical_step, next_turf))
				valid_routes++
			else
				cardinal_blocked |= vertical_dir
		if(valid_routes == 0)
			return last_processed_turf // Blocked!
		if(next_turf == target)
			return next_turf // Hit!
		last_processed_turf = next_turf
		pixels_travelled %= 32

	return last_processed_turf // Ran out of breath in the process!
#undef ORDINAL_PIXELS_MOVE


/// Avoid calling this directly unless you also guarantee the safety checks euclidian_reach() does.
/turf/proc/do_sloping_reach(turf/target, movement_dir, reach, dir_angle)
	// We'll simulate movement as if it was to the NE, with increasing x and y values, for simplicity.
	// For this we'll need to perform some conversions.
	var/left_dir
	var/right_dir
	var/x_offset
	var/y_offset
	switch(movement_dir)
		if(NORTHEAST)
			x_offset = round(sin(dir_angle), 0.01)
			y_offset = round(cos(dir_angle), 0.01)
			left_dir = NORTH
			right_dir = EAST
		if(SOUTHEAST)
			x_offset = round(-cos(dir_angle), 0.01)
			y_offset = round(sin(dir_angle), 0.01)
			left_dir = EAST
			right_dir = SOUTH
		if(SOUTHWEST)
			x_offset = round(-sin(dir_angle), 0.01)
			y_offset = round(-cos(dir_angle), 0.01)
			left_dir = SOUTH
			right_dir = WEST
		if(NORTHWEST)
			x_offset = round(cos(dir_angle), 0.01)
			y_offset = round(-sin(dir_angle), 0.01)
			left_dir = WEST
			right_dir = NORTH
		else
			CRASH("do_sloping_reach() called on cardinal dir: [movement_dir]")

	var/x_pixel_step = 32 * x_offset
	var/y_pixel_step = 32 * y_offset

	/**
	 * We start where the line between the center of our tile and that of the target touches the edge.
	 * Think of the first quadrant of a circle inscribed on a square.
	 * As we travel through the circle we project a shadow on the square.
	 * We travel from 0 to 90 degrees (from coordinate 17 to 32).
	 * At 45 degrees and beyond the shadow is already at its maximum value in the square, reaching and staying at coordinate 32.
	 * We could use `min(15, tan((dir_angle % 90)) * 15)` and `min(15, tan(90 - (dir_angle % 90)) * 15)`, but this is simpler.
	 **/
	// Sine and/or cosine of 45 degrees:
	#define SIN_COS_45 0.70710678118
	var/x_pixels_travelled = 17 + min(round(x_offset * 15 / SIN_COS_45, 1), 15)
	var/y_pixels_travelled = 17 + min(round(y_offset * 15 / SIN_COS_45, 1), 15)
	#undef SIN_COS_45

	var/turf/last_processed_turf = src

	for(var/i in 1 to reach)
		x_pixels_travelled += x_pixel_step
		y_pixels_travelled += y_pixel_step
		var/first_dir
		var/second_dir
		if(x_pixels_travelled < 33)
			if(y_pixels_travelled < 33)
				continue // Didn't manage to change turf.
			first_dir = left_dir
		else if(y_pixels_travelled < 33)
			first_dir = right_dir
		else if(x_pixels_travelled < y_pixels_travelled)
			first_dir = left_dir
			second_dir = right_dir
		else
			first_dir = right_dir
			second_dir = left_dir
		var/turf/crossing = get_step(last_processed_turf, first_dir)
		if(!CAN_CLICK_THROUGH(last_processed_turf, crossing))
			return last_processed_turf // Blocked!
		if(crossing == target)
			return crossing // Hit!
		last_processed_turf = crossing
		if(second_dir)
			crossing = get_step(last_processed_turf, second_dir)
			if(!CAN_CLICK_THROUGH(last_processed_turf, crossing))
				return last_processed_turf // Blocked!
			if(crossing == target)
				return crossing // Hit!
			last_processed_turf = crossing
	
	return last_processed_turf // Ran out of breath in the process!


#undef CAN_CLICK_THROUGH
