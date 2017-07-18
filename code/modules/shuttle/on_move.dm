<<<<<<< HEAD
// Called before shuttle starts moving atoms.
/atom/movable/proc/beforeShuttleMove(turf/T1, rotation)
	return
=======
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
// Only gets called if fromShuttleMove returns true first
/turf/proc/toShuttleMove(turf/oldT, shuttle_dir)
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

	return TRUE

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
	ChangeTurf(turf_type, FALSE, TRUE, baseturf_type)

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
/atom/movable/proc/onShuttleMove(turf/newT, turf/oldT, rotation, list/movement_force, move_dir)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return

	if(locs && locs.len > 1) // This is for multi tile objects
		if(loc != oldT)
			return
>>>>>>> c86e4370aa... Fixes a ... likely important bug with shuttle code.... (#29335)

// Called when shuttle attempts to move an atom.
/atom/movable/proc/onShuttleMove(turf/T1, rotation, knockdown = TRUE)
	if(rotation)
		shuttleRotate(rotation)
	loc = T1
	if (length(client_mobs_in_contents))
		update_parallax_contents()
	return 1

// Called after all of the atoms on shuttle are moved.
/atom/movable/proc/afterShuttleMove()
	return


/obj/onShuttleMove()
	if(invisibility >= INVISIBILITY_ABSTRACT)
		return 0
	. = ..()


/atom/movable/light/onShuttleMove()
	return 0

/obj/machinery/door/airlock/onShuttleMove()
	shuttledocked = 0
	for(var/obj/machinery/door/airlock/A in range(1, src))
		A.shuttledocked = 0
		A.air_tight = TRUE
		INVOKE_ASYNC(A, /obj/machinery/door/.proc/close)
	. = ..()
	shuttledocked =  1
	for(var/obj/machinery/door/airlock/A in range(1, src))
		A.shuttledocked = 1
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

/mob/living/carbon/onShuttleMove(turf/T1, rotation, knockdown = TRUE)
	. = ..()
	if(!.)
		return
	if(!buckled && knockdown)
		Knockdown(60)

/obj/effect/abstract/proximity_checker/onShuttleMove()
	//timer so it only happens once
	addtimer(CALLBACK(monitor, /datum/proximity_monitor/proc/SetRange, monitor.current_range, TRUE), 0, TIMER_UNIQUE)

// Shuttle Rotation //

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