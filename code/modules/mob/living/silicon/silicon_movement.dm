/mob/living/silicon/Moved(oldLoc, dir)
	. = ..()
	update_camera_location(oldLoc)

/mob/living/silicon/forceMove(atom/destination)
	. = ..()
	update_camera_location(destination)

/mob/living/silicon/proc/do_camera_update(oldLoc)
	if(!QDELETED(builtInCamera) && oldLoc != get_turf(src))
		GLOB.cameranet.updatePortableCamera(builtInCamera)
	updating = FALSE

#define SILICON_CAMERA_BUFFER 10
/mob/living/silicon/proc/update_camera_location(oldLoc)
	oldLoc = get_turf(oldLoc)
	if(!QDELETED(builtInCamera) && !updating && oldLoc != get_turf(src))
		updating = TRUE
		addtimer(CALLBACK(src, .proc/do_camera_update, oldLoc), SILICON_CAMERA_BUFFER)
#undef SILICON_CAMERA_BUFFER
