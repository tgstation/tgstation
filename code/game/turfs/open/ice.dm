/turf/open/misc/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-0"
	base_icon_state = "ice_turf-0"
	initial_gas_mix = FROZEN_ATMOS
	temperature = 180
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/ice
	slowdown = 1
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/open/misc/ice/break_tile()
	return

/turf/open/misc/ice/burn_tile()
	return

/turf/open/misc/ice/smooth
	icon_state = "ice_turf-255"
	base_icon_state = "ice_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ICE)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ICE)

/turf/open/misc/ice/icemoon
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	slowdown = 0

/turf/open/misc/ice/icemoon/no_planet_atmos
	planetary_atmos = FALSE

/turf/open/misc/ice/temperate
	baseturfs = /turf/open/misc/ice/temperate
	desc = "Somehow, it is not melting under these conditions. Must be some very thick ice. Just as slippery too."
	initial_gas_mix = "o2=22;n2=82;TEMP=255.37" //it works with /turf/open/misc/asteroid/snow/temperatre

//For when you want real, genuine ice in your kitchen's cold room.
/turf/open/misc/ice/coldroom
	desc = "Somehow, it is not melting under these conditions. Must be some very thick ice. Just as slippery too."
	baseturfs = /turf/open/misc/ice/coldroom
	planetary_atmos = FALSE
	temperature = COLD_ROOM_TEMP

/turf/open/misc/ice/coldroom/Initialize(mapload)
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	return ..()
