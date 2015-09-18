// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = 101
	var/datum/gas_mixture/gas = null	// gas used to flush, will appear at exit point
	var/active = 0	// true if the holder is moving, otherwise inactive
	dir = 0
	var/count = 1000	//*** can travel 1000 steps before going inactive (in case of loops)
	var/destinationTag = 0 // changes if contains a delivery container
	var/tomail = 0 //changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob

/obj/structure/disposalholder/Destroy()
	qdel(gas)
	active = 0
	return ..()

	// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(obj/machinery/disposal/D)
	gas = D.air_contents// transfer gas resv. into holder object

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M && M.stat != DEAD)
			if(M.client)
				M.client.eye = src
			hasmob = 1

	//Checks 1 contents level deep. This means that players can be sent through disposals...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(O.contents)
			for(var/mob/living/M in O.contents)
				if(M && M.stat != DEAD)
					if(M.client)
						M.client.eye = src
					hasmob = 1

	// now everything inside the disposal gets put into the holder
	// note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.loc = src
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			src.destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			src.destinationTag = T.sortTag


// start the movement process
// argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src)	// no trunk connected, so expel immediately
		return
	loc = D.trunk
	active = 1
	dir = DOWN
	spawn(1)
		move()		// spawn off the movement process

	return

// movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()
	var/obj/structure/disposalpipe/last
	while(active)
		var/obj/structure/disposalpipe/curr = loc
		last = curr
		curr = curr.transfer(src)
		if(!curr && active)
			last.expel(src, loc, dir)

		sleep(1)
		if(!(count--))
			active = 0
	return

// find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(loc,dir)

// find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(turf/T)

	if(!T)
		return null

	var/fdir = turn(dir, 180)	// flip the movement direction
	for(var/obj/structure/disposalpipe/P in T)
		if(fdir & P.dpdir)		// find pipe direction mask that matches flipped dir
			return P
	// if no matching pipe, return null
	return null

// merge two holder objects
// used when a a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.loc = src		// move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)	// if a client mob, update eye to follow this holder
				M.client.eye = src
	qdel(other)


// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user)
	if (user.stat)
		return
	if (src.loc)
		for (var/mob/M in get_hearers_in_view(src.loc.loc))
			M.show_message("<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>", 2)
	playsound(src.loc, 'sound/effects/clang.ogg', 50, 0, 0)

// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(turf/T)
	T.assume_air(gas)
	T.air_update_turf()

/obj/structure/disposalholder/allow_drop()
	return 1

// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0

	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	layer = 2.3			// slightly lower than wires and other pipes
	var/base_icon_state	// initial icon state on map
	var/obj/structure/disposalconstruct/stored

	// new pipe, set the icon_state as on map
/obj/structure/disposalpipe/New(loc,var/obj/structure/disposalconstruct/make_from)
	..()

	if(make_from && !make_from.gc_destroyed)
		base_icon_state = make_from.base_state
		dir = make_from.dir
		dpdir = make_from.dpdir
		make_from.loc = src
		stored = make_from
	else
		base_icon_state = icon_state
		stored = new /obj/structure/disposalconstruct(src,direction=dir)
		switch(base_icon_state)
			if("pipe-s")
				stored.ptype = DISP_PIPE_STRAIGHT
			if("pipe-c")
				stored.ptype = DISP_PIPE_BENT
			if("pipe-j1")
				stored.ptype = DISP_JUNCTION
			if("pipe-j2")
				stored.ptype = DISP_JUNCTION_FLIP
			if("pipe-y")
				stored.ptype = DISP_YJUNCTION
			if("pipe-t")
				stored.ptype = DISP_END_TRUNK
			if("pipe-j1s")
				stored.ptype = DISP_SORTJUNCTION
			if("pipe-j2s")
				stored.ptype = DISP_SORTJUNCTION_FLIP
	return


	// pipe is deleted
	// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = 0
		var/turf/T = src.loc
		if(T.density)
			// deleting pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			return ..()

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)
	return ..()

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(fromdir)
	return dpdir & (~turn(fromdir, 180))

// transfer the holder through this pipe segment
// overriden for special behaviour
//
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			// if wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P


// update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/T = src.loc
	hide(T.intact && !istype(T,/turf/space))	// space never hides pipes

// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(var/intact)
	invisibility = intact ? 101: 0	// hide if floor is intact
	updateicon()

// update actual icon_state depending on visibility
// if invisible, append "f" to icon_state to show faded version
// this will be revealed if a T-scanner is used
// if visible, use regular icon_state
/obj/structure/disposalpipe/proc/updateicon()
	if(invisibility)
		icon_state = "[base_icon_state]f"
	else
		icon_state = base_icon_state
	return


// expel the held objects into a turf
// called when there is a break in the pipe
//

/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/H, turf/T, direction)

	var/turf/target

	if(istype(T, /turf/simulated/floor)) //intact floor, pop the tile
		var/turf/simulated/floor/myturf = T
		if(myturf.builtin_tile)
			myturf.builtin_tile.loc = T
			myturf.builtin_tile = null
		myturf.make_plating()

	if(direction)		// direction is specified
		if(istype(T, /turf/space)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		if(H)
			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(direction)
				spawn(1)
					if(AM)
						AM.throw_at(target, 10, 1)

	else	// no specified direction, so throw in random direction

		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.loc = T
				AM.pipe_eject(0)
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)
	H.vent_gas(T)
	qdel(H)
	return

// call to break the pipe
// will expel any holder inside at the time
// then delete the pipe
// remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(remains = 0)
	if(remains)
		for(var/D in cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(src.loc)
				P.dir = D

	src.invisibility = 101	// make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = 0
		var/turf/T = src.loc
		if(T.density)
			// broken pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			return

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)

	spawn(2)	// delete pipe after 2 ticks to ensure expel proc finished
		qdel(src)


// pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity, target)

	//pass on ex_act to our contents before calling it on ourself
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		H.contents_explosion(severity, target)

	switch(severity)
		if(1.0)
			broken(0)
			return
		if(2.0)
			health -= rand(5,15)
			healthcheck()
			return
		if(3.0)
			health -= rand(0,15)
			healthcheck()
			return


// test health for brokenness
/obj/structure/disposalpipe/proc/healthcheck()
	if(health < -2)
		broken(0)
	else if(health<1)
		broken(1)
	return

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/disposalpipe/attackby(obj/item/I, mob/user, params)

	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	src.add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
			user << "<span class='notice'>You start slicing the disposal pipe...</span>"
			// check if anything changed over 2 seconds
			if(do_after(user,30, target = src))
				if(!src || !W.isOn()) return
				Deconstruct()
				user << "<span class='notice'>You slice the disposal pipe.</span>"
		else
			return

// called when pipe is cut with welder
/obj/structure/disposalpipe/Deconstruct()
	if(stored)
		var/turf/T = loc
		stored.loc = T
		transfer_fingerprints_to(stored)
		stored.dir = dir
		stored.density = 0
		stored.anchored = 1
		stored.update()
		..()

/obj/structure/disposalpipe/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		Deconstruct()

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/New()
	..()
	if(stored.ptype == DISP_PIPE_STRAIGHT)
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)

	update()
	return




//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/New()
	..()
	switch(stored.ptype)
		if(DISP_JUNCTION)
			dpdir = dir | turn(dir, -90) | turn(dir,180)
		if(DISP_JUNCTION_FLIP)
			dpdir = dir | turn(dir, 90) | turn(dir,180)
		if(DISP_YJUNCTION)
			dpdir = dir | turn(dir,90) | turn(dir, -90)
	update()
	return


// next direction to move
// if coming in from secondary dirs, then next is primary dir
// if coming in from primary dir, then next is equal chance of other dirs

/obj/structure/disposalpipe/junction/nextdir(fromdir)
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)	// came from secondary dir
		return dir		// so exit through primary
	else				// came from primary
						// so need to choose either secondary exit
		var/mask = ..(fromdir)

		// find a bit which is set
		var/setbit = 0
		if(mask & NORTH)
			setbit = NORTH
		else if(mask & SOUTH)
			setbit = SOUTH
		else if(mask & EAST)
			setbit = EAST
		else
			setbit = WEST

		if(prob(50))	// 50% chance to choose the found bit or the other one
			return setbit
		else
			return mask & (~setbit)

//a three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction

	icon_state = "pipe-j1s"
	var/sortType = 0	//Look at the list called TAGGERLOCATIONS in flavor_misc.dm
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/proc/updatedesc()
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	if(sortType>0)
		var/tag = uppertext(TAGGERLOCATIONS[sortType])
		desc += "\nIt's tagged with [tag]"

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(stored.ptype == DISP_SORTJUNCTION)
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/New()
	..()
	updatedir()
	updatedesc()
	update()
	return

/obj/structure/disposalpipe/sortjunction/attackby(obj/item/I, mob/user, params)
	if(..())
		return

	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag > 0)// Tag set
			sortType = O.currTag
			playsound(src.loc, 'sound/machines/twobeep.ogg', 100, 1)
			var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
			user << "<span class='warning'>Changed filter to [tag].</span>"
			updatedesc()


// next direction to move
// if coming in from negdir, then next is primary dir or sortdir
// if coming in from posdir, then flip around and go back to posdir
// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(fromdir, sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(src.sortType == sortTag) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			// if wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P


//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction

	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/wrapsortjunction/New()
	..()
	posdir = dir
	if(stored.ptype == DISP_SORTJUNCTION)
		sortdir = turn(posdir, -90)
		negdir = turn(posdir, 180)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)
		negdir = turn(posdir, 180)
	dpdir = sortdir | posdir | negdir

	update()
	return

// next direction to move
// if coming in from negdir, then next is primary dir or sortdir
// if coming in from posdir, then flip around and go back to posdir
// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/wrapsortjunction/nextdir(fromdir, istomail)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(istomail) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/wrapsortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.tomail)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			// if wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P





//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/New()
	..()
	dpdir = dir
	spawn(1)
		getlinked()

	update()
	return

/obj/structure/disposalpipe/trunk/Destroy()
	if(linked)
		if(istype(linked, /obj/structure/disposaloutlet))
			var/obj/structure/disposaloutlet/D = linked
			D.trunk = null
		else if(istype(linked, /obj/machinery/disposal))
			var/obj/machinery/disposal/D = linked
			D.trunk = null
	return ..()

/obj/structure/disposalpipe/trunk/proc/getlinked()
	linked = null
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D)
		linked = D
		if (!D.trunk)
			D.trunk = src

	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O)
		linked = O

	update()
	return

	// Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(obj/item/I, mob/user, params)

	//Disposal bins or chutes
	/*
	These shouldn't be required
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D && D.anchored)
		return

	//Disposal outlet
	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O && O.anchored)
		return
	*/

	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in src.loc
	if(C && C.anchored)
		return

	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	src.add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I

		if(linked)
			user << "<span class='warning'>You need to deconstruct disposal machinery above this pipe!</span>"
			return

		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
			user << "<span class='notice'>You start slicing the disposal pipe...</span>"
			if(do_after(user,30, target = src))
				if(!src || !W.isOn()) return
				Deconstruct()
				user << "<span class='notice'>You slice the disposal pipe.</span>"
		else
			return

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)

/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)

	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O) && (H))
			O.expel(H)	// expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			if(H)
				D.expel(H)	// expel at disposal
	else
		if(H)
			src.expel(H, src.loc, 0)	// expel at turf
	return null

	// nextdir

/obj/structure/disposalpipe/trunk/nextdir(fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

// a broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

/obj/structure/disposalpipe/broken/New()
	..()
	update()
	return

// the disposal outlet machine

/obj/structure/disposalpipe/broken/Deconstruct()
	qdel(src)

/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "outlet"
	density = 1
	anchored = 1
	var/active = 0
	var/turf/target	// this will be where the output objects are 'thrown' to.
	var/obj/structure/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/obj/structure/disposalconstruct/stored
	var/mode = 0
	var/start_eject = 0
	var/eject_range = 2

/obj/structure/disposaloutlet/New(loc, var/obj/structure/disposalconstruct/make_from)
	..()

	if(make_from)
		dir = make_from.dir
		make_from.loc = src
		stored = make_from
	else
		stored = new (src, DISP_END_OUTLET,dir)

	spawn(1)
		target = get_ranged_target_turf(src, dir, 10)

		trunk = locate() in src.loc
		if(trunk)
			trunk.linked = src	// link the pipe trunk to self

/obj/structure/disposaloutlet/Destroy()
	if(trunk)
		trunk.linked = null
	return ..()

// expel the contents of the holder object, then delete it
// called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(obj/structure/disposalholder/H)

	flick("outlet-open", src)
	if((start_eject + 30) < world.time)
		start_eject = world.time
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, 0)
		sleep(20)
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
	else
		sleep(20)
	if(H)
		for(var/atom/movable/AM in H)
			AM.loc = src.loc
			AM.pipe_eject(dir)
			spawn(5)
				if(AM)
					AM.throw_at(target, eject_range, 1)
		H.vent_gas(src.loc)
		qdel(H)
	return

/obj/structure/disposaloutlet/attackby(obj/item/I, mob/user, params)
	if(!I || !user)
		return
	src.add_fingerprint(user)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(mode==0)
			mode=1
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='notice'>You remove the screws around the power connection.</span>"
			return
		else if(mode==1)
			mode=0
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='notice'>You attach the screws around the power connection.</span>"
			return
	else if(istype(I,/obj/item/weapon/weldingtool) && mode==1)
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
			user << "<span class='notice'>You start slicing the floorweld off \the [src]...</span>"
			if(do_after(user,20, target = src))
				if(!src || !W.isOn()) return
				user << "<span class='notice'>You slice the floorweld off \the [src].</span>"
				stored.loc = loc
				src.transfer_fingerprints_to(stored)
				stored.update()
				stored.anchored = 0
				stored.density = 1
				qdel(src)
			return
		else
			return



// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour

/atom/movable/proc/pipe_eject(direction)
	return

// check if mob has client, if so restore client view on eject
/mob/pipe_eject(var/direction)
	if (src.client)
		src.client.perspective = MOB_PERSPECTIVE
		src.client.eye = src

	return

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)

/obj/effect/decal/cleanable/robot_debris/gib/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)
