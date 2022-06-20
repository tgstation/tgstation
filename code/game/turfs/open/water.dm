/turf/open/water
	gender = PLURAL
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/chasm/lavaland
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	turf_flags = NO_RUST

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/water/jungle
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

//This version of the beach turf uses low pressure, inherieted from above
/turf/open/water/beach
	planetary_atmos = FALSE
	gender = PLURAL
	desc = "You get the feeling that nobody's bothered to actually make this water functional..."
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"
	base_icon_state = "water"
	baseturfs = /turf/open/water/beach

/turf/open/water/beach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, FISHING_SPOT_PRESET_BEACH)

//Same turf, but instead used in the Beach Biodome
/turf/open/water/beach/biodome
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
