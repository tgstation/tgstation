/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice. These hold our station together."
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	layer = 2.3 //under pipes
	var/obj/item/stack/rods/stored
	//	flags = CONDUCT

/obj/structure/lattice/New()
	..()
	if(!(istype(src.loc, /turf/space)))
		qdel(src)
	for(var/obj/structure/lattice/LAT in src.loc)
		if(LAT != src)
			qdel(LAT)
	stored = new/obj/item/stack/rods(src)
	icon = 'icons/obj/smoothlattice.dmi'
	updateOverlays()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays()

/obj/structure/lattice/Destroy()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays(src.loc)
	..()

/obj/structure/lattice/blob_act()
	qdel(src)
	return

/obj/structure/lattice/ex_act(severity, target)
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

/obj/structure/lattice/attackby(obj/item/C, mob/user, params)
	var/turf/T = get_turf(src)
	if (istype(C, /obj/item/stack/tile/plasteel))
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead (for building plating)
	if(istype(C, /obj/item/stack/rods))
		T.attackby(C, user) //see above, for building catwalks
	if (istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			user << "<span class='notice'>Slicing [name] joints ...</span>"
			Deconstruct()
	return

/obj/structure/lattice/proc/updateOverlays()
	//if(!(istype(src.loc, /turf/space)))
	//	qdel(src)
	overlays.Cut()

	var/dir_sum = 0

	for (var/direction in cardinal)
		if(locate(/obj/structure/lattice, get_step(src, direction)))
			dir_sum += direction
		else
			if(!(istype(get_step(src, direction), /turf/space)))
				dir_sum += direction

	icon_state = "[name][dir_sum]"
	return

/obj/structure/lattice/Deconstruct()
	var/turf/T = loc
	stored.loc = T
	updateOverlays()
	..()

/obj/structure/lattice/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		Deconstruct()

/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA manuevering and cable placement."
	icon_state = "catwalkfull"

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

/obj/structure/lattice/catwalk/attackby(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/stack/cable_coil))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //catwalks 'enable' coil laying on space tiles, not the catwalks themselves
		return

/obj/structure/lattice/catwalk/updateOverlays()
	overlays.Cut()

	var/dir_sum = 0

	for (var/direction in cardinal)
		if(locate(/obj/structure/lattice/catwalk, get_step(src, direction))) //so we only blend with other catwalks
			dir_sum += direction

	icon_state = "[name][dir_sum]"
	return