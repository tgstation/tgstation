/// these need to be different than regular elevators as we have the mining z-level detached from the station.
/// Why we have them detached? we use a single image as the ocean overlay and this can't be used with plane cube
/// as we need to provide an offset atom which can't be done with a single one


/obj/machinery/ocean_elevator
	name = "ocean elevator"
	desc = "an elevator used to move things up and down the ocean floors."

	//icon = ''
	//icon_state = "elevator"
	anchored = TRUE

	max_integrity = 7500 /// holy fuck these things are strong they could survive a nuke

	///this is an array that sorts elevators by id and if they are up or down
	var/static/list/elevator_list = list()
	///the id to use for sorting and activation
	var/elevator_id = "generic"
	///elevator state for trench up means blocked, and for station level down means fall
	var/elevator_up = TRUE
	///are we trenched? if so we have different up/down icons
	var/trenched = FALSE


/obj/machinery/ocean_elevator/Initialize(mapload)
	. = ..()
	var/second_tag = "Station"
	if(trenched)
		second_tag = "Trench"
	elevator_list[elevator_id][second_tag] += src

/turf/open/floor/elevator_shaft
	name = "elevator shaft"
	desc = "A hole going straight down"

	icon = 'goon/icons/turf/floors.dmi'
	icon_state = "moon_shaft"


/turf/open/floor/elevator_shaft/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/obj/machinery/ocean_elevator/located_elevator = locate(/obj/machinery/ocean_elevator) in CONTENTS_CHANGE_ID

	if(!located_elevator || !located_elevator?.elevator_up)
		var/turf/turf = locate(src.x, src.y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1])
		arrived.forceMove(turf)
		if(iscarbon(arrived))
			var/mob/living/carbon/living_carbon = arrived
			living_carbon.emote("Scream")
			living_carbon.ZImpactDamage(turf, 1)

