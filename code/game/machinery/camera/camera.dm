/**
 * Camera assembly frame
 * Putting this on a wall will put a deconstructed camera machine on the wall.
 */
/obj/item/wallframe/camera
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "cameracase"
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.5,
	)
	result_path = /obj/machinery/camera/autoname/deconstructed
	wall_external = TRUE

/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "camera"
	base_icon_state = "camera"
	use_power = ACTIVE_POWER_USE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	layer = WALL_OBJ_LAYER
	resistance_flags = FIRE_PROOF
	damage_deflection = 12
	armor_type = /datum/armor/machinery_camera
	max_integrity = 100
	integrity_failure = 0.5

	///An analyzer in the camera being used for x-ray upgrade.
	var/obj/item/analyzer/xray_module
	///used to keep from revealing malf AI upgrades for user facing isXRay() checks when they use Upgrade Camera Network ability
	///will be false if the camera is upgraded with the proper parts.
	var/malf_xray_firmware_active
	///so the malf upgrade is restored when the normal upgrade part is removed.
	var/malf_xray_firmware_present
	///A sheet of plasma stored inside of the camera, giving it EMP protection.
	var/obj/item/stack/sheet/mineral/plasma/emp_module
	///used to keep from revealing malf AI upgrades for user facing isEmp() checks after they use Upgrade Camera Network ability
	///will be false if the camera is upgraded with the proper parts.
	var/malf_emp_firmware_active
	///so the malf upgrade is restored when the normal upgrade part is removed.
	var/malf_emp_firmware_present

	///The current state of the camera's construction, all mapped in ones start off already built.
	var/camera_construction_state = CAMERA_STATE_FINISHED

	///Bitflag of upgrades this camera has: (CAMERA_UPGRADE_XRAY | CAMERA_UPGRADE_EMP_PROOF | CAMERA_UPGRADE_MOTION)
	var/camera_upgrade_bitflags = NONE

	///List of all networks that can see this camera through the security console.
	var/list/network = list(CAMERANET_NETWORK_SS13)
	///The tag the camera has, which is essentially its name to security camera consoles.
	var/c_tag = null
	///Boolean on whether the camera is activated, so can be seen on camera consoles or will just be static.
	var/camera_enabled = TRUE
	///Boolean for special cameras to bypass the random chance of being broken on roundstart.
	var/start_active = FALSE
	///The area this camera is built in, which we will add/remove ourselves to the list of cameras in that area from.
	var/area/myarea = null

	///The max range (and default range) the camera can see.
	var/view_range = 7
	///The short range the camera can see, if tampered with to be short-sighted.
	var/short_range = 2

	///Boolean on whether the camera's alarm is triggered.
	var/alarm_on = FALSE
	///How many times this camera has been EMP'ed consecutively, will reset back to 0 when fixed.
	var/emped
	///Boolean on whether the AI can even turn on this camera's light- borg cameras dont have one, for example.
	var/internal_light = TRUE
	///Number of AIs watching this camera with lights on, used for icons.
	var/in_use_lights = 0

	///Represents a signal source of camera alarms about movement or camera tampering
	var/datum/alarm_handler/alarm_manager
	///Proximity monitor associated with this atom, for motion sensitive cameras.
	var/datum/proximity_monitor/proximity_monitor

	/// A copy of the last paper object that was shown to this camera.
	var/obj/item/paper/last_shown_paper

	var/list/datum/weakref/localMotionTargets = list()
	var/detectTime = 0
	var/area/station/ai_monitored/area_motion = null
	var/alarm_delay = 30 // Don't forget, there's another 3 seconds in queueAlarm()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera/autoname, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera/autoname/motion, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera/emp_proof, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera/motion, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/camera/xray, 0)

/datum/armor/machinery_camera
	melee = 50
	bullet = 20
	laser = 20
	energy = 20
	fire = 90
	acid = 50

/obj/machinery/camera/Initialize(mapload, ndir, building)
	. = ..()

	if(building)
		setDir(ndir)

	for(var/network_name in network)
		network -= network_name
		network += LOWER_TEXT(network_name)

	GLOB.cameranet.cameras += src

	myarea = get_room_area()

	if(camera_enabled)
		GLOB.cameranet.addCamera(src)
		LAZYADD(myarea.cameras, src)
#ifdef MAP_TEST
		update_appearance()
#else
		if(mapload && !start_active && is_station_level(z) && prob(3))
			toggle_cam()
		else //this is handled by toggle_camera, so no need to update it twice.
			update_appearance()
#endif

	alarm_manager = new(src)
	find_and_hang_on_wall(directional = TRUE, \
		custom_drop_callback = CALLBACK(src, PROC_REF(deconstruct), FALSE))

/obj/machinery/camera/Destroy(force)
	if(can_use())
		toggle_cam(null, 0) //kick anyone viewing out and remove from the camera chunks
	GLOB.cameranet.removeCamera(src)
	GLOB.cameranet.cameras -= src
	cancelCameraAlarm()
	if(isarea(myarea))
		LAZYREMOVE(myarea.cameras, src)
	QDEL_NULL(alarm_manager)
	QDEL_NULL(last_shown_paper)
	QDEL_NULL(xray_module)
	QDEL_NULL(emp_module)
	QDEL_NULL(proximity_monitor)
	return ..()

/obj/machinery/camera/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	for(var/i in network)
		network -= i
		network += "[port.shuttle_id]_[i]"

/obj/machinery/camera/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == xray_module)
		xray_module = null
		update_appearance()
		if(malf_xray_firmware_present)
			malf_xray_firmware_active = malf_xray_firmware_present //re-enable firmware based upgrades after the part is removed.
		removeXRay(malf_xray_firmware_present) //make sure we don't remove MALF upgrades.

	else if(gone == emp_module)
		emp_module = null
		if(malf_emp_firmware_present)
			malf_emp_firmware_active = malf_emp_firmware_present //re-enable firmware based upgrades after the part is removed.
		removeEmpProof(malf_emp_firmware_present) //make sure we don't remove MALF upgrades

	else if(gone == proximity_monitor)
		emp_module = null
		removeMotion()

/obj/machinery/camera/proc/create_prox_monitor()
	if(!proximity_monitor)
		proximity_monitor = new(src, 1)
		RegisterSignal(proximity_monitor, COMSIG_QDELETING, PROC_REF(proximity_deleted))

/obj/machinery/camera/proc/proximity_deleted()
	SIGNAL_HANDLER
	proximity_monitor = null

/obj/machinery/camera/proc/set_area_motion(area/A)
	area_motion = A
	create_prox_monitor()

/obj/machinery/camera/examine(mob/user)
	. = ..()

	if(isEmpProof(TRUE)) //don't reveal it's upgraded if was done via MALF AI Upgrade Camera Network ability
		. += span_info("It has electromagnetic interference shielding installed.")
	else
		. += span_info("It can be shielded against electromagnetic interference with some <b>plasma</b>.")

	if(isXRay(TRUE)) //don't reveal it's upgraded if was done via MALF AI Upgrade Camera Network ability
		. += span_info("It has an X-ray photodiode installed.")
	else
		. += span_info("It can be upgraded with an X-ray photodiode with an <b>analyzer</b>.")

	if(isMotion())
		. += span_info("It has a proximity sensor installed.")
	else
		. += span_info("It can be upgraded with a <b>proximity sensor</b>.")

	if(!camera_enabled)
		. += span_info("It's currently deactivated.")
		if(!panel_open && powered())
			. += span_notice("You'll need to open its maintenance panel with a <b>screwdriver</b> to turn it back on.")

	if(panel_open)
		. += span_info("Its maintenance panel is currently open.")
		if(!camera_enabled && powered())
			. += span_info("It can reactivated with <b>wirecutters</b>.")

/obj/machinery/camera/emp_act(severity, reset_time = 90 SECONDS)
	. = ..()
	if(!camera_enabled)
		return
	if(. & EMP_PROTECT_SELF)
		return
	if(!prob(150 / severity))
		return
	network = list()
	GLOB.cameranet.removeCamera(src)
	set_machine_stat(machine_stat | EMPED)
	set_light(0)
	emped++ //Increase the number of consecutive EMP's
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(post_emp_reset), emped, network), reset_time)
	for(var/mob/M as anything in GLOB.player_list)
		if (M.client?.eye == src)
			M.reset_perspective(null)
			to_chat(M, span_warning("The screen bursts into static!"))

/obj/machinery/camera/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	//lasts twice as much so we don't have to constantly shoot cameras just to be S T E A L T H Y
	emp_act(EMP_LIGHT, reset_time = disrupt_duration * 2)
	return TRUE

/obj/machinery/camera/proc/post_emp_reset(thisemp, previous_network)
	if(QDELETED(src))
		return
	triggerCameraAlarm() //camera alarm triggers even if multiple EMPs are in effect.
	if(emped != thisemp) //Only fix it if the camera hasn't been EMP'd again
		return
	network = previous_network
	set_machine_stat(machine_stat & ~EMPED)
	update_appearance()
	if(can_use())
		GLOB.cameranet.addCamera(src)
	emped = 0 //Resets the consecutive EMP count
	addtimer(CALLBACK(src, PROC_REF(cancelCameraAlarm)), 10 SECONDS)

/obj/machinery/camera/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	if (!can_use())
		return
	user.switchCamera(src)

/obj/machinery/camera/proc/setViewRange(num = 7)
	src.view_range = num
	GLOB.cameranet.updateVisibility(src, 0)

/obj/machinery/camera/proc/shock(mob/living/user)
	if(!istype(user))
		return
	user.electrocute_act(10, src)

/obj/machinery/camera/singularity_pull(atom/singularity, current_size)
	if (camera_enabled && current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects and the camera is still active, turn off the camera as it gets ripped off the wall.
		toggle_cam(null, 0)
	return ..()

///Drops a specific upgrade and nulls it where necessary.
/obj/machinery/camera/proc/drop_upgrade(obj/item/upgrade_dropped)
	upgrade_dropped.forceMove(drop_location())
	if(upgrade_dropped == xray_module)
		xray_module = null
		if(malf_xray_firmware_present)
			malf_xray_firmware_active = malf_xray_firmware_present //re-enable firmware based upgrades after the part is removed.
		update_appearance()

	else if(upgrade_dropped == emp_module)
		emp_module = null
		if(malf_emp_firmware_present)
			malf_emp_firmware_active = malf_emp_firmware_present //re-enable firmware based upgrades after the part is removed.

	else if(upgrade_dropped == proximity_monitor)
		proximity_monitor = null

/obj/machinery/camera/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(machine_stat & BROKEN)
		return damage_amount
	. = ..()

/obj/machinery/camera/atom_break(damage_flag)
	if(!camera_enabled)
		return
	. = ..()
	if(.)
		triggerCameraAlarm()
		toggle_cam(null, 0)

/obj/machinery/camera/on_deconstruction(disassembled)
	if(!disassembled)
		if(camera_construction_state >= CAMERA_STATE_WIRED)
			new /obj/item/stack/cable_coil(drop_location(), 2)
		new /obj/item/stack/sheet/iron(loc)
		return

	var/obj/item/wallframe/camera/dropped_cam = new(drop_location())
	dropped_cam.update_integrity(dropped_cam.max_integrity * 0.5)
	if(camera_construction_state >= CAMERA_STATE_WIRED)
		new /obj/item/stack/cable_coil(drop_location(), 2)
	if(xray_module)
		drop_upgrade(xray_module)
	if(emp_module)
		drop_upgrade(emp_module)
	if(proximity_monitor)
		drop_upgrade(proximity_monitor)

/obj/machinery/camera/update_icon_state() //TO-DO: Make panel open states, xray camera, and indicator lights overlays instead.
	var/xray_module
	if(isXRay(TRUE))
		xray_module = "xray"

	if(!camera_enabled)
		icon_state = "[xray_module][base_icon_state]_off"
		return ..()
	if(machine_stat & EMPED)
		icon_state = "[xray_module][base_icon_state]_emp"
		return ..()
	icon_state = "[xray_module][base_icon_state][in_use_lights ? "_in_use" : ""]"
	return ..()

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = TRUE)
	camera_enabled = !camera_enabled
	if(can_use())
		GLOB.cameranet.addCamera(src)
		if (isturf(loc))
			myarea = get_area(src)
			LAZYADD(myarea.cameras, src)
		else
			myarea = null
	else
		set_light(0)
		GLOB.cameranet.removeCamera(src)
		if (isarea(myarea))
			LAZYREMOVE(myarea.cameras, src)
	// We are not guarenteed that the camera will be on a turf. account for that
	var/turf/our_turf = get_turf(src)
	GLOB.cameranet.updateChunk(our_turf.x, our_turf.y, our_turf.z)
	var/change_msg = "deactivates"
	if(camera_enabled)
		change_msg = "reactivates"
		triggerCameraAlarm()
		if(!QDELETED(src)) //We'll be doing it anyway in destroy
			addtimer(CALLBACK(src, PROC_REF(cancelCameraAlarm)), 10 SECONDS)
	if(displaymessage)
		if(user)
			visible_message(span_danger("[user] [change_msg] [src]!"))
			add_hiddenprint(user)
		else
			visible_message(span_danger("\The [src] [change_msg]!"))

		playsound(src, 'sound/items/tools/wirecutter.ogg', 100, TRUE)
	update_appearance() //update Initialize() if you remove this.

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O as anything in GLOB.player_list)
		if (O.client?.eye == src)
			O.reset_perspective(null)
			to_chat(O, span_warning("The screen bursts into static!"))

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = TRUE
	alarm_manager.send_alarm(ALARM_CAMERA, src, src)

/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = FALSE
	alarm_manager.clear_alarm(ALARM_CAMERA)

/obj/machinery/camera/proc/can_use()
	if(!camera_enabled)
		return FALSE
	if(machine_stat & EMPED)
		return FALSE
	return TRUE

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	var/turf/directly_above = GET_TURF_ABOVE(pos)
	var/check_lower = pos != get_lowest_turf(pos)
	var/check_higher = directly_above && istransparentturf(directly_above) && (pos != get_highest_turf(pos))

	if(isXRay())
		see = range(view_range, pos)
	else
		see = get_hear(view_range, pos)
	if(check_lower || check_higher)
		// Haha datum var access KILL ME
		for(var/turf/seen in see)
			if(check_lower)
				var/turf/visible = seen
				while(visible && istransparentturf(visible))
					var/turf/below = GET_TURF_BELOW(visible)
					for(var/turf/adjacent in range(1, below))
						see += adjacent
						see += adjacent.contents
					visible = below
			if(check_higher)
				var/turf/above = GET_TURF_ABOVE(seen)
				while(above && istransparentturf(above))
					for(var/turf/adjacent in range(1, above))
						see += adjacent
						see += adjacent.contents
					above = GET_TURF_ABOVE(above)
	return see

/obj/machinery/camera/proc/Togglelight(on=0)
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		set_light(AI_CAMERA_LUMINOSITY)
	else
		set_light(0)

/obj/machinery/camera/get_remote_view_fullscreens(mob/user)
	if(view_range == short_range) //unfocused
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)

/obj/machinery/camera/update_remote_sight(mob/living/user)
	user.set_invis_see(SEE_INVISIBLE_LIVING) //can't see ghosts through cameras
	if(isXRay())
		user.add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
	else
		user.clear_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
	return TRUE

///Called when the camera starts being watched on a camera console.
/obj/machinery/camera/proc/on_start_watching()
	return

///Called when the camera stops being watched on a camera console.
/obj/machinery/camera/proc/on_stop_watching()
	return
