/obj/structure/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	layer = 2.3 //under pipes
	//	flags = CONDUCT

/obj/structure/lattice/New()
	..()
	if(!(istype(src.loc, /turf/space)))
		del(src)
	for(var/obj/structure/lattice/LAT in src.loc)
		if(LAT != src)
			del(LAT)
	icon = 'icons/obj/smoothlattice.dmi'
	icon_state = "latticeblank"
	updateOverlays()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays()

/obj/structure/lattice/Del()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays(src.loc)
	..()

/obj/structure/lattice/blob_act()
	del(src)
	return

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			del(src)
			return
		if(3.0)
			return
		else
	return

/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/tile/plasteel))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead
		return
	if (istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			user << "\blue Slicing lattice joints ..."
		new /obj/item/stack/rods(src.loc)
		del(src)

	return

/obj/structure/lattice/proc/updateOverlays()
	//if(!(istype(src.loc, /turf/space)))
	//	del(src)
	spawn(1)
		overlays = list()

		var/dir_sum = 0

		for (var/direction in cardinal)
			if(locate(/obj/structure/lattice, get_step(src, direction)))
				dir_sum += direction
			else
				if(!(istype(get_step(src, direction), /turf/space)))
					dir_sum += direction

		icon_state = "lattice[dir_sum]"
		return