/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	icon_state = "grey"
	baseturfs = /turf/open/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
	plane = FLOOR_OPENSPACE_PLANE
	layer = OPENSPACE_LAYER
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/turf/open/openspace/debug/update_multiz()
	..()
	return TRUE

/turf/open/openspace/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	update_multiz(TRUE)

/turf/open/openspace/Destroy()
	vis_contents.Cut()
	return ..()

/turf/open/openspace/update_multiz(prune_on_fail = FALSE)
	. = ..()
	vis_contents.Cut()
	var/turf/T = below()
	if(!T)
		if(prune_on_fail)
			ChangeTurf(/turf/open/floor/plating)
		return FALSE
	vis_contents += T
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
	return TRUE

/turf/open/openspace/zImpact(atom/movable/A, levels = 1)
	. = FALSE
	if(!zFall(A, ++levels))
		return ..()
