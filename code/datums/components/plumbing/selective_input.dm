/// Only draws a whitelist of reagents
/datum/component/plumbing/selective
	demand_connects = NORTH
	supply_connects = SOUTH

	/// A list of reagent types that we allow
	var/list/allowed_reagents

/datum/component/plumbing/selective/Initialize(start, ducting_layer, turn_connects, datum/reagents/custom_receiver, extend_pipe_to_edge, allowed_reagents)
	. = ..()
	src.allowed_reagents = allowed_reagents

/datum/component/plumbing/selective/send_request(dir)
	for(var/allowed_type in allowed_reagents)
		process_request(MACHINE_REAGENT_TRANSFER, allowed_type, dir)
