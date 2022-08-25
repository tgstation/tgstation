/turf/open/misc/snow
	gender = PLURAL
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	desc = "Looks cold."
	icon_state = "snow"
	planetary_atmos = TRUE
	initial_gas_mix = FROZEN_ATMOS
	slowdown = 2
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/snow/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diggable, /obj/item/stack/sheet/mineral/snow, 2)

/turf/open/misc/snow/break_tile()
	. = ..()
	icon_state = "snow_dug"

/turf/open/misc/snow/actually_safe
	slowdown = 0
	planetary_atmos = FALSE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
