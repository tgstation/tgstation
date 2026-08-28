/turf/open/misc/beach
	name = "beach"
	desc = "Sandy."
	icon = 'icons/turf/sand.dmi'
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	rust_resistance = RUST_RESISTANCE_REINFORCED
	leave_footprints = TRUE

/turf/open/misc/beach/Initialize(mapload)
	. = ..()
	add_lazy_fishing(/datum/fish_source/sand)

/turf/open/misc/beach/ex_act(severity, target)
	if(fish_source)
		GLOB.preset_fish_sources[fish_source].spawn_reward_from_explosion(src, severity)
	return FALSE

/turf/open/misc/beach/add_footprint(mob/living/carbon/human/walker, movement_direction)
	if(!SSmapping.level_trait(z, ZTRAIT_SANDSTORM))
		return ..()

	// if an active sand storm affecting this turf is currently in its main or wind down stage, skip footprint creation
	for(var/datum/weather/sand_storm/active_weather in SSweather.processing)
		if(active_weather.stage != MAIN_STAGE && active_weather.stage != WIND_DOWN_STAGE)
			continue
		if(!(loc in active_weather.impacted_areas))
			continue
		return

	. = ..()
	// when a sand storm enters its main stage, clear all of our footprints
	for(var/sand_type in typesof(/datum/weather/sand_storm))
		RegisterSignal(SSdcs, COMSIG_WEATHER_START(sand_type), PROC_REF(sand_clear_footprints), override = TRUE)

/turf/open/misc/beach/proc/sand_clear_footprints(datum/source, datum/weather/storm)
	SIGNAL_HANDLER

	if(!(loc in storm.impacted_areas))
		return

	clear_footprints()
	for(var/sand_type in typesof(/datum/weather/sand_storm))
		UnregisterSignal(SSdcs, COMSIG_WEATHER_START(sand_type))

/turf/open/misc/beach/sand
	gender = PLURAL
	name = "sand"
	desc = "Surf's up."
	icon_state = "sand"
	base_icon_state = "sand"
	baseturfs = /turf/open/misc/beach/sand

/turf/open/misc/beach/sand/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "sand[rand(1,4)]"

/turf/open/misc/beach/coast
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon = 'icons/turf/beach.dmi'
	icon_state = "beach"
	base_icon_state = "beach"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/misc/beach/coast/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/turf/open/misc/beach/coast/break_tile()
	. = ..()
	icon_state = "beach"

/turf/open/misc/beach/coast/corner
	icon_state = "beach-corner"
	base_icon_state = "beach-corner"

/turf/open/misc/beach/coast/corner/break_tile()
	. = ..()
	icon_state = "beach-corner"

/turf/open/misc/sandy_dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	damaged_dmi = 'icons/turf/damaged.dmi'
	icon_state = "sand"
	base_icon_state = "sand"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_turf = FALSE
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/open/misc/sandy_dirt/break_tile()
	. = ..()
	icon_state = "sand_damaged"

/turf/open/misc/sandy_dirt/broken_states()
	return list("sand_damaged")

/turf/open/misc/ironsand
	gender = PLURAL
	name = "iron sand"
	desc = "Like sand, but more <i>iron</i>."
	icon_state = "ironsand1"
	base_icon_state = "ironsand1"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"
