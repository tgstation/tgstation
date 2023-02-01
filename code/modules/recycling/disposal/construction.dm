// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct
	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "conpipe"
	anchored = FALSE
	density = FALSE
	pressure_resistance = 5*ONE_ATMOSPHERE
	max_integrity = 200
	var/obj/pipe_type = /obj/structure/disposalpipe/segment
	var/pipename

/obj/structure/disposalconstruct/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	set_density(anchorvalue ? initial(pipe_type.density) : FALSE)

/obj/structure/disposalconstruct/Initialize(mapload, _pipe_type, _dir = SOUTH, flip = FALSE, obj/make_from)
	. = ..()
	if(make_from)
		pipe_type = make_from.type
		setDir(make_from.dir)
		set_anchored(TRUE)

	else
		if(_pipe_type)
			pipe_type = _pipe_type
		setDir(_dir)

	pipename = initial(pipe_type.name)

	AddComponent(/datum/component/simple_rotation, AfterRotation = CALLBACK(src, PROC_REF(AfterRotation)))
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

	if(flip)
		var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
		rotcomp.Rotate(usr, ROTATION_FLIP) // this only gets used by pipes created by RPDs or pipe dispensers

	update_appearance(UPDATE_ICON)

/obj/structure/disposalconstruct/Move()
	var/old_dir = dir
	..()
	setDir(old_dir) //pipes changing direction when moved is just annoying and buggy

/obj/structure/disposalconstruct/update_icon_state()
	if(ispath(pipe_type, /obj/machinery/disposal/bin))
		// Disposal bins receive special icon treating
		icon_state = "[anchored ? "con" : null]disposal"
		return ..()

	icon_state = "[is_pipe() ? "con" : null][initial(pipe_type.icon_state)]"
	return ..()

// Extra layer handling
/obj/structure/disposalconstruct/update_icon()
	. = ..()
	if(!is_pipe())
		return

	layer = anchored ? initial(pipe_type.layer) : initial(layer)

/obj/structure/disposalconstruct/proc/get_disposal_dir()
	if(!is_pipe())
		return NONE

	var/obj/structure/disposalpipe/temp = pipe_type
	var/initialize_dirs = initial(temp.initialize_dirs)
	var/dpdir = NONE

	if(ISDIAGONALDIR(dir)) // Bent pipes
		return dir

	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir

		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= turn(dir, 180)
	return dpdir

/obj/structure/disposalconstruct/proc/AfterRotation(mob/user, degrees)
	if(degrees == ROTATION_FLIP)
		var/obj/structure/disposalpipe/temp = pipe_type
		if(initial(temp.flip_type))
			if(ISDIAGONALDIR(dir)) // Fix RPD-induced diagonal turning
				setDir(turn(dir, 45))
			pipe_type = initial(temp.flip_type)
	update_appearance()

/obj/structure/disposalconstruct/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

// construction/deconstruction
// wrench: (un)anchor
// weldingtool: convert to real pipe
/obj/structure/disposalconstruct/wrench_act(mob/living/user, obj/item/I)
	..()
	if(anchored)
		set_anchored(FALSE)
		to_chat(user, span_notice("You detach the [pipename] from the underfloor."))
	else
		var/ispipe = is_pipe() // Indicates if we should change the level of this pipe

		var/turf/T = get_turf(src)
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && isfloorturf(T))
			var/obj/item/crowbar/held_crowbar = user.is_holding_item_of_type(/obj/item/crowbar)
			if(!held_crowbar || !T.crowbar_act(user, held_crowbar))
				to_chat(user, span_warning("You can only attach the [pipename] if the floor plating is removed!"))
				return TRUE

		if(!ispipe && iswallturf(T))
			to_chat(user, span_warning("You can't build [pipename]s on walls, only disposal pipes!"))
			return TRUE

		if(ispipe)
			var/dpdir = get_disposal_dir()
			for(var/obj/structure/disposalpipe/CP in T)
				var/pdir = CP.dpdir
				if(istype(CP, /obj/structure/disposalpipe/broken))
					pdir = CP.dir
				if(pdir & dpdir)
					if(istype(CP, /obj/structure/disposalpipe/broken))
						qdel(CP)
					else
						to_chat(user, span_warning("There is already a disposal pipe at that location!"))
						return TRUE

		else // Disposal or outlet
			var/found_trunk = locate(/obj/structure/disposalpipe/trunk) in T

			if(!found_trunk)
				to_chat(user, span_warning("The [pipename] requires a trunk underneath it in order to work!"))
				return TRUE

		set_anchored(TRUE)
		to_chat(user, span_notice("You attach the [pipename] to the underfloor."))
	I.play_tool_sound(src, 100)
	update_appearance()
	return TRUE

/obj/structure/disposalconstruct/welder_act(mob/living/user, obj/item/I)
	..()
	if(anchored)
		var/turf/T = get_turf(src)
		if(!is_pipe() && ((locate(/obj/machinery/disposal) in T) || ((locate(/obj/structure/disposaloutlet) in T))))
			to_chat(user, span_warning("A disposals machine already exists here!"))
			return TRUE

		if(!I.tool_start_check(user, amount=0))
			return TRUE

		to_chat(user, span_notice("You start welding the [pipename] in place..."))
		if(I.use_tool(src, user, 8, volume=50))
			to_chat(user, span_notice("The [pipename] has been welded in place."))
			var/obj/O = new pipe_type(loc, src)
			transfer_fingerprints_to(O)

	else
		to_chat(user, span_warning("You need to attach it to the plating first!"))
	return TRUE

/obj/structure/disposalconstruct/proc/is_pipe()
	return ispath(pipe_type, /obj/structure/disposalpipe)

//helper proc that makes sure you can place the construct (i.e no dense objects stacking)
/obj/structure/disposalconstruct/proc/can_place()
	if(is_pipe())
		return TRUE

	for(var/obj/structure/disposalconstruct/DC in get_turf(src))
		if(DC == src)
			continue

		if(!DC.is_pipe()) //there's already a chute/outlet/bin there
			return FALSE

	return TRUE
