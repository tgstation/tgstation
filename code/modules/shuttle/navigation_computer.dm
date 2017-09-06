/obj/machinery/computer/camera_advanced/shuttle_docker
	name = "navigation computer"
	desc = "Used to designate a precise transit location for a spacecraft."
	z_lock = ZLEVEL_STATION
	jump_action = null
	var/datum/action/innate/shuttledocker_rotate/rotate_action = new
	var/datum/action/innate/shuttledocker_place/place_action = new
	var/shuttleId = ""
	var/shuttlePortId = ""
	var/shuttlePortName = ""
	var/list/jumpto_ports = list() //hashset of ports to jump to and ignore for collision purposes
	var/list/blacklisted_turfs
	var/obj/docking_port/stationary/my_port
	var/view_range = 7
	var/x_offset = 0
	var/y_offset = 0
	var/space_turfs_only = TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/GrantActions(mob/living/user)
	if(jumpto_ports.len)
		jump_action = new /datum/action/innate/camera_jump/shuttle_docker
	..()

	if(rotate_action)
		rotate_action.target = user
		rotate_action.Grant(user)
		actions += rotate_action

	if(place_action)
		place_action.target = user
		place_action.Grant(user)
		actions += place_action

/obj/machinery/computer/camera_advanced/shuttle_docker/CreateEye()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(QDELETED(M))
		return
	eyeobj = new /mob/camera/aiEye/remote/shuttle_docker()
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	the_eye.origin = src
	the_eye.dir = M.dir
	var/area/A = get_area(M)
	if(QDELETED(A))
		return
	var/turf/origin = locate(M.x + x_offset, M.y + y_offset, M.z)
	for(var/turf/T in A)
		if(T.z != origin.z)
			continue
		var/image/I = image('icons/effects/alphacolors.dmi', origin, "red")
		I.layer = ABOVE_NORMAL_TURF_LAYER
		I.plane = 0
		I.mouse_opacity = 0
		var/x_off = T.x - origin.x
		var/y_off = T.y - origin.y
		I.pixel_x = x_off * 32
		I.pixel_y = y_off * 32
		the_eye.placement_images[I] = list(x_off, y_off)
	generateBlacklistedTurfs()

/obj/machinery/computer/camera_advanced/shuttle_docker/give_eye_control(mob/user)
	..()
	if(!QDELETED(user) && user.client)
		var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
		user.client.images += the_eye.placement_images
		user.client.images += the_eye.placed_images
		user.client.view = view_range

/obj/machinery/computer/camera_advanced/shuttle_docker/remove_eye_control(mob/living/user)
	..()
	if(!QDELETED(user) && user.client)
		var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
		user.client.images -= the_eye.placement_images
		user.client.images -= the_eye.placed_images
		user.client.view = world.view

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/placeLandingSpot()
	if(!checkLandingSpot())
		return FALSE
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	if(!my_port)
		my_port = new /obj/docking_port/stationary
		my_port.name = shuttlePortName
		my_port.id = shuttlePortId
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
		my_port.height = M.height
		my_port.width = M.width
		my_port.dheight = M.dheight
		my_port.dwidth = M.dwidth
	my_port.dir = the_eye.dir
	my_port.loc = locate(eyeobj.x - x_offset, eyeobj.y - y_offset, eyeobj.z)
	if(current_user && current_user.client)
		current_user.client.images -= the_eye.placed_images

	for(var/V in the_eye.placed_images)
		qdel(V)
	the_eye.placed_images = list()

	for(var/V in the_eye.placement_images)
		var/turf/T = locate(eyeobj.x + the_eye.placement_images[V][1], eyeobj.y + the_eye.placement_images[V][2], eyeobj.z)
		var/image/I = image('icons/effects/alphacolors.dmi', T, "blue")
		I.layer = ABOVE_OPEN_TURF_LAYER
		I.plane = 0
		I.mouse_opacity = 0
		the_eye.placed_images += I

	if(current_user && current_user.client)
		current_user.client.images += the_eye.placed_images
	return TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/rotateLandingSpot()
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	the_eye.dir = turn(the_eye.dir, -90)
	for(var/V in the_eye.placement_images)
		var/image/I = V
		var/list/coords = the_eye.placement_images[V]
		var/Tmp = coords[1]
		coords[1] = coords[2]
		coords[2] = -Tmp

		I.pixel_x = coords[1] * 32
		I.pixel_y = coords[2] * 32
	var/Tmp = x_offset
	x_offset = y_offset
	y_offset = -Tmp
	checkLandingSpot()

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/checkLandingTurf(turf/T)
	return T && (!blacklisted_turfs || !blacklisted_turfs[T]) && (!space_turfs_only || isspaceturf(T))

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/generateBlacklistedTurfs()
	blacklisted_turfs = list()
	for(var/V in SSshuttle.stationary)
		if(!V)
			continue
		var/obj/docking_port/stationary/S = V
		if(z_lock && (S.z != z_lock))
			continue
		if((S.id == shuttlePortId) || jumpto_ports[S.id])
			continue
		for(var/T in S.return_turfs())
			blacklisted_turfs[T] = TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/proc/checkLandingSpot()
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/turf/eyeturf = get_turf(the_eye)
	if(!eyeturf)
		return
	var/landing_spot_clear = TRUE
	for(var/V in the_eye.placement_images)
		var/image/I = V
		I.loc = eyeturf
		var/list/coords = the_eye.placement_images[V]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		if(checkLandingTurf(T))
			I.icon_state = "green"
		else
			I.icon_state = "red"
			landing_spot_clear = FALSE
	return landing_spot_clear

/mob/camera/aiEye/remote/shuttle_docker
	visible_icon = FALSE
	use_static = FALSE
	var/list/placement_images = list()
	var/list/placed_images = list()

/mob/camera/aiEye/remote/shuttle_docker/setLoc(T)
	..()
	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = origin
	console.checkLandingSpot()

/mob/camera/aiEye/remote/shuttle_docker/update_remote_sight(mob/living/user)
	user.sight = BLIND|SEE_TURFS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/datum/action/innate/shuttledocker_rotate
	name = "Rotate"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/shuttledocker_rotate/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/origin = remote_eye.origin
	origin.rotateLandingSpot()

/datum/action/innate/shuttledocker_place
	name = "Place"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_zoom_off"

/datum/action/innate/shuttledocker_place/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/origin = remote_eye.origin
	if(origin.placeLandingSpot())
		to_chat(target, "<span class='notice'>Transit location designated</span>")
	else
		to_chat(target, "<span class='warning'>Invalid transit location</span>")

/datum/action/innate/camera_jump/shuttle_docker
	name = "Jump to Location"
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/shuttle_docker/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = remote_eye.origin

	playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)

	var/list/L = list()
	for(var/V in SSshuttle.stationary)
		if(!V)
			continue
		var/obj/docking_port/stationary/S = V
		if(console.z_lock && (S.z != console.z_lock))
			continue
		if(console.jumpto_ports[S.id])
			L[S.name] = S

	playsound(console, 'sound/machines/terminal_prompt.ogg', 25, 0)
	var/selected = input("Choose location to jump to", "Locations", null) as null|anything in L
	if(QDELETED(src) || QDELETED(target) || !isliving(target))
		return
	playsound(src, "terminal_type", 25, 0)
	if(selected)
		var/turf/T = get_turf(L[selected])
		if(T)
			playsound(console, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
			remote_eye.setLoc(T)
			to_chat(target, "<span class='notice'>Jumped to [selected]</span>")
			C.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			C.clear_fullscreen("flash", 3)
	else
		playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)
