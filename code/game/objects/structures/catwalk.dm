/obj/structure/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"
	name = "catwalk"
	desc = "Cats really don't like these things."
	density = 0
	anchored = 1.0
	layer = 2.3 //under pipes

	canSmoothWith = "/obj/structure/catwalk=0"

/obj/structure/catwalk/New(loc)

	..(loc)

	relativewall()
	relativewall_neighbours()

/obj/structure/catwalk/relativewall()

	var/junction = findSmoothingNeighbors()
	icon_state = "catwalk[junction]"

/obj/structure/catwalk/isSmoothableNeighbor(atom/A)

	if(istype(A, /turf/space))
		return 0
	return ..()

/obj/structure/catwalk/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(75))
				qdel(src)
			else
				new /obj/structure/lattice(src.loc)
				qdel(src)
		if(3.0)
			if(prob(10))
				new /obj/structure/lattice(src.loc)
				qdel(src)

/obj/structure/catwalk/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(istype(C, /obj/item/weapon/screwdriver))
		user << "<span class='notice'>You begin undoing the screws holding the catwalk together.</span>"
		playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
		if(do_after(user, 30) && src)
			user << "<span class='notice'>You finish taking taking the catwalk apart.</span>"
			new /obj/item/stack/rods(src.loc, 2)
			new /obj/structure/lattice(src.loc)
			qdel(src)
		return

	if(istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		if(get_turf(src) == src.loc)
			coil.turf_place(src.loc, user)
