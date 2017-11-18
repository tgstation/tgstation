/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	var/list/z_lock = list() // Lock use to these z levels
	var/station_lock_override = FALSE
	var/mob/camera/aiEye/remote/eyeobj
	var/mob/living/current_user = null
	var/list/networks = list("SS13")
	var/datum/action/innate/camera_off/off_action = new
	var/datum/action/innate/camera_jump/jump_action = new
	var/list/actions = list()

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/camera_advanced/Initialize()
	. = ..()
	if(station_lock_override)
		z_lock = GLOB.station_z_levels.Copy()

/obj/machinery/computer/camera_advanced/syndie
	icon_keyboard = "syndie_key"

/obj/machinery/computer/camera_advanced/proc/CreateEye()
	eyeobj = new()
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.Grant(user)
		actions += off_action

	if(jump_action)
		jump_action.target = user
		jump_action.Grant(user)
		actions += jump_action

/obj/machinery/computer/camera_advanced/proc/remove_eye_control(mob/living/user)
	if(!user)
		return
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(user)
	if(user.client)
		user.reset_perspective(null)
		eyeobj.RemoveImages()
	eyeobj.eye_user = null
	user.remote_control = null

	current_user = null
	user.unset_machine()
	playsound(src, 'sound/machines/terminal_off.ogg', 25, 0)

/obj/machinery/computer/camera_advanced/check_eye(mob/user)
	if( (stat & (NOPOWER|BROKEN)) || (!Adjacent(user) && !user.has_unlimited_silicon_privilege) || user.eye_blind || user.incapacitated() )
		user.unset_machine()

/obj/machinery/computer/camera_advanced/Destroy()
	if(current_user)
		current_user.unset_machine()
	if(eyeobj)
		qdel(eyeobj)
	return ..()

/obj/machinery/computer/camera_advanced/on_unset_machine(mob/M)
	if(M == current_user)
		remove_eye_control(M)

/obj/machinery/computer/camera_advanced/attack_hand(mob/user)
	if(current_user)
		to_chat(user, "The console is already in use!")
		return
	if(..())
		return
	var/mob/living/L = user

	if(!eyeobj)
		CreateEye()

	if(!eyeobj.eye_initialized)
		var/camera_location
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use() || z_lock.len && !(C.z in z_lock))
				continue
			if(C.network & networks)
				camera_location = get_turf(C)
				break
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

/mob/camera/aiEye/remote
	name = "Inactive Camera Eye"
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/mob/living/eye_user = null
	var/obj/machinery/computer/camera_advanced/origin
	var/eye_initialized = 0
	var/visible_icon = 0
	var/image/user_image = null

/mob/camera/aiEye/remote/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING //can't see ghosts through cameras
	user.sight = 0
	user.see_in_dark = 2
	return 1

/mob/camera/aiEye/remote/RemoveImages()
	..()
	if(visible_icon)
		var/client/C = GetViewerClient()
		if(C)
			C.images -= user_image

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
		if(use_static)
			GLOB.cameranet.visibility(src)
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
	if(!target || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin
	console.remove_eye_control(target)

/datum/action/innate/camera_jump
	name = "Jump To Camera"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/Activate()
	if(!target || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin

	var/list/L = list()

	for (var/obj/machinery/camera/cam in GLOB.cameranet.cameras)
		if(origin.z_lock.len && !(cam.z in origin.z_lock))
			continue
		L.Add(cam)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/netcam in L)
		var/list/tempnetwork = netcam.network & origin.networks
		if (tempnetwork.len)
			T["[netcam.c_tag][netcam.can_use() ? null : " (Deactivated)"]"] = netcam

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


//Used by servants of Ratvar! They let you beam to the station.
/obj/machinery/computer/camera_advanced/ratvar
	name = "ratvarian camera observer"
	desc = "A console used to snoop on the station's goings-on. A jet of steam occasionally whooshes out from slats on its sides."
	use_power = FALSE
	networks = list("SS13", "MiniSat") //:eye:
	var/datum/action/innate/servant_warp/warp_action = new

/obj/machinery/computer/camera_advanced/ratvar/Initialize()
	. = ..()
	ratvar_act()

/obj/machinery/computer/camera_advanced/ratvar/process()
	if(prob(1))
		playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 25, TRUE)
		new/obj/effect/temp_visual/steam_release(get_turf(src))

/obj/machinery/computer/camera_advanced/ratvar/CreateEye()
	..()
	eyeobj.visible_icon = 1
	eyeobj.icon = 'icons/obj/abductor.dmi' //in case you still had any doubts
	eyeobj.icon_state = "camera_target"

/obj/machinery/computer/camera_advanced/ratvar/GrantActions(mob/living/carbon/user)
	..()
	if(warp_action)
		warp_action.Grant(user)
		warp_action.target = src
		actions += warp_action

/obj/machinery/computer/camera_advanced/ratvar/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='warning'>[src]'s keys are in a language foreign to you, and you don't understand anything on its screen.</span>")
		return
	. = ..()

/datum/action/innate/servant_warp
	name = "Warp"
	desc = "Warps to the tile you're viewing. You can use the Abscond scripture to return."
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "warp_down"
	background_icon_state = "bg_clock"
	buttontooltipstyle = "clockcult"
	var/obj/effect/temp_visual/ratvar/warp_marker/warping

/datum/action/innate/servant_warp/Activate()
	if(QDELETED(target) || !(ishuman(owner) || iscyborg(owner)) || !owner.canUseTopic(target) || warping)
		return
	if(!GLOB.servants_active) //No leaving unless there's servants from the get-go
		return
	var/mob/living/carbon/human/user = owner
	var/mob/camera/aiEye/remote/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/ratvar/R  = target
	var/turf/T = get_turf(remote_eye)
	if(user.z != ZLEVEL_CITYOFCOGS || !(T.z in GLOB.station_z_levels))
		return
	if(isclosedturf(T))
		to_chat(user, "<span class='sevtug_small'>You can't teleport into a wall.</span>")
		return
	else if(isspaceturf(T))
		to_chat(user, "<span class='sevtug_small'>[prob(1) ? "Servant cannot into space." : "You can't teleport into space."]</span>")
		return
	var/area/AR = get_area(T)
	if(!AR.clockwork_warp_allowed)
		to_chat(user, "<span class='sevtug_small'>[AR.clockwork_warp_fail]</span>")
		return
	if(alert(user, "Are you sure you want to warp to [AR]?", target.name, "Warp", "Cancel") == "Cancel" || QDELETED(R) || !user.canUseTopic(R))
		return
	do_sparks(5, TRUE, user)
	do_sparks(5, TRUE, T)
	warping = new(T)
	user.visible_message("<span class='warning'>[user]'s [target.name] flares!</span>", "<span class='bold sevtug_small'>You begin warping to [AR]...</span>")
	if(!do_after(user, 50, target = warping))
		to_chat(user, "<span class='bold sevtug_small'>Warp interrupted.</span>")
		QDEL_NULL(warping)
		return
	T.visible_message("<span class='warning'>[user] warps in!</span>")
	playsound(user, 'sound/magic/magic_missile.ogg', 50, TRUE)
	playsound(T, 'sound/magic/magic_missile.ogg', 50, TRUE)
	user.forceMove(get_turf(T))
	user.setDir(SOUTH)
	flash_color(user, flash_color = "#AF0AAF", flash_time = 5)
	R.remove_eye_control(user)
	QDEL_NULL(warping)
