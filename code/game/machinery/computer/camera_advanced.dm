/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	light_color = COLOR_SOFT_RED
	var/list/z_lock = list() // Lock use to these z levels
	var/lock_override = NONE
	var/mob/camera/ai_eye/remote/eyeobj
	var/mob/living/current_user = null
	var/list/networks = list("ss13")
	/// Typepath of the action button we use as "off"
	/// It's a typepath so subtypes can give it fun new names
	var/datum/action/innate/camera_off/off_action
	/// Typepath for jumping
	var/datum/action/innate/camera_jump/jump_action
	/// Typepath of the move up action
	var/datum/action/innate/camera_multiz_up/move_up_action
	/// Typepath of the move down action
	var/datum/action/innate/camera_multiz_down/move_down_action

	/// List of all actions to give to a user when they're well, granted actions
	var/list/actions = list()
	///Should we supress any view changes?
	var/should_supress_view_changes = TRUE

	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_SET_MACHINE | INTERACT_MACHINE_REQUIRES_SIGHT

/obj/machinery/computer/camera_advanced/Initialize(mapload)
	. = ..()
	for(var/i in networks)
		networks -= i
		networks += lowertext(i)
	if(lock_override)
		if(lock_override & CAMERA_LOCK_STATION)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_STATION)
		if(lock_override & CAMERA_LOCK_MINING)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_MINING)
		if(lock_override & CAMERA_LOCK_CENTCOM)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_CENTCOM)

	if(off_action)
		actions += new off_action(src)
	if(jump_action)
		actions += new jump_action(src)
	//Camera action button to move up a Z level
	if(move_up_action)
		actions += new move_up_action(src)
	//Camera action button to move down a Z level	
	if(move_down_action)
		actions += new move_down_action(src)

/obj/machinery/computer/camera_advanced/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	for(var/i in networks)
		networks -= i
		networks += "[port.id]_[i]"

/obj/machinery/computer/camera_advanced/syndie
	icon_keyboard = "syndie_key"
	circuit = /obj/item/circuitboard/computer/advanced_camera

/obj/machinery/computer/camera_advanced/syndie/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	return //For syndie nuke shuttle, to spy for station.

/obj/machinery/computer/camera_advanced/proc/CreateEye()
	eyeobj = new()
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/user)
	for(var/datum/action/to_grant as anything in actions)
		to_grant.Grant(user)

/obj/machinery/proc/remove_eye_control(mob/living/user)
	CRASH("[type] does not implement ai eye handling")

/obj/machinery/computer/camera_advanced/remove_eye_control(mob/living/user)
	if(!user)
		return
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(user)
	for(var/V in eyeobj.visibleCameraChunks)
		var/datum/camerachunk/C = V
		C.remove(eyeobj)
	if(user.client)
		user.reset_perspective(null)
		if(eyeobj.visible_icon && user.client)
			user.client.images -= eyeobj.user_image
		user.client.view_size.unsupress()

	eyeobj.eye_user = null
	user.remote_control = null
	current_user = null
	user.unset_machine()
	playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)

/obj/machinery/computer/camera_advanced/check_eye(mob/user)
	if(!can_use(user) || (issilicon(user) && !user.has_unlimited_silicon_privilege))
		user.unset_machine()

/obj/machinery/computer/camera_advanced/Destroy()
	if(eyeobj)
		QDEL_NULL(eyeobj)
	QDEL_LIST(actions)
	current_user = null
	return ..()

/obj/machinery/computer/camera_advanced/on_unset_machine(mob/M)
	if(M == current_user)
		remove_eye_control(M)

/obj/machinery/computer/camera_advanced/proc/can_use(mob/living/user)
	return can_interact(user)

/obj/machinery/computer/camera_advanced/abductor/can_use(mob/user)
	if(!isabductor(user))
		return FALSE
	return ..()

/obj/machinery/computer/camera_advanced/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!can_use(user))
		return
	if(current_user)
		to_chat(user, span_warning("The console is already in use!"))
		return
	var/mob/living/L = user
	if(!eyeobj)
		CreateEye()
	if(!eyeobj) //Eye creation failed
		return
	if(!eyeobj.eye_initialized)
		var/camera_location
		var/turf/myturf = get_turf(src)
		if(eyeobj.use_static != FALSE)
			if((!length(z_lock) || (myturf.z in z_lock)) && GLOB.cameranet.checkTurfVis(myturf))
				camera_location = myturf
			else
				for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
					if(!C.can_use() || length(z_lock) && !(C.z in z_lock))
						continue
					var/list/network_overlap = networks & C.network
					if(length(network_overlap))
						camera_location = get_turf(C)
						break
		else
			camera_location = myturf
			if(length(z_lock) && !(myturf.z in z_lock))
				camera_location = locate(round(world.maxx/2), round(world.maxy/2), z_lock[1])

		if(camera_location)
			eyeobj.eye_initialized = TRUE
			give_eye_control(L)
			eyeobj.setLoc(camera_location)
		else
			user.unset_machine()
	else
		give_eye_control(L)
		eyeobj.setLoc(eyeobj.loc)

/obj/machinery/computer/camera_advanced/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/computer/camera_advanced/attack_ai(mob/user)
	return //AIs would need to disable their own camera procs to use the console safely. Bugs happen otherwise.

/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	GrantActions(user)
	current_user = user
	eyeobj.eye_user = user
	eyeobj.name = "Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(eyeobj.loc)
	if(should_supress_view_changes )
		user.client.view_size.supress()

/mob/camera/ai_eye/remote
	name = "Inactive Camera Eye"
	ai_detector_visible = FALSE
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/mob/living/eye_user = null
	var/obj/machinery/origin
	var/eye_initialized = 0
	var/visible_icon = 0
	var/image/user_image = null

/mob/camera/ai_eye/remote/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING //can't see ghosts through cameras
	user.sight = SEE_TURFS | SEE_BLACKNESS
	user.see_in_dark = 2
	return TRUE

/mob/camera/ai_eye/remote/Destroy()
	if(origin && eye_user)
		origin.remove_eye_control(eye_user,src)
	origin = null
	. = ..()
	eye_user = null

/mob/camera/ai_eye/remote/GetViewerClient()
	if(eye_user)
		return eye_user.client
	return null

/mob/camera/ai_eye/remote/setLoc(turf/destination, force_update = FALSE)
	if(eye_user)
		destination = get_turf(destination)
		if (destination)
			abstract_move(destination)
		else
			moveToNullspace()

		update_ai_detect_hud()

		if(use_static)
			GLOB.cameranet.visibility(src, GetViewerClient(), null, use_static)

		if(visible_icon)
			if(eye_user.client)
				eye_user.client.images -= user_image
				user_image = image(icon,loc,icon_state,FLY_LAYER)
				eye_user.client.images += user_image

/mob/camera/ai_eye/remote/relaymove(mob/living/user, direction)
	var/initial = initial(sprint)
	var/max_sprint = 50

	if(cooldown && cooldown < world.timeofday) // 3 seconds
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(src, direction))
		if(step)
			setLoc(step)

	cooldown = world.timeofday + 5
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial

/datum/action/innate/camera_off
	name = "End Camera View"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"

/datum/action/innate/camera_off/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/camera/ai_eye/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin
	console.remove_eye_control(owner)

/datum/action/innate/camera_jump
	name = "Jump To Camera"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/camera/ai_eye/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin

	var/list/L = list()

	for (var/obj/machinery/camera/cam in GLOB.cameranet.cameras)
		if(length(origin.z_lock) && !(cam.z in origin.z_lock))
			continue
		L.Add(cam)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/netcam in L)
		var/list/tempnetwork = netcam.network & origin.networks
		if (length(tempnetwork))
			if(!netcam.c_tag)
				continue
			T["[netcam.c_tag][netcam.can_use() ? null : " (Deactivated)"]"] = netcam

	playsound(origin, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
	var/camera = tgui_input_list(usr, "Camera to view", "Cameras", T)
	if(isnull(camera))
		return
	if(isnull(T[camera]))
		return
	var/obj/machinery/camera/final = T[camera]
	playsound(src, "terminal_type", 25, FALSE)
	if(final)
		playsound(origin, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)
		remote_eye.setLoc(get_turf(final))
		owner.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
		owner.clear_fullscreen("flash", 3) //Shorter flash than normal since it's an ~~advanced~~ console!
	else
		playsound(origin, 'sound/machines/terminal_prompt_deny.ogg', 25, FALSE)

/datum/action/innate/camera_multiz_up
	name = "Move up a floor"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "move_up"

/datum/action/innate/camera_multiz_up/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/camera/ai_eye/remote/remote_eye = owner.remote_control
	if(remote_eye.zMove(UP))
		to_chat(owner, span_notice("You move upwards."))
	else
		to_chat(owner, span_notice("You couldn't move upwards!"))

/datum/action/innate/camera_multiz_down
	name = "Move down a floor"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "move_down"

/datum/action/innate/camera_multiz_down/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/camera/ai_eye/remote/remote_eye = owner.remote_control
	if(remote_eye.zMove(DOWN))
		to_chat(owner, span_notice("You move downwards."))
	else
		to_chat(owner, span_notice("You couldn't move downwards!"))
