/// these need to be different than regular elevators as we have the mining z-level detached from the station.
/// Why we have them detached? we use a single image as the ocean overlay and this can't be used with plane cube
/// as we need to provide an offset atom which can't be done with a single one

///this is an array that sorts elevators by id and if they are up or down
GLOBAL_LIST_INIT(sea_elevator_list_station, list())
GLOBAL_LIST_INIT(sea_elevator_list_trench, list())

/obj/machinery/ocean_elevator
	name = "ocean elevator"
	desc = "an elevator used to move things up and down the ocean floors."

	icon = 'monkestation/icons/obj/machines/sea_elevator.dmi'
	icon_state = "elevator_up_station"
	anchored = TRUE

	max_integrity = 7500 /// holy fuck these things are strong they could survive a nuke

	///the id to use for sorting and activation
	var/elevator_id = "generic"
	///elevator state for trench up means blocked, and for station level down means fall
	var/elevator_up = TRUE
	///are we trenched? if so we have different up/down icons
	var/trenched = FALSE


/obj/machinery/ocean_elevator/Initialize(mapload)
	. = ..()
	if(!GLOB.sea_elevator_list_station[elevator_id])
		GLOB.sea_elevator_list_station[elevator_id] = list()
	if(!GLOB.sea_elevator_list_trench[elevator_id])
		GLOB.sea_elevator_list_trench[elevator_id] = list()

	if(trenched)
		GLOB.sea_elevator_list_trench[elevator_id] += src
	else
		GLOB.sea_elevator_list_station[elevator_id] += src
	update_appearance()

/obj/machinery/ocean_elevator/Destroy()
	. = ..()
	var/obj/machinery/ocean_elevator/linked_elevator
	var/turf/returned_turf
	if(trenched)
		GLOB.sea_elevator_list_trench -= src
		returned_turf = get_turf(locate(x, y, SSmapping.levels_by_trait(ZTRAIT_STATION)[1]))
		if(returned_turf)
			linked_elevator = locate(/obj/machinery/ocean_elevator) in returned_turf.contents
	else
		GLOB.sea_elevator_list_station -= src
		returned_turf = get_turf(locate(x, y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1]))
		if(returned_turf)
			linked_elevator = locate(/obj/machinery/ocean_elevator) in returned_turf.contents
	if(linked_elevator)
		qdel(linked_elevator)

/obj/machinery/ocean_elevator/update_icon_state()
	. = ..()
	var/added_string = "station"
	if(trenched)
		added_string = "trench"
	if(elevator_up)
		icon_state = "elevator_up_[added_string]"
	else
		icon_state = "elevator_down_[added_string]"

///these two are seperate procs for snowflake effects
/obj/machinery/ocean_elevator/proc/going_down()
	elevator_up = FALSE
	update_appearance()
	if(trenched)
		return
	var/turf/parent_turf = get_turf(src)
	for(var/atom/movable/listed_atom in parent_turf)
		if(listed_atom.anchored)
			continue
		var/turf/turf = locate(src.x, src.y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1])
		listed_atom.forceMove(turf)

/obj/machinery/ocean_elevator/proc/going_up()
	elevator_up = TRUE
	update_appearance()
	if(!trenched)
		return
	var/turf/parent_turf = get_turf(src)
	for(var/atom/movable/listed_atom in parent_turf)
		if(listed_atom.anchored)
			continue
		var/turf/turf = locate(src.x, src.y, SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
		listed_atom.forceMove(turf)

/obj/machinery/button/sea_elevator
	name = "sea elevator button control"
	desc = "a button to control the state of the sea elevators"

/obj/machinery/button/sea_elevator/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!length(GLOB.sea_elevator_list_station[id]))
		return
	///we only need to iterate over the station levels as we just loacte the one below it to mirror
	for(var/obj/machinery/ocean_elevator/listed_elevator as anything in GLOB.sea_elevator_list_station[id])
		if(!istype(listed_elevator)) /// your not suppose to be here
			return
		var/turf/turf = locate(listed_elevator.x, listed_elevator.y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1])
		var/obj/machinery/ocean_elevator/paired_elevator = locate(/obj/machinery/ocean_elevator) in turf.contents
		if(!paired_elevator)
			continue
		if(listed_elevator.elevator_up)
			listed_elevator.going_down()
			paired_elevator.going_down()
		else
			listed_elevator.going_up()
			paired_elevator.going_up()

/turf/open/floor/elevator_shaft
	name = "elevator shaft"
	desc = "A hole going straight down"

	icon = 'goon/icons/turf/floors.dmi'
	icon_state = "moon_shaft"

	overfloor_placed = FALSE


/turf/open/floor/elevator_shaft/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(arrived.anchored)
		return
	var/obj/machinery/ocean_elevator/located_elevator = locate(/obj/machinery/ocean_elevator) in contents

	if(!located_elevator || !located_elevator?.elevator_up)
		var/turf/turf = locate(src.x, src.y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1])
		arrived.forceMove(turf)
		if(iscarbon(arrived))
			var/mob/living/carbon/living_carbon = arrived
			living_carbon.emote("Scream")
			living_carbon.ZImpactDamage(turf, 1)

