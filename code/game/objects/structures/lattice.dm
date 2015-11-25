/obj/structure/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	layer = 2.3 //under pipes
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
			to_chat(user, "<span class='notice'>Slicing lattice joints...</span>")
		new/obj/item/stack/rods(loc)
		qdel(src)
	else
		var/turf/T = get_turf(src)
		T.attackby(C, user) //Attacking to the lattice will attack to the space turf
