/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	var/mob/camera/aiEye/remote/eyeobj
	var/mob/living/carbon/human/current_user = null
	var/list/networks = list("SS13")
	var/datum/action/innate/camera_off/off_action = new
	var/datum/action/innate/camera_jump/jump_action = new

/obj/machinery/computer/camera_advanced/proc/CreateEye()
	eyeobj = new()
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/carbon/user)
	off_action.target = user
	off_action.Grant(user)
	jump_action.target = user
	jump_action.Grant(user)

/obj/machinery/computer/camera_advanced/check_eye(mob/user)
	if( (stat & (NOPOWER|BROKEN)) || !Adjacent(user) || user.eye_blind || user.incapacitated() )
		user.unset_machine()

/obj/machinery/computer/camera_advanced/Destroy()
	if(current_user)
		current_user.unset_machine()
	if(eyeobj)
		qdel(eyeobj)
	return ..()

/obj/machinery/computer/camera_advanced/on_unset_machine(mob/M)
	if(M == current_user)
		off_action.Activate()

/obj/machinery/computer/camera_advanced/attack_hand(mob/user)
	if(current_user)
		user << "The console is already in use!"
		return
	if(!iscarbon(user))
		return
	if(..())
		return
	var/mob/living/carbon/L = user

	if(!eyeobj)
		CreateEye()

	if(!eyeobj.initialized)
		var/camera_location
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!C.can_use())
				continue
			if(C.network&networks)
				camera_location = get_turf(C)
				break
		if(camera_location)
			eyeobj.initialized = 1
			give_eye_control(L)
			eyeobj.setLoc(camera_location)
		else
			user.unset_machine()
	else
		give_eye_control(L)
		eyeobj.setLoc(eyeobj.loc)



/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	GrantActions(user)
	current_user = user
	eyeobj.eye_user = user
	eyeobj.name = "Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)

/mob/camera/aiEye/remote
	name = "Inactive Camera Eye"
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/mob/living/carbon/human/eye_user = null
	var/obj/machinery/computer/camera_advanced/origin
	var/initialized = 0
	var/visible_icon = 0
	var/image/user_image = null

/mob/camera/aiEye/remote/Destroy()
	eye_user = null
	origin = null
	return ..()

/mob/camera/aiEye/remote/GetViewerClient()
	if(eye_user)
		return eye_user.client
	return null

/mob/camera/aiEye/remote/setLoc(T)
	if(eye_user)
		if(!isturf(eye_user.loc))
			return
		T = get_turf(T)
		loc = T
		cameranet.visibility(src)
		if(visible_icon)
			if(eye_user.client)
				eye_user.client.images -= user_image
				user_image = image(icon,loc,icon_state,FLY_LAYER)
				eye_user.client.images += user_image

/mob/camera/aiEye/remote/relaymove(mob/user,direct)
	var/initial = initial(sprint)
	var/max_sprint = 50

	if(cooldown && cooldown < world.timeofday) // 3 seconds
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(src, direct))
		if(step)
			src.setLoc(step)

	cooldown = world.timeofday + 5
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial

/datum/action/innate/camera_off
	name = "End Camera View"
	button_icon_state = "camera_off"

/datum/action/innate/camera_off/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	remote_eye.origin.current_user = null
	remote_eye.origin.jump_action.Remove(C)
	remote_eye.eye_user = null
	if(C.client)
		C.reset_perspective(null)
		if(remote_eye.visible_icon)
			C.client.images -= remote_eye.user_image
		for(var/datum/camerachunk/chunk in remote_eye.visibleCameraChunks)
			C.client.images -= chunk.obscured
	C.remote_control = null
	C.unset_machine()
	src.Remove(C)
	playsound(remote_eye.origin, 'sound/machines/terminal_off.ogg', 25, 0)

/datum/action/innate/camera_jump
	name = "Jump To Camera"
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin

	var/list/L = list()

	for (var/obj/machinery/camera/cam in cameranet.cameras)
		L.Add(cam)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/netcam in L)
		var/list/tempnetwork = netcam.network&origin.networks
		if (tempnetwork.len)
			T[text("[][]", netcam.c_tag, (netcam.can_use() ? null : " (Deactivated)"))] = netcam


	playsound(origin, 'sound/machines/terminal_prompt.ogg', 25, 0)
	var/camera = input("Choose which camera you want to view", "Cameras") as null|anything in T
	var/obj/machinery/camera/final = T[camera]
	playsound(src, "terminal_type", 25, 0)
	if(final)
		playsound(origin, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
		remote_eye.setLoc(get_turf(final))
		C.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
		C.clear_fullscreen("flash", 3) //Shorter flash than normal since it's an ~~advanced~~ console!
	else
		playsound(origin, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)
