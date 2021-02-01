// Disposal pipes

/obj/structure/disposalpipe
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	anchored = TRUE
	density = FALSE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	dir = NONE			// dir will contain dominant direction for junction pipes
	max_integrity = 200
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 90, ACID = 30)
	layer = DISPOSAL_PIPE_LAYER			// slightly lower than wires and other pipes
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	damage_deflection = 10
	var/dpdir = NONE					// bitmask of pipe directions
	var/initialize_dirs = NONE			// bitflags of pipe directions added on init, see \code\_DEFINES\pipe_construction.dm
	var/flip_type						// If set, the pipe is flippable and becomes this type when flipped
	var/obj/structure/disposalconstruct/stored


/obj/structure/disposalpipe/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	if(!QDELETED(make_from))
		setDir(make_from.dir)
		make_from.forceMove(src)
		stored = make_from
	else
		stored = new /obj/structure/disposalconstruct(src, null , SOUTH , FALSE , src)

	if(ISDIAGONALDIR(dir)) // Bent pipes already have all the dirs set
		initialize_dirs = NONE

	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir

		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= turn(dir, 180)

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

// pipe is deleted
// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		H.active = FALSE
		expel(H, get_turf(src), 0)
	QDEL_NULL(stored)
	return ..()

/obj/structure/disposalpipe/handle_atom_del(atom/A)
	if(A == stored && !QDELETED(src))
		stored = null
		deconstruct(FALSE) //pipe has broken.

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(obj/structure/disposalholder/H)
	return dpdir & (~turn(H.dir, 180))

// transfer the holder through this pipe segment
// overridden for special behaviour
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/H)
	return transfer_to_dir(H, nextdir(H))

/obj/structure/disposalpipe/proc/transfer_to_dir(obj/structure/disposalholder/H, nextdir)
	H.setDir(nextdir)
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(!P) // if there wasn't a pipe, then they'll be expelled.
		return
	// find other holder in next loc, if inactive merge it with current
	var/obj/structure/disposalholder/H2 = locate() in P
	if(H2 && !H2.active)
		H.merge(H2)

	H.forceMove(P)
	return P

// expel the held objects into a turf
// called when there is a break in the pipe
/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/H, turf/T, direction)
	if(!T)
		T = get_turf(src)
	var/turf/target
	var/eject_range = 5
	var/turf/open/floor/floorturf

	if(isfloorturf(T) && T.intact) //intact floor, pop the tile
		floorturf = T
		if(floorturf.floor_tile)
			new floorturf.floor_tile(T)
		floorturf.make_plating(TRUE)

	if(direction)		// direction is specified
		if(isspaceturf(T)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		eject_range = 10

	else if(floorturf)
		target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

	playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, FALSE)
	pipe_eject(H, direction, TRUE, target, eject_range)
	H.vent_gas(T)
	qdel(H)


// pipe affected by explosion
/obj/structure/disposalpipe/contents_explosion(severity, target)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		H.contents_explosion(severity, target)


//welding tool: unfasten and convert to obj/disposalconstruct
/obj/structure/disposalpipe/welder_act(mob/living/user, obj/item/I)
	..()
	if(!can_be_deconstructed(user))
		return TRUE

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	to_chat(user, "<span class='notice'>You start slicing [src]...</span>")
	if(I.use_tool(src, user, 30, volume=50))
		deconstruct()
		to_chat(user, "<span class='notice'>You slice [src].</span>")
	return TRUE

//checks if something is blocking the deconstruction (e.g. trunk with a bin still linked to it)
/obj/structure/disposalpipe/proc/can_be_deconstructed()
	return TRUE

// called when pipe is cut with welder
/obj/structure/disposalpipe/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			if(stored)
				stored.forceMove(loc)
				transfer_fingerprints_to(stored)
				stored.setDir(dir)
				stored = null
		else
			var/turf/T = get_turf(src)
			for(var/D in GLOB.cardinals)
				if(D & dpdir)
					var/obj/structure/disposalpipe/broken/P = new(T)
					P.setDir(D)
	qdel(src)


/obj/structure/disposalpipe/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()


// Straight/bent pipe segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe"
	initialize_dirs = DISP_DIR_FLIP


// A three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"
	initialize_dirs = DISP_DIR_RIGHT | DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/junction/flip

// next direction to move
// if coming in from secondary dirs, then next is primary dir
// if coming in from primary dir, then next is equal chance of other dirs
/obj/structure/disposalpipe/junction/nextdir(obj/structure/disposalholder/H)
	var/flipdir = turn(H.dir, 180)
	if(flipdir != dir)	// came from secondary dir, so exit through primary
		return dir

	else	// came from primary, so need to choose a secondary exit
		var/mask = dpdir & (~dir)	// get a mask of secondary dirs

		// find one secondary dir in mask
		var/secdir = NONE
		for(var/D in GLOB.cardinals)
			if(D & mask)
				secdir = D
				break

		if(prob(50))	// 50% chance to choose the found secondary dir
			return secdir
		else			// or the other one
			return mask & (~secdir)

/obj/structure/disposalpipe/junction/flip
	icon_state = "pipe-j2"
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/junction

/obj/structure/disposalpipe/junction/yjunction
	icon_state = "pipe-y"
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_RIGHT
	flip_type = null


//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/Initialize()
	. = ..()
	getlinked()

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
	var/turf/T = get_turf(src)
	var/obj/machinery/disposal/D = locate() in T
	if(D)
		linked = D
		if (!D.trunk)
			D.trunk = src

	var/obj/structure/disposaloutlet/O = locate() in T
	if(O)
		linked = O


/obj/structure/disposalpipe/trunk/can_be_deconstructed(mob/user)
	if(linked)
		to_chat(user, "<span class='warning'>You need to deconstruct disposal machinery above this pipe!</span>")
		return FALSE
	return TRUE

// would transfer to next pipe segment, but we are in a trunk
// if not entering from disposal bin,
// transfer to linked object (outlet or bin)
/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)
	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O))
			O.expel(H)	// expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			D.expel(H)	// expel at disposal

	// Returning null without expelling holder makes the holder expell itself
	return null

/obj/structure/disposalpipe/trunk/nextdir(obj/structure/disposalholder/H)
	if(H.dir == DOWN)
		return dir
	else
		return NONE

// a broken pipe
/obj/structure/disposalpipe/broken
	desc = "A broken piece of disposal pipe."
	icon_state = "pipe-b"
	initialize_dirs = DISP_DIR_NONE
	// broken pipes always have dpdir=0 so they're not found as 'real' pipes
	// i.e. will be treated as an empty turf

/obj/structure/disposalpipe/broken/deconstruct()
	qdel(src)
