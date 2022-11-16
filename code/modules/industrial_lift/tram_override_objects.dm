/**
 * the tram has a few objects mapped onto it at roundstart, by default many of those objects have unwanted properties
 * for example grilles and windows have the atmos_sensitive element applied to them, which makes them register to
 * themselves moving to re register signals onto the turf via connect_loc. this is bad and dumb since it makes the tram
 * more expensive to move.
 *
 * if you map something on to the tram, make SURE if possible that it doesnt have anythign reacting to its own movement
 * it will make the tram more expensive to move and we dont want that because we dont want to return to the days where
 * the tram took a third of the tick per movement when its just carrying its default mapped in objects
 */
/obj/structure/grille/tram/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	//atmos_sensitive applies connect_loc which 1. reacts to movement in order to 2. unregister and register signals to
	//the old and new locs. we dont want that, pretend these grilles and windows are plastic or something idk

/obj/structure/window/reinforced/shuttle/tram/Initialize(mapload, direct)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)

/obj/machinery/power/shuttle_engine/propulsion/tram
	//if this has opacity, then every movement of the tram causes lighting updates
	//DO NOT put something on the tram roundstart that has opacity, it WILL overload SSlighting
	opacity = FALSE

/obj/machinery/door/window/tram
	icon = 'icons/obj/doors/tramdoor.dmi'
	var/associated_lift = MAIN_STATION_TRAM
	var/datum/weakref/tram_ref
	name = "tram door"
	desc = "Probably won't crush you if you try to rush them as they close. But we know you live on that danger, try and beat the tram!"

/obj/machinery/door/window/tram/left
	icon_state = "left"
	base_state = "left"

/obj/machinery/door/window/tram/right
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/tram/proc/find_tram()
	for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(lift.specific_lift_id == associated_lift)
			tram_ref = WEAKREF(lift)

/obj/machinery/door/window/tram/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	associated_lift = MAIN_STATION_TRAM
	INVOKE_ASYNC(src, PROC_REF(open))
	find_tram()

/obj/machinery/door/window/tram/open_and_close()
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(!open())
		return
	if(tram_part.travelling) //making a daring exit midtravel? make sure the doors don't go in the wrong state on arrival.
		say("Emergency exit activated!")
		return PROCESS_KILL

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/right, 0)
