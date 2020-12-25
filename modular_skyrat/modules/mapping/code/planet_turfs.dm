// Put tiles here if you want planet ones!

/turf/open/floor/plating/dirt/planet
	baseturfs = /turf/open/floor/plating/dirt/planet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
// We don't want to create chasms upon destruction, as this is too easy to abuse.
// For some reason, the dirt used Lavaland atmos (OPENTURF_LOW_PRESSURE), this would suck whilst on the planet.

/turf/open/floor/plating/grass/planet
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/floor/plating/sandy_dirt/planet

/turf/open/floor/plating/grass/jungle/planet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/plating/sandy_dirt/planet
// We want planetary atmos, but most importantly, to become dirt upon destruction. Well, dirt, then dirtier dirt.
// Why are we doing this? Grief-proofing. It'd suck if I walked out my house and there was just a space tile and all the air in the city is being sucked in because some smackhead destroyed the ground in the night somehow.

/turf/open/floor/plating/sandy_dirt/planet
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/floor/plating/dirt/planet

/////////////   GRASS TURFS   /////////////
///////////////////////////////////////////
/////////////   SNOW  TURFS   /////////////
/turf/open/floor/plating/asteroid/snow/indestructible
	gender = PLURAL
	name = "snow"
	desc = "Pretty snow! It's not too cold."
	baseturfs = /turf/open/floor/plating/asteroid/snow/indestructible
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	slowdown = 1
	planetary_atmos = FALSE

/turf/open/floor/plating/asteroid/snow/indestructible/planet
	baseturfs = /turf/open/floor/plating/asteroid/snow/indestructible/planet
	planetary_atmos = TRUE
/* This works but doesn't mesh well with lighting at the moment.
/turf/open/floor/plating/asteroid/snow/indestructible/overlay
	baseturfs = /turf/open/floor/plating/asteroid/snow/indestructible/overlay
	planetary_atmos = FALSE
	var/obj/effect/overlay/snow/snow_overlay = new()

/turf/open/floor/plating/asteroid/snow/indestructible/overlay/planet
	baseturfs = /turf/open/floor/plating/asteroid/snow/indestructible/overlay/planet
	planetary_atmos = TRUE

/obj/effect/overlay/snow
	name = "snow"
	icon = 'modular_skyrat/modules/mapping/icons/dungeon.dmi'
	icon_state = "deep_snow"
	density = 0
	mouse_opacity = 0
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	vis_flags = NONE

/turf/open/floor/plating/asteroid/snow/indestructible/overlay/Initialize()
	..()
	vis_contents += snow_overlay
*/
