///////////// OVERLAY EFFECTS /////////////
/obj/effect/overlay/water
	name = "water"
	icon = 'modular_skyrat/modules/mapping/icons/unique/pool.dmi'
	icon_state = "bottom"
	density = 0
	mouse_opacity = 0
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	vis_flags = NONE

/obj/effect/overlay/water/top
	icon_state = "top"
	layer = BELOW_MOB_LAYER
	vis_flags = NONE
///////////// OVERLAY EFFECTS /////////////
///////////////////////////////////////////
/////////////   INITIALISE    /////////////
/turf/open/water/overlay/Initialize()
	.  = ..()
	var/obj/effect/overlay/water/water_overlay = new()
	var/obj/effect/overlay/water/top/water_top_overlay = new()
	vis_contents += water_overlay
	vis_contents += water_top_overlay
/////////////   INITIALISE    /////////////
///////////////////////////////////////////
///////////// GARBAGE CONTROL /////////////

///////////// GARBAGE CONTROL /////////////
///////////////////////////////////////////
///////////// CLEANING  BLOCK /////////////
/turf/open/water/overlay/Entered(atom/movable/AM)
	..()
	wash_atom(AM)
	wash_atom(loc)

/turf/open/water/overlay/proc/wash_atom(atom/A)
	A.wash(CLEAN_RAD | CLEAN_TYPE_WEAK) // Clean radiation non-instantly
	A.wash(CLEAN_WASH)
///////////// CLEANING  BLOCK /////////////
///////////////////////////////////////////
/////////////   MOOD  EVENT   /////////////
/turf/open/water/overlay/hotspring/Entered(atom/movable/AM)
	..()
	SEND_SIGNAL(AM, COMSIG_ADD_MOOD_EVENT, "hotspring", /datum/mood_event/hotspring)
	hotspring_mood(AM)

/turf/open/water/overlay/hotspring/proc/hotspring_mood(atom/A)
	SEND_SIGNAL(A, COMSIG_ADD_MOOD_EVENT, "hotspring", /datum/mood_event/hotspring)

/datum/mood_event/hotspring
	description = "<span class='nicegreen'>I recently a paddle in some nice warm water! It was so refreshing!</span>\n"
	mood_change = 4
	timeout = 20 MINUTES
/////////////   MOOD  EVENT   /////////////
///////////////////////////////////////////
/////////////   WATER TURFS   /////////////
// Planetside water, indestructible.
/turf/open/water/overlay
	name = "shallow water"
	desc = "A natural body of shallow water."
	icon = 'modular_skyrat/modules/mapping/icons/unique/pool.dmi'
	icon_state = "rocky"
	baseturfs = /turf/open/water/overlay
	var/obj/effect/overlay/water/water_overlay
	var/obj/effect/overlay/water/top/water_top_overlay
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE
// Use this for indoors. It has a roof!

/turf/open/water/overlay/outdoors
	baseturfs = /turf/open/water/overlay/outdoors
	planetary_atmos = TRUE
// Use this for outdoors. It normalises to it's initial airmix over time!

// Hotpsrings! They give a positive mood event.
/turf/open/water/overlay/hotspring
	name = "hotspring"
	desc = "A warm, steamy swimming pool."
	icon_state = "hotspring_tile"
	baseturfs = /turf/open/floor/plating
	planetary_atmos = FALSE

/turf/open/water/overlay/hotspring/indestructible
	baseturfs = /turf/open/water/overlay/hotspring/indestructible

/turf/open/water/overlay/hotspring/indestructible/outdoors
	baseturfs = /turf/open/water/overlay/hotspring/indestructible/outdoors
	planetary_atmos = TRUE

/turf/open/water/overlay/hotspring/planet
	name = "natural hotspring"
	desc = "A natural body of water kept warm by geothermal activity."
	icon_state = "hotspring"
	baseturfs = /turf/open/water/overlay/hotspring/planet
// Use this for indoors. It has a roof!

/turf/open/water/overlay/hotspring/planet/outdoors
	baseturfs = /turf/open/water/overlay/hotspring/planet/outdoors
	planetary_atmos = TRUE
/////////////   WATER TURFS   /////////////
///////////////////////////////////////////
/////////////     CREDITS     /////////////
//• Paradise, Tigercat2000 - Original idea for the pool and the sprites for the water overlay and the 'pool' floor tile.
//• TGstation, Rohesie - Offered help in making this perform better by using vis contents instead of overlays. Thanks!
/////////////     CREDITS     /////////////
