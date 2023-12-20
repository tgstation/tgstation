/atom/movable
	/**
	 * Current visual angle in degrees
	 * Generally if you want to make an atom rotate visually, you should use this var
	 * and it's setter procs
	 */
	var/visual_angle = 0

/// Adjusts the visual angle of the atom by angle_amount in degrees, based on it's current transform
/atom/movable/proc/adjust_visual_angle(angle_amount, animate_time = 0, animate_loop = 0, animate_easing = LINEAR_EASING, animate_flags = NONE)
	angle_amount = SIMPLIFY_DEGREES(angle_amount)
	if(!angle_amount)
		return
	animate(src, transform = transform.Turn(angle_amount), time = animate_time, loop = animate_loop, easing = animate_easing, flags = animate_flags)
	visual_angle += angle_amount
	visual_angle = SIMPLIFY_DEGREES(visual_angle)

/// Sets the angle of the transform to exactly new_angle in degrees
/atom/movable/proc/set_visual_angle(new_angle = 0)
	if(isnull(new_angle))
		return
	var/difference = SIMPLIFY_DEGREES(new_angle - visual_angle)
	return adjust_visual_angle(difference)
