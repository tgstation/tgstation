//We only call a camera static update if we have successfully moved and the camera is present and working
/mob/living/silicon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(old_loc != get_turf(src))
		QUEUE_CAMERA_UPDATE(builtInCamera)
