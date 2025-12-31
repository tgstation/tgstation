/**
 * Finds a duct or machinery located at the same layer as the the param obj
 *
 * Arguments
 * * obj/machinery/parent_obj - the machinery we are checking for
 * * ducting_layer - the ducting layer the machinery is occupying
*/
/proc/ducting_layer_check(obj/machinery/parent_obj, ducting_layer)
	for(var/obj/machinery/other in parent_obj.loc)
		if(other == parent_obj)
			continue

		//check for overlapping ducts
		var/obj/machinery/duct/pipe = other
		if(istype(pipe) && (pipe.duct_layer & ducting_layer))
			return pipe

		//check for overlapping machines
		for(var/datum/component/plumbing/plumber as anything in other.GetComponents(/datum/component/plumbing))
			if(plumber.ducting_layer & ducting_layer)
				return plumber
