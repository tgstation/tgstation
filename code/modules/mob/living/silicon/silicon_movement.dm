//We only call a camera static update if we have successfully moved and the camera is present and working
/mob/living/silicon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(builtInCamera?.can_use())
		update_camera_location(old_loc)

/mob/living/silicon/proc/update_camera_location(oldLoc)
	oldLoc = get_turf(oldLoc)
	if(!updating && oldLoc != get_turf(src))
		updating = TRUE
		do_camera_update(oldLoc)

///The static update delay on movement of the camera in a borg we use
#define SILICON_CAMERA_BUFFER 0.5 SECONDS

/**
 * The actual update - also passes our unique update buffer. This makes our static update faster than stationary cameras,
 * helping us to avoid running out of the camera's FoV.
*/
/mob/living/silicon/proc/do_camera_update(oldLoc)
	if(oldLoc != get_turf(src))
		GLOB.cameranet.updatePortableCamera(builtInCamera, SILICON_CAMERA_BUFFER)
	updating = FALSE
#undef SILICON_CAMERA_BUFFER
