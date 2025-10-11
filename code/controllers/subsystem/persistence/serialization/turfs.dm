// Optimiziations that skip saving atmospheric data for turfs that don't need it
// - Space: Gas is constantly purged, and temperature is immutable
// - Walls: Atmos values should not realistically change
// - Planetary: Atmos slowly reverts to its default gas mix
/turf/open/get_custom_save_vars()
	. = ..()
	if(isspaceturf(src) || planetary_atmos)
		return .

	var/datum/gas_mixture/turf_gasmix = return_air()
	.[NAMEOF(src, initial_gas_mix)] = turf_gasmix.to_string()
	return .
