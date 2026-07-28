/**
 * Called whenever the mob is to be resized or when lying/standing up for carbons.
 * IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
 */
/mob/living/proc/update_transform(resize = RESIZE_DEFAULT_SIZE)
	var/matrix/ntransform = matrix(transform)
	var/current_translate = get_transform_translation_size(current_size)
	var/final_dir = dir
	var/changed = FALSE

	if(lying_angle != lying_prev && rotate_on_lying)
		changed = TRUE
		if(lying_angle && lying_prev == 0)
			if(current_translate)
				ntransform.Translate(0, -current_translate)
			// Standing to lying and facing east or west
			if(dir & (EAST|WEST))
				// ...So you fall on your side, rather than your face or ass
				final_dir = pick(NORTH, SOUTH)
		else
			if(current_translate && !lying_angle && lying_prev != 0)
				ntransform.Translate(current_translate * (lying_prev == 270 ? -1 : 1), 0)
		// Done last, as it can mess with the translation.
		ntransform.TurnTo(lying_prev, lying_angle)

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		var/is_vertical = !lying_angle || !rotate_on_lying
		var/new_translation = get_transform_translation_size(resize * current_size)
		// scaling also affects translation, so we've to undo the old translate beforehand.
		if(is_vertical && current_translate)
			ntransform.Translate(0, -current_translate)

		ntransform.Scale(resize)
		current_size *= resize
		// Update the height of the maptext according to the size of the mob so they don't overlap.
		var/old_maptext_offset = body_maptext_height_offset
		body_maptext_height_offset = initial(maptext_height) * (current_size - 1) * 0.5
		maptext_height += body_maptext_height_offset - old_maptext_offset
		// and update the new translation
		if(is_vertical && new_translation)
			ntransform.Translate(0, new_translation)

	if(!changed) //Nothing has been changed, nothing has to be done.
		return FALSE

	// ensures the floating animation doesn't mess with our animation
	if(HAS_TRAIT(src, TRAIT_MOVE_FLOATING))
		ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, UPDATE_TRANSFORM_TRAIT)
		addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_NO_FLOATING_ANIM, UPDATE_TRANSFORM_TRAIT), 0.3 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	//if true, we want to avoid any animation time, it'll tween and not rotate at all otherwise.
	var/is_opposite_angle = REVERSE_ANGLE(lying_angle) == lying_prev
	var/animate_time = is_opposite_angle ? 0 : UPDATE_TRANSFORM_ANIMATION_TIME
	animate(src, transform = ntransform, time = animate_time, dir = final_dir, easing = SINE_EASING)
	readjust_atom_huds(animate_time)

	SEND_SIGNAL(src, COMSIG_LIVING_POST_UPDATE_TRANSFORM, resize, lying_angle, is_opposite_angle)
	unconscious_appearance?.transform = ntransform
	return TRUE

/mob/living/proc/readjust_atom_huds(animate_time = null)
	for (var/hud_key in hud_list)
		var/image/hud_image = hud_list[hud_key]
		if (istype(hud_image))
			adjust_hud_position(hud_image, animate_time = animate_time)

/// Calculates how far vertically the mob's transform should translate according to its size (1 being "default")
/mob/living/proc/get_transform_translation_size(value)
	return (value - 1) * 16
