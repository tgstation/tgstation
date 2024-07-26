// Disposal pipes

/obj/structure/disposalpipe
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	icon = 'icons/obj/pipes_n_cables/disposal.dmi'
	anchored = TRUE
	density = FALSE
	obj_flags = CAN_BE_HIT
	dir = NONE // dir will contain dominant direction for junction pipes
	max_integrity = 200
	armor_type = /datum/armor/structure_disposalpipe
	plane = FLOOR_PLANE
	layer = DISPOSAL_PIPE_LAYER // slightly lower than wires and other pipes
	damage_deflection = 10
	var/dpdir = NONE // bitmask of pipe directions
	var/initialize_dirs = NONE // bitflags of pipe directions added on init, see \code\_DEFINES\pipe_construction.dm
	var/flip_type // If set, the pipe is flippable and becomes this type when flipped
	/// The pipe used to create us, if it exists
	/// (I like it when c4 carries over)
	var/obj/structure/disposalconstruct/stored
	/// Should we create a pipe on destroy?
	var/spawn_pipe = TRUE

/datum/armor/structure_disposalpipe
	melee = 25
	bullet = 10
	laser = 10
	energy = 100
	fire = 90
	acid = 30

/obj/structure/disposalpipe/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	if(!QDELETED(make_from))
		setDir(make_from.dir)
		make_from.forceMove(src)
		stored = make_from

	if(ISDIAGONALDIR(dir)) // Bent pipes already have all the dirs set
		initialize_dirs = NONE

	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir

		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= REVERSE_DIR(dir)

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)
	if(isturf(loc))
		var/turf/turf_loc = loc
		turf_loc.add_blueprints_preround(src)

/obj/structure/disposalpipe/Destroy()
	spawn_pipe = FALSE
	QDEL_NULL(stored)
	return ..()

/**
 * Expells the pipe's contents.
 *
 * This proc checks through src's contents for holder objects,
 * and then tells each one to empty onto the tile. Called when
 * the pipe is deconstructed or someone struggles out.
 */
/obj/structure/disposalpipe/proc/spew_forth()
	for(var/obj/structure/disposalholder/holdplease in src)
		if(!istype(holdplease))
			continue
		holdplease.active = FALSE
		expel(holdplease, get_turf(src), 0)
	stored = null // It gets dumped out in expel()

/obj/structure/disposalpipe/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != stored || QDELETED(src))
		return
	spawn_pipe = FALSE
	stored = null
	if(QDELETED(gone))
		deconstruct(FALSE) //pipe has broken.

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(obj/structure/disposalholder/H)
	return dpdir & (~REVERSE_DIR(H.dir))

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
		if(H2.hasmob) //If it's stopped and there's a mob, add to the pile
			H2.merge(H)
			return
		H.merge(H2)//Otherwise, we push it along through.
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

	if(isfloorturf(T) && T.overfloor_placed) // pop the tile if present
		floorturf = T
		if(floorturf.floor_tile)
			new floorturf.floor_tile(T)
		floorturf.make_plating(TRUE)

	if(direction) // direction is specified
		if(isspaceturf(T)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else // otherwise limit to 10 tiles
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
	H?.contents_explosion(severity, target)


//welding tool: unfasten and convert to obj/disposalconstruct
/obj/structure/disposalpipe/welder_act(mob/living/user, obj/item/I)
	..()
	if(!can_be_deconstructed(user))
		return TRUE

	if(!I.tool_start_check(user, amount=1))
		return TRUE

	to_chat(user, span_notice("You start slicing [src]..."))
	if(I.use_tool(src, user, 30, volume=50))
		deconstruct()
		to_chat(user, span_notice("You slice [src]."))
	return TRUE

//checks if something is blocking the deconstruction (e.g. trunk with a bin still linked to it)
/obj/structure/disposalpipe/proc/can_be_deconstructed()
	return TRUE

// called when pipe is cut with welder
/obj/structure/disposalpipe/atom_deconstruct(disassembled = TRUE)
	if(disassembled)
		if(spawn_pipe)
			var/obj/structure/disposalconstruct/construct = stored
			if(!construct) // Don't have something? Make one now
				construct = new /obj/structure/disposalconstruct(src, null, SOUTH, FALSE, src)
			stored = null
			construct.forceMove(loc)
			transfer_fingerprints_to(construct)
			construct.setDir(dir)
			spawn_pipe = FALSE
	else
		var/turf/location = get_turf(src)
		for(var/dir in GLOB.cardinals)
			if(dir & dpdir)
				var/obj/structure/disposalpipe/broken/pipe = new(location)
				pipe.setDir(dir)
	spew_forth()

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
	var/flipdir = REVERSE_DIR(H.dir)
	if(flipdir != dir) // came from secondary dir, so exit through primary
		return dir

	else // came from primary, so need to choose a secondary exit
		var/mask = dpdir & (~dir) // get a mask of secondary dirs

		// find one secondary dir in mask
		var/secdir = NONE
		for(var/D in GLOB.cardinals)
			if(D & mask)
				secdir = D
				break

		if(prob(50)) // 50% chance to choose the found secondary dir
			return secdir
		else // or the other one
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
	var/obj/linked // the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/Initialize(mapload)
	. = ..()
	getlinked()

/obj/structure/disposalpipe/trunk/Destroy()
	null_linked_ref_to_us()
	linked = null
	return ..()

/obj/structure/disposalpipe/trunk/proc/null_linked_ref_to_us()
	if(linked)
		if(istype(linked, /obj/structure/disposaloutlet))
			var/obj/structure/disposaloutlet/D = linked
			D.trunk = null
		else if(istype(linked, /obj/machinery/disposal))
			var/obj/machinery/disposal/D = linked
			D.trunk = null

/obj/structure/disposalpipe/trunk/proc/set_linked(obj/to_link)
	null_linked_ref_to_us()
	linked = to_link

/obj/structure/disposalpipe/trunk/proc/getlinked()
	null_linked_ref_to_us()
	linked = null
	var/turf/T = get_turf(src)
	var/obj/machinery/disposal/D = locate() in T
	if(D)
		set_linked(D)
	var/obj/structure/disposaloutlet/O = locate() in T
	if(O)
		set_linked(O)


/obj/structure/disposalpipe/trunk/can_be_deconstructed(mob/user)
	if(linked)
		to_chat(user, span_warning("You need to deconstruct disposal machinery above this pipe!"))
		return FALSE
	return TRUE

// would transfer to next pipe segment, but we are in a trunk
// if not entering from disposal bin,
// transfer to linked object (outlet or bin)
/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)
	if(H.dir == DOWN) // we just entered from a disposer
		return ..() // so do base transfer proc
	// otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O))
			O.expel(H) // expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			D.expel(H) // expel at disposal

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
	spawn_pipe = FALSE
	anchored = FALSE

/obj/structure/disposalpipe/rotator
	icon_state = "pipe-r1"
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_RIGHT | DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/rotator/flip
	/// In what direction the atom travels.
	var/direction_angle = -90

/obj/structure/disposalpipe/rotator/nextdir(obj/structure/disposalholder/holder)
	return turn(holder.dir, direction_angle)

/obj/structure/disposalpipe/rotator/flip
	icon_state = "pipe-r2"
	flip_type = /obj/structure/disposalpipe/rotator
	direction_angle = 90
