/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	icon_state = "transparent"
	baseturfs = /turf/open/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
	color = "#777777"

/turf/open/openspace/debug/setup_multiz()
	..()
	return TRUE

/turf/open/openspace/Initialize()
	. = ..()
	setup_multiz()
	//if(!setup_multiz())
		//. = INITIALIZE_HINT_QDEL
		//ChangeTurf(/turf/open/floor/plating)

/turf/open/openspace/Destroy()
	vis_contents.Cut()
	return ..()

/turf/open/openspace/proc/setup_multiz()
	var/turf/T = SSmapping.get_turf_below(src)
	if(!T)
		return FALSE
	vis_contents += T

/turf/open/openspace/multiz_turf_del(turf/T, dir)
	if(dir != DOWN)
		return
	vis_contents -= T

/turf/open/openspace/multiz_turf_new(turf/T, dir)
	if(dir != DOWN)
		return
	vis_contents += T

/turf/open/openspace/Crossed(atom/movable/AM)
	. = ..()
	if(!AM.zfalling)
		zFall(AM)

/turf/open/openspace/can_zFall(atom/movable/A, levels = 1)
	..()
	return TRUE

/turf/open/openspace/zImpact(atom/movable/A, levels = 1)
	..()
	. = FALSE
	INVOKE_ASYNC(src, .proc/zFall, A, ++levels)
