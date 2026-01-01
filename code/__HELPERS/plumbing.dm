/**
 * Finds a duct or plumbing machinery located at the destination
 *
 * Arguments
 * * atom/destination - the target loc we are checking for
 * * ducting_layer - the ducting layer to check for. Pass 0 to ignore all layer checks
*/
/proc/ducting_layer_check(atom/destination, ducting_layer, check_machine_layer)
	. = null
	for(var/obj/machinery/other in get_turf(destination))
		if(other == destination)
			continue

		//check for overlapping ducts
		var/obj/machinery/duct/pipe = other
		if(istype(pipe) && (!ducting_layer || (pipe.duct_layer & ducting_layer)))
			return pipe

		//check for overlapping machines that are not wallmounts cause they are allowed on the same turf
		if(!HAS_TRAIT(destination, TRAIT_WALLMOUNTED))
			for(var/datum/component/plumbing/plumber as anything in other.GetComponents(/datum/component/plumbing))
				return plumber
