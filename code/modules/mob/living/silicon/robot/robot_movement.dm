/mob/living/silicon/robot/Moved(oldLoc, dir)
	. = ..()
	update_camera_location(oldLoc)

/mob/living/silicon/robot/forceMove(atom/destination)
	. = ..()
	update_camera_location(destination)

/mob/living/silicon/robot/proc/do_camera_update(oldLoc)
	if(!QDELETED(camera) && oldLoc != get_turf(src))
		GLOB.cameranet.updatePortableCamera(camera)
	updating = FALSE

#define BORG_CAMERA_BUFFER 30
/mob/living/silicon/robot/proc/update_camera_location(oldLoc)
	oldLoc = get_turf(oldLoc)
	if(!QDELETED(camera) && !updating && oldLoc != get_turf(src))
		updating = TRUE
		addtimer(CALLBACK(src, .proc/do_camera_update, oldLoc), BORG_CAMERA_BUFFER)
#undef BORG_CAMERA_BUFFER

/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0)
	if(ionpulse())
		return 1
	return ..()

/mob/living/silicon/robot/movement_delay()
	. = ..()
	. += speed
	. += config.robot_delay

/mob/living/silicon/robot/mob_negates_gravity()
	return magpulse

/mob/living/silicon/robot/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()

/mob/living/silicon/robot/Moved()
	. = ..()
	if(riding_datum)
		riding_datum.on_vehicle_move()
