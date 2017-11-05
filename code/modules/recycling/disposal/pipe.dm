// Disposal pipes

/obj/structure/disposalpipe
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	anchored = TRUE
	density = FALSE
	on_blueprints = TRUE
	level = 1			// underfloor only
	dir = 0				// dir will contain dominant direction for junction pipes
	max_integrity = 200
	armor = list(melee = 25, bullet = 10, laser = 10, energy = 100, bomb = 0, bio = 100, rad = 100, fire = 90, acid = 30)
	layer = DISPOSAL_PIPE_LAYER			// slightly lower than wires and other pipes
	var/dpdir = 0						// bitmask of pipe directions
	var/initialize_dirs = 0				// bitflags of pipe directions added on init, see \_DEFINES\pipe_construction.dm
	var/construct_type					// If set, used as type for pipe constructs. If not set, src.type is used.
	var/flip_type						// If set, the pipe is flippable and becomes this type when flipped
	var/obj/structure/disposalconstruct/stored


/obj/structure/disposalpipe/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	if(make_from && !QDELETED(make_from))
		setDir(make_from.dir)
		make_from.forceMove(src)
		stored = make_from
	else
		stored = new /obj/structure/disposalconstruct(src, make_from=src)

		// Hack for old map pipes to work, remove after all maps are updated
		if(flip_type)
			var/obj/structure/disposalpipe/flip = flip_type
			if(icon_state == initial(flip.icon_state))
				initialize_dirs = initial(flip.initialize_dirs)
				construct_type = flip_type

	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir
		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= turn(dir, 180)
	update()

/obj/structure/disposalpipe/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, RAD_NO_INSULATION)

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
/obj/structure/disposalpipe/proc/nextdir(obj/structure/disposalholder/H)
	return dpdir & (~turn(H.dir, 180))

// transfer the holder through this pipe segment
// overriden for special behaviour
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/H)
	return transfer_to_dir(H, nextdir(H))

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

// expel the held objects into a turf
// called when there is a break in the pipe
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
	if(istype(I, /obj/item/weldingtool))
		if(!can_be_deconstructed(user))
			return

		var/obj/item/weldingtool/W = I
		if(W.remove_fuel(0, user))
			playsound(src, I.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You start slicing [src]...</span>")
			// check if anything changed over 2 seconds
			if(do_after(user, 30*I.toolspeed, target = src))
				if(!src || !W.isOn())
					return
				deconstruct()
				to_chat(user, "<span class='notice'>You slice [src].</span>")
	else
		return ..()

//checks if something is blocking the deconstruction (e.g. trunk with a bin still linked to it)
/obj/structure/disposalpipe/proc/can_be_deconstructed()
	. = 1

// called when pipe is cut with welder
/obj/structure/disposalpipe/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			if(stored)
				var/turf/T = loc
				stored.loc = T
				transfer_fingerprints_to(stored)
				stored.setDir(dir)
				stored.density = FALSE
				stored.anchored = TRUE
				stored.update_icon()
		else
			for(var/D in GLOB.cardinals)
				if(D & dpdir)
					var/obj/structure/disposalpipe/broken/P = new(src.loc)
					P.setDir(D)
	qdel(src)


/obj/structure/disposalpipe/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()


// Straight pipe segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"
	initialize_dirs = DISP_DIR_FLIP

/obj/structure/disposalpipe/segment/Initialize()
	if(icon_state == "pipe-c")	// Hack for old map pipes to work, remove after all maps are updated
		initialize_dirs = DISP_DIR_RIGHT
		construct_type = /obj/structure/disposalpipe/segment/bent
	. = ..()

// Bent pipe segment
/obj/structure/disposalpipe/segment/bent
	icon_state = "pipe-c"
	initialize_dirs = DISP_DIR_RIGHT


// A three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"
	initialize_dirs = DISP_DIR_RIGHT | DISP_DIR_FLIP
	flip_type = /obj/structure/disposalpipe/junction/flip

/obj/structure/disposalpipe/junction/Initialize()
	if(icon_state == "pipe-y")	// Hack for old map pipes to work, remove after all maps are updated
		initialize_dirs = DISP_DIR_LEFT | DISP_DIR_RIGHT
		flip_type = null
		construct_type = /obj/structure/disposalpipe/junction/yjunction
	. = ..()


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
		var/secdir = 0
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
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D)
		linked = D
		if (!D.trunk)
			D.trunk = src

	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O)
		linked = O


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
		if(istype(O))
			O.expel(H)	// expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			D.expel(H)	// expel at disposal
	else
		src.expel(H, get_turf(src), 0)	// expel at turf
	return null

/obj/structure/disposalpipe/trunk/nextdir(obj/structure/disposalholder/H)
	if(H.dir == DOWN)
		return dir
	else
		return 0

// a broken pipe
/obj/structure/disposalpipe/broken
	desc = "A broken piece of disposal pipe."
	icon_state = "pipe-b"
	initialize_dirs = DISP_DIR_NONE
	// broken pipes always have dpdir=0 so they're not found as 'real' pipes
	// i.e. will be treated as an empty turf

/obj/structure/disposalpipe/broken/deconstruct()
	qdel(src)




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
