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
	layer = WALL_OBJ_LAYER

	resistance_flags = FIRE_PROOF

	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 90, acid = 50)
	obj_integrity = 100
	max_integrity = 100
	integrity_failure = 50
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1
	anchored = 1
	var/start_active = 0 //If it ignores the random chance to start broken on round start
	var/invuln = null
	var/obj/item/device/camera_bug/bug = null
	var/obj/structure/camera_assembly/assembly = null

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/alarm_on = 0
	var/busy = 0
	var/emped = 0  //Number of consecutive EMP's on this camera

	// Upgrades bitflag
	var/upgrades = 0

/obj/machinery/camera/Initialize(mapload)
	. = ..()
	assembly = new(src)
	assembly.state = 4
	GLOB.cameranet.cameras += src
	GLOB.cameranet.addCamera(src)
	proximity_monitor = new(src, 1)

	if(mapload && z == ZLEVEL_STATION && prob(3) && !start_active)
		toggle_cam()

/obj/machinery/camera/Destroy()
	toggle_cam(null, 0) //kick anyone viewing out
	if(assembly)
		qdel(assembly)
		assembly = null
	if(bug)
		bug.bugged_cameras -= src.c_tag
		if(bug.current == src)
			bug.current = null
		bug = null
	GLOB.cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	GLOB.cameranet.cameras -= src
	GLOB.cameranet.removeCamera(src)
	return ..()

/obj/machinery/camera/emp_act(severity)
	if(!status)
		return
	if(!isEmpProof())
		if(prob(150/severity))
			update_icon()
			var/list/previous_network = network
			network = list()
			GLOB.cameranet.removeCamera(src)
			stat |= EMPED
			set_light(0)
			emped = emped+1  //Increase the number of consecutive EMP's
			update_icon()
			var/thisemp = emped //Take note of which EMP this proc is for
			spawn(900)
				if(loc) //qdel limbo
					triggerCameraAlarm() //camera alarm triggers even if multiple EMPs are in effect.
					if(emped == thisemp) //Only fix it if the camera hasn't been EMP'd again
						network = previous_network
						stat &= ~EMPED
						update_icon()
						if(can_use())
							GLOB.cameranet.addCamera(src)
						emped = 0 //Resets the consecutive EMP count
						addtimer(CALLBACK(src, .proc/cancelCameraAlarm), 100)
			for(var/mob/O in GLOB.mob_list)
				if (O.client && O.client.eye == src)
					O.unset_machine()
					O.reset_perspective(null)
					to_chat(O, "The screen bursts into static.")
			..()

/obj/machinery/camera/tesla_act(var/power)//EMP proof upgrade also makes it tesla immune
	if(isEmpProof())
		return
	..()
	qdel(src)//to prevent bomb testing camera from exploding over and over forever

/obj/machinery/camera/ex_act(severity, target)
	if(invuln)
		return
	..()

/obj/machinery/camera/proc/setViewRange(num = 7)
	src.view_range = num
	GLOB.cameranet.updateVisibility(src, 0)

/obj/machinery/camera/proc/shock(mob/living/user)
	if(!istype(user))
		return
	user.electrocute_act(10, src)

/obj/machinery/camera/attackby(obj/item/W, mob/living/user, params)
	var/msg = "<span class='notice'>You attach [W] into the assembly's inner circuits.</span>"
	var/msg2 = "<span class='notice'>[src] already has that upgrade!</span>"

	// DECONSTRUCTION
	if(istype(W, /obj/item/weapon/screwdriver))
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You screw the camera's panel [panel_open ? "open" : "closed"].</span>")
		playsound(src.loc, W.usesound, 50, 1)
		return

	if(panel_open)
		if(istype(W, /obj/item/weapon/wirecutters)) //enable/disable the camera
			toggle_cam(user, 1)
			obj_integrity = max_integrity //this is a pretty simplistic way to heal the camera, but there's no reason for this to be complex.
			return

		else if(istype(W, /obj/item/device/multitool)) //change focus
			setViewRange((view_range == initial(view_range)) ? short_range : initial(view_range))
			to_chat(user, "<span class='notice'>You [(view_range == initial(view_range)) ? "restore" : "mess up"] the camera's focus.</span>")
			return

		else if(istype(W, /obj/item/weapon/weldingtool))
			if(weld(W, user))
				visible_message("<span class='warning'>[user] unwelds [src], leaving it as just a frame bolted to the wall.</span>", "<span class='warning'>You unweld [src], leaving it as just a frame bolted to the wall</span>")
				deconstruct(TRUE)
			return

		else if(istype(W, /obj/item/device/analyzer))
			if(!isXRay())
				if(!user.drop_item(W))
					return
				upgradeXRay()
				qdel(W)
				to_chat(user, "[msg]")
			else
				to_chat(user, "[msg2]")
			return

		else if(istype(W, /obj/item/stack/sheet/mineral/plasma))
			if(!isEmpProof())
				upgradeEmpProof()
				to_chat(user, "[msg]")
				qdel(W)
			else
				to_chat(user, "[msg2]")
			return

		else if(istype(W, /obj/item/device/assembly/prox_sensor))
			if(!isMotion())
				upgradeMotion()
				to_chat(user, "[msg]")
				qdel(W)
			else
				to_chat(user, "[msg2]")
			return

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
		to_chat(U, "<span class='notice'>You hold \the [itemname] up to the camera...</span>")
		U.changeNext_move(CLICK_CD_MELEE)
		for(var/mob/O in GLOB.player_list)
			if(isAI(O))
				var/mob/living/silicon/ai/AI = O
				if(AI.control_disabled || (AI.stat == DEAD))
					return
				if(U.name == "Unknown")
					to_chat(AI, "<b>[U]</b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				else
					to_chat(AI, "<b><a href='?src=\ref[AI];track=[html_encode(U.name)]'>[U]</a></b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				AI.last_paper_seen = "<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"
			else if (O.client && O.client.eye == src)
				to_chat(O, "[U] holds \a [itemname] up to one of the cameras ...")
				O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
		return

	else if(istype(W, /obj/item/device/camera_bug))
		if(!can_use())
			to_chat(user, "<span class='notice'>Camera non-functional.</span>")
			return
		if(bug)
			to_chat(user, "<span class='notice'>Camera bug removed.</span>")
			bug.bugged_cameras -= src.c_tag
			bug = null
		else
			to_chat(user, "<span class='notice'>Camera bugged.</span>")
			bug = W
			bug.bugged_cameras[src.c_tag] = src
		return

	else if(istype(W, /obj/item/weapon/pai_cable))
		var/obj/item/weapon/pai_cable/cable = W
		cable.plugin(src, user)
		return

	return ..()

/obj/machinery/camera/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 12 && !(stat & BROKEN))
		return 0
	. = ..()

/obj/machinery/camera/obj_break(damage_flag)
	if(status && !(flags & NODECONSTRUCT))
		triggerCameraAlarm()
		toggle_cam(null, 0)

/obj/machinery/camera/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			if(!assembly)
				assembly = new()
			assembly.loc = src.loc
			assembly.state = 1
			assembly.setDir(dir)
			assembly = null
		else
			var/obj/item/I = new /obj/item/wallframe/camera (loc)
			I.obj_integrity = I.max_integrity * 0.5
			new /obj/item/stack/cable_coil(loc, 2)
	qdel(src)

/obj/machinery/camera/update_icon()
	if(!status)
		icon_state = "[initial(icon_state)]1"
	else if (stat & EMPED)
		icon_state = "[initial(icon_state)]emp"
	else
		icon_state = "[initial(icon_state)]"

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = 1)
	status = !status
	if(can_use())
		GLOB.cameranet.addCamera(src)
	else
		set_light(0)
		GLOB.cameranet.removeCamera(src)
	GLOB.cameranet.updateChunk(x, y, z)
	var/change_msg = "deactivates"
	if(status)
		change_msg = "reactivates"
		triggerCameraAlarm()
		addtimer(CALLBACK(src, .proc/cancelCameraAlarm), 100)
	if(displaymessage)
		if(user)
			visible_message("<span class='danger'>[user] [change_msg] [src]!</span>")
			add_hiddenprint(user)
		else
			visible_message("<span class='danger'>\The [src] [change_msg]!</span>")

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
	update_icon()

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in GLOB.player_list)
		if (O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_perspective(null)
			to_chat(O, "The screen bursts into static.")

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = 1
	for(var/mob/living/silicon/S in GLOB.mob_list)
		S.triggerAlarm("Camera", get_area(src), list(src), src)

/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = 0
	for(var/mob/living/silicon/S in GLOB.mob_list)
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
	var/turf/closed/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					src.setDir(SOUTH)
				if(SOUTH)
					src.setDir(NORTH)
				if(WEST)
					src.setDir(EAST)
				if(EAST)
					src.setDir(WEST)
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

	to_chat(user, "<span class='notice'>You start to weld [src]...</span>")
	playsound(src.loc, WT.usesound, 50, 1)
	busy = 1
	if(do_after(user, 100*WT.toolspeed, target = src))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0

/obj/machinery/camera/proc/Togglelight(on=0)
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		set_light(AI_CAMERA_LUMINOSITY)
	else
		set_light(0)

/obj/machinery/camera/portable //Cameras which are placed inside of things, such as helmets.
	var/turf/prev_turf

/obj/machinery/camera/portable/Initialize()
	. = ..()
	assembly.state = 0 //These cameras are portable, and so shall be in the portable state if removed.
	assembly.anchored = 0
	assembly.update_icon()

/obj/machinery/camera/portable/process() //Updates whenever the camera is moved.
	if(GLOB.cameranet && get_turf(src) != prev_turf)
		GLOB.cameranet.updatePortableCamera(src)
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
