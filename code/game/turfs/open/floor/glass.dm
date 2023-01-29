/turf/open/floor/glass
	name = "glass floor"
	desc = "Don't jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	baseturfs = /turf/baseturf_bottom
	layer = GLASS_FLOOR_LAYER
	underfloor_accessibility = UNDERFLOOR_VISIBLE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS
	canSmoothWith = SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/tile/glass
	overfloor_placed = FALSE

/turf/open/floor/glass/broken_states()
	return list("glass-damaged1", "glass-damaged2", "glass-damaged3")

/turf/open/floor/glass/Initialize(mapload)
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency)

/turf/open/floor/glass/make_plating()
	return

/turf/open/floor/glass/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/glass/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/glass/reinforced
	name = "reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
	floor_tile = /obj/item/stack/tile/rglass


/turf/open/floor/glass/reinforced/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/glass/reinforced/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/glass/plasma
	name = "plasma glass floor"
	desc = "Studies by the Nanotrasen Materials Safety Division have not yet determined if this is safe to jump on, do so at your own risk."
	icon = 'icons/turf/floors/plasma_glass.dmi'
	icon_state = "plasma_glass-0"
	base_icon_state = "plasma_glass"
	floor_tile = /obj/item/stack/tile/glass/plasma

/turf/open/floor/glass/plasma/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/glass/plasma/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/glass/reinforced/plasma
	name = "reinforced plasma glass floor"
	desc = "Do jump on it, jump on it while in a mecha, it can take it."
	icon = 'icons/turf/floors/reinf_plasma_glass.dmi'
	icon_state = "reinf_plasma_glass-0"
	base_icon_state = "reinf_plasma_glass"
	floor_tile = /obj/item/stack/tile/rglass/plasma

/turf/open/floor/glass/reinforced/plasma/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/glass/reinforced/plasma/airless
	initial_gas_mix = AIRLESS_ATMOS
