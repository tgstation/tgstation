/turf/open/misc/snow
	gender = PLURAL
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	damaged_dmi = 'icons/turf/snow.dmi'
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
	leave_footprints = TRUE

/turf/open/misc/snow/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diggable, /obj/item/stack/sheet/mineral/snow, 2)

/turf/open/misc/snow/broken_states()
	return list("snow_dug")

/turf/open/misc/snow/add_footprint(mob/living/carbon/human/walker, movement_direction)
	if(HAS_TRAIT(walker, TRAIT_NO_SNOWPRINTS))
		return
	// skip the special logic if the level doesn't naturally have snowstorms
	if(!SSmapping.level_trait(z, ZTRAIT_SNOWSTORM))
		return ..()

	// if an active snow storm affecting this turf is currently in its main or wind down stage, skip footprint creation
	for(var/datum/weather/snow_storm/active_weather in SSweather.processing)
		if(active_weather.stage != MAIN_STAGE && active_weather.stage != WIND_DOWN_STAGE)
			continue
		if(!(loc in active_weather.impacted_areas))
			continue
		return
	. = ..()
	// when a snow storm enters its main stage, clear all of our footprints
	for(var/snow_type in typesof(/datum/weather/snow_storm))
		RegisterSignal(SSdcs, COMSIG_WEATHER_START(snow_type), PROC_REF(snow_clear_footprints), override = TRUE)

/turf/open/misc/snow/proc/snow_clear_footprints(datum/source, datum/weather/storm)
	SIGNAL_HANDLER

	if(!(loc in storm.impacted_areas))
		return

	clear_footprints()
	for(var/snow_type in typesof(/datum/weather/snow_storm))
		UnregisterSignal(SSdcs, COMSIG_WEATHER_START(snow_type))

/turf/open/misc/snow/actually_safe
	slowdown = 0
	planetary_atmos = FALSE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
