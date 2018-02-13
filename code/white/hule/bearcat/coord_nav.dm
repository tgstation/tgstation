/obj/machinery/computer/camera_advanced/shuttle_docker/coordinate
	jump_action = new /datum/action/innate/camera_jump_coord

/obj/machinery/computer/camera_advanced/shuttle_docker/coordinate/GrantActions(mob/living/user)
	rotate_action.target = user
	rotate_action.Grant(user)
	actions += rotate_action

	place_action.target = user
	place_action.Grant(user)
	actions += place_action

	off_action.target = user
	off_action.Grant(user)
	actions += off_action

	jump_action.target = user
	jump_action.Grant(user)
	actions += jump_action

/datum/action/innate/camera_jump_coord
	name = "Jump to Coordinate"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump_coord/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = remote_eye.origin

	var/targ_x = input("X coordinate","X", null) as num|null
	var/targ_y = input("Y coordinate","Y", null) as num|null
	var/targ_z = input("Z coordinate","Z", null) as num|null

	if(targ_z in console.z_lock)
		remote_eye.x = targ_x
		remote_eye.y = targ_y
		remote_eye.z = targ_z
		playsound(console, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
		C.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
		C.clear_fullscreen("flash", 3)
	else
		to_chat(target, "<span class='notice'>Fuck you, leatherman!</span>")
		playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)