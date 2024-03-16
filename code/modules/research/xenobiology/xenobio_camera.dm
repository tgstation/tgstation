//Xenobio control console
/mob/camera/ai_eye/remote/xenobio
	visible_icon = TRUE
	icon = 'icons/mob/silicon/cameramob.dmi'
	icon_state = "generic_camera"
	var/allowed_area = null

/mob/camera/ai_eye/remote/xenobio/Initialize(mapload)
	var/area/our_area = get_area(loc)
	allowed_area = our_area.name
	. = ..()

/mob/camera/ai_eye/remote/xenobio/setLoc(turf/destination, force_update = FALSE)
	var/area/new_area = get_area(destination)

	if(new_area && new_area.name == allowed_area || new_area && (new_area.area_flags & XENOBIOLOGY_COMPATIBLE))
		return ..()

/mob/camera/ai_eye/remote/xenobio/can_z_move(direction, turf/start, turf/destination, z_move_flags = NONE, mob/living/rider)
	. = ..()
	if(!.)
		return
	var/area/new_area = get_area(.)
	if(new_area.name != allowed_area && !(new_area.area_flags & XENOBIOLOGY_COMPATIBLE))
		return FALSE

/obj/machinery/computer/camera_advanced/xenobio
	name = "Slime management console"
	desc = "A computer used for remotely handling slimes."
	networks = list("ss13")
	circuit = /obj/item/circuitboard/computer/xenobiology
	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/camera/ai_eye/remote/xenobio(get_turf(src))
	eyeobj.origin = src
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/silicon/cameramob.dmi'
	eyeobj.icon_state = "generic_camera"

/*
Boilerplate check for a valid area to perform a camera action in.
Checks if the AI eye is on a valid turf and then checks if the target turf is xenobiology compatible
Due to keyboard shortcuts, the second one is not necessarily the remote eye's location.
*/
/obj/machinery/computer/camera_advanced/xenobio/proc/validate_area(mob/living/user, mob/camera/ai_eye/remote/xenobio/remote_eye, turf/open/target_turf)
	if(!GLOB.cameranet.checkTurfVis(remote_eye.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return FALSE

	var/area/turfarea = get_area(target_turf)
	if(turfarea.name != remote_eye.allowed_area && !(turfarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		to_chat(user, span_warning("Invalid area. Cannot proceed."))
		return FALSE

	return TRUE
