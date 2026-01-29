///When your device has multiple directions for input or output
/datum/component/plumbing/multi_directional

///Give the direction of a pipe, and it'll return wich direction it originally was when its object pointed SOUTH
/datum/component/plumbing/multi_directional/proc/get_original_direction(dir)
	PROTECTED_PROC(TRUE)

	if(!dir)
		return 0
	var/atom/movable/parent_movable = parent
	return turn(dir, dir2angle(parent_movable.dir) - 180)

/datum/component/plumbing/multi_directional/send_request(dir)
	return process_request(amount = MACHINE_REAGENT_TRANSFER * 2, dir = dir) //these need to move reagents fast

///Splitter that transfers diffrent amounts along diffrent directions
/datum/component/plumbing/multi_directional/splitter
	demand_connects = NORTH
	supply_connects = SOUTH | EAST

/datum/component/plumbing/multi_directional/splitter/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/splitter))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/multi_directional/splitter/supply_demand(dir)
	var/amount = MACHINE_REAGENT_TRANSFER
	var/obj/machinery/plumbing/splitter/S = parent
	switch(get_original_direction(dir))
		if(SOUTH)
			amount = S.transfer_straight
		if(EAST)
			amount = S.transfer_side
	return process_demand(amount, dir = dir)


///The magical plumbing component used by the chemical filters. The different supply connects behave differently depending on the filters set on the chemical filter
/datum/component/plumbing/multi_directional/filter
	demand_connects = NORTH
	supply_connects = SOUTH | EAST | WEST //SOUTH is straight, EAST is left and WEST is right. We look from the perspective of the insert

/datum/component/plumbing/multi_directional/filter/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/filter))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/multi_directional/filter/supply_demand(dir)
	var/list/whitelist = null

	var/obj/machinery/plumbing/filter/F = parent
	switch(get_original_direction(dir))
		if(SOUTH) //straight
			if(length(F.left) || length(F.right))
				whitelist = list()
				for(var/datum/reagent/target as anything in reagents.reagent_list)
					if((target.type in F.left) || (target.type in F.right))
						continue
					whitelist += target.type
				if(whitelist.len == reagents.reagent_list.len)
					whitelist = null
		if(EAST) //left
			whitelist = F.left
		if(WEST) //right
			whitelist = F.right

	. = 0
	var/transfer = MACHINE_REAGENT_TRANSFER * 2
	if(whitelist)
		for(var/datum/reagent/send as anything in whitelist)
			. += process_demand(amount = transfer, reagent = send, dir = dir)
	else
		. = process_demand(amount = transfer, dir = dir)
