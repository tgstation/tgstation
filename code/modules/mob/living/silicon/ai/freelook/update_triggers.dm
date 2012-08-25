//UPDATE TRIGGERS, when the chunk (and the surrounding chunks) should update.

// TURFS

/turf
	var/image/obscured

/turf/proc/visibilityChanged()
	cameranet.updateVisibility(src)

/atom/proc/move_camera_by_click()
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.client.eye == AI.eyeobj)
			AI.eyeobj.setLoc(src)

/turf/simulated/Del()
	visibilityChanged()
	..()

/turf/simulated/New()
	..()
	visibilityChanged()

// STRUCTURES

/obj/structure/Del()
	cameranet.updateVisibility(src)
	..()

/obj/structure/New()
	..()
	cameranet.updateVisibility(src)

// DOORS

// Simply updates the visibility of the area when it opens/closes/destroyed.
/obj/machinery/door/update_nearby_tiles(need_rebuild)
	. = ..(need_rebuild)
	// Glass door glass = 1
	// don't check then?
	if(!glass)
		cameranet.updateVisibility(src, 0)

// ROBOT MOVEMENT

// Update the portable camera everytime the Robot moves.
// This might be laggy, comment it out if there are problems.

/mob/living/silicon/robot/Move()
	. = ..()
	if(.)
		if(src.camera)
			cameranet.updatePortableCamera(src.camera)

// CAMERA

// An addition to deactivate which removes/adds the camera from the chunk list based on if it works or not.

/obj/machinery/camera/deactivate(user as mob, var/choice = 1)
	..(user, choice)
	if(src.can_use())
		cameranet.addCamera(src)
	else
		src.SetLuminosity(0)
		cameranet.removeCamera(src)

/obj/machinery/camera/New()
	..()
	cameranet.cameras += src
	cameranet.addCamera(src)

/obj/machinery/camera/Del()
	cameranet.cameras -= src
	cameranet.removeCamera(src)
	..()