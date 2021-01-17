/turf/open/floor/glass
	name = "Glass floor"
	desc = "Dont jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	baseturfs = /turf/open/openspace
	intact = FALSE //this means wires go on top
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/glass/Initialize()
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency, TRUE)

/turf/open/floor/glass/setup_broken_states()
	broken_states = string_list(list("[base_icon_state]-damaged1", "[base_icon_state]-damaged2", "[base_icon_state]-damaged3", "[base_icon_state]-damaged4", "[base_icon_state]-damaged5"))
	return

/turf/open/floor/glass/reinforced
	name = "Reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
