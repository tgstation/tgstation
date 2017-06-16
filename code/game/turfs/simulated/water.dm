/turf/open/water
	name = "water"
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater"
	baseturf = /turf/open/chasm/straight_down/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE
	slowdown = 1
	wet = TURF_WET_WATER

/turf/open/water/HandleWet()
    if(wet == TURF_WET_WATER)
        return
    ..()
    MakeSlippery(TURF_WET_WATER) //rewet after ..() clears out lube/ice etc.