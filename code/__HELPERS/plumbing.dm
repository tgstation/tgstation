/**
 * Finds a duct or machinery located at the same layer in the target loc
 *
 * Arguments
 * * atom/destination - the target loc we are checking for
 * * ducting_layer - the ducting layer the machinery is occupying
*/
/proc/ducting_layer_check(atom/destination, ducting_layer)
	. = null
	for(var/obj/machinery/other in get_turf(destination))
		if(other == destination)
			continue

		//check for overlapping ducts
		var/obj/machinery/duct/pipe = other
		if(istype(pipe) && (pipe.duct_layer & ducting_layer))
			return pipe

		//check for overlapping machines
		for(var/datum/component/plumbing/plumber as anything in other.GetComponents(/datum/component/plumbing))
			if(plumber.ducting_layer & ducting_layer)
				return plumber
