// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	dir = NONE
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	var/datum/gas_mixture/gas // gas used to flush, will appear at exit point
	var/active = FALSE // true if the holder is moving, otherwise inactive
	var/count = 1000 // can travel 1000 steps before going inactive (in case of loops)
	var/destinationTag = NONE // changes if contains a delivery container
	var/tomail = FALSE // contains wrapped package
	var/hasmob = FALSE // contains a mob

/obj/structure/disposalholder/Destroy()
	active = FALSE
	return ..()

// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(obj/machinery/disposal/D)
	gas = istype(D) ? D.air_contents : null// transfer gas resv. into holder object

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
	for(var/atom/movable/atom_in_transit as anything in D)
		if(atom_in_transit == src)
			continue
		SEND_SIGNAL(atom_in_transit, COMSIG_MOVABLE_DISPOSING, src, D, hasmob)
		atom_in_transit.forceMove(src)
		if(iscyborg(atom_in_transit))
			var/obj/item/dest_tagger/borg/tagger = locate() in atom_in_transit
			if(tagger)
				destinationTag = tagger.currTag


/// start the movement process
/// argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src) // no trunk connected, so expel immediately
		return
	forceMove(D.trunk.real_loc || D.trunk)
	active = TRUE
	setDir(DOWN)
	move()

/// movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()
	set waitfor = FALSE
	var/ticks = 1
	var/obj/structure/disposalpipe/last
	while(active)
		var/turf/current_turf = get_turf(src)
		var/obj/structure/disposalpipe/current_pipe_loc = locate() in (current_turf.nullspaced_contents | current_turf.contents) //TODOKYLER: make this not linked with loc but a reference to the disposal pipe it should be in

		last = current_pipe_loc
		set_glide_size(DELAY_TO_GLIDE_SIZE(ticks * world.tick_lag))
		current_pipe_loc = current_pipe_loc.transfer(src)
		if(!current_pipe_loc && active)
			last.expel(src, get_turf(real_loc || src), dir)

		ticks = stoplag()
		if(!(count--))
			active = FALSE

//failsafe in the case the holder is somehow forcemoved somewhere that's not a disposal pipe. Otherwise the above loop breaks.
/obj/structure/disposalholder/Moved(atom/oldLoc, dir)
	. = ..()
	var/static/list/pipes_typecache = typecacheof(/obj/structure/disposalpipe)
	//Moved to nullspace gang
	if(!loc)
		return
	var/obj/structure/disposalpipe/fake_loc = locate() in loc.nullspaced_contents | loc.contents
	if(!fake_loc)
		var/turf/T = get_turf(loc)
		if(T)
			vent_gas(T)
		for(var/atom/movable/contents_movable as anything in contents)
			contents_movable.forceMove(drop_location())
		qdel(src)

/// find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(real_loc || src, dir)

/// find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(turf/T)
	if(!T)
		return null

	var/fdir = turn(dir, 180) // flip the movement direction
	var/list/contents_to_check = T.nullspaced_contents | T.contents
	for(var/obj/structure/disposalpipe/P in contents_to_check)
		if(fdir & P.dpdir) // find pipe direction mask that matches flipped dir
			return P
	// if no matching pipe, return null
	return null

/// merge two holder objects
/// used when a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(obj/structure/disposalholder/other)
	for(var/atom/movable/other_holder_contents in other)
		other_holder_contents.forceMove(real_loc || src) // move everything in other holder to this one
		if(ismob(other_holder_contents))
			var/mob/disposed_mob = other_holder_contents
			disposed_mob.reset_perspective(other_holder_contents) // if a client mob, update eye to follow this holder
	qdel(other)


/// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/living/user, direction)
	if(user.incapacitated())
		return
	for(var/mob/M in range(5, get_turf(real_loc || src)))
		M.show_message("<FONT size=[max(0, 5 - get_dist(real_loc || src, M))]>CLONG, clong!</FONT>", MSG_AUDIBLE)
	playsound(real_loc || loc, 'sound/effects/clang.ogg', 50, FALSE, FALSE)

// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(turf/T)
	T.assume_air(gas)

/obj/structure/disposalholder/AllowDrop()
	return TRUE

/obj/structure/disposalholder/ex_act(severity, target)
	return FALSE
