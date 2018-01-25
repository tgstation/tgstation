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
	level = 2
	max_integrity = 200
	var/obj/pipe_type = /obj/structure/disposalpipe/segment
	var/pipename


/obj/structure/disposalconstruct/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")

/obj/structure/disposalconstruct/New(loc, _pipe_type, _dir = SOUTH, flip = FALSE, obj/make_from)
	..()
	if(make_from)
		pipe_type = make_from.type
		setDir(make_from.dir)
		anchored = TRUE

	else
		if(_pipe_type)
			pipe_type = _pipe_type
		setDir(_dir)

	pipename = initial(pipe_type.name)

	if(flip)
		flip()

	update_icon()

/obj/structure/disposalconstruct/Move()
	var/old_dir = dir
	..()
	setDir(old_dir) //pipes changing direction when moved is just annoying and buggy

// update iconstate and dpdir due to dir and type
/obj/structure/disposalconstruct/update_icon()
	icon_state = initial(pipe_type.icon_state)
	if(is_pipe())
		icon_state = "con[icon_state]"
		if(anchored)
			level = initial(pipe_type.level)
			layer = initial(pipe_type.layer)
		else
			level = initial(level)
			layer = initial(layer)

	else if(ispath(pipe_type, /obj/machinery/disposal/bin))
		// Disposal bins recieve special icon treating
		if(anchored)
			icon_state = "disposal"
		else
			icon_state = "condisposal"


// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalconstruct/hide(var/intact)
	invisibility = (intact && level==1) ? INVISIBILITY_MAXIMUM: 0	// hide if floor is intact
	update_icon()

/obj/structure/disposalconstruct/proc/get_disposal_dir()
	if(!is_pipe())
		return NONE

	var/obj/structure/disposalpipe/temp = pipe_type
	var/initialize_dirs = initial(temp.initialize_dirs)
	var/dpdir = NONE

	if(dir in GLOB.diagonals) // Bent pipes
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

// flip and rotate verbs
/obj/structure/disposalconstruct/verb/rotate()
	set name = "Rotate Pipe"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>You must unfasten the pipe before rotating it!</span>")
		return

	setDir(turn(dir, -90))
	update_icon()

/obj/structure/disposalconstruct/AltClick(mob/user)
	..()
	if(!in_range(src, user))
		return
	else
		rotate()

/obj/structure/disposalconstruct/verb/flip()
	set name = "Flip Pipe"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>You must unfasten the pipe before flipping it!</span>")
		return

	setDir(turn(dir, 180))

	var/obj/structure/disposalpipe/temp = pipe_type
	if(initial(temp.flip_type))
		if(dir in GLOB.diagonals)	// Fix RPD-induced diagonal turning
			setDir(turn(dir, 45))
		pipe_type = initial(temp.flip_type)

	update_icon()


// attackby item
// wrench: (un)anchor
// weldingtool: convert to real pipe

/obj/structure/disposalconstruct/attackby(obj/item/I, mob/user, params)
	var/ispipe = is_pipe() // Indicates if we should change the level of this pipe

	add_fingerprint(user)

	var/turf/T = get_turf(src)
	if(T.intact && isfloorturf(T))
		to_chat(user, "<span class='warning'>You can only attach the [pipename] if the floor plating is removed!</span>")
		return

	if(!ispipe && iswallturf(T))
		to_chat(user, "<span class='warning'>You can't build [pipename]s on walls, only disposal pipes!</span>")
		return

	if(istype(I, /obj/item/wrench))
		if(anchored)
			anchored = FALSE
			density = FALSE
			to_chat(user, "<span class='notice'>You detach the [pipename] from the underfloor.</span>")
		else
			if(ispipe)
				var/dpdir = get_disposal_dir()
				for(var/obj/structure/disposalpipe/CP in T)
					var/pdir = CP.dpdir
					if(istype(CP, /obj/structure/disposalpipe/broken))
						pdir = CP.dir
					if(pdir & dpdir)
						to_chat(user, "<span class='warning'>There is already a disposal pipe at that location!</span>")
						return
				level = 1 // Pipes only, don't want disposal bins to disappear under the floors

			else	// Disposal or outlet
				var/found_trunk = FALSE
				for(var/obj/structure/disposalpipe/CP in T)
					if(istype(CP, /obj/structure/disposalpipe/trunk))
						found_trunk = TRUE
						break

				if(!found_trunk)
					to_chat(user, "<span class='warning'>The [pipename] requires a trunk underneath it in order to work!</span>")
					return

			anchored = TRUE
			density = initial(pipe_type.density)
			to_chat(user, "<span class='notice'>You attach the [pipename] to the underfloor.</span>")
		playsound(src, I.usesound, 100, 1)
		update_icon()

	else if(istype(I, /obj/item/weldingtool))
		if(anchored)
			var/obj/item/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(src, I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start welding the [pipename] in place...</span>")
				if(do_after(user, 8*I.toolspeed, target = src))
					if(!loc || !W.isOn())
						return
					to_chat(user, "<span class='notice'>The [pipename] has been welded in place.</span>")

					var/obj/O = new pipe_type(loc, src)
					transfer_fingerprints_to(O)

					return
		else
			to_chat(user, "<span class='warning'>You need to attach it to the plating first!</span>")
			return

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
