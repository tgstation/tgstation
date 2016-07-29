/obj/structure/lattice
<<<<<<< HEAD
	name = "lattice"
	desc = "A lightweight support lattice. These hold our station together."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice"
	density = 0
	anchored = 1
	layer = LATTICE_LAYER //under pipes
	var/obj/item/stack/rods/stored
	canSmoothWith = list(/obj/structure/lattice,
	/turf/open/floor,
	/turf/closed/wall,
	/obj/structure/falsewall)
	smooth = SMOOTH_MORE
	//	flags = CONDUCT

/obj/structure/lattice/New()
	..()
	if(!(istype(src.loc, /turf/open/space)))
		qdel(src)
	for(var/obj/structure/lattice/LAT in src.loc)
		if(LAT != src)
			qdel(LAT)
	stored = new/obj/item/stack/rods(src)

/obj/structure/lattice/Destroy()
	qdel(stored)
	stored = null
	return ..()

/obj/structure/lattice/blob_act(obj/effect/blob/B)
	return

/obj/structure/lattice/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			qdel(src)
			return
		if(3)
			return
		else
	return

/obj/structure/lattice/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			user << "<span class='notice'>Slicing [name] joints ...</span>"
			Deconstruct()
	else
		var/turf/T = get_turf(src)
		return T.attackby(C, user) //hand this off to the turf instead (for building plating, catwalks, etc)

/obj/structure/lattice/Deconstruct()
	stored.loc = get_turf(src)
	stored = null
	..()

/obj/structure/lattice/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		Deconstruct()

/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA maneuvering and cable placement."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	smooth = SMOOTH_TRUE
	canSmoothWith = null

/obj/structure/lattice/catwalk/Move()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.Deconstruct()
	..()

/obj/structure/lattice/catwalk/Deconstruct()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.Deconstruct()
	..()

=======
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	layer = 2.3 //under pipes
	plane = PLANE_TURF // thanks for using a define up there it's really useful and maintainable.

	//	flags = CONDUCT

	canSmoothWith = "/obj/structure/lattice=0&/obj/structure/catwalk=0&/turf=0"

/obj/structure/lattice/New(loc)
	..(loc)

	icon = 'icons/obj/smoothlattice.dmi'

	relativewall()

	relativewall_neighbours()

/obj/structure/lattice/relativewall()
	var/junction = findSmoothingNeighbors()
	icon_state = "lattice[junction]"

/obj/structure/lattice/isSmoothableNeighbor(atom/A)
	if (istype(A, /turf/space))
		return 0

	return ..()

/obj/structure/lattice/blob_act()
	qdel(src)

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			qdel(src)

/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)
	if(iswelder(C))
		var/obj/item/weapon/weldingtool/WeldingTool = C
		if(WeldingTool.remove_fuel(0, user))
			to_chat(user, "<span class='notice'>Slicing [src] joints...</span>")
		new/obj/item/stack/rods(loc)
		qdel(src)
	else
		var/turf/T = get_turf(src)
		T.attackby(C, user) //Attacking to the lattice will attack to the space turf

/obj/structure/lattice/wood/attackby(obj/item/C as obj, mob/user as mob)
	if((C.is_sharp() >= 1.2) && (C.w_class <= W_CLASS_SMALL)) // If C is able to cut down a tree
		new/obj/item/stack/sheet/wood(loc)
		to_chat(user, "<span class='notice'>You chop the [src] apart!</span>")
		qdel(src)
	else
		var/turf/T = get_turf(src)
		T.attackby(C, user) //Attacking the wood will attack the turf underneath

/obj/structure/lattice/wood
	name = "wood foundations"
	desc = "It's a foundation, for building on."
	icon_state = "lattice-wood"
	canSmoothWith = null

/obj/structure/lattice/wood/New()
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
