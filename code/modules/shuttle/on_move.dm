/*
All ShuttleMove procs go here
*/

/************************************Base procs************************************/

// Called on every turf in the shuttle region, returns a bitflag for allowed movements of that turf
// returns the new move_mode (based on the old)
/turf/proc/fromShuttleMove(turf/newT, turf_type, list/baseturf_cache, move_mode)
	if(!(move_mode & MOVE_AREA) || (istype(src, turf_type) && baseturf_cache[baseturf]))
		return move_mode
	return move_mode | MOVE_TURF | MOVE_CONTENTS

// Called from the new turf before anything has been moved
// Only gets called if fromShuttleMove returns true first
// returns the new move_mode (based on the old)
/turf/proc/toShuttleMove(turf/oldT, shuttle_dir, move_mode)
	for(var/i in contents)
		var/atom/movable/thing = i
		if(ismob(thing))
			if(isliving(thing))
				var/mob/living/M = thing
				if(M.buckled)
					M.buckled.unbuckle_mob(M, 1)
				if(M.pulledby)
					M.pulledby.stop_pulling()
				M.stop_pulling()
				M.visible_message("<span class='warning'>[src] slams into [M]!</span>")
				if(M.key || M.get_ghost(TRUE))
					SSblackbox.add_details("shuttle_gib", "[type]")
				else
					SSblackbox.add_details("shuttle_gib_unintelligent", "[type]")
				M.gib()

		else //non-living mobs shouldn't be affected by shuttles, which is why this is an else
			if(istype(thing, /obj/singularity) && !istype(thing, /obj/singularity/narsie)) //it's a singularity but not a god, ignore it.
				continue
			if(!thing.anchored)
				step(thing, shuttle_dir)
			else
				qdel(thing)

	return move_mode

// Called on the old turf to move the turf data
/turf/proc/onShuttleMove(turf/newT, turf_type, baseturf_type, rotation, list/movement_force, move_dir)
	if(newT == src) // In case of in place shuttle rotation shenanigans.
		return

	//Destination turf changes
	var/destination_turf_type = newT.type
	copyTurf(newT)
	newT.baseturf = destination_turf_type

	if(isopenturf(newT))
		var/turf/open/new_open = newT
		new_open.copy_air_with_tile(src)

	//Source turf changes
	ChangeTurf(turf_type, baseturf_type, FALSE, TRUE)

	return TRUE

// Called on the new turf after everything has been moved
/turf/proc/afterShuttleMove(turf/oldT)
	if(SSlighting.initialized && FALSE)
		var/atom/movable/lighting_object/old_obj = lighting_object
		var/atom/movable/lighting_object/new_obj = oldT.lighting_object
		if(old_obj)
			old_obj.update()
		if(new_obj)
			new_obj.update()
	return TRUE

/////////////////////////////////////////////////////////////////////////////////////

// Called on every atom in shuttle turf contents before anything has been moved
// Return true if it should be moved regardless of turf being moved
/atom/movable/proc/beforeShuttleMove(turf/newT, rotation)
	return FALSE

// Called on atoms to move the atom to the new location
/atom/movable/proc/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return

	if(locs && locs.len > 1) // This is for multi tile objects
		if(loc != oldT)
			return

	if(rotation)
		shuttleRotate(rotation)
	loc = newT
	if(length(client_mobs_in_contents))
		update_parallax_contents()
	return TRUE

// Called on atoms after everything has been moved
/atom/movable/proc/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	if(light)
		update_light()
	return TRUE

/////////////////////////////////////////////////////////////////////////////////////

// Called on areas before anything has been moved
// returns the new move_mode (based on the old)
/area/proc/beforeShuttleMove(list/shuttle_areas)
	if(!shuttle_areas[src])
		return NONE
	return MOVE_AREA

// Called on areas to move their turf between areas
/area/proc/onShuttleMove(turf/oldT, turf/newT, area/underlying_old_area)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return TRUE

	contents -= oldT
	underlying_old_area.contents += oldT
	oldT.change_area(src, underlying_old_area)
	//The old turf has now been given back to the area that turf originaly belonged to

	var/area/old_dest_area = newT.loc
	parallax_movedir = old_dest_area.parallax_movedir
	
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

/turf/open/afterShuttleMove(turf/oldT) //Recalculates SSair stuff for turfs on both sides
	. = ..()
	SSair.remove_from_active(src)
	SSair.remove_from_active(oldT)

	src.CalculateAdjacentTurfs()
	oldT.CalculateAdjacentTurfs()

	SSair.add_to_active(src, TRUE)
	SSair.add_to_active(oldT, TRUE)

/************************************Machinery move procs************************************/

/obj/machinery/door/airlock/beforeShuttleMove(turf/newT, rotation)
	. = ..()
	shuttledocked = 0
	for(var/obj/machinery/door/airlock/A in range(1, src))
		A.shuttledocked = 0
		A.air_tight = TRUE
		INVOKE_ASYNC(A, /obj/machinery/door/.proc/close)

/obj/machinery/door/airlock/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	shuttledocked =  1
	for(var/obj/machinery/door/airlock/A in range(1, src))
		A.shuttledocked = 1

/obj/machinery/camera/beforeShuttleMove(turf/newT, rotation)
	. = ..()
	GLOB.cameranet.removeCamera(src)
	GLOB.cameranet.updateChunk()
	return TRUE

/obj/machinery/camera/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	if(can_use())
		GLOB.cameranet.addCamera(src)
	var/datum/camerachunk/chunk = GLOB.cameranet.getCameraChunk(x, y, z)
	chunk.hasChanged(TRUE)

/obj/machinery/telecomms/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	listening_level = z // Update listening Z, just in case you have telecomm relay on a shuttle

/obj/machinery/mech_bay_recharge_port/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	recharging_turf = get_step(loc, dir)

/obj/machinery/atmospherics/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	if(pipe_vision_img)
		pipe_vision_img.loc = loc

/obj/machinery/computer/auxillary_base/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	. = ..()
	if(z == ZLEVEL_MINING) //Avoids double logging and landing on other Z-levels due to badminnery
		SSblackbox.add_details("colonies_dropped", "[x]|[y]|[z]") //Number of times a base has been dropped!

/obj/machinery/gravity_generator/main/beforeShuttleMove(turf/newT, rotation)
	. = ..()
	on = FALSE
	update_list()

/obj/machinery/gravity_generator/main/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	if(charge_count != 0 && charging_state != POWER_UP)
		on = TRUE
	update_list()

/obj/machinery/thruster/beforeShuttleMove(turf/newT, rotation)
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

/obj/machinery/atmospherics/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
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

/obj/machinery/atmospherics/pipe/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	var/turf/T = loc
	hide(T.intact)

/obj/machinery/navbeacon/beforeShuttleMove(turf/newT, rotation)
	. = ..()
	GLOB.navbeacons["[z]"] -= src
	GLOB.deliverybeacons -= src

/obj/machinery/navbeacon/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
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

/obj/machinery/power/terminal/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	var/turf/T = src.loc
	if(level==1)
		hide(T.intact)

/************************************Item move procs************************************/

/obj/item/storage/pod/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	unlocked = TRUE
	// If the pod was launched, the storage will always open.
	return ..()

/************************************Mob move procs************************************/

/mob/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
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

/mob/living/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	if(movement_force && !buckled)
		if(movement_force["THROW"])
			var/throw_dir = move_dir
			var/turf/target = get_edge_target_turf(src, throw_dir)
			var/range = movement_force["THROW"]
			var/speed = range/5
			src.throw_at(target, range, speed)
		if(movement_force["KNOCKDOWN"])
			Knockdown(movement_force["KNOCKDOWN"])

/mob/living/simple_animal/hostile/megafauna/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	. = ..()
	message_admins("Megafauna [src] [ADMIN_FLW(src)] moved via shuttle from [ADMIN_COORDJMP(oldT)] to [ADMIN_COORDJMP(loc)]")

/************************************Structure move procs************************************/

/obj/structure/grille/beforeShuttleMove(turf/newT, rotation)
	. = ..()
	. = TRUE

/obj/structure/lattice/beforeShuttleMove(turf/newT, rotation)
	. = ..()
	. = TRUE

/obj/structure/disposalpipe/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	update()

/obj/structure/cable/afterShuttleMove(list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir)
	. = ..()
	var/turf/T = loc
	if(level==1)
		hide(T.intact)

/************************************Misc move procs************************************/

/atom/movable/lighting_object/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	return FALSE

/atom/movable/light/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	return FALSE

/obj/docking_port/stationary/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	if(old_dock == src) //Don't move the dock we're leaving
		return FALSE

	. = ..()

/obj/docking_port/stationary/public_mining_dock/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	id = "mining_public" //It will not move with the base, but will become enabled as a docking point.
	return 0

/obj/effect/abstract/proximity_checker/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir, old_dock)
	//timer so it only happens once
	addtimer(CALLBACK(monitor, /datum/proximity_monitor/proc/SetRange, monitor.current_range, TRUE), 0, TIMER_UNIQUE)
