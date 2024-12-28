/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	light_color = COLOR_SOFT_RED
	processing_flags = START_PROCESSING_MANUALLY

	var/list/z_lock = list() // Lock use to these z levels
	var/lock_override = NONE
	var/mob/eye/camera/remote/eyeobj
	var/mob/living/current_user = null
	var/list/networks = list(CAMERANET_NETWORK_SS13)
	/// Typepath of the action button we use as "off"
	/// It's a typepath so subtypes can give it fun new names
	var/datum/action/innate/camera_off/off_action = /datum/action/innate/camera_off
	/// Typepath for jumping
	var/datum/action/innate/camera_jump/jump_action = /datum/action/innate/camera_jump
	/// Typepath of the move up action
	var/datum/action/innate/camera_multiz_up/move_up_action = /datum/action/innate/camera_multiz_up
	/// Typepath of the move down action
	var/datum/action/innate/camera_multiz_down/move_down_action = /datum/action/innate/camera_multiz_down

	/// List of all actions to give to a user when they're well, granted actions
	var/list/actions = list()
	///Should we supress any view changes?
	var/should_supress_view_changes = TRUE

	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_REQUIRES_SIGHT

/obj/machinery/computer/camera_advanced/Initialize(mapload)
	. = ..()
	for(var/i in networks)
		networks -= i
		networks += LOWER_TEXT(i)
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

/obj/machinery/computer/camera_advanced/Destroy()
	unset_machine()
	QDEL_NULL(eyeobj)
	QDEL_LIST(actions)
	current_user = null
	return ..()

/obj/machinery/computer/camera_advanced/process()
	if(!can_use(current_user) || (issilicon(current_user) && !HAS_SILICON_ACCESS(current_user)))
		unset_machine()
		return PROCESS_KILL

/obj/machinery/computer/camera_advanced/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	for(var/i in networks)
		networks -= i
		networks += "[port.shuttle_id]_[i]"

/obj/machinery/computer/camera_advanced/syndie
	icon_keyboard = "syndie_key"
	circuit = /obj/item/circuitboard/computer/advanced_camera

/obj/machinery/computer/camera_advanced/syndie/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	return //For syndie nuke shuttle, to spy for station.

/**
 * Initializes a camera eye.
 * Returns TRUE if initialization was successful.
 * Will return nothing if it runtimes.
 */
/obj/machinery/computer/camera_advanced/proc/CreateEye()
	if(eyeobj)
		CRASH("Tried to make another eyeobj for some reason. Why?")

	eyeobj = new(get_turf(src), src)
	return TRUE

/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/user)
	for(var/datum/action/to_grant as anything in actions)
		to_grant.Grant(user)

/obj/machinery/proc/remove_eye_control(mob/living/user)
	CRASH("[type] does not implement camera eye handling")

/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	if(isnull(user?.client))
		return

	current_user = user
	eyeobj.assign_user(user)
	GrantActions(user)

	if(should_supress_view_changes)
		user.client.view_size.supress()
	begin_processing()

/obj/machinery/computer/camera_advanced/remove_eye_control(mob/living/user)
	if(isnull(user?.client))
		return

	for(var/datum/action/actions_removed as anything in actions)
		actions_removed.Remove(user)
	for(var/datum/camerachunk/camerachunks_gone as anything in eyeobj.visibleCameraChunks)
		camerachunks_gone.remove(eyeobj)

	eyeobj.assign_user(null)
	current_user = null

	user.client.view_size.unsupress()

	playsound(src, 'sound/machines/terminal/terminal_off.ogg', 25, FALSE)

/obj/machinery/computer/camera_advanced/on_set_is_operational(old_value)
	if(!is_operational)
		unset_machine()

/obj/machinery/computer/camera_advanced/proc/unset_machine()
	if(!QDELETED(current_user))
		remove_eye_control(current_user)
	end_processing()

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
	if(isnull(user.client))
		return
	if(!QDELETED(current_user))
		to_chat(user, span_warning("The console is already in use!"))
		return

	if(eyeobj)
		give_eye_control(user)
		eyeobj.setLoc(eyeobj.loc)
		return
	/* We're attempting to initialize the eye past this point */

	if(!CreateEye())
		to_chat(user, span_warning("\The [src] flashes a bunch of never-ending errors on the display. Something is really wrong."))
		return

	var/camera_location
	var/turf/myturf = get_turf(src)
	var/consider_zlock = (!!length(z_lock))

	if(!eyeobj.use_visibility)
		if(consider_zlock && !(myturf.z in z_lock))
			camera_location = locate(round(world.maxx * 0.5), round(world.maxy * 0.5), z_lock[1])
		else
			camera_location = myturf
	else
		if((!consider_zlock || (myturf.z in z_lock)) && GLOB.cameranet.checkTurfVis(myturf))
			camera_location = myturf
		else
			for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
				if(!C.can_use() || consider_zlock && !(C.z in z_lock))
					continue
				var/list/network_overlap = networks & C.network
				if(length(network_overlap))
					camera_location = get_turf(C)
					break

	if(camera_location)
		give_eye_control(user)
		eyeobj.setLoc(camera_location, TRUE)
	else
		unset_machine()

/obj/machinery/computer/camera_advanced/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/computer/camera_advanced/attack_ai(mob/user)
	return //AIs would need to disable their own camera procs to use the console safely. Bugs happen otherwise.

/datum/action/innate/camera_off
	name = "End Camera View"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"

/datum/action/innate/camera_off/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin_ref.resolve()
	console.remove_eye_control(owner)

/datum/action/innate/camera_jump
	name = "Jump To Camera"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin_ref.resolve()

	var/list/L = list()

	for (var/obj/machinery/camera/cam as anything in GLOB.cameranet.cameras)
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

	playsound(origin, 'sound/machines/terminal/terminal_prompt.ogg', 25, FALSE)
	var/camera = tgui_input_list(usr, "Camera to view", "Cameras", T)
	if(isnull(camera))
		return
	if(isnull(T[camera]))
		return
	var/obj/machinery/camera/final = T[camera]
	playsound(src, SFX_TERMINAL_TYPE, 25, FALSE)
	if(final)
		playsound(origin, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 25, FALSE)
		remote_eye.setLoc(get_turf(final))
		owner.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
		owner.clear_fullscreen("flash", 3) //Shorter flash than normal since it's an ~~advanced~~ console!
	else
		playsound(origin, 'sound/machines/terminal/terminal_prompt_deny.ogg', 25, FALSE)

/datum/action/innate/camera_multiz_up
	name = "Move up a floor"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "move_up"

/datum/action/innate/camera_multiz_up/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	if(remote_eye.zMove(UP))
		to_chat(owner, span_notice("You move upwards."))
	else
		to_chat(owner, span_notice("You couldn't move upwards!"))

/datum/action/innate/camera_multiz_down
	name = "Move down a floor"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "move_down"

/datum/action/innate/camera_multiz_down/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	if(remote_eye.zMove(DOWN))
		to_chat(owner, span_notice("You move downwards."))
	else
		to_chat(owner, span_notice("You couldn't move downwards!"))

/obj/machinery/computer/camera_advanced/human_ai/screwdriver_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "repackaging...")
	if(!do_after(user, 5 SECONDS, src))
		return ITEM_INTERACT_BLOCKING
	tool.play_tool_sound(src, 40)
	new /obj/item/secure_camera_console_pod(get_turf(src))
	qdel(src)
	return ITEM_INTERACT_SUCCESS
