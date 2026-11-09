/**
 * Finds a duct or plumbing machinery located at the destination
 *
 * Arguments
 * * atom/destination - the target loc we are checking for
 * * ducting_layer - the ducting layer to check for. pass -ve value when you are checking for overlapping machines
*/
/proc/ducting_layer_check(atom/destination, ducting_layer)
	. = null

	var/is_machine = FALSE
	if(ducting_layer < 0)
		is_machine = TRUE
		ducting_layer = abs(ducting_layer)

	for(var/atom/movable/other in get_turf(destination))
		if(other == destination)
			continue

		//check for overlapping ducts
		var/obj/machinery/duct/pipe = other
		if(istype(pipe) && (pipe.duct_layer & ducting_layer))
			return pipe

		//check for overlapping machines. -ve duct layer means we are checking machines on machines overlap which regardless of layer is not allowed
		for(var/datum/component/plumbing/plumber as anything in other.GetComponents(/datum/component/plumbing))
			if(is_machine || (plumber.ducting_layer & ducting_layer))
				return plumber
