/**
 * Finds a duct or machinery located at the same layers as the the param obj
 *
 * Arguments
 * * obj/machinery/parent_obj - the machinery we are checking for
 * * list/ducting_layers - the various ducting layers the machinery is occupying
*/
/proc/ducting_layer_check(obj/machinery/parent_obj, list/ducting_layers)
	if(!islist(ducting_layers))
		ducting_layers = list(ducting_layers)

	for(var/obj/machinery/other in parent_obj.loc)
		if(other == parent_obj)
			continue

		//check for overlapping ducts
		var/obj/machinery/duct/pipe = other
		if(istype(pipe) && (pipe.duct_layer in ducting_layers))
			return pipe

		//check for overlapping machines
		for(var/datum/component/plumbing/plumber as anything in other.GetComponents(/datum/component/plumbing))
			if(plumber.ducting_layer in ducting_layers)
				return plumber
