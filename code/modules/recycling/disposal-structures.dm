
// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
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
		if(M.client)
			M.reset_perspective(src)
		hasmob = 1

	//Checks 1 contents level deep. This means that players can be sent through disposals...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(O.contents)
			for(var/mob/living/M in O.contents)
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
	setDir(DOWN)
	move()

	return

// movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()
	set waitfor = 0
	var/obj/structure/disposalpipe/last
	while(active)
		var/obj/structure/disposalpipe/curr = loc
		last = curr
		curr = curr.transfer(src)
		if(!curr && active)
			last.expel(src, loc, dir)

		stoplag()
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
			M.reset_perspective(src)	// if a client mob, update eye to follow this holder
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

/obj/structure/disposalholder/ex_act(severity, target)
	return

// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0
	on_blueprints = TRUE
	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0// dir will contain dominant direction for junction pipes
	obj_integrity = 200
	max_integrity = 200
	armor = list(melee = 25, bullet = 10, laser = 10, energy = 100, bomb = 0, bio = 100, rad = 100, fire = 90, acid = 30)
	layer = DISPOSAL_PIPE_LAYER			// slightly lower than wires and other pipes
	var/base_icon_state	// initial icon state on map
	var/obj/structure/disposalconstruct/stored

	// new pipe, set the icon_state as on map
/obj/structure/disposalpipe/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	if(make_from && !QDELETED(make_from))
		base_icon_state = make_from.base_state
		setDir(make_from.dir)
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


	// pipe is deleted
	// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		H.active = 0
		var/turf/T = src.loc
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
	return transfer_to_dir(H, nextdir)

/obj/structure/disposalpipe/proc/transfer_to_dir(obj/structure/disposalholder/H, nextdir)
	H.setDir(nextdir)
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
		return P
	else			// if wasn't a pipe, then they're now in our turf
		H.loc = get_turf(src)
		return null

// update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/T = src.loc
	hide(T.intact && !isspaceturf(T))	// space never hides pipes

// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(var/intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM: 0	// hide if floor is intact
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
	var/eject_range = 5
	var/turf/open/floor/floorturf

	if(isfloorturf(T)) //intact floor, pop the tile
		floorturf = T
		if(floorturf.floor_tile)
			new floorturf.floor_tile(T)
		floorturf.make_plating()

	if(direction)		// direction is specified
		if(isspaceturf(T)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		eject_range = 10

	else if(floorturf)
		target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

	playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
	for(var/atom/movable/AM in H)
		AM.forceMove(src.loc)
		AM.pipe_eject(direction)
		if(target)
			AM.throw_at(target, eject_range, 1)
	H.vent_gas(T)
	qdel(H)


// pipe affected by explosion
/obj/structure/disposalpipe/contents_explosion(severity, target)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		H.contents_explosion(severity, target)


/obj/structure/disposalpipe/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 10)
		return 0
	. = ..()

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/disposalpipe/attackby(obj/item/I, mob/user, params)
	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(can_be_deconstructed(user))
			if(W.remove_fuel(0,user))
				playsound(src.loc, 'sound/items/welder2.ogg', 100, 1)
				to_chat(user, "<span class='notice'>You start slicing the disposal pipe...</span>")
				// check if anything changed over 2 seconds
				if(do_after(user,30, target = src))
					if(!src || !W.isOn()) return
					deconstruct()
					to_chat(user, "<span class='notice'>You slice the disposal pipe.</span>")
	else
		return ..()

//checks if something is blocking the deconstruction (e.g. trunk with a bin still linked to it)
/obj/structure/disposalpipe/proc/can_be_deconstructed()
	. = 1

// called when pipe is cut with welder
/obj/structure/disposalpipe/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			if(stored)
				var/turf/T = loc
				stored.loc = T
				transfer_fingerprints_to(stored)
				stored.setDir(dir)
				stored.density = 0
				stored.anchored = 1
				stored.update_icon()
		else
			for(var/D in GLOB.cardinal)
				if(D & dpdir)
					var/obj/structure/disposalpipe/broken/P = new(src.loc)
					P.setDir(D)
	qdel(src)


/obj/structure/disposalpipe/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct()

//Fixes dpdir on shuttle rotation
/obj/structure/disposalpipe/shuttleRotate(rotation)
	..()
	var/new_dpdir = 0
	for(var/D in GLOB.cardinal)
		if(dpdir & D)
			new_dpdir = new_dpdir | angle2dir(rotation+dir2angle(D))
	dpdir = new_dpdir


// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/Initialize()
	. = ..()
	if(stored.ptype == DISP_PIPE_STRAIGHT)
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)

	update()




//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/Initialize()
	. = ..()
	switch(stored.ptype)
		if(DISP_JUNCTION)
			dpdir = dir | turn(dir, -90) | turn(dir,180)
		if(DISP_JUNCTION_FLIP)
			dpdir = dir | turn(dir, 90) | turn(dir,180)
		if(DISP_YJUNCTION)
			dpdir = dir | turn(dir,90) | turn(dir, -90)
	update()


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
	desc = "An underfloor disposal pipe with a package sorting mechanism."
	icon_state = "pipe-j1s"
	var/sortType = 0
	// To be set in map editor.
	// Supports both singular numbers and strings of numbers similar to access level strings.
	// Look at the list called TAGGERLOCATIONS in /_globalvars/lists/flavor_misc.dm
	var/list/sortTypes = list()
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/examine(mob/user)
	..()
	if(sortTypes.len>0)
		to_chat(user, "It is tagged with the following tags:")
		for(var/t in sortTypes)
			to_chat(user, GLOB.TAGGERLOCATIONS[t])
	else
		to_chat(user, "It has no sorting tags set.")


/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(stored.ptype == DISP_SORTJUNCTION)
		sortdir = turn(posdir, -90)
	else
		icon_state = "pipe-j2s"
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/Initialize()
	. = ..()

	// Generate a list of soring tags.
	if(sortType)
		if(isnum(sortType))
			sortTypes |= sortType
		else if(istext(sortType))
			var/list/sorts = splittext(sortType,";")
			for(var/x in sorts)
				var/n = text2num(x)
				if(n)
					sortTypes |= n

	updatedir()
	update()

/obj/structure/disposalpipe/sortjunction/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag > 0)// Tag set
			if(O.currTag in sortTypes)
				sortTypes -= O.currTag
				to_chat(user, "<span class='notice'>Removed \"[GLOB.TAGGERLOCATIONS[O.currTag]]\" filter.</span>")
			else
				sortTypes |= O.currTag
				to_chat(user, "<span class='notice'>Added \"[GLOB.TAGGERLOCATIONS[O.currTag]]\" filter.</span>")
			playsound(src.loc, 'sound/machines/twobeep.ogg', 100, 1)
	else
		return ..()


// next direction to move
// if coming in from negdir, then next is primary dir or sortdir
// if coming in from posdir, then flip around and go back to posdir
// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(fromdir, sortTag)
	//var/flipdir = turn(fromdir, 180)
	if(fromdir != sortdir)	// probably came from the negdir

		if(sortTag in sortTypes) //if destination matches filtered type...
			return sortdir		// exit through sortdirection
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	return transfer_to_dir(H, nextdir)

//a three-way junction that sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/wrapsortjunction

	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects."
	icon_state = "pipe-j1s"
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/wrapsortjunction/Initialize()
	. = ..()
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
	return transfer_to_dir(H, nextdir)

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/Initialize()
	. = ..()
	dpdir = dir
	getlinked()
	update()

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

/obj/structure/disposalpipe/trunk/can_be_deconstructed(mob/user)
	if(linked)
		to_chat(user, "<span class='warning'>You need to deconstruct disposal machinery above this pipe!</span>")
	else
		. = 1

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
			src.expel(H, get_turf(src), 0)	// expel at turf
	return null

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

/obj/structure/disposalpipe/broken/Initialize()
	. = ..()
	update()

// the disposal outlet machine

/obj/structure/disposalpipe/broken/deconstruct()
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

/obj/structure/disposaloutlet/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()
	if(make_from)
		setDir(make_from.dir)
		make_from.loc = src
		stored = make_from
	else
		stored = new (src, DISP_END_OUTLET,dir)

	target = get_ranged_target_turf(src, dir, 10)

	trunk = locate() in loc
	if(trunk)
		trunk.linked = src	// link the pipe trunk to self

/obj/structure/disposaloutlet/Destroy()
	if(trunk)
		trunk.linked = null
	return ..()

// expel the contents of the holder object, then delete it
// called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(obj/structure/disposalholder/H)
	var/turf/T = get_turf(src)
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
			AM.forceMove(T)
			AM.pipe_eject(dir)
			AM.throw_at(target, eject_range, 1)

		H.vent_gas(T)
		qdel(H)
	return

/obj/structure/disposaloutlet/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(mode==0)
			mode=1
			playsound(src.loc, I.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You remove the screws around the power connection.</span>")
		else if(mode==1)
			mode=0
			playsound(src.loc, I.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You attach the screws around the power connection.</span>")

	else if(istype(I,/obj/item/weapon/weldingtool) && mode==1)
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/welder2.ogg', 100, 1)
			to_chat(user, "<span class='notice'>You start slicing the floorweld off \the [src]...</span>")
			if(do_after(user,20*I.toolspeed, target = src))
				if(!src || !W.isOn()) return
				to_chat(user, "<span class='notice'>You slice the floorweld off \the [src].</span>")
				stored.loc = loc
				src.transfer_fingerprints_to(stored)
				stored.update_icon()
				stored.anchored = 0
				stored.density = 1
				qdel(src)
	else
		return ..()



// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour

/atom/movable/proc/pipe_eject(direction)
	return

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	src.streak(dirs)

/obj/effect/decal/cleanable/robot_debris/gib/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	src.streak(dirs)
