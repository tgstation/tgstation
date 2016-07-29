// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
<<<<<<< HEAD
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
=======
	icon = 'icons/obj/pipes/disposal.dmi'
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	icon_state = "conpipe-s"
	anchored = 0
	density = 0
	pressure_resistance = 5*ONE_ATMOSPHERE
<<<<<<< HEAD
	level = 2
	var/ptype = 0
=======
	starting_materials = list(MAT_IRON = 1850)
	w_type = RECYK_METAL
	level = 2
	var/ptype = 0
	// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk, 6=disposal bin, 7=outlet, 8=inlet
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-s"

<<<<<<< HEAD
/obj/structure/disposalconstruct/examine(mob/user)
	..()
	user << "<span class='notice'>Alt-click to rotate it clockwise.</span>"

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
		usr << "<span class='warning'>You must unfasten the pipe before rotating it!</span>"
		return

	setDir(turn(dir, -90))
	update_icon()

/obj/structure/disposalconstruct/AltClick(mob/user)
	..()
	if(user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
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
		usr << "<span class='warning'>You must unfasten the pipe before flipping it!</span>"
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
	if(T.intact && istype(T, /turf/open/floor))
		user << "<span class='warning'>You can only attach the [nicetype] if the floor plating is removed!</span>"
		return

	if(!ispipe && istype(T, /turf/closed/wall))
		user << "<span class='warning'>You can't build [nicetype]s on walls, only disposal pipes!</span>"
		return

	var/obj/structure/disposalpipe/CP = locate() in T

	if(istype(I, /obj/item/weapon/wrench))
		if(anchored)
			anchored = 0
			if(ispipe)
				level = 2
			density = 0
			user << "<span class='notice'>You detach the [nicetype] from the underfloor.</span>"
		else
			if(!is_pipe()) // Disposal or outlet
				if(CP) // There's something there
					if(!istype(CP,/obj/structure/disposalpipe/trunk))
						user << "<span class='warning'>The [nicetype] requires a trunk underneath it in order to work!</span>"
						return
				else // Nothing under, fuck.
					user << "<span class='warning'>The [nicetype] requires a trunk underneath it in order to work!</span>"
					return
			else
				if(CP)
					update_icon()
					var/pdir = CP.dpdir
					if(istype(CP, /obj/structure/disposalpipe/broken))
						pdir = CP.dir
					if(pdir & dpdir)
						user << "<span class='warning'>There is already a [nicetype] at that location!</span>"
						return
			anchored = 1
			if(ispipe)
				level = 1 // We don't want disposal bins to disappear under the floors
			density = 0
			user << "<span class='notice'>You attach the [nicetype] to the underfloor.</span>"
		playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
		update_icon()

	else if(istype(I, /obj/item/weapon/weldingtool))
		if(anchored)
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(loc, 'sound/items/Welder2.ogg', 100, 1)
				user << "<span class='notice'>You start welding the [nicetype] in place...</span>"
				if(do_after(user, 20/I.toolspeed, target = src))
					if(!loc || !W.isOn())
						return
					user << "<span class='notice'>The [nicetype] has been welded in place.</span>"
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
						B.mode = 0 // start with pump off
						transfer_fingerprints_to(B)

					else if(ptype == DISP_END_OUTLET)
						var/obj/structure/disposaloutlet/P = new /obj/structure/disposaloutlet(loc,src)
						transfer_fingerprints_to(P)

					else if(ptype == DISP_END_CHUTE)
						var/obj/machinery/disposal/deliveryChute/P = new /obj/machinery/disposal/deliveryChute(loc,src)
						transfer_fingerprints_to(P)

					return
		else
			user << "<span class='warning'>You need to attach it to the plating first!</span>"
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
=======
	// update iconstate and dpdir due to dir and type
	proc/update()
		var/flip = turn(dir, 180)
		var/left = turn(dir, 90)
		var/right = turn(dir, -90)

		switch(ptype)
			if(0)
				base_state = "pipe-s"
				dpdir = dir | flip
			if(1)
				base_state = "pipe-c"
				dpdir = dir | right
			if(2)
				base_state = "pipe-j1"
				dpdir = dir | right | flip
			if(3)
				base_state = "pipe-j2"
				dpdir = dir | left | flip
			if(4)
				base_state = "pipe-y"
				dpdir = dir | left | right
			if(5)
				base_state = "pipe-t"
				dpdir = dir
			 // disposal bin has only one dir, thus we don't need to care about setting it
			if(6)
				if(anchored)
					base_state = "disposal"
				else
					base_state = "condisposal"

			if(7)
				base_state = "outlet"
				dpdir = dir

			if(8)
				base_state = "intake"
				dpdir = dir

			if(9, 11)
				base_state = "pipe-j1s"
				dpdir = dir | right | flip

			if(10, 12)
				base_state = "pipe-j2s"
				dpdir = dir | left | flip

		if(ptype<6 || ptype>8)
			icon_state = "con[base_state]"
		else
			icon_state = base_state

		if(invisibility)				// if invisible, fade icon
			icon -= rgb(0,0,0,128)

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = (intact && level==1) ? 101: 0	// hide if floor is intact
		update()


	// flip and rotate verbs
	verb/rotate()
		set name = "Rotate Pipe"
		set category = "Object"
		set src in view(1)

		if(usr.isUnconscious())
			return

		if(anchored)
			to_chat(usr, "You must unfasten the pipe before rotating it.")
			return

		dir = turn(dir, -90)
		update()

	verb/flip()
		set name = "Flip Pipe"
		set category = "Object"
		set src in view(1)
		if(usr.isUnconscious())
			return

		if(anchored)
			to_chat(usr, "You must unfasten the pipe before flipping it.")
			return

		dir = turn(dir, 180)
		switch(ptype)
			if(2)
				ptype = 3
			if(3)
				ptype = 2
			if(9)
				ptype = 10
			if(10)
				ptype = 9
			if(11)
				ptype = 12
			if(12)
				ptype = 11

		update()

	// returns the type path of disposalpipe corresponding to this item dtype
	proc/dpipetype()
		switch(ptype)
			if(0,1)
				return /obj/structure/disposalpipe/segment
			if(2,3,4)
				return /obj/structure/disposalpipe/junction
			if(5)
				return /obj/structure/disposalpipe/trunk
			if(6)
				return /obj/machinery/disposal
			if(7)
				return /obj/structure/disposaloutlet
			if(8)
				return /obj/machinery/disposal/deliveryChute
			if(9,10)
				return /obj/structure/disposalpipe/sortjunction
			if(11, 12)
				return /obj/structure/disposalpipe/wrapsortjunction
		return



	// attackby item
	// wrench: (un)anchor
	// weldingtool: convert to real pipe

	attackby(var/obj/item/I, var/mob/user)
		var/nicetype = "pipe"
		var/ispipe = 0 // Indicates if we should change the level of this pipe
		src.add_fingerprint(user)
		switch(ptype)
			if(6)
				nicetype = "disposal bin"
			if(7)
				nicetype = "disposal outlet"
			if(8)
				nicetype = "delivery chute"
			if(9, 10)
				nicetype = "sorting pipe"
				ispipe = 1
			if(11, 12)
				nicetype = "wrap sorting pipe"
				ispipe = 1
			else
				nicetype = "pipe"
				ispipe = 1

		var/turf/T = src.loc
		if(T.intact)
			to_chat(user, "You can only attach the [nicetype] if the floor plating is removed.")
			return

		var/obj/structure/disposalpipe/CP = locate() in T
		if(ptype>=6 && ptype <= 8) // Disposal or outlet
			if(CP) // There's something there
				if(!istype(CP,/obj/structure/disposalpipe/trunk) && !anchored)
					to_chat(user, "The [nicetype] requires a trunk underneath it in order to work.")
					return
			else // Nothing under, fuck.
				if(!anchored)
					to_chat(user, "The [nicetype] requires a trunk underneath it in order to work.")
					return
		else
			if(CP)
				update()
				var/pdir = CP.dpdir
				if(istype(CP, /obj/structure/disposalpipe/broken))
					pdir = CP.dir
				if(pdir & dpdir)
					to_chat(user, "There is already a [nicetype] at that location.")
					return


		if(iswrench(I))
			if(anchored)
				anchored = 0
				if(ispipe)
					level = 2
					density = 0
				else
					density = 1
				to_chat(user, "You detach the [nicetype] from the underfloor.")
			else
				anchored = 1
				if(ispipe)
					level = 1 // We don't want disposal bins to disappear under the floors
					density = 0
				else
					density = 1 // We don't want disposal bins or outlets to go density 0
				to_chat(user, "You attach the [nicetype] to the underfloor.")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
			update()

		else if(iswelder(I))
			if(anchored)
				var/obj/item/weapon/weldingtool/W = I
				if(W.remove_fuel(0,user))
					playsound(get_turf(src), 'sound/items/Welder2.ogg', 100, 1)
					to_chat(user, "Welding the [nicetype] in place.")
					if(do_after(user, src, 20))
						if(!src || !W.isOn()) return
						to_chat(user, "The [nicetype] has been welded in place!")
						update() // TODO: Make this neat
						if(ispipe) // Pipe

							var/pipetype = dpipetype()
							var/obj/structure/disposalpipe/P = new pipetype(src.loc)
							src.transfer_fingerprints_to(P)
							P.base_icon_state = base_state
							P.dir = dir
							P.dpdir = dpdir
							P.updateicon()

							//Needs some special treatment ;)
							switch(ptype)
								if(9, 10)
									var/obj/structure/disposalpipe/sortjunction/SortP = P
									SortP.updatedir()
								if(11, 12)
									var/obj/structure/disposalpipe/wrapsortjunction/sort_P = P
									sort_P.update_dir()

						else if(ptype==6) // Disposal bin
							var/obj/machinery/disposal/P = new /obj/machinery/disposal(src.loc)
							src.transfer_fingerprints_to(P)
							P.mode = 0 // start with pump off

						else if(ptype==7) // Disposal outlet

							var/obj/structure/disposaloutlet/P = new /obj/structure/disposaloutlet(src.loc)
							src.transfer_fingerprints_to(P)
							P.dir = dir
							var/obj/structure/disposalpipe/trunk/Trunk = CP
							Trunk.linked = P

						else if(ptype==8) // Disposal outlet

							var/obj/machinery/disposal/deliveryChute/P = new /obj/machinery/disposal/deliveryChute(src.loc)
							src.transfer_fingerprints_to(P)
							P.dir = dir

						qdel(src)
						return
				else
					to_chat(user, "You need more welding fuel to complete this task.")
					return
			else
				to_chat(user, "You need to attach it to the plating first!")
				return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
