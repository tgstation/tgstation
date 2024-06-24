
/turf/open/floor/plating/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/lowpressure
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	baseturfs = /turf/open/floor/plating/lowpressure

/turf/open/floor/plating/dumpsterair
	initial_gas_mix = OPENTURF_DIRTY_ATMOS
	temperature = 309

/turf/open/floor/plating/icemoon
	icon_state = "plating"
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	base_icon_state = "alienpod1"
	tiled_dirt = FALSE
	rust_resistance = RUST_RESISTANCE_ORGANIC
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
	rust_resistance = RUST_RESISTANCE_ORGANIC
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
	initial_gas_mix = FROZEN_ATMOS
	temperature = 180
	attachment_holes = FALSE
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/open/floor/plating/snowed/cavern
	initial_gas_mix = BURNING_COLD

/turf/open/floor/plating/snowed/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

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
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = FALSE
	temperature = COLD_ROOM_TEMP

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
