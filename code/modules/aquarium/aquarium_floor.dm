
/turf/open/floor/aquarium
	name = "aquarium floor"
	desc = "Ooooh! Look at the fishies!"
	icon = 'icons/obj/aquarium/aquarium_floor.dmi'
	icon_state = "base"
	intact = FALSE //this means wires go on top
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/aquarium/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aquarium, 3, 30, 3, 30)
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/aquarium/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency, TRUE)

/turf/open/floor/aquarium/setup_broken_states()
	return list("base") //the aquarium glass will be cracked instead of the floor changing
