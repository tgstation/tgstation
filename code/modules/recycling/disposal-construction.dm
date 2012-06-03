// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'disposal.dmi'
	icon_state = "conpipe-s"
	anchored = 0
	density = 0
	pressure_resistance = 5*ONE_ATMOSPHERE
	m_amt = 1850
	level = 2
	var/ptype = 0
	// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk, 6=disposal bin, 7=outlet, 8=inlet

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-s"

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


		if(ptype<6)
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
		set src in view(1)

		if(usr.stat)
			return

		if(anchored)
			usr << "You must unfasten the pipe before rotating it."
			return

		dir = turn(dir, -90)
		update()

	verb/flip()
		set name = "Flip Pipe"
		set src in view(1)
		if(usr.stat)
			return

		if(anchored)
			usr << "You must unfasten the pipe before flipping it."
			return

		dir = turn(dir, 180)
		if(ptype == 2)
			ptype = 3
		else if(ptype == 3)
			ptype = 2
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
		return



	// attackby item
	// wrench: (un)anchor
	// weldingtool: convert to real pipe

	attackby(var/obj/item/I, var/mob/user)
		var/nicetype = "pipe"
		var/ispipe = 0 // Indicates if we should change the level of this pipe
		switch(ptype)
			if(6)
				nicetype = "disposal bin"
			if(7)
				nicetype = "disposal outlet"
			if(8)
				nicetype = "delivery chute"
			else
				nicetype = "pipe"
				ispipe = 1

		var/turf/T = src.loc
		if(T.intact)
			user << "You can only attach the [nicetype] if the floor plating is removed."
			return

		var/obj/structure/disposalpipe/CP = locate() in T
		if(ptype>=6) // Disposal or outlet
			if(CP) // There's something there
				if(!istype(CP,/obj/structure/disposalpipe/trunk))
					user << "The [nicetype] requires a trunk underneath it in order to work."
					return
			else // Nothing under, fuck.
				user << "The [nicetype] requires a trunk underneath it in order to work."
				return
		else
			if(CP)
				update()
				var/pdir = CP.dpdir
				if(istype(CP, /obj/structure/disposalpipe/broken))
					pdir = CP.dir
				if(pdir & dpdir)
					user << "There is already a [nicetype] at that location."
					return

		var/obj/structure/disposalpipe/trunk/Trunk = CP

		if(istype(I, /obj/item/weapon/wrench))
			if(anchored)
				anchored = 0
				if(ispipe)
					level = 2
					density = 0
				else
					density = 1
				user << "You detach the [nicetype] from the underfloor."
			else
				anchored = 1
				if(ispipe)
					level = 1 // We don't want disposal bins to disappear under the floors
					density = 0
				else
					density = 1 // We don't want disposal bins or outlets to go density 0
				user << "You attach the [nicetype] to the underfloor."
			playsound(src.loc, 'Ratchet.ogg', 100, 1)
			update()

		else if(istype(I, /obj/item/weapon/weldingtool))
			if(anchored)
				var/obj/item/weapon/weldingtool/W = I
				if(W.remove_fuel(0,user))
					playsound(src.loc, 'Welder2.ogg', 100, 1)
					user << "Welding the [nicetype] in place."
					W:welding = 2
					if(do_after(user, 20))
						user << "The [nicetype] has been welded in place!"
						update() // TODO: Make this neat
						if(ispipe) // Pipe

							var/pipetype = dpipetype()
							var/obj/structure/disposalpipe/P = new pipetype(src.loc)
							P.base_icon_state = base_state
							P.dir = dir
							P.dpdir = dpdir
							P.updateicon()

						else if(ptype==6) // Disposal bin
							var/obj/machinery/disposal/P = new /obj/machinery/disposal(src.loc)
							P.mode = 0 // start with pump off

						else if(ptype==7) // Disposal outlet

							var/obj/structure/disposaloutlet/P = new /obj/structure/disposaloutlet(src.loc)
							P.dir = dir
							Trunk.linked = P

						else if(ptype==8) // Disposal outlet

							var/obj/machinery/disposal/deliveryChute/P = new /obj/machinery/disposal/deliveryChute(src.loc)
							P.dir = dir

						del(src)
						return
					W:welding = 1
				else
					user << "You need more welding fuel to complete this task."
					return
			else
				user << "You need to attach it to the plating first!"
				return
