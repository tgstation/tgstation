// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "conpipe-s"
	anchored = FALSE
	density = FALSE
	pressure_resistance = 5*ONE_ATMOSPHERE
	level = 2
	max_integrity = 200
	var/ptype = 0

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-s"

/obj/structure/disposalconstruct/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")

/obj/structure/disposalconstruct/New(var/loc, var/pipe_type, var/direction = 1)
	..(loc)
	if(pipe_type)
		ptype = pipe_type
	setDir(direction)

// update iconstate and dpdir due to dir and type
/obj/structure/disposalconstruct/update_icon()
	var/flip = turn(dir, 180)
	var/left = turn(dir, 90)
	var/right = turn(dir, -90)

	switch(ptype)
		if(DISP_PIPE_STRAIGHT)
			base_state = "pipe-s"
			dpdir = dir | flip
		if(DISP_PIPE_BENT)
			base_state = "pipe-c"
			dpdir = dir | right
		if(DISP_JUNCTION)
			base_state = "pipe-j1"
			dpdir = dir | right | flip
		if(DISP_JUNCTION_FLIP)
			base_state = "pipe-j2"
			dpdir = dir | left | flip
		if(DISP_YJUNCTION)
			base_state = "pipe-y"
			dpdir = dir | left | right
		if(DISP_END_TRUNK)
			base_state = "pipe-t"
			dpdir = dir
		 // disposal bin has only one dir, thus we don't need to care about setting it
		if(DISP_END_BIN)
			if(anchored)
				base_state = "disposal"
			else
				base_state = "condisposal"

		if(DISP_END_OUTLET)
			base_state = "outlet"
			dpdir = dir

		if(DISP_END_CHUTE)
			base_state = "intake"
			dpdir = dir

		if(DISP_SORTJUNCTION)
			base_state = "pipe-j1s"
			dpdir = dir | right | flip

		if(DISP_SORTJUNCTION_FLIP)
			base_state = "pipe-j2s"
			dpdir = dir | left | flip


	if(is_pipe())
		icon_state = "con[base_state]"
	else
		icon_state = base_state

	// if invisible, fade icon
	alpha = (invisibility ? 0 : 255)

// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalconstruct/hide(var/intact)
	invisibility = (intact && level==1) ? INVISIBILITY_MAXIMUM: 0	// hide if floor is intact
	update_icon()


// flip and rotate verbs
/obj/structure/disposalconstruct/verb/rotate()
	set name = "Rotate Pipe"
	set category = "Object"
	set src in view(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>You must unfasten the pipe before rotating it!</span>")
		return

	setDir(turn(dir, -90))
	update_icon()

/obj/structure/disposalconstruct/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	else
		rotate()

/obj/structure/disposalconstruct/verb/flip()
	set name = "Flip Pipe"
	set category = "Object"
	set src in view(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>You must unfasten the pipe before flipping it!</span>")
		return

	setDir(turn(dir, 180))
	switch(ptype)
		if(DISP_JUNCTION)
			ptype = DISP_JUNCTION_FLIP
		if(DISP_JUNCTION_FLIP)
			ptype = DISP_JUNCTION
		if(DISP_SORTJUNCTION)
			ptype = DISP_SORTJUNCTION_FLIP
		if(DISP_SORTJUNCTION_FLIP)
			ptype = DISP_SORTJUNCTION

	update_icon()

// returns the type path of disposalpipe corresponding to this item dtype
/obj/structure/disposalconstruct/proc/dpipetype()
	switch(ptype)
		if(DISP_PIPE_STRAIGHT,DISP_PIPE_BENT)
			return /obj/structure/disposalpipe/segment
		if(DISP_JUNCTION, DISP_JUNCTION_FLIP, DISP_YJUNCTION)
			return /obj/structure/disposalpipe/junction
		if(DISP_END_TRUNK)
			return /obj/structure/disposalpipe/trunk
		if(DISP_END_BIN)
			return /obj/machinery/disposal/bin
		if(DISP_END_OUTLET)
			return /obj/structure/disposaloutlet
		if(DISP_END_CHUTE)
			return /obj/machinery/disposal/deliveryChute
		if(DISP_SORTJUNCTION, DISP_SORTJUNCTION_FLIP)
			return /obj/structure/disposalpipe/sortjunction
	return



// attackby item
// wrench: (un)anchor
// weldingtool: convert to real pipe

/obj/structure/disposalconstruct/attackby(obj/item/I, mob/user, params)
	var/nicetype = "pipe"
	var/ispipe = is_pipe() // Indicates if we should change the level of this pipe
	add_fingerprint(user)
	switch(ptype)
		if(DISP_END_BIN)
			nicetype = "disposal bin"
		if(DISP_END_OUTLET)
			nicetype = "disposal outlet"
		if(DISP_END_CHUTE)
			nicetype = "delivery chute"
		if(DISP_SORTJUNCTION, DISP_SORTJUNCTION_FLIP)
			nicetype = "sorting pipe"
		else
			nicetype = "pipe"

	var/turf/T = loc
	if(T.intact && isfloorturf(T))
		to_chat(user, "<span class='warning'>You can only attach the [nicetype] if the floor plating is removed!</span>")
		return

	if(!ispipe && iswallturf(T))
		to_chat(user, "<span class='warning'>You can't build [nicetype]s on walls, only disposal pipes!</span>")
		return

	var/obj/structure/disposalpipe/CP = locate() in T

	if(istype(I, /obj/item/wrench))
		if(anchored)
			anchored = FALSE
			if(ispipe)
				level = 2
			density = FALSE
			to_chat(user, "<span class='notice'>You detach the [nicetype] from the underfloor.</span>")
		else
			if(!is_pipe()) // Disposal or outlet
				if(CP) // There's something there
					if(!istype(CP, /obj/structure/disposalpipe/trunk))
						to_chat(user, "<span class='warning'>The [nicetype] requires a trunk underneath it in order to work!</span>")
						return
				else // Nothing under, fuck.
					to_chat(user, "<span class='warning'>The [nicetype] requires a trunk underneath it in order to work!</span>")
					return
			else
				if(CP)
					update_icon()
					var/pdir = CP.dpdir
					if(istype(CP, /obj/structure/disposalpipe/broken))
						pdir = CP.dir
					if(pdir & dpdir)
						to_chat(user, "<span class='warning'>There is already a [nicetype] at that location!</span>")
						return
			anchored = TRUE
			if(ispipe)
				level = 1 // We don't want disposal bins to disappear under the floors
			density = FALSE
			to_chat(user, "<span class='notice'>You attach the [nicetype] to the underfloor.</span>")
		playsound(loc, I.usesound, 100, 1)
		update_icon()

	else if(istype(I, /obj/item/weldingtool))
		if(anchored)
			var/obj/item/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(loc, 'sound/items/welder2.ogg', 100, 1)
				to_chat(user, "<span class='notice'>You start welding the [nicetype] in place...</span>")
				if(do_after(user, 8*I.toolspeed, target = src))
					if(!loc || !W.isOn())
						return
					to_chat(user, "<span class='notice'>The [nicetype] has been welded in place.</span>")
					update_icon() // TODO: Make this neat

					if(ispipe)
						var/pipetype = dpipetype()
						var/obj/structure/disposalpipe/P = new pipetype(loc, src)
						P.updateicon()
						transfer_fingerprints_to(P)

						if(ptype == DISP_SORTJUNCTION || ptype == DISP_SORTJUNCTION_FLIP)
							var/obj/structure/disposalpipe/sortjunction/SortP = P
							SortP.updatedir()

					else if(ptype == DISP_END_BIN)
						var/obj/machinery/disposal/bin/B = new /obj/machinery/disposal/bin(loc,src)
						B.pressure_charging = FALSE // start with pump off
						transfer_fingerprints_to(B)

					else if(ptype == DISP_END_OUTLET)
						var/obj/structure/disposaloutlet/P = new /obj/structure/disposaloutlet(loc,src)
						transfer_fingerprints_to(P)

					else if(ptype == DISP_END_CHUTE)
						var/obj/machinery/disposal/deliveryChute/P = new /obj/machinery/disposal/deliveryChute(loc,src)
						transfer_fingerprints_to(P)

					return
		else
			to_chat(user, "<span class='warning'>You need to attach it to the plating first!</span>")
			return

/obj/structure/disposalconstruct/proc/is_pipe()
	return !(ptype >=DISP_END_BIN && ptype <= DISP_END_CHUTE)

//helper proc that makes sure you can place the construct (i.e no dense objects stacking)
/obj/structure/disposalconstruct/proc/can_place()
	if(is_pipe())
		return 1

	for(var/obj/structure/disposalconstruct/DC in get_turf(src))
		if(DC == src)
			continue

		if(!DC.is_pipe()) //there's already a chute/outlet/bin there
			return 0

	return 1
