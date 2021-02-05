GLOBAL_DATUM_INIT(openspace_backdrop_one_for_all, /atom/movable/openspace_backdrop, new)

/atom/movable/openspace_backdrop
	name			= "openspace_backdrop"

	anchored		= TRUE

	icon            = 'icons/turf/floors.dmi'
	icon_state      = "grey"
	plane           = OPENSPACE_BACKDROP_PLANE
	mouse_opacity 	= MOUSE_OPACITY_TRANSPARENT
	layer           = SPLASHSCREEN_LAYER
	//I don't know why the others are aligned but I shall do the same.
	vis_flags		= VIS_INHERIT_ID

/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	icon_state = "transparent"
	baseturfs = /turf/open/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
	baseturfs = /turf/open/openspace
	intact = FALSE //this means wires go on top
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/can_cover_up = TRUE
	var/can_build_on = TRUE

/turf/open/openspace/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/openspace/Initialize() // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	vis_contents += GLOB.openspace_backdrop_one_for_all //Special grey square for projecting backdrop darkness filter on it.
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency, FALSE)

/turf/open/openspace/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	return FALSE

/turf/open/openspace/zAirIn()
	return TRUE

/turf/open/openspace/zAirOut()
	return TRUE

/turf/open/openspace/zPassIn(atom/movable/A, direction, turf/source)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/zPassOut(atom/movable/A, direction, turf/destination)
	if(A.anchored)
		return FALSE
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/open/openspace/proc/CanBuildHere()
	return can_build_on

/turf/open/openspace/attackby(obj/item/C, mob/user, params)
	..()
	if(!CanBuildHere())
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			to_chat(user, "<span class='warning'>There is already a catwalk here!</span>")
			return
		if(L)
			if(R.use(1))
				qdel(L)
				to_chat(user, "<span class='notice'>You construct a catwalk.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
				new/obj/structure/lattice/catwalk(src)
			else
				to_chat(user, "<span class='warning'>You need two rods to build a catwalk!</span>")
			return
		if(R.use(1))
			to_chat(user, "<span class='notice'>You construct a lattice.</span>")
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			ReplaceWithLattice()
		else
			to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
		return
	if(istype(C, /obj/item/stack/tile/plasteel))
		if(!CanCoverUp())
			return
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place iron rods first.</span>")

/turf/open/openspace/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!CanBuildHere())
		return FALSE

	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			if(L)
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)
			else
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/openspace/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a floor.</span>")
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE

/turf/open/openspace/icemoon
	name = "ice chasm"
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE
	var/replacement_turf = /turf/open/floor/plating/asteroid/snow/icemoon

/turf/open/openspace/icemoon/Initialize()
	. = ..()
	var/turf/T = below()
	if(T.flags_1 & NO_RUINS_1)
		ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)
		return
	if(!ismineralturf(T))
		return
	var/turf/closed/mineral/M = T
	M.mineralAmt = 0
	M.gets_drilled()
	baseturfs = /turf/open/openspace/icemoon //This is to ensure that IF random turf generation produces a openturf, there won't be other turfs assigned other than openspace.

