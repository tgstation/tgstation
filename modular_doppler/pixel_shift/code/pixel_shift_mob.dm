/// Adds pixel_shift component on call. Default proc does nothing.
/mob/proc/add_pixel_shift_component()
	return

/mob/living/add_pixel_shift_component()
	AddComponent(/datum/component/pixel_shift)
