/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	icon_state = "grey"
	baseturfs = /turf/open/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
	plane = FLOOR_OPENSPACE_PLANE
	layer = OPENSPACE_LAYER
	var/obj/effect/abstract/openspace_lookthrough/lookthrough
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/turf/open/openspace/debug/setup_multiz()
	..()
	return TRUE

/turf/open/openspace/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	if(!setup_multiz())
		ChangeTurf(/turf/open/floor/plating)

/turf/open/openspace/proc/check_effect()
	if(QDELETED(lookthrough))
		lookthrough = new(src)
	else if(lookthrough.loc != src)
		QDEL_NULL(lookthrough)
		lookthrough = new(src)

/turf/open/openspace/Destroy()
	QDEL_NULL(lookthrough)
	return ..()

/turf/open/openspace/proc/setup_multiz()
	var/turf/T = below()
	if(!T)
		return FALSE
	check_effect()
	lookthrough.vis_contents += T
	return TRUE

/turf/open/openspace/multiz_turf_del(turf/T, dir)
	if(dir != DOWN)
		return
	check_effect()
	lookthrough.vis_contents -= T

/turf/open/openspace/multiz_turf_new(turf/T, dir)
	if(dir != DOWN)
		return
	check_effect()
	lookthrough.vis_contents += T

/turf/open/openspace/zAirIn()
	return TRUE

/turf/open/openspace/zAirOut()
	return TRUE

/turf/open/openspace/zPassIn(atom/movable/A, direction, turf/source)
	return TRUE

/turf/open/openspace/zPassOut(atom/movable/A, direction, turf/destination)
	return TRUE

/turf/open/openspace/zImpact(atom/movable/A, levels = 1)
	. = FALSE
	if(!zFall(A, ++levels))
		return ..()

/obj/effect/abstract/openspace_lookthrough
	name = "Open Space Lookthrough"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FLOAT_PLANE
	appearance_flags = KEEP_TOGETHER
	layer = FLOAT_LAYER

/obj/effect/abstract/openspace_lookthrough/Destroy()
	vis_contents.Cut()
	return ..()
