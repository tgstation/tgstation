GLOBAL_DATUM_INIT(openspace_backdrop, /atom/movable/openspace_backdrop, new)
GLOBAL_DATUM_INIT(openspace_backdrop_light, /atom/movable/openspace_backdrop/light, new)

/atom/movable/openspace_backdrop
	name			= "openspace_backdrop"
	anchored		= TRUE
	icon            = 'icons/turf/floors.dmi'
	icon_state      = "grey"
	plane           = OPENSPACE_BACKDROP_PLANE
	mouse_opacity 	= MOUSE_OPACITY_TRANSPARENT
	layer           = SPLASHSCREEN_LAYER

/atom/movable/openspace_backdrop/light
	icon_state      = "greylight"
	plane			= OPENSPACE_BACKDROP_PLANE_LIGHT

/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	icon_state = "transparent"
	baseturfs = /turf/open/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/can_cover_up = TRUE
	var/can_build_on = TRUE

	intact = 0
/turf/open/openspace/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/openspace/debug/update_multiz()
	..()
	return TRUE

/turf/open/openspace/Initialize() // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	plane = OPENSPACE_PLANE
	layer = OPENSPACE_LAYER

	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	update_multiz(TRUE, TRUE)

/turf/open/openspace/Destroy()
	vis_contents.len = 0
	return ..()

/turf/open/openspace/examine(mob/user)
	. = ..()
	if(isclosedturf(below()))
		. += "<span class='notice'>There seems to be something below that I could walk on </span>"

/turf/open/openspace/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	return FALSE

/turf/open/openspace/update_multiz(prune_on_fail = FALSE, init = FALSE)
	. = ..()
	var/turf/below = below()
	if(!below)
		vis_contents.len = 0
		if(prune_on_fail)
			ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return FALSE
	if(isclosedturf(below)) //If wall_below is false, it means we havn't switched to remove the backdrop yet
		vis_contents -= GLOB.openspace_backdrop
		vis_contents += GLOB.openspace_backdrop_light
	else //This implies that we have no wall below us, but havn't updated this yet
		vis_contents -= GLOB.openspace_backdrop_light
		vis_contents += GLOB.openspace_backdrop

	if(init)
		vis_contents += below
	return TRUE

/turf/open/openspace/multiz_turf_del(turf/T, dir)
	if(dir != DOWN)
		return
	update_multiz()

/turf/open/openspace/multiz_turf_new(turf/T, dir)
	if(dir != DOWN)
		return
	update_multiz()

/turf/open/openspace/zAirIn()
	return TRUE

/turf/open/openspace/zAirOut()
	return TRUE

/turf/open/openspace/zPassIn(atom/movable/A, direction, turf/source)
	return TRUE

/turf/open/openspace/zPassOut(atom/movable/A, direction, turf/destination)
	if(isclosedturf(below()))
		return FALSE
	if(A.anchored)
		return FALSE
	for(var/obj/O in contents)
		if(O.obj_flags & BLOCK_Z_FALL)
			return FALSE
	return TRUE

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
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

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
