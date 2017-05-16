/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice. These hold our station together."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice"
	density = 0
	anchored = 1
	armor = list(melee = 50, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 50)
	obj_integrity = 50
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	var/number_of_rods = 1
	canSmoothWith = list(/obj/structure/lattice,
	/turf/open/floor,
	/turf/closed/wall,
	/obj/structure/falsewall)
	smooth = SMOOTH_MORE
	//	flags = CONDUCT

/obj/structure/lattice/Initialize(mapload)
	. = ..()
	for(var/obj/structure/lattice/LAT in loc)
		if(LAT != src)
			QDEL_IN(LAT, 0)

/obj/structure/lattice/blob_act(obj/structure/blob/B)
	return

/obj/structure/lattice/ratvar_act()
	if(IsEven(x + y))
		new /obj/structure/lattice/clockwork(loc)
	else
		new /obj/structure/lattice/clockwork/large(loc)

/obj/structure/lattice/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/weapon/wirecutters))
		to_chat(user, "<span class='notice'>Slicing [name] joints ...</span>")
		deconstruct()
	else
		var/turf/T = get_turf(src)
		return T.attackby(C, user) //hand this off to the turf instead (for building plating, catwalks, etc)

/obj/structure/lattice/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/rods(get_turf(src), number_of_rods)
	qdel(src)

/obj/structure/lattice/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		deconstruct()

/obj/structure/lattice/clockwork
	name = "clockwork lattice"
	desc = "A lightweight support lattice. These hold the Justicar's station together."
	icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'

/obj/structure/lattice/clockwork/Initialize(mapload)
	..()
	ratvar_act()

/obj/structure/lattice/clockwork/ratvar_act()
	if(IsOdd(x+y))
		new /obj/structure/lattice/clockwork/large(loc) // deletes old one

/obj/structure/lattice/clockwork/large/Initialize(mapload)
	..()
	icon = 'icons/obj/smooth_structures/lattice_clockwork_large.dmi'
	pixel_x = -9
	pixel_y = -9

/obj/structure/lattice/clockwork/large/ratvar_act()
	if(IsEven(x + y))
		new /obj/structure/lattice/clockwork(loc)

/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA maneuvering and cable placement."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	number_of_rods = 2
	smooth = SMOOTH_TRUE
	canSmoothWith = null

/obj/structure/lattice/catwalk/ratvar_act()
	new /obj/structure/lattice/catwalk/clockwork(loc)

/obj/structure/lattice/catwalk/Move()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/catwalk/deconstruct()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/catwalk/clockwork
	name = "clockwork catwalk"
	icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'

/obj/structure/lattice/catwalk/clockwork/Initialize(mapload)
	..()
	new /obj/effect/temp_visual/ratvar/floor/catwalk(loc)
	new /obj/effect/temp_visual/ratvar/beam/catwalk(loc)

/obj/structure/lattice/catwalk/clockwork/ratvar_act()
	return
