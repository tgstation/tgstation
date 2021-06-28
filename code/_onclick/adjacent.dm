/*
	Adjacency proc for determining touch range

	This is mostly to determine if a user can enter a square for the purposes of touching something.
	Examples include reaching a square diagonally or reaching something on the other side of a glass window.

	This is calculated by looking for border items, or in the case of clicking diagonally from yourself, dense items.
	This proc will NOT notice if you are trying to attack a window on the other side of a dense object in its turf.  There is a window helper for that.

	Note that in all cases the neighbor is handled simply; this is usually the user's mob, in which case it is up to you
	to check that the mob is not inside of something
*/
/atom/proc/Adjacent(atom/neighbor, atom/target, atom/movable/mover) // basic inheritance, unused
	return

// Not a sane use of the function and (for now) indicative of an error elsewhere
/area/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	CRASH("Call to /area/Adjacent(), unimplemented proc")


/*
	Adjacency (to turf):
	* If you are in the same turf, always true
	* If you are vertically/horizontally adjacent, ensure there are no border objects
	* If you are diagonally adjacent, ensure you can pass through at least one of the mutually adjacent square.
		* Passing through in this case ignores anything with the LETPASSTHROW pass flag, such as tables, racks, and morgue trays.
*/
/turf/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	var/turf/neighbor_turf = get_turf(neighbor)

	if(neighbor_turf == src) //same turf
		return TRUE

	if(get_dist(src, neighbor_turf) > 1 || z != neighbor_turf.z) //too far
		return FALSE

	var/border_dir = get_dir(src, neighbor)
	// Non diagonal case
	if(neighbor_turf.x == x || neighbor_turf.y == y)
		// Check for border blockages
		return can_click_out_through_dir(border_dir, target, mover) && neighbor_turf.can_click_out_through_dir(REVERSE_DIR(border_dir), target, mover)
		//return T0.ClickCross(get_dir(T0, src), TRUE, target, mover) && ClickCross(get_dir(src, T0), TRUE, target, mover)

	// Diagonal case
	var/horizontal_dir = border_dir & (EAST|WEST)
	var/vertical_dir = border_dir & (NORTH|SOUTH)
	var/turf/cardinal_neighbor = get_step(neighbor, vertical_dir)
	// Vertical case.
	if(\
		cardinal_neighbor\
		&& can_click_out_through_dir(vertical_dir, target, mover)\
		&& cardinal_neighbor.can_let_clicks_pass_through_dir(REVERSE_DIR(vertical_dir) | horizontal_dir, target, mover)\
		&& neighbor_turf.can_click_out_through_dir(REVERSE_DIR(horizontal_dir), target, mover)\
		)
		return TRUE
	else // Horizontal case.
		cardinal_neighbor = get_step(neighbor, horizontal_dir)
		if(\
			cardinal_neighbor\
			&& can_click_out_through_dir(horizontal_dir, target, mover)\
			&& cardinal_neighbor.can_let_clicks_pass_through_dir(REVERSE_DIR(horizontal_dir) | vertical_dir, target, mover)\
			&& neighbor_turf.can_click_out_through_dir(REVERSE_DIR(vertical_dir), target, mover)\
			)
			return TRUE
	
	return FALSE


/*
	Adjacency (to anything else):
	* Must be on a turf
*/
/atom/movable/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	if(neighbor == loc)
		return TRUE
	var/turf/T = loc
	if(!istype(T))
		return FALSE
	if(T.Adjacent(neighbor,target = neighbor, mover = src))
		return TRUE
	return FALSE

// This is necessary for storage items not on your person.
/obj/item/Adjacent(atom/neighbor, atom/target, atom/movable/mover, recurse = 1)
	if(neighbor == loc)
		return TRUE
	if(isitem(loc))
		if(recurse > 0)
			for(var/obj/item/item_loc as anything in get_locs())
				if(item_loc.Adjacent(neighbor, target, mover, recurse - 1))
					return TRUE
		return FALSE
	return ..()

/*
	This checks if you there is uninterrupted airspace between that turf and this one.
	This is defined as any dense ON_BORDER_1 object, or any dense object without LETPASSTHROW.
	The border_only flag allows you to not objects (for source and destination squares)
*/
/turf/proc/ClickCross(target_dir, border_only = FALSE, atom/target, atom/movable/mover)
	for(var/obj/blocker in src)
		if(blocker == target || (blocker.pass_flags_self & LETPASSTHROW)) //check if there's a dense object present on the turf
			continue // LETPASSTHROW is used for anything you can click through (or the firedoor special case, see above)

		if(mover)
			if(blocker == mover)
				continue
			if(blocker.CanPass(mover, target_dir))
				continue
		else if(!blocker.density)
			continue

		if(blocker.flags_1 & ON_BORDER_1) // windows are on border, check them first
			if((blocker.dir & target_dir) || ISDIAGONALDIR(blocker.dir)) // full tile windows are just diagonals mechanically
				return FALSE   //O.dir&(O.dir-1) is false for any cardinal direction, but true for diagonal ones
		else if(!border_only) // dense, not on border, cannot pass over
			return FALSE

	return TRUE


/// Checks whether this turf has dense directional blockages on the given direction, taking into account target and mover.
/turf/proc/can_click_out_through_dir(target_dir, atom/target, atom/movable/mover)
	for(var/obj/blocker in src)
		if(blocker == target || (blocker.pass_flags_self & LETPASSTHROW))
			continue // LETPASSTHROW is used for anything you can click through

		if(mover)
			if(blocker == mover)
				continue
			if(blocker.CanPass(mover, target_dir))
				continue
		else if(!blocker.density)
			continue

		if(!(blocker.flags_1 & ON_BORDER_1)) // windows are on border, check them first
			continue
		if((blocker.dir & target_dir) || ISDIAGONALDIR(blocker.dir)) // full tile windows are just diagonals mechanically
			return FALSE

	return TRUE


/// Checks whether this turf has any kind of dense blockers, either full tile or on-border in the given direction, taking into account target and mover.
/turf/proc/can_let_clicks_pass_through_dir(target_dir, atom/target, atom/movable/mover)
	if(density)
		return FALSE
	for(var/obj/blocker in src)
		if(blocker == target || (blocker.pass_flags_self & LETPASSTHROW)) //check if there's a dense object present on the turf
			continue // LETPASSTHROW is used for anything you can click through (or the firedoor special case, see above)

		if(mover)
			if(blocker == mover)
				continue
			if(blocker.CanPass(mover, target_dir))
				continue
		else if(!blocker.density)
			continue

		if(blocker.flags_1 & ON_BORDER_1) // windows are on border, check them first
			if((blocker.dir & target_dir) || ISDIAGONALDIR(blocker.dir)) // full tile windows are just diagonals mechanically
				return FALSE
		else // Dense, not on border, cannot pass over
			return FALSE

	return TRUE


/**
 * Checks whether this turf can be left from the given direction.
 */
/turf/proc/can_move_uncross(border_dir, atom/movable/mover)
	for(var/obj/blocker in src)
		if(blocker == mover)
			continue
		if(!blocker.density || !(blocker.flags_1 & ON_BORDER_1) || !(blocker.dir & border_dir))
			continue
		if(blocker.CanPass(mover, border_dir))
			continue
		return FALSE
	return TRUE


/**
 * Checks whether this turf can be entered by the given mover.
 */
/turf/proc/can_move_cross(border_dir, atom/movable/mover)
	if(density)
		return FALSE
	for(var/atom/movable/blocker as anything in src)
		if(blocker == mover)
			continue
		if(!blocker.density)
			continue
		if(blocker.CanPass(mover, border_dir))
			continue
		return FALSE
	return TRUE


/**
 * Checks whether a hypothetical mover with given pass_flags can enter this turf from the given direction.
 * 
 */
/turf/proc/can_reach_cross(border_dir, pass_flags_check, atom/movable/target)
	if(pass_flags_check & PHASING)
		return TRUE
	if(density)
		return FALSE
	for(var/atom/movable/blocker as anything in src)
		if(blocker == target)
			continue
		if(!blocker.density || blocker.pass_flags_self & pass_flags_check)
			continue
		if(blocker.flags_1 & ON_BORDER_1)
			var/blocker_dir = blocker.dir
			if(!ISDIAGONALDIR(blocker_dir) && !(blocker_dir & border_dir))
				continue
		return FALSE
	return TRUE


/**
 * Checks whether this turf can be left from the given direction by a hypothetical mover with given pass_flags.
 */
/turf/proc/can_reach_uncross(border_dir, pass_flags_check, atom/movable/mover)
	if(pass_flags_check & PHASING)
		return TRUE
	for(var/obj/blocker in src)
		if(blocker == mover)
			continue
		if(!blocker.density || blocker.pass_flags_self & pass_flags_check)
			continue
		if(!(blocker.flags_1 & ON_BORDER_1) || !(blocker.dir & border_dir))
			continue
		return FALSE
	return TRUE

