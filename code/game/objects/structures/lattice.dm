/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice. These hold our station together."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice"
	density = 0
	anchored = 1
	layer = 2.3 //under pipes
	var/obj/item/stack/rods/stored
	canSmoothWith = list(/obj/structure/lattice,
	/turf/simulated/floor,
	/turf/simulated/wall,
	/obj/structure/falsewall)
	smooth = SMOOTH_MORE
	//	flags = CONDUCT

/obj/structure/lattice/New()
	..()
	if(!(istype(src.loc, /turf/space)))
		qdel(src)
	for(var/obj/structure/lattice/LAT in src.loc)
		if(LAT != src)
			qdel(LAT)
	stored = new/obj/item/stack/rods(src)

<<<<<<< HEAD
/obj/structure/lattice/Destroy()
	qdel(stored)
	stored = null
	return ..()

=======
>>>>>>> dbd4169c0e4c4afad12aa45d35bc095f56f20461
/obj/structure/lattice/blob_act()
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
<<<<<<< HEAD
	if(istype(C, /obj/item/weapon/weldingtool))
=======
	var/turf/T = get_turf(src)
	if (istype(C, /obj/item/stack/tile/plasteel))
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead (for building plating)
	if(istype(C, /obj/item/stack/rods))
		T.attackby(C, user) //see above, for building catwalks
	if (istype(C, /obj/item/weapon/weldingtool))
>>>>>>> dbd4169c0e4c4afad12aa45d35bc095f56f20461
		var/obj/item/weapon/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			user << "<span class='notice'>Slicing [name] joints ...</span>"
			Deconstruct()
<<<<<<< HEAD
	else
		var/turf/T = get_turf(src)
		return T.attackby(C, user) //hand this off to the turf instead (for building plating, catwalks, etc)

/obj/structure/lattice/Deconstruct()
	stored.loc = get_turf(src)
	stored = null
=======
	return

/obj/structure/lattice/Deconstruct()
	var/turf/T = loc
	stored.loc = T
>>>>>>> dbd4169c0e4c4afad12aa45d35bc095f56f20461
	..()

/obj/structure/lattice/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		Deconstruct()

/obj/structure/lattice/catwalk
	name = "catwalk"
<<<<<<< HEAD
	desc = "A catwalk for easier EVA maneuvering and cable placement."
=======
	desc = "A catwalk for easier EVA manuevering and cable placement."
>>>>>>> dbd4169c0e4c4afad12aa45d35bc095f56f20461
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

<<<<<<< HEAD
=======
/obj/structure/lattice/catwalk/attackby(obj/item/C, mob/user, params)
	..()
	if(istype(C, /obj/item/stack/cable_coil))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //catwalks 'enable' coil laying on space tiles, not the catwalks themselves
		return
>>>>>>> dbd4169c0e4c4afad12aa45d35bc095f56f20461
