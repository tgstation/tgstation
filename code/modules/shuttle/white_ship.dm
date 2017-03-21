/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/weapon/circuitboard/computer/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland"

/obj/docking_port/mobile/engi_ship
	name = "Engineering Ship"
	id = "engi_ship"
	dwidth = 11
	dheight = 11
	width = 23
	height = 23
	dir = 1
	ignitionTime = 10
	var/obj/machinery/computer/shuttle/engi_ship/C = null

/obj/docking_port/mobile/engi_ship/dock()
	..()
	C = getControlConsole()
	C.say("You have successfully docked at [C.picked_area].")
	say("You have successfully docked at [C.picked_area].")
	C.clear()

/obj/machinery/computer/shuttle/engi_ship
	name = "Engi Ship Console"
	desc = "Used to control the Engi Ship."
	circuit = /obj/item/weapon/circuitboard/computer/engi_ship
	shuttleId = "engi_ship"
	possible_destinations = null
	var/dwidth = 11
	var/dheight = 11
	var/width = 23
	var/height = 23
	var/lz_dir = 1
	var/target_area = null
	var/area/picked_area = null
	var/obj/docking_port/stationary/landing_zone = null
	var/shuttle_id = "engi_ship"
	var/mob/camera/aiEye/nav/eyeobj
	var/datum/action/innate/nav_off/off_action = new
	var/datum/action/innate/nav_dock/beacon = new
	var/mob/living/current_user = null

/obj/machinery/computer/shuttle/engi_ship/proc/clear()
	qdel(landing_zone)
	target_area = null
	picked_area = null
	landing_zone = null
	possible_destinations = null

/obj/machinery/computer/shuttle/engi_ship/proc/set_landing(var/mob/N)
	clear()
	target_area = get_turf(N)
	new /obj/effect/overlay/temp/cult/turf(target_area)
	picked_area = get_area(target_area)
	if(!src || QDELETED(src))
		return
	var/turf/T = safepick(get_area_turfs(picked_area))
	if(!T)
		return
	landing_zone = new /obj/docking_port/stationary(T)
	landing_zone.id = "engi_ship(\ref[src])"
	landing_zone.name = "[picked_area]"
	landing_zone.dwidth = dwidth
	landing_zone.dheight = dheight
	landing_zone.width = width
	landing_zone.height = height
	landing_zone.setDir(lz_dir)
	possible_destinations = "[landing_zone.id]"
	to_chat(src, "Landing zone set to [picked_area].")

/obj/machinery/computer/shuttle/engi_ship/attack_hand(mob/user)
	if(..(user))
		return
	src.add_fingerprint(user)
	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(M.mode != SHUTTLE_IDLE)
		to_chat(usr, "<span class='warning'>Shuttle already in transit.</span>")
		return
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		dat += "<A href='?src=\ref[src];action=select'>Select Location</A><br>"
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S))
				continue
			destination_found = 1
			dat += "<B>Destination Status: [M.canDock(S)]</B><br>"
			dat += "<A href='?src=\ref[src];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>No Destination Detected</B><br>"
	dat += "<a href='?src=\ref[user];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()


/obj/machinery/computer/shuttle/engi_ship/Topic(href, href_list)
	if(href_list["action"])
		if("select")
			qdel(landing_zone)
			Navigate(usr)

	..()

/obj/machinery/computer/shuttle/engi_ship/proc/Navigate(mob/user)
	if(!eyeobj)
		eyeobj = new(get_turf(src))
		eyeobj.origin = src
	GrantActions(user)
	current_user = user
	eyeobj.eye_user = user
	user.client.change_view(20)
	user.see_invisible = SEE_INVISIBLE_MINIMUM
	eyeobj.name = "Navigation Probe([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	user.sight -= SEE_MOBS
	user.sight |= SEE_TURFS
	user.update_sight()


/obj/machinery/computer/shuttle/engi_ship/proc/GrantActions(mob/living/user)
	off_action.target = user
	off_action.Grant(user)
	beacon.target = user
	beacon.Grant(user)


/mob/camera/aiEye/nav
	name = "Inactive Navigation Probe"
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/mob/living/eye_user = null
	var/obj/machinery/computer/shuttle/engi_ship/origin
	var/eye_initialized = 0
	var/visible_icon = 0
	var/image/user_image = null
	/*
			user.vision_flags = SEE_TURFS
			user.darkness_view = 1
			user.invis_view = SEE_INVISIBLE_MINIMUM
			to_chat(user, "<span class='notice'>You activate the ship's scanners to search for a destination.</span>")
			user.invis_update()
			user.client.eye = locate(125,125,1)
			user.client.change_view(125)
			C.mouse_pointer_icon
			*/

/mob/camera/aiEye/nav/Destroy()
	eye_user = null
	origin = null
	return ..()

/mob/camera/aiEye/nav/GetViewerClient()
	if(eye_user)
		return eye_user.client
	return null

/mob/camera/aiEye/nav/setLoc(T)
	if(eye_user)
		if(!isturf(eye_user.loc))
			return
		T = get_turf(T)
		loc = T
		if(visible_icon)
			if(eye_user.client)
				eye_user.client.images -= user_image
				user_image = image(icon,loc,icon_state,FLY_LAYER)
				eye_user.client.images += user_image

/mob/camera/aiEye/nav/relaymove(mob/user,direct)
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

/datum/action/innate/nav_off
	name = "End Navigation View"
	button_icon_state = "camera_off"

/datum/action/innate/nav_off/Activate()
	if(!target || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/nav/N = C.remote_control
	N.origin.current_user = null
	N.origin.beacon.Remove(C)
	N.eye_user = null
	if(C.client)
		C.reset_perspective(null)
		if(N.visible_icon)
			C.client.images -= N.user_image
		for(var/datum/camerachunk/chunk in N.visibleCameraChunks)
			C.client.images -= chunk.obscured
	C.remote_control = null
	C.unset_machine()
	src.Remove(C)
	playsound(N.origin, 'sound/machines/terminal_off.ogg', 25, 0)

var/datum/action/innate/nav_dock
	name = "Select Docking Location"
	button_icon_state = "Judicial Marker"

/datum/action/innate/nav_dock/Activate()
	if(!target || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/nav/N = C.remote_control
	var/obj/machinery/computer/shuttle/engi_ship/O = N.origin
	O.set_landing(get_turf(N))
