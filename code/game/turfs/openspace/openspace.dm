/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	baseturfs = /turf/open/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES

/turf/open/openspace/debug/setup_multiz()
	..()
	return TRUE

/turf/open/openspace/Initialize()
	. = ..()
	if(!setup_multiz())
		. = INITIALIZE_HINT_QDEL
		ChangeTurf(/turf/open/floor/plating)

/turf/open/openspace/Destroy()
	vis_contents.Cut()
	return ..()

/turf/open/openspace/proc/setup_multiz()
	var/turf/T = SSmapping.get_turf_below(src)
	if(!T)
		return FALSE
	vis_contents += T
