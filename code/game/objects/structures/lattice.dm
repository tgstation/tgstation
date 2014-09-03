/obj/structure/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	layer = 2.3 //under pipes
	//	flags = CONDUCT

/obj/structure/lattice/New(loc)
	..(loc)

	if(!(istype(loc, /turf/space)))
		qdel(src)

	for(var/obj/structure/lattice/ExistingLattice in loc)
		if(ExistingLattice != src)
			qdel(ExistingLattice)

	icon = 'icons/obj/smoothlattice.dmi'
	icon_state = "latticeblank"
	updateOverlays()

	for(var/direction in cardinal)
		var/obj/structure/lattice/NearbyLattice = \
			locate(/obj/structure/lattice) in get_step(src, direction)

		if(istype(NearbyLattice))
			NearbyLattice.updateOverlays()

/obj/structure/lattice/blob_act()
	del(src)
	return

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			return
		else
	return

/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)

	// /vg/ - Rods for catwalks - N3X
	if (istype(C, /obj/item/stack/tile/plasteel) || istype(C, /obj/item/stack/rods))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead
		return

	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WeldingTool = C

		if(WeldingTool.remove_fuel(0, user))
			user << "<span class='notice'>Slicing lattice joints...</span>"

		new/obj/item/stack/rods(loc)
		qdel(src)

/obj/structure/lattice/proc/updateOverlays()
	set waitfor = 0

	overlays.len = 0

	var/dir_sum = 0

	for(var/direction in cardinal)
		var/location = get_step(src, direction)

		if(locate(/obj/structure/lattice) in location)
			dir_sum += direction
		else
			if(!istype(location, /turf/space))
				dir_sum += direction

	icon_state = "lattice[dir_sum]"
