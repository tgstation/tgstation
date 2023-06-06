
/// Called whenever the mob is to be resized or when lying/standing up for carbons.
/mob/living/update_transform(resize = RESIZE_DEFAULT_SIZE)
	perform_update_transform(resize) // carbon mobs do it differently than silicons and simple animals.
	SEND_SIGNAL(src, COMSIG_LIVING_POST_UPDATE_TRANSFORM) // ...and we want the signal to be sent last.

/mob/living/proc/perform_update_transform(resize = RESIZE_DEFAULT_SIZE)
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/changed = FALSE

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		ntransform.Scale(resize)
		//Update final_pixel_y so our mob doesn't go out of the southern bounds of the tile when standing
		final_pixel_y += (current_size * resize - current_size) * world.icon_size/2
		current_size *= resize

	if(changed)
		animate(src, transform = ntransform, time = 2, pixel_y = final_pixel_y, easing = EASE_IN|EASE_OUT)
