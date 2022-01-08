// Disposal pipes

/obj/structure/disposalpipe
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	anchored = TRUE
	density = FALSE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	dir = NONE // dir will contain dominant direction for junction pipes
	max_integrity = 200
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 90, ACID = 30)
	layer = DISPOSAL_PIPE_LAYER // slightly lower than wires and other pipes
	damage_deflection = 10
	/// bitmask of pipe directions
	var/dpdir = NONE
	/// bitflags of pipe directions added on init, see \code\_DEFINES\pipe_construction.dm
	var/initialize_dirs = NONE
	/// If set, the pipe is flippable and becomes this type when flipped
	var/flip_type
	var/obj/structure/disposalconstruct/stored


/obj/structure/disposalpipe/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	associated_loc = get_turf(src)
	if(associated_loc)
		LAZYADD(associated_loc.nullspaced_contents, src)

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
		if(initialize_dirs & DISP_DIR_UP)
			dpdir |= UP
		if(initialize_dirs & DISP_DIR_DOWN)
			dpdir |= DOWN

	//AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, nullspace_target = TRUE)
	AddComponent(/datum/component/nullspace_undertile, invisibility_trait = TRAIT_T_RAY_VISIBLE, nullspace_when_underfloor_visible = FALSE)

// pipe is deleted
// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/holder = locate() in associated_loc
	if(holder)
		holder.active = FALSE
		expel(holder, associated_loc, 0)
	stored = null //The qdel is handled in expel()

	if(associated_loc)
		LAZYREMOVE(associated_loc.nullspaced_contents, src)

	return ..()

/obj/structure/disposalpipe/handle_atom_del(atom/A)
	if(A == stored && !QDELETED(src))
		stored = null
		deconstruct(FALSE) //pipe has broken.

/// returns the direction of the next pipe object, given the entrance dir.
/// by default, returns the bitfield of directions this pipe is connected in and the directions that holder didnt come from
/obj/structure/disposalpipe/proc/nextdir(obj/structure/disposalholder/holder)
	if(holder.dir == UP)
		return dpdir & ~DOWN//if holder is vertical, return everything shared between our directions and the opposite direction holder came from

	else if(holder.dir == DOWN)
		return dpdir & ~UP

	else //holder didnt come from a multiz turf
		return dpdir & ~turn(holder.dir & ~(UP|DOWN), 180)//turn() doesnt work with UP|DOWN so we need to make sure it doesnt get those directions

/// transfer the holder through this pipe segment.
/// overridden for special behaviour
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/holder)
	return transfer_to_dir(holder, nextdir(holder))

/obj/structure/disposalpipe/proc/transfer_to_dir(obj/structure/disposalholder/holder, nextdir)
	holder.setDir(nextdir)
	var/turf/destination_turf = holder.nextloc()
	var/obj/structure/disposalpipe/destination_pipe = holder.findpipe(destination_turf)

	if(!destination_pipe) // if there wasn't a pipe, then they'll be expelled.
		return
	// find other holder in next loc, if inactive merge it with current
	var/obj/structure/disposalholder/other_holder = locate() in destination_pipe.associated_loc
	if(other_holder && !other_holder.active)
		holder.merge(other_holder)

	holder.forceMove(destination_turf)
	return destination_pipe

// expel the held objects into a turf
// called when there is a break in the pipe
/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/holder, turf/target_turf, direction)
	if(!target_turf)
		target_turf = associated_loc
	var/turf/target
	var/eject_range = 5
	var/turf/open/floor/floorturf

	if(isfloorturf(target_turf) && target_turf.overfloor_placed) // pop the tile if present
		floorturf = target_turf
		if(floorturf.floor_tile)
			new floorturf.floor_tile(target_turf)
		floorturf.make_plating(TRUE)

	if(direction) // direction is specified
		if(isspaceturf(target_turf)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(target_turf, direction)
		else // otherwise limit to 10 tiles
			target = get_ranged_target_turf(target_turf, direction, 10)

		eject_range = 10

	else if(floorturf)
		target = get_offset_target_turf(target_turf, rand(5) - rand(5), rand(5) - rand(5))

	playsound(associated_loc, 'sound/machines/hiss.ogg', 50, FALSE, FALSE)
	pipe_eject(holder, direction, TRUE, target, eject_range)
	holder.vent_gas(target_turf)
	qdel(holder)


// pipe affected by explosion
/obj/structure/disposalpipe/contents_explosion(severity, target)
	var/obj/structure/disposalholder/holder = locate() in associated_loc
	holder?.contents_explosion(severity, target)


//welding tool: unfasten and convert to obj/disposalconstruct
/obj/structure/disposalpipe/welder_act(mob/living/user, obj/item/I)
	..()
	if(!can_be_deconstructed(user))
		return TRUE

	if(!I.tool_start_check(user, amount=0))
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
/obj/structure/disposalpipe/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			if(stored)
				stored.forceMove(associated_loc)
				transfer_fingerprints_to(stored)
				stored.setDir(dir)
				stored = null
			if (contents.len > 1) // if there is actually something in the pipe
				var/obj/structure/disposalholder/holder = locate() in src
				expel(holder, loc, dir)
		else
			for(var/direction in GLOB.cardinals)
				if(direction & dpdir)
					var/obj/structure/disposalpipe/broken/P = new(associated_loc)
					P.setDir(direction)
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

/// next direction to move.
/// if coming in from secondary dirs, then next is primary dir.
/// if coming in from primary dir, then next is equal chance of other dirs.
/obj/structure/disposalpipe/junction/nextdir(obj/structure/disposalholder/H)
	var/flipdir = turn(H.dir, 180)
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
	/// the linked obj/machinery/disposal or obj/disposaloutlet
	var/obj/linked

/obj/structure/disposalpipe/trunk/Initialize(mapload)
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
	var/obj/machinery/disposal/disposal_chute = locate() in associated_loc
	if(disposal_chute)
		linked = disposal_chute
		if (!disposal_chute.trunk)
			disposal_chute.trunk = src

	var/obj/structure/disposaloutlet/outlet = locate() in associated_loc
	if(outlet)
		linked = outlet


/obj/structure/disposalpipe/trunk/can_be_deconstructed(mob/user)
	if(linked)
		to_chat(user, span_warning("You need to deconstruct disposal machinery above this pipe!"))
		return FALSE
	return TRUE

// would transfer to next pipe segment, but we are in a trunk
// if not entering from disposal bin,
// transfer to linked object (outlet or bin)
/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/holder)
	if(holder.dir == DOWN || dpdir & (UP|DOWN)) // we just entered from a disposer or we're a multiz pipe
		return ..() // so do base transfer proc
	// otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/outlet = linked
		if(istype(outlet))
			outlet.expel(holder) // expel at outlet
		else
			var/obj/machinery/disposal/disposal_can = linked
			disposal_can.expel(holder) // expel at disposal

	// Returning null without expelling holder makes the holder expell itself
	return null

/obj/structure/disposalpipe/trunk/nextdir(obj/structure/disposalholder/holder)
	if(dpdir & (UP|DOWN))
		return ..()

	else if(holder.dir == DOWN)
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
