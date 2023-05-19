
/turf/open/floor/plating/airless/Initialize(mapload)
	initial_gas_mix = AIRLESS_ATMOS
	return ..()

/turf/open/floor/plating/lowpressure
	baseturfs = /turf/open/floor/plating/lowpressure

/turf/open/floor/plating/lowpressure/Initialize(mapload)
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	return ..()

/turf/open/floor/plating/icemoon
	icon_state = "plating"
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	base_icon_state = "alienpod1"
	tiled_dirt = FALSE
	// Not actually broken, just should never break...yeah.
	broken = TRUE
	damaged_dmi = null

/turf/open/floor/plating/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/open/floor/plating/abductor2
	name = "alien plating"
	icon_state = "alienplating"
	base_icon_state = "alienplating"
	tiled_dirt = FALSE
	damaged_dmi = null

/turf/open/floor/plating/abductor2/break_tile()
	return //unbreakable

/turf/open/floor/plating/abductor2/burn_tile()
	return //unburnable

/turf/open/floor/plating/abductor2/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/snowed
	name = "snowed-over plating"
	desc = "A section of heated plating, helps keep the snow from stacking up too high."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snowplating"
	base_icon_state = "snowplating"
	temperature = 180
	attachment_holes = FALSE
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/snowed/Initialize(mapload)
	if(!initial_gas_mix)
		initial_gas_mix = FROZEN_ATMOS
	return ..()

/turf/open/floor/plating/snowed/cavern/Initialize(mapload)
	initial_gas_mix = BURNING_COLD
	return ..()

/turf/open/floor/plating/snowed/icemoon/Initialize(mapload)
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	return ..()

/turf/open/floor/plating/snowed/smoothed
	icon = 'icons/turf/floors/snow_turf.dmi'
	icon_state = "snow_turf-0"
	base_icon_state = "snow_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_SNOWED
	canSmoothWith = SMOOTH_GROUP_FLOOR_SNOWED
	planetary_atmos = TRUE

/turf/open/floor/plating/snowed/temperatre
	temperature = 255.37

// When you want real, genuine snowed plating in your kitchen's cold room.
/turf/open/floor/plating/snowed/coldroom
	planetary_atmos = FALSE
	temperature = COLD_ROOM_TEMP

/turf/open/floor/plating/snowed/coldroom/Initialize(mapload)
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	return ..()

//Used in SnowCabin.dm
/turf/open/floor/plating/snowed/snow_cabin
	temperature = 180

/turf/open/floor/plating/snowed/smoothed/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/plating/lavaland_atmos
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/plating/elevatorshaft
	name = "elevator shaft"
	icon_state = "elevatorshaft"
	base_icon_state = "elevatorshaft"
