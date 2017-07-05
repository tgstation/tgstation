/*
All ShuttleMove procs go here
*/

/************************************Base procs************************************/

// Called on every turf in the shuttle region, return false if it doesn't want to move
/turf/proc/fromShuttleMove(turf/newT, turf_type, baseturf_type)
	if(type == turf_type && baseturf == baseturf_type)
		return FALSE
	return TRUE

// Called from the new turf before anything has been moved
/turf/proc/toShuttleMove(turf/oldT)
	return TRUE

// Called on the old turf to move the turf data
/turf/proc/onShuttleMove(turf/newT, turf_type, baseturf_type, rotation, list/movement_force)
	//Destination turf changes
	SSair.remove_from_active(newT)
	copyTurf(newT)
	newT.CalculateAdjacentTurfs()
	SSair.add_to_active(newT, TRUE)

	//Source turf changes
	SSair.remove_from_active(src)
	ChangeTurf(turf_type, FALSE, FALSE, baseturf_type)
	CalculateAdjacentTurfs()
	SSair.add_to_active(src, TRUE)

	return TRUE

// Called on the new turf after everything has been moved
/turf/proc/afterShuttleMove(turf/oldT)
	return TRUE

/////////////////////////////////////////////////////////////////////////////////////

// Called on every atom in shuttle turf contents before anything has been moved
// Return true if it should be moved regardless of turf being moved
/atom/movable/proc/beforeShuttleMove(turf/newT, rotation)
	return FALSE

// Called on atoms to move the atom to the new location
/atom/movable/proc/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force)
	if(locs && locs.len > 1)
		if(loc != oldT)
			return FALSE
	if(rotation)
		shuttleRotate(rotation)
	loc = newT
	if(length(client_mobs_in_contents))
		update_parallax_contents()
	return TRUE

// Called on atoms after everything has been moved
/atom/movable/proc/afterShuttleMove(list/movement_force)
	if(light)
		update_light()
	return TRUE

/////////////////////////////////////////////////////////////////////////////////////

// Called on areas before anything has been moved
/area/proc/beforeShuttleMove()
	return TRUE

// Called on areas to move their turf between areas
/area/proc/onShuttleMove(turf/oldT, turf/newT, area/underlying_old_area)
	contents -= oldT
	underlying_old_area.contents += oldT
	oldT.change_area(src, underlying_old_area)

	var/area/old_dest_area = newT.loc
	old_dest_area.contents -= newT
	contents += newT
	newT.change_area(old_dest_area, src)
	return TRUE

// Called on areas after everything has been moved
/area/proc/afterShuttleMove()
	return TRUE

/************************************Shuttle Rotation************************************/

/atom/proc/shuttleRotate(rotation)
	//rotate our direction
	setDir(angle2dir(rotation+dir2angle(dir)))

	//resmooth if need be.
	if(smooth)
		queue_smooth(src)

	//rotate the pixel offsets too.
	if (pixel_x || pixel_y)
		if (rotation < 0)
			rotation += 360
		for (var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))

/************************************Turf move procs************************************/

/turf/open/onShuttleMove(turf/newT, turf_type, baseturf_type, rotation, list/movement_force)
	. = ..()
	var/turf/open/newOpen = newT
	newOpen.copy_air_with_tile(src)

/************************************Machinery move procs************************************/

/obj/machinery/door/airlock/beforeShuttleMove()
	. = ..()
	shuttledocked = 0
	for(var/obj/machinery/door/airlock/A in range(1, src))
		A.shuttledocked = 0
		A.air_tight = TRUE
		INVOKE_ASYNC(A, /obj/machinery/door/.proc/close)

/obj/machinery/door/airlock/afterShuttleMove()
	. = ..()
	shuttledocked =  1
	for(var/obj/machinery/door/airlock/A in range(1, src))
		A.shuttledocked = 1

/obj/machinery/camera/beforeShuttleMove()
	. = ..()
	GLOB.cameranet.removeCamera(src)
	GLOB.cameranet.updateChunk()
	return TRUE

/obj/machinery/camera/afterShuttleMove()
	. = ..()
	if(can_use())
		GLOB.cameranet.addCamera(src)
	var/datum/camerachunk/chunk = GLOB.cameranet.getCameraChunk(x, y, z)
	chunk.hasChanged(TRUE)

/obj/machinery/telecomms/onShuttleMove(turf/T1)
	. = ..()
	if(. && T1) // Update listening Z, just in case you have telecomm relay on a shuttle
		listening_level = T1.z

/obj/machinery/mech_bay_recharge_port/afterShuttleMove()
	. = ..()
	recharging_turf = get_step(loc, dir)

/obj/machinery/atmospherics/afterShuttleMove()
	. = ..()
	if(pipe_vision_img)
		pipe_vision_img.loc = loc

/obj/machinery/computer/auxillary_base/onShuttleMove(turf/T1)
	. = ..()
	if(z == ZLEVEL_MINING) //Avoids double logging and landing on other Z-levels due to badminnery
		SSblackbox.add_details("colonies_dropped", "[x]|[y]|[z]") //Number of times a base has been dropped!

/obj/machinery/gravity_generator/main/beforeShuttleMove()
	. = ..()
	on = FALSE
	update_list()

/obj/machinery/gravity_generator/main/afterShuttleMove()
	. = ..()
	if(charge_count != 0 && charging_state != POWER_UP)
		on = TRUE
	update_list()

/obj/machinery/thruster/beforeShuttleMove()
	. = ..()
	. = TRUE

//Properly updates pipes on shuttle movement
/obj/machinery/atmospherics/shuttleRotate(rotation)
	var/list/real_node_connect = getNodeConnects()
	for(DEVICE_TYPE_LOOP)
		real_node_connect[I] = angle2dir(rotation+dir2angle(real_node_connect[I]))

	. = ..()
	SetInitDirections()
	var/list/supposed_node_connect = getNodeConnects()
	var/list/nodes_copy = nodes.Copy()

	for(DEVICE_TYPE_LOOP)
		var/new_pos = supposed_node_connect.Find(real_node_connect[I])
		nodes[new_pos] = nodes_copy[I]

/obj/machinery/atmospherics/afterShuttleMove()
	. = ..()
	var/missing_nodes = FALSE
	for(DEVICE_TYPE_LOOP)
		if(src.nodes[I])
			var/obj/machinery/atmospherics/node = src.nodes[I]
			var/connected = FALSE
			for(var/D in GLOB.cardinals)
				if(node in get_step(src, D))
					connected = TRUE
					break

			if(!connected)
				nullifyNode(I)

		if(!src.nodes[I])
			missing_nodes = TRUE

	if(missing_nodes)
		atmosinit()
		for(var/obj/machinery/atmospherics/A in pipeline_expansion())
			A.atmosinit()
			if(A.returnPipenet())
				A.addMember(src)
		build_network()
	else
		// atmosinit() calls update_icon(), so we don't need to call it
		update_icon()

/obj/machinery/atmospherics/pipe/afterShuttleMove()
	. = ..()
	var/turf/T = loc
	hide(T.intact)

/obj/machinery/navbeacon/beforeShuttleMove()
	. = ..()
	GLOB.navbeacons["[z]"] -= src
	GLOB.deliverybeacons -= src

/obj/machinery/navbeacon/afterShuttleMove()
	. = ..()
	var/turf/T = loc
	hide(T.intact)
	if(codes["patrol"])
		if(!GLOB.navbeacons["[z]"])
			GLOB.navbeacons["[z]"] = list()
		GLOB.navbeacons["[z]"] += src //Register with the patrol list!
	if(codes["delivery"])
		GLOB.deliverybeacons += src
		GLOB.deliverybeacontags += location

/obj/machinery/power/terminal/afterShuttleMove()
	. = ..()
	var/turf/T = src.loc
	if(level==1)
		hide(T.intact)

/************************************Item move procs************************************/

/obj/item/weapon/storage/pod/onShuttleMove()
	unlocked = TRUE
	// If the pod was launched, the storage will always open.
	return ..()

/************************************Mob move procs************************************/

/mob/onShuttleMove()
	if(!move_on_shuttle)
		return 0
	. = ..()
	if(!.)
		return
	if(client)
		if(buckled)
			shake_camera(src, 2, 1) // turn it down a bit come on
		else
			shake_camera(src, 7, 1)

/mob/living/carbon/afterShuttleMove(turf/T1, turf/T0, rotation, list/movement_force = list("KNOCKDOWN" = 3, "THROW" = 0))
	. = ..()
	if(movement_force && !buckled)
		if(movement_force["KNOCKDOWN"])
			Knockdown(movement_force["KNOCKDOWN"])
		if(movement_force["THROW"])
			var/throw_dir = pick(GLOB.cardinal)
			var/turf/target = get_edge_target_turf(src, throw_dir)
			var/range = movement_force["THROW"]
			var/speed = range/5
			src.throw_at(target, range, speed)

/mob/living/simple_animal/hostile/megafauna/onShuttleMove()
	var/turf/oldT = loc
	. = ..()
	message_admins("Megafauna [src] [ADMIN_FLW(src)] moved via shuttle from [ADMIN_COORDJMP(oldT)] to [ADMIN_COORDJMP(loc)]")

/************************************Structure move procs************************************/

/obj/structure/grille/beforeShuttleMove()
	. = ..()
	. = TRUE

/obj/structure/lattice/beforeShuttleMove()
	. = ..()
	. = TRUE

/obj/structure/disposalpipe/afterShuttleMove()
	. = ..()
	update()

/obj/structure/cable/afterShuttleMove()
	. = ..()
	var/turf/T = loc
	if(level==1)
		hide(T.intact)

/************************************Misc move procs************************************/

/atom/movable/lighting_object/onShuttleMove()
	return FALSE

/atom/movable/light/onShuttleMove()
	return FALSE

/obj/docking_port/stationary/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force)
	var/obj/docking_port/mobile/docked_port = get_docked()
	if(!docked_port)
		docked_port = locate(/obj/docking_port/mobile) in newT

	if(docked_port && locate(/obj/docking_port/stationary) in newT)
		return FALSE 	//There's a mobile dock that's moving to the new turf to be with another stationary dock! After all I did for them...

	. = ..()

obj/docking_port/stationary/public_mining_dock/onShuttleMove()
	id = "mining_public" //It will not move with the base, but will become enabled as a docking point.
	return 0

/obj/effect/abstract/proximity_checker/onShuttleMove()
	//timer so it only happens once
	addtimer(CALLBACK(monitor, /datum/proximity_monitor/proc/SetRange, monitor.current_range, TRUE), 0, TIMER_UNIQUE)
