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


///////////////////////////////////////////
/////////////   OTHER TURFS   /////////////
///////////////////////////////////////////

/turf/closed/mineral/earth_like
	icon_state = "rock"
	turf_type = /turf/open/floor/plating/asteroid
	baseturfs = /turf/open/floor/plating/asteroid
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/random/asteroid/rockplanet	//A version that can be used on the mining planet without destroying atmos - starts with Low_Pressure, along with the rest of the planet.
	name = "iron rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "redrock"
	smooth_icon = 'icons/turf/walls/red_wall.dmi'
	base_icon_state = "red_wall"
	turf_type = /turf/open/floor/plating/asteroid/lowpressure
	baseturfs = /turf/open/floor/plating/asteroid/lowpressure
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	defer_change = TRUE

	mineralSpawnChanceList = list(
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/gibtonite = 3,	//A bit less gibtonite because of higher spawns making it nuts
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/bluespace_crystal = 1
		)
	mineralChance = 25	//Higher mineral chance than normal

/turf/closed/mineral/random/asteroid/rockplanet/labor	//No bluespace for the inmates!
	icon_state = "rock_labor"
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/iron = 95,
		/obj/item/stack/ore/plasma = 30,
		/obj/item/stack/ore/silver = 20,
		/obj/item/stack/ore/gold = 8,
		/obj/item/stack/ore/titanium = 8,
		/obj/item/stack/ore/uranium = 3,
		/obj/item/stack/ore/diamond = 1,
		/turf/closed/mineral/gibtonite = 1
		)

/turf/closed/mineral/asteroid/has_air
	initial_gas_mix = OPENTURF_LOW_PRESSURE	//one that WONT screw with atmos if its mapped somewhere

///////////////////////////////////////////
/////////////  HAZARD  TURFS  /////////////
///////////////////////////////////////////

/turf/open/chasm/sandy	//just a retexture of the other chasm. making this was nothing but painful.
	icon = 'modular_skyrat/modules/mapping/icons/turf/open/sandychasm.dmi'
	icon_state = "chasms-255"	//No I'm not going to go change all the different icon names
	base_icon_state = "chasms"
	baseturfs = /turf/open/chasm/sandy
	planetary_atmos = TRUE
	light_range = 1.5 //God only knows why its glowing, but its gotta stand out somehow - the other chasms glow too
	light_power = 0.65
	light_color = LIGHT_COLOR_TUNGSTEN

	initial_gas_mix = OPENTURF_LOW_PRESSURE
