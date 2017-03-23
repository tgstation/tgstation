/turf/open/floor/plating/dirt
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	var/smooth_icon = 'icons/turf/floors/dirt.dmi'
	canSmoothWith = list(/turf/closed, /turf/open/floor/plating/dirt)
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	baseturf = /turf/open/chasm/straight_down/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE

/turf/open/floor/plating/dirt/Initialize()
	pixel_y = -2
	pixel_x = -2
	icon = smooth_icon
	..()

/turf/open/floor/plating/dirt/dark
	icon_state = "darkdirt"
	smooth_icon = 'icons/turf/floors/darkdirt.dmi'
