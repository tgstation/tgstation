#define CAMERA_UPGRADE_XRAY 1
#define CAMERA_UPGRADE_EMP_PROOF 2
#define CAMERA_UPGRADE_MOTION 4

/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10
	layer = 5

	var/health = 50
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1
	anchored = 1
	var/start_active = 0 //If it ignores the random chance to start broken on round start
	var/invuln = null
	var/obj/item/device/camera_bug/bug = null
	var/obj/machinery/camera_assembly/assembly = null

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/alarm_on = 0
	var/busy = 0
	var/emped = 0  //Number of consecutive EMP's on this camera

	// Upgrades bitflag
	var/upgrades = 0

/obj/machinery/camera/New()
	..()
	assembly = new(src)
	assembly.state = 4
	cameranet.cameras += src
	cameranet.addCamera(src)
	add_to_proximity_list(src, 1) //1 was default of everything
	/* // Use this to look for cameras that have the same c_tag.
	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if(C != src && C.c_tag == src.c_tag && tempnetwork.len)
			world.log << "[src.c_tag] [src.x] [src.y] [src.z] conflicts with [C.c_tag] [C.x] [C.y] [C.z]"
	*/

/obj/machinery/camera/initialize()
	if(z == 1 && prob(3) && !start_active)
		toggle_cam()

/obj/machinery/camera/Move()
	remove_from_proximity_list(src, 1)
	return ..()

/obj/machinery/camera/Destroy()
	toggle_cam(null, 0) //kick anyone viewing out
	remove_from_proximity_list(src, 1)
	if(assembly)
		qdel(assembly)
		assembly = null
	if(istype(bug))
		bug.bugged_cameras -= src.c_tag
		if(bug.current == src)
			bug.current = null
		bug = null
	cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	cameranet.cameras -= src
	cameranet.removeCamera(src)
	return ..()

/obj/machinery/camera/emp_act(severity)
	if(!status)
		return
	if(!isEmpProof())
		if(prob(150/severity))
			icon_state = "[initial(icon_state)]emp"
			var/list/previous_network = network
			network = list()
			cameranet.removeCamera(src)
			stat |= EMPED
			SetLuminosity(0)
			emped = emped+1  //Increase the number of consecutive EMP's
			var/thisemp = emped //Take note of which EMP this proc is for
			spawn(900)
				if(loc) //qdel limbo
					triggerCameraAlarm() //camera alarm triggers even if multiple EMPs are in effect.
					if(emped == thisemp) //Only fix it if the camera hasn't been EMP'd again
						network = previous_network
						icon_state = initial(icon_state)
						stat &= ~EMPED
						if(can_use())
							cameranet.addCamera(src)
						emped = 0 //Resets the consecutive EMP count
						spawn(100)
							if(!qdeleted(src))
								cancelCameraAlarm()
			for(var/mob/O in mob_list)
				if (O.client && O.client.eye == src)
					O.unset_machine()
					O.reset_perspective(null)
					O << "The screen bursts into static."
			..()


/obj/machinery/camera/ex_act(severity, target)
	if(src.invuln)
		return
	else
		..()
	return

/obj/machinery/camera/proc/setViewRange(num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/proc/shock(mob/living/user)
	if(!istype(user))
		return
	user.electrocute_act(10, src)

/obj/machinery/camera/attack_paw(mob/living/carbon/alien/humanoid/user)
	if(!istype(user))
		return
	user.do_attack_animation(src)
	add_hiddenprint(user)
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	health = max(0, health - 30)
	if(!health && status)
		toggle_cam(user, 0)

/obj/machinery/camera/attackby(obj/W, mob/living/user, params)
	var/msg = "<span class='notice'>You attach [W] into the assembly's inner circuits.</span>"
	var/msg2 = "<span class='notice'>[src] already has that upgrade!</span>"

	// DECONSTRUCTION
	if(istype(W, /obj/item/weapon/screwdriver))
		panel_open = !panel_open
		user << "<span class='notice'>You screw the camera's panel [panel_open ? "open" : "closed"].</span>"
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		return

	if(panel_open)
		if(istype(W, /obj/item/weapon/wirecutters)) //enable/disable the camera
			toggle_cam(user, 1)
			health = initial(health) //this is a pretty simplistic way to heal the camera, but there's no reason for this to be complex.

		else if(istype(W, /obj/item/device/multitool)) //change focus
			setViewRange((view_range == initial(view_range)) ? short_range : initial(view_range))
			user << "<span class='notice'>You [(view_range == initial(view_range)) ? "restore" : "mess up"] the camera's focus.</span>"

		else if(istype(W, /obj/item/weapon/weldingtool))
			if(weld(W, user))
				visible_message("<span class='warning'>[user] unwelds [src], leaving it as just a frame screwed to the wall.</span>", "<span class='warning'>You unweld [src], leaving it as just a frame screwed to the wall</span>")
				if(!assembly)
					assembly = new()
				assembly.loc = src.loc
				assembly.state = 1
				assembly.dir = src.dir
				assembly = null
				qdel(src)
				return

		else if(istype(W, /obj/item/device/analyzer))
			if(!isXRay())
				upgradeXRay()
				qdel(W)
				user << "[msg]"
			else
				user << "[msg2]"

		else if(istype(W, /obj/item/stack/sheet/mineral/plasma))
			if(!isEmpProof())
				upgradeEmpProof()
				user << "[msg]"
				qdel(W)
			else
				user << "[msg2]"
		else if(istype(W, /obj/item/device/assembly/prox_sensor))
			if(!isMotion())
				upgradeMotion()
				user << "[msg]"
				qdel(W)
			else
				user << "[msg2]"

	// OTHER
	if((istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/device/pda)) && isliving(user))
		var/mob/living/U = user
		var/obj/item/weapon/paper/X = null
		var/obj/item/device/pda/P = null

		var/itemname = ""
		var/info = ""
		if(istype(W, /obj/item/weapon/paper))
			X = W
			itemname = X.name
			info = X.info
		else
			P = W
			itemname = P.name
			info = P.notehtml
		U << "<span class='notice'>You hold \the [itemname] up to the camera...</span>"
		U.changeNext_move(CLICK_CD_MELEE)
		for(var/mob/O in player_list)
			if(istype(O, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = O
				if(AI.control_disabled || (AI.stat == DEAD))
					return
				if(U.name == "Unknown")
					AI << "<b>[U]</b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ..."
				else
					AI << "<b><a href='?src=\ref[AI];track=[html_encode(U.name)]'>[U]</a></b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ..."
				AI.last_paper_seen = "<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"
			else if (O.client && O.client.eye == src)
				O << "[U] holds \a [itemname] up to one of the cameras ..."
				O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))

	else if (istype(W, /obj/item/device/camera_bug))
		if (!src.can_use())
			user << "<span class='notice'>Camera non-functional.</span>"
			return
		if(istype(src.bug))
			user << "<span class='notice'>Camera bug removed.</span>"
			src.bug.bugged_cameras -= src.c_tag
			src.bug = null
		else
			user << "<span class='notice'>Camera bugged.</span>"
			src.bug = W
			src.bug.bugged_cameras[src.c_tag] = src

	else if(istype(W, /obj/item/device/laser_pointer))
		var/obj/item/device/laser_pointer/L = W
		L.laser_act(src, user)

	else
		if(W.force >= 10) //fairly simplistic, but will do for now.
			user.changeNext_move(CLICK_CD_MELEE)
			visible_message("<span class='warning'>[user] hits [src] with [W]!</span>", "<span class='warning'>You hit [src] with [W]!</span>")
			health = max(0, health - W.force)
			user.do_attack_animation(src)
			if(!health && status)
				triggerCameraAlarm()
				toggle_cam(user, 1)
	return

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = 1)
	status = !status
	if(can_use())
		cameranet.addCamera(src)
	else
		SetLuminosity(0)
		cameranet.removeCamera(src)
	cameranet.updateChunk(x, y, z)
	var/change_msg = "deactivates"
	if(!status)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = initial(icon_state)
		change_msg = "reactivates"
		triggerCameraAlarm()
		spawn(100)
			if(!qdeleted(src))
				cancelCameraAlarm()
	if(displaymessage)
		if(user)
			visible_message("<span class='danger'>[user] [change_msg] [src]!</span>")
			add_hiddenprint(user)
		else
			visible_message("<span class='danger'>\The [src] [change_msg]!</span>")

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in player_list)
		if (O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_perspective(null)
			O << "The screen bursts into static."

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = 1
	for(var/mob/living/silicon/S in mob_list)
		S.triggerAlarm("Camera", get_area(src), list(src), src)

/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = 0
	for(var/mob/living/silicon/S in mob_list)
		S.cancelAlarm("Camera", get_area(src), src)

/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & EMPED)
		return 0
	return 1

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = get_hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					src.dir = SOUTH
				if(SOUTH)
					src.dir = NORTH
				if(WEST)
					src.dir = EAST
				if(EAST)
					src.dir = WEST
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break
	return null

/proc/near_range_camera(var/mob/M)
	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break

	return null

/obj/machinery/camera/proc/weld(obj/item/weapon/weldingtool/WT, mob/living/user)
	if(busy)
		return 0
	if(!WT.remove_fuel(0, user))
		return 0

	user << "<span class='notice'>You start to weld [src]...</span>"
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	busy = 1
	if(do_after(user, 100, target = src))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0

/obj/machinery/camera/proc/Togglelight(on=0)
	for(var/mob/living/silicon/ai/A in ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		src.SetLuminosity(AI_CAMERA_LUMINOSITY)
	else
		src.SetLuminosity(0)

/obj/machinery/camera/bullet_act(obj/item/projectile/proj)
	if(proj.damage_type == BRUTE)
		health = max(0, health - proj.damage)
		if(!health && status)
			triggerCameraAlarm()
			toggle_cam(null, 1)

/obj/machinery/camera/portable //Cameras which are placed inside of things, such as helmets.
	var/turf/prev_turf

/obj/machinery/camera/portable/New()
	..()
	assembly.state = 0 //These cameras are portable, and so shall be in the portable state if removed.
	assembly.anchored = 0
	assembly.update_icon()

/obj/machinery/camera/portable/process() //Updates whenever the camera is moved.
	if(cameranet && get_turf(src) != prev_turf)
		cameranet.updatePortableCamera(src)
		prev_turf = get_turf(src)

/obj/machinery/camera/get_remote_view_fullscreens(mob/user)
	if(view_range == short_range) //unfocused
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/obj/machinery/camera/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING //can't see ghosts through cameras
	if(isXRay())
		user.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		user.see_in_dark = max(user.see_in_dark, 8)
	else
		user.sight = 0
		user.see_in_dark = 2
	return 1
