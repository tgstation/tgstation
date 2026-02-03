///When you have a component accepting multiple connections
/datum/component/plumbing/multidirectional
	demand_connects = NORTH

/**
 * Returns the direction in which this component is connected to an ductnet without the rotation
 * Arguments
 *
 * * datum/ductnet/net - the net we are checking for an connection to
*/
/datum/component/plumbing/multidirectional/proc/get_connection(datum/ductnet/net)
	PROTECTED_PROC(TRUE)

	var/atom/movable/parent_movable = parent
	for(var/A in ducts)
		if(ducts[A] == net)
			return turn(text2num(A), dir2angle(parent_movable.dir) - 180)

///Splits reagent amounts along 2 directions
/datum/component/plumbing/multidirectional/splitter
	supply_connects = SOUTH | EAST

/datum/component/plumbing/multidirectional/splitter/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/splitter))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/multidirectional/splitter/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	var/obj/machinery/plumbing/splitter/S = parent
	var/limit = INFINITY
	switch(get_connection(net))
		if(SOUTH)
			limit = S.transfer_straight
		if(EAST)
			limit = S.transfer_side
	amount = min(amount, limit, reagents.total_volume)
	S.use_energy(S.active_power_usage)
	return ..()

///Splits reagents along 3 directions
/datum/component/plumbing/multidirectional/filter
	supply_connects = SOUTH | EAST | WEST //SOUTH is straight, EAST is left and WEST is right. We look from the perspective of the insert

/datum/component/plumbing/multidirectional/filter/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/filter))
		return COMPONENT_INCOMPATIBLE
	return ..()


/**
 * Returns if an reagent can be supplied in an specific direction
 * Arguments
 *
 * * dir - the direction to check
 * * datum/reagent/reagent - the reagent we are checking for
*/
/datum/component/plumbing/multidirectional/filter/proc/can_give_in_direction(dir, datum/reagent/reagent)
	PRIVATE_PROC(TRUE)

	var/obj/machinery/plumbing/filter/F = parent
	switch(dir)
		if(SOUTH) //straight
			if(!F.left.Find(reagent) && !F.right.Find(reagent))
				return TRUE
		if(WEST) //right
			if(F.right.Find(reagent))
				return TRUE
		if(EAST) //left
			if(F.left.Find(reagent))
				return TRUE

/datum/component/plumbing/multidirectional/filter/can_give(amount, reagent, datum/ductnet/net)
	return (reagent ? can_give_in_direction(get_connection(net), reagent) : TRUE) && ..()

/datum/component/plumbing/multidirectional/filter/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	var/obj/machinery/plumbing/filter/F = parent
	if(reagent)
		reagents.trans_to(target.parent, amount, target_id = reagent, methods = round_robin ? LINEAR : NONE)
	else
		var/direction = get_connection(net)
		for(var/datum/reagent/R as anything in reagents.reagent_list)
			if(!can_give_in_direction(direction, R.type))
				continue
			amount -= reagents.trans_to(target.parent, min(R.volume, amount), target_id = R.type, methods = round_robin ? LINEAR : NONE)
			if(amount <= 0)
				break
	F.use_energy(F.active_power_usage)
