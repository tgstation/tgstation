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
		C.client.change_view(7)
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
	var/list/zees = list(1,7,8,9,10,11,12)
	var/selection = input(C,"Select Local Quadrant Number", "Quadrant Number") as null|anything in zees
	N.setLoc(locate(125,125,selection))



// Ship's construction systems



/obj/machinery/computer/ship_construction
	name = "ship contruction console"
	desc = "An engineering computer integrated with a camera-assisted rapid construction drone."
	var/obj/item/weapon/rcd/internal/RCD //Internal RCD. The computer passes user commands to this in order to avoid massive copypaste.
	var/datum/action/innate/camera_off/engi_ship = new
	var/datum/action/innate/engi_ship/switch_mode/switch_mode_action = new //Action for switching the RCD's build modes
	var/datum/action/innate/engi_ship/build/build_action = new //Action for using the RCD
	var/datum/action/innate/engi_ship/airlock_type/airlock_mode_action = new //Action for setting the airlock type
	var/datum/action/innate/engi_ship/recaller/rec = new // BRING HIM HOME
	var/mob/camera/aiEye/construction/eyeobj

/obj/machinery/computer/ship_construction/attack_hand(mob/user)
	if(!eyeobj)
		eyeobj = new(get_turf(src))
		eyeobj.origin = src
	GrantActions(user)
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	user.sight |= SEE_TURFS
	user.update_sight()


/obj/machinery/computer/ship_construction/New()
	..()
	RCD = new /obj/item/weapon/rcd/internal(src)

/obj/machinery/computer/ship_construction/Destroy()
	qdel(RCD)
	return ..()

/obj/machinery/computer/ship_construction/proc/GrantActions(mob/living/user)
	engi_ship.target = user
	engi_ship.Grant(user)
	switch_mode_action.target = src
	switch_mode_action.Grant(user)
	build_action.target = src
	build_action.Grant(user)
	airlock_mode_action.target = src
	airlock_mode_action.Grant(user)
	rec.target = src
	rec.Grant(user)

/obj/machinery/computer/ship_construction/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/rcd_ammo) || istype(W, /obj/item/stack/sheet))
		RCD.attackby(W, user, params) //If trying to feed the console more materials, pass it along to the RCD.
	else
		return ..()

/mob/camera/aiEye/construction
	name = "nss dauntless holo-drone"
	icon = 'icons/obj/mining.dmi'
	icon_state = "construction_drone"
	invisibility = INVISIBILITY_MAXIMUM
	var/obj/machinery/computer/ship_construction/origin


/mob/camera/aiEye/construction/setLoc(var/t)
	if(get_dist(origin, t) < 75)
		t = get_turf(t)
		loc = t
	else
		playsound(origin, 'sound/machines/buzz-sigh.ogg', 60, 1)

/mob/camera/aiEye/construction/relaymove(mob/user, direct)
	dir = direct //This camera eye is visible as a drone, and needs to keep the dir updated
	..()

/datum/action/innate/engi_ship //Parent aux base action
	var/mob/living/C //Mob using the action
	var/mob/camera/aiEye/construction/remote_eye //Console's eye mob
	var/obj/machinery/computer/ship_construction/B //Console itself

/datum/action/innate/engi_ship/Activate()
	if(!target)
		return TRUE
	C = owner
	remote_eye = C.remote_control
	B = target
	if(!B.RCD) //The console must always have an RCD.
		B.RCD = new /obj/item/weapon/rcd/internal(src) //If the RCD is lost somehow, make a new (empty) one!

/datum/action/innate/engi_ship/proc/check_spot()
	var/turf/build_target = get_turf(remote_eye)
	if(get_dist(remote_eye.origin, build_target) > 75 || build_target.z != ZLEVEL_STATION)
		to_chat(owner, "<span class='warning'>The ship is out of range, recall to its position and try again.</span>")
		return FALSE
	return TRUE

/datum/action/innate/camera_off/engi_ship
	name = "Log out"

/datum/action/innate/camera_off/engi_ship/Activate()
	if(!owner || !owner.remote_control)
		return

	var/mob/camera/aiEye/construction/remote_eye = owner.remote_control

	var/obj/machinery/computer/ship_construction/origin = remote_eye.origin
	origin.switch_mode_action.Remove(target)
	origin.build_action.Remove(target)
	origin.airlock_mode_action.Remove(target)
	origin.rec.Remove(target)
	..()

//*******************FUNCTIONS*******************

/datum/action/innate/engi_ship/build
	name = "Build"
	button_icon_state = "build"

/datum/action/innate/engi_ship/build/Activate()
	if(..())
		return

	if(!check_spot())
		return

	var/atom/movable/rcd_target
	var/turf/target_turf = get_turf(remote_eye)

	//Find airlocks
	rcd_target = locate(/obj/machinery/door/airlock) in target_turf

	if(!rcd_target)
		rcd_target = locate (/obj/structure) in target_turf

	if(!rcd_target || !rcd_target.anchored)
		rcd_target = target_turf

	owner.changeNext_move(CLICK_CD_RANGE)
	B.RCD.afterattack(rcd_target, owner, TRUE) //Activate the RCD and force it to work remotely!
	playsound(target_turf, 'sound/items/Deconstruct.ogg', 60, 1)

/datum/action/innate/engi_ship/switch_mode
	name = "Switch Mode"
	button_icon_state = "builder_mode"

/datum/action/innate/engi_ship/switch_mode/Activate()
	if(..())
		return
	var/list/buildlist = list("Walls and Floors" = 1,"Airlocks" = 2,"Deconstruction" = 3,"Windows and Grilles" = 4)
	var/buildmode = input("Set construction mode.", "construction options", null) in buildlist
	B.RCD.mode = buildlist[buildmode]
	to_chat(owner, "Build mode is now [buildmode].")

/datum/action/innate/engi_ship/airlock_type
	name = "Select Airlock Type"
	button_icon_state = "airlock_select"

/datum/action/innate/engi_ship/airlock_type/Activate()
	if(..())
		return
	B.RCD.change_airlock_setting()

/datum/action/innate/engi_ship/recaller/recall
	name = "Recall the Holo-drone"
	button_icon_state = "mech_overload_off"

/datum/action/innate/engi_ship/recaller/recall/Activate()
	remote_eye.setLoc(get_turf(B))