/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	icon_state = "openspace"
	baseturfs = /turf/open/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
	plane = FLOOR_OPENSPACE_PLANE
	layer = FLOOR_OPENSPACE_LAYER

/turf/open/openspace/debug/setup_multiz()
	..()
	return TRUE

/turf/open/openspace/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	if(!setup_multiz())
		ChangeTurf(/turf/open/floor/plating)

/turf/open/openspace/Destroy()
	vis_contents.Cut()
	return ..()

/turf/open/openspace/proc/setup_multiz()
	var/turf/T = below()
	if(!T)
		return FALSE
	vis_contents += T
	return TRUE

/turf/open/openspace/multiz_turf_del(turf/T, dir)
	if(dir != DOWN)
		return
	vis_contents -= T

/turf/open/openspace/multiz_turf_new(turf/T, dir)
	if(dir != DOWN)
		return
	vis_contents += T

/turf/open/openspace/Entered(atom/movable/AM)
	. = ..()
	if(!AM.zfalling)
		zFall(AM)

/turf/open/openspace/zAirIn()
	return TRUE

/turf/open/openspace/zAirOut()
	return TRUE

/turf/open/openspace/zPassIn(atom/movable/A, direction, turf/source)
	return TRUE

/turf/open/openspace/zPassOut(atom/movable/A, direction, turf/destination)
	return TRUE

/turf/open/openspace/zImpact(atom/movable/A, levels = 1)
	A.visible_message("<span class='danger'>[A] falls straight through [src]!</span>")
	. = FALSE
	INVOKE_ASYNC(src, .proc/zFall, A, ++levels)
