/turf/open/floor/iron/submarine
	name = "submarine floor"
	icon = 'monkestation/code/modules/blueshift/icons/turf/submarine.dmi'
	base_icon_state = "submarine_floor"
	icon_state = "submarine_floor"
	liquid_height = -30
	turf_height = -30

/turf/open/floor/iron/submarine/rust_heretic_act()
	return

/turf/open/floor/iron/submarine_vents
	name = "submarine floor"
	icon = 'monkestation/code/modules/blueshift/icons/turf/submarine.dmi'
	base_icon_state = "submarine_vents"
	icon_state = "submarine_vents"
	liquid_height = -30
	turf_height = -30

/turf/open/floor/iron/submarine_vents/rust_heretic_act()
	return

/turf/open/floor/iron/submarine_perf
	name = "submarine floor"
	icon = 'monkestation/code/modules/blueshift/icons/turf/submarine.dmi'
	base_icon_state = "submarine_perf"
	icon_state = "submarine_perf"
	liquid_height = -30
	turf_height = -30

/turf/open/floor/iron/submarine_perf/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/submarine_perf/rust_heretic_act()
	return

//For now just a titanium wall. I'll make sprites for it later
/turf/closed/wall/mineral/titanium/submarine
	name = "submarine wall"


/obj/effect/overlay/water
	name = "water"
	icon = 'monkestation/code/modules/blueshift/icons/unique/pool.dmi'
	icon_state = "bottom"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = ABOVE_MOB_LAYER

/obj/effect/overlay/water/top
	icon_state = "top"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE

/**
 * Planetside water, indestructible.
 *
 * Use this for indoors.
 */
/turf/open/water/overlay
	name = "shallow water"
	desc = "A natural body of shallow water."
	icon = 'monkestation/code/modules/blueshift/icons/unique/pool.dmi'
	icon_state = "rocky"
	baseturfs = /turf/open/water/overlay
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE

/turf/open/water/overlay/Initialize(mapload)
	. = ..()

	var/obj/effect/overlay/water/bottom = new()
	SET_PLANE(bottom, PLANE_TO_TRUE(bottom.plane), src)
	vis_contents += bottom

	var/obj/effect/overlay/water/top/top = new()
	SET_PLANE(top, PLANE_TO_TRUE(top.plane), src)
	vis_contents += top

/turf/open/water/overlay/Entered(atom/movable/arrived)
	..()
	wash_atom(arrived)
	wash_atom(loc)

/turf/open/water/overlay/proc/wash_atom(atom/nasty)
	nasty.wash(CLEAN_RAD) // Clean radiation non-instantly
	nasty.wash(CLEAN_WASH)

/turf/open/water/overlay/hotspring/Entered(atom/movable/arrived)
	..()
	if(istype(arrived, /mob/living))
		hotspring_mood(arrived)

/turf/open/water/overlay/hotspring/proc/hotspring_mood(mob/living/swimmer)
	swimmer.add_mood_event("hotspring", /datum/mood_event/hotspring)

/datum/mood_event/hotspring
	description = span_nicegreen("I recently had a paddle in some nice warm water! It was so refreshing!\n")
	mood_change = 4
	timeout = 20 MINUTES

/**
 * Planetside water, indestructible.
 *
 * Use this for outdoors. It normalises to it's initial airmix over time!
 */
/turf/open/water/overlay/outdoors
	baseturfs = /turf/open/water/overlay/outdoors
	planetary_atmos = TRUE

/**
 * Hotpsrings! They give a positive mood event.
 */
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
