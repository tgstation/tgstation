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
	callTime = 30
	safety = TRUE
	var/obj/machinery/computer/shuttle/engi_ship/C = null

/obj/machinery/computer/shuttle/engi_ship
	name = "ship control console"
	desc = "Used to control the Engi Ship."
	icon_screen = "comm"
	icon_keyboard = "power_key"
	circuit = /obj/item/weapon/circuitboard/computer/engi_ship
	shuttleId = "engi_ship"
	possible_destinations = null


/obj/machinery/computer/engi_nav
	name = "navigations console"
	desc = "Used to navigate"
	icon_screen = "navigation"
	icon_keyboard = "power_key"
	var/shuttle_id = "engi_ship"
	var/target_area = null
	var/obj/docking_port/stationary/landing_zone = null
	var/mob/camera/aiEye/nav/eyeobj
	var/datum/action/innate/nav_off/off_action = new
	var/datum/action/innate/nav_dock/beacon = new
	var/datum/action/innate/z_switch/warp = new
	var/dwidth = 11
	var/dheight = 11
	var/width = 23
	var/height = 23
	var/lz_dir = 1

/obj/machinery/computer/engi_nav/attack_hand(mob/user)
	Navigate(user)

/obj/machinery/computer/engi_nav/proc/Navigate(mob/user)
	if(!eyeobj)
		eyeobj = new(get_turf(src))
		eyeobj.origin = src
	GrantActions(user)
	eyeobj.eye_user = user
	user.client.change_view(20)
	user.see_invisible = SEE_INVISIBLE_MINIMUM
	eyeobj.name = "Navigation Probe([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	user.sight |= SEE_TURFS
	user.update_sight()

/obj/machinery/computer/engi_nav/proc/clear()
	qdel(landing_zone, force=TRUE)
	target_area = null
	landing_zone = null

/obj/machinery/computer/engi_nav/proc/SetLanding(var/mob/N)
	clear()
	target_area = get_turf(N)
	var/area/picked_area = get_area(target_area)
	if(!src || QDELETED(src))
		return
	var/turf/T = safepick(get_area_turfs(picked_area))
	if(!T)
		return
	spawn_atom_to_turf(/obj/effect/overlay/temp/emp/pulse, target_area, 1)
	landing_zone = new(target_area)
	landing_zone.id = "engi_ship(\ref[src])"
	landing_zone.name = "Navigator's Beacon"
	landing_zone.dwidth = dwidth
	landing_zone.dheight = dheight
	landing_zone.width = width
	landing_zone.height = height
	landing_zone.setDir(lz_dir)

	for(var/obj/machinery/computer/shuttle/S in machines)
		if(S.shuttleId == shuttle_id)
			S.possible_destinations = "[landing_zone.id]"
	say("Landing Zone Set")

/obj/machinery/computer/engi_nav/proc/GrantActions(mob/living/user)
	off_action.target = user
	off_action.Grant(user)
	beacon.target = user
	beacon.Grant(user)
	warp.target = user
	warp.Grant(user)


/mob/camera/aiEye/nav
	name = "Inactive Navigation Probe"
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/mob/living/eye_user = null
	var/obj/machinery/computer/engi_nav/origin
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
	N.origin.beacon.Remove(C)
	N.origin.warp.Remove(C)
	N.eye_user = null
	if(C.client)
		C.reset_perspective(null)

	C.remote_control = null
	C.unset_machine()
	src.Remove(C)
	playsound(N.origin, 'sound/machines/terminal_off.ogg', 25, 0)

/datum/action/innate/nav_dock
	name = "Select Docking Location"
	button_icon_state = "Judicial Marker"

/datum/action/innate/nav_dock/Activate()
	if(!target || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/nav/N = C.remote_control
	var/obj/machinery/computer/engi_nav/O = N.origin
	O.SetLanding(N)

/datum/action/innate/z_switch
	name = "Switch Z Level"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/z_switch/Activate()
	if(!target || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/nav/N = C.remote_control
	var/list/zees = list(1,2,3,4,5,7,8,9)
	var/selection = input(C,"Select Local Quadrant Number", "Quadrant Number") as null|anything in zees
	N.setLoc(locate(125,125,selection))


// Ship's construction systems

/obj/machinery/computer/camera_advanced/base_construction/ship
	name = "long distance construction console"

/obj/machinery/computer/camera_advanced/base_construction/CreateEye()
	eyeobj = new /mob/camera/aiEye/remote/base_construction/ship(get_turf(src))
	eyeobj.origin = src

/datum/action/innate/aux_base/ship
	var/obj/machinery/computer/camera_advanced/base_construction/ship

/datum/action/innate/aux_base/ship/check_spot()
	if(get_dist(origin, remote_eye) > 60)
		return FALSE
	else
		return TRUE


/mob/camera/aiEye/remote/base_construction/ship
	name = "nss dauntless holo-drone"


/mob/camera/aiEye/remote/base_construction/ship/setLoc(var/t)
	if(get_dist(src,origin)<60)
		loc = t
	else
		world << "movement failed, distance is [get_dist(t,origin)]"