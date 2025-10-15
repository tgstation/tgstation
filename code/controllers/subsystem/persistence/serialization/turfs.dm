// Save atmos data
/turf/open/get_custom_save_vars()
	. = ..()
	var/datum/gas_mixture/turf_gasmix = return_air()
	.[NAMEOF(src, initial_gas_mix)] = turf_gasmix.to_string()
	return .
