// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	dir = NONE
	/// gas used to flush, will appear at exit point
	var/datum/gas_mixture/gas
	/// true if the holder is moving, otherwise inactive
	var/active = FALSE
	/// can travel 1000 steps before going inactive (in case of loops)
	var/count = 1000
	/// changes if contains a delivery container
	var/destinationTag = NONE
	/// wether we contain a wrapped package
	var/tomail = FALSE
	/// whether we contain a mob
	var/hasmob = FALSE

/obj/structure/disposalholder/Destroy()
	active = FALSE
	return ..()

/// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(obj/machinery/disposal/D)
	gas = D.air_contents// transfer gas resv. into holder object

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M.client)
			M.reset_perspective(src)
		hasmob = TRUE

	//Checks 1 contents level deep. This means that players can be sent through disposals mail...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(locate(/mob/living) in O)
			hasmob = TRUE
			break

	// now everything inside the disposal gets put into the holder
	// note AM since can contain mobs or objs
	for(var/A in D)
		var/atom/movable/atom_in_transit = A
		if(atom_in_transit == src)
			continue
		SEND_SIGNAL(atom_in_transit, COMSIG_MOVABLE_DISPOSING, src, D, hasmob)
		atom_in_transit.forceMove(src)
		if(iscyborg(atom_in_transit))
			var/obj/item/dest_tagger/borg/tagger = locate() in atom_in_transit
			if(tagger)
				destinationTag = tagger.currTag


/// start the movement process.
/// argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src) // no trunk connected, so expel immediately
		return
	forceMove(D.trunk.associated_loc)
	active = TRUE
	setDir(DOWN)
	move(D.trunk)

/// movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move(obj/structure/disposalpipe/starting_node)
	set waitfor = FALSE
	var/ticks = 1
	var/obj/structure/disposalpipe/last_node = starting_node
	while(active)
		var/obj/structure/disposalpipe/current_node = last_node.transfer(src)

		set_glide_size(DELAY_TO_GLIDE_SIZE(ticks * world.tick_lag))

		if(!current_node && active)
			last_node.expel(src, get_turf(src), dir)
		last_node = current_node

		sleep(1)
		//ticks = stoplag()
		if(!(count--))
			active = FALSE

//failsafe in the case the holder is somehow forcemoved somewhere that doesnt have a disposals pipe. Otherwise the above loop breaks.
/obj/structure/disposalholder/Moved(atom/oldLoc, dir)
	. = ..()
	var/static/list/pipes_typecache = typecacheof(/obj/structure/disposalpipe)
	//Moved to nullspace gang

	var/turf/turf_loc = get_turf(src)

	if(!turf_loc)
		return

	var/has_possible_loc = FALSE

	for(var/obj/structure/disposalpipe/possible_loc in turf_loc?.disposals_nodes)
		if(pipes_typecache[possible_loc.type])
			has_possible_loc = TRUE
			break

	if(has_possible_loc)
		return

	vent_gas(turf_loc)

	for(var/atom/movable/movable_contents as anything in contents)
		movable_contents.forceMove(drop_location())

	qdel(src)

/// find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step_multiz(src, dir)

/// find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(turf/destination_turf)
	if(!destination_turf)
		return null

	var/fdir
	if(dir == UP)
		fdir = DOWN
	else if(dir == DOWN)
		fdir = UP
	else
		fdir = turn(dir, 180) // flip the movement direction (turn doesnt work with UP|DOWN)

	for(var/obj/structure/disposalpipe/destination_pipe in destination_turf.disposals_nodes)
		if(fdir & destination_pipe.dpdir) // find pipe direction mask that matches flipped dir
			return destination_pipe
	// if no matching pipe, return null
	return null

/// merge two holder objects.
/// used when a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(obj/structure/disposalholder/other)
	for(var/atom/movable/AM as anything in other)
		AM.forceMove(src) // move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			M.reset_perspective(src) // if a client mob, update eye to follow this holder
	qdel(other)


// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/living/user, direction)
	if(user.incapacitated())
		return
	for(var/mob/clangers as anything in SSspatial_grid.orthogonal_range_search(get_turf(src), SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, 5))
		clangers.show_message("<FONT size=[max(0, 5 - get_dist(src, clangers))]>CLONG, clong!</FONT>", MSG_AUDIBLE)

	playsound(src.loc, 'sound/effects/clang.ogg', 50, FALSE, FALSE)

// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(turf/T)
	T.assume_air(gas)

/obj/structure/disposalholder/AllowDrop()
	return TRUE

/obj/structure/disposalholder/ex_act(severity, target)
	return FALSE
