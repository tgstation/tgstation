// Bonfires but with a grill pre-attached

/obj/structure/bonfire/grill_pre_attached

/obj/structure/bonfire/grill_pre_attached/Initialize(mapload)
	. = ..()

	grill = TRUE
	add_overlay("bonfire_grill")

// Dirt but icebox and also farmable

/turf/open/misc/dirt/icemoon
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = "ICEMOON_ATMOS"

/turf/open/misc/dirt/icemoon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_farm, set_plant = TRUE)

// Hotspring water with icebox air

/turf/open/water/hot_spring/icemoon
	initial_gas_mix = "ICEMOON_ATMOS"

// The area

/area/ruin/unpowered/primitive_genemod_den
	name = "\improper Icewalker Camp"
