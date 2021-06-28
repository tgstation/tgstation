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
					if(target_loc.Adjacent(src, ultimate_target, src, depth - 1))
						return TRUE // One turf away.
		return FALSE

	if(reach == 1) // Too close, just check for adjacency.
		if(ismovable(ultimate_target))
			var/atom/movable/movable_target = ultimate_target
			for(var/atom/movable/target_loc as anything in movable_target.get_locs())
				if(target_loc.Adjacent(src, ultimate_target, src))
					return TRUE
			return FALSE
		return ultimate_target.Adjacent(src)

	var/turf/target_turf
	var/target_distance
	if(isturf(ultimate_target))
		if(ultimate_target.z != z)
			return FALSE
		target_turf = ultimate_target
		target_distance = round(GET_DIST_EUCLIDEAN(src, target_turf))
	else // Prior checks guarantee the target's loc is a turf.
		var/atom/movable/movable_target = ultimate_target
		target_turf = movable_target.loc
		for(var/turf/turf_loc as anything in movable_target.locs)
			if(turf_loc.z != z)
				continue
			var/checking_distance = round(GET_DIST_EUCLIDEAN(src, turf_loc))
			if(target_turf && checking_distance >= target_distance)
				continue
			target_turf = turf_loc
			target_distance = checking_distance

	if(!target_turf || target_distance > reach)
		return FALSE // Too far away, no need to waste time calculating the path.

	return euclidian_reach(target_turf, reach, REACH_CLICK) == target_turf


/**
 * The ranged version of Adjacent().
 * Uses euclidian distances for diagonal movements.
 * Can be repurposed for usage of other euclidian ranges.
 * Returns the last reachable turf encountered.
 */
/atom/proc/euclidian_reach(atom/target, reach = 2, reach_type = REACH_CLICK)
	if(reach < 2)
		CRASH("Use Adjacent() instead of this proc for ranges such as [reach]")
	var/turf/source_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if(source_turf.z != target_turf.z) // Multi-z support could be added, but it's not here yet.
		return get_turf(src) // Maybe return an error code instead?
	if(get_dist(source_turf, target_turf) < 2) // Let's not waste time if the distance is so small.
		return Adjacent(target_turf) ? target_turf : source_turf

	var/movement_dir = get_dir(source_turf, target_turf)

	if(!ISDIAGONALDIR(movement_dir)) // Simple case, let's not bother with complex checks.
		return do_cardinal_reach(target, movement_dir, reach, reach_type)

	var/dir_angle = round(Get_Angle(source_turf, target_turf), 1)

	if(dir_angle % 45 == 0) // Perfectly diagonal. We don't have to check for zero because cardinals were already checked.
		return do_ordinal_reach(target, movement_dir, reach, reach_type)
	
	return do_sloping_reach(target, movement_dir, reach, reach_type, dir_angle)

/area/euclidian_reach(atom/target, reach = 2, reach_type = REACH_CLICK)
	CRASH("Areas can't reach. euclidian_reach() called with area as source")

/turf/euclidian_reach(atom/target, reach = 2, reach_type = REACH_CLICK)
	switch(reach_type)
		if(REACH_CLICK)
			return ..()
		else
			CRASH("euclidian_reach() called for turf with reach_type value as [reach_type]")


#define CAN_CLICK_FROM(turf_source, target_dir, target, mover) (turf_source.can_click_out_through_dir(target_dir, target, mover))
#define CAN_CLICK_THROUGH(turf_target, source_dir, target, mover) (turf_target.can_let_clicks_pass_through_dir(source_dir, target, mover))
#define CAN_MOVE_FROM(turf_source, target_dir, mover) (turf_source.can_move_uncross(target_dir, mover))
#define CAN_MOVE_INTO(turf_target, source_dir, mover) (turf_target.can_move_cross(source_dir, mover))
#define CAN_ATTACK_FROM(turf_target, source_dir, mover) (turf_target.can_reach_uncross(source_dir, PASSTABLE, mover))
#define CAN_ATTACK_THROUGH(turf_target, source_dir, target) (turf_target.can_reach_cross(source_dir, PASSTABLE, target))
/**
 * This define is to avoid the extra overhead from having to pass callbacks as arguments and invoke them.
 * REACH_CLICK will just check for the ability to click through every step of the way.
 * REACH_MOVE will check for the ability to move, and assume the source is not an /obj. Else it should add checks to avoid it potentially blocking itself.
 * REACH_ATTACK will check for the ability to move each step of the way until the last step, where it will check for the ability to click.
 */
#define REACH_CHECK(return_var, reach_type, turf_source, turf_target, source_dir, target_dir, target, mover, ultimate_target_turf)\
	do {\
		switch(reach_type) {\
			if (REACH_CLICK) {\
				if(ultimate_target_turf == turf_target) {\
					return_var = (CAN_CLICK_FROM(turf_source, target_dir, target, mover) && CAN_CLICK_FROM(turf_target, source_dir, target, mover));\
				} else {\
					return_var = (CAN_CLICK_FROM(turf_source, target_dir, target, mover) && CAN_CLICK_THROUGH(turf_target, source_dir, target, mover));\
				};\
			}\
			if (REACH_MOVE) {\
				return_var = (CAN_MOVE_FROM(turf_source, target_dir, mover) && CAN_MOVE_INTO(turf_target, source_dir, mover));\
			}\
			if (REACH_ATTACK) {\
				if(ultimate_target_turf == turf_target) {\
					return_var = (CAN_ATTACK_FROM(turf_source, target_dir, mover) && CAN_ATTACK_THROUGH(turf_target, source_dir, target));\
				} else {\
					return_var = (CAN_ATTACK_FROM(turf_source, target_dir, mover) && CAN_ATTACK_FROM(turf_target, source_dir, target));\
				};\
			}\
		};\
	} while(FALSE)


/// Avoid calling this directly unless you also guarantee the safety checks euclidian_reach() does.
/atom/proc/do_cardinal_reach(atom/target, movement_dir, reach, reach_type)
	var/turf/last_processed_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	for(var/i in 1 to reach)
		var/turf/next_turf = get_step(last_processed_turf, movement_dir)
		REACH_CHECK(., reach_type, last_processed_turf, next_turf, movement_dir, REVERSE_DIR(movement_dir), target, src, target_turf)
		if(!.)
			return last_processed_turf // Blocked!
		if(next_turf == target_turf)
			return next_turf // Hit!
		last_processed_turf = next_turf
	return last_processed_turf // Ran out of breath in the process!


// (sin(45) * 32), rounded.
#define ORDINAL_PIXELS_MOVE 27

/// Avoid calling this directly unless you also guarantee the safety checks euclidian_reach() does.
/atom/proc/do_ordinal_reach(atom/target, movement_dir, reach, reach_type)
	var/turf/last_processed_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)

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
			REACH_CHECK(., reach_type, last_processed_turf, horizontal_step, horizontal_dir, REVERSE_DIR(horizontal_dir), target, src, target_turf)
			if(.)
				REACH_CHECK(., reach_type, horizontal_step, next_turf, vertical_dir, REVERSE_DIR(vertical_dir), target, src, target_turf)
				if(.)
					valid_routes++
				else
					cardinal_blocked |= horizontal_dir
			else
				cardinal_blocked |= horizontal_dir
		if(!(cardinal_blocked & vertical_dir))
			var/turf/vertical_step = get_step(last_processed_turf, vertical_dir)
			REACH_CHECK(., reach_type, last_processed_turf, vertical_step, vertical_dir, REVERSE_DIR(vertical_dir), target, src, target_turf)
			if(.)
				REACH_CHECK(., reach_type, vertical_step, next_turf, horizontal_dir, REVERSE_DIR(horizontal_dir), target, src, target_turf)
				if(.)
					valid_routes++
				else
					cardinal_blocked |= vertical_dir
			else
				cardinal_blocked |= vertical_dir
		if(valid_routes == 0)
			return last_processed_turf // Blocked!
		if(next_turf == target_turf)
			return next_turf // Hit!
		last_processed_turf = next_turf
		pixels_travelled %= 32

	return last_processed_turf // Ran out of breath in the process!
#undef ORDINAL_PIXELS_MOVE


/// Avoid calling this directly unless you also guarantee the safety checks euclidian_reach() does.
/atom/proc/do_sloping_reach(atom/target, movement_dir, reach, reach_type, dir_angle)
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

	var/turf/last_processed_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)

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
		REACH_CHECK(., reach_type, last_processed_turf, crossing, first_dir, REVERSE_DIR(first_dir), target, src, target_turf)
		if(!.)
			return last_processed_turf // Blocked!
		if(crossing == target_turf)
			return crossing // Hit!
		last_processed_turf = crossing
		if(second_dir)
			crossing = get_step(last_processed_turf, second_dir)
			REACH_CHECK(., reach_type, last_processed_turf, crossing, second_dir, REVERSE_DIR(second_dir), target, src, target_turf)
			if(!.)
				return last_processed_turf // Blocked!
			if(crossing == target_turf)
				return crossing // Hit!
			last_processed_turf = crossing
	
	return last_processed_turf // Ran out of breath in the process!


#undef REACH_CHECK
#undef CAN_ATTACK_THROUGH
#undef CAN_MOVE_INTO
#undef CAN_MOVE_FROM
#undef CAN_CLICK_THROUGH
#undef CAN_CLICK_FROM
