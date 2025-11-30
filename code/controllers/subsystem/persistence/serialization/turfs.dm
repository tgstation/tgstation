// Save atmos data
/turf/open/get_custom_save_vars(save_flags=ALL)
	. = ..()

	if(!(save_flags & SAVE_TURFS_ATMOS))
		return .

	// is_safe_turf checks if the temperature, gas mix, pressure is in the goldilock safe zones
	// if it is safe, we skip saving atmos and use the default to help compress our map save size
	if(!is_safe_turf(src)) // compare optimization times in tracy with this check enabled vs without
		var/datum/gas_mixture/turf_gasmix = return_air()
		.[NAMEOF(src, initial_gas_mix)] = turf_gasmix.to_string()
	return .
