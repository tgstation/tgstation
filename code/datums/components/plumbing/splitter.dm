/datum/component/plumbing/splitter
	demand_connects = NORTH
	supply_connects = SOUTH | EAST

/datum/component/plumbing/splitter/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/splitter))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/splitter/supply_demand(dir)
	var/amount = MACHINE_REAGENT_TRANSFER
	var/obj/machinery/plumbing/splitter/S = parent
	switch(get_original_direction(dir))
		if(SOUTH)
			amount = S.transfer_straight
		if(EAST)
			amount = S.transfer_side
	return process_demand(amount, dir)

