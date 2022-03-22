/proc/molar_cmp_less_than(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return (a < (b + epsilon))

/proc/molar_cmp_greater_than(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return ((a + epsilon) > b)

/proc/molar_cmp_equals(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return (((a + epsilon) > b) && ((a - epsilon) < b))

/** A simple rudimentary gasmix to information list converter. Can be used for UIs.
 * Args: 
 * - gasmix: [/datum/gas_mixture]
 * - name: String used to name the list, optional.
 * Returns: A list parsed_gasmixes with the following structure:
 * - parsed_gasmixes - Assoc List
 * -- Key: name			Value: String			Desc: Gasmix Name
 * -- Key: temperature		Value: Number			Desc: Temperature in kelvins
 * -- Key: volume 			Value: Number			Desc: Volume in liters
 * -- Key: pressure 		Value: Number			Desc: Pressure in kPa
 * -- Key: ref				Value: Text				Desc: The reference for the instantiated gasmix.
 * -- Key: gases			Value: Assoc list		Desc: List of gasses in our gasmix
 * --- Key: gas_name 		Value: Gas Mole			Desc: Gas Name - Gas Amount pair
 * Returned list should always be filled with keys even if value are nulls.
 */
/proc/gas_mixture_parser(datum/gas_mixture/gasmix, name)
	. = list(
		"gases" = list(),
		"name" = name,
		"total_moles" = null,
		"temperature" = null,
		"volume"= null,
		"pressure"= null,
		"ref" = null,
		)
	if(!gasmix)
		return
	for(var/gas_id in gasmix.gases)
		.["gases"][gasmix.gases[gas_id][GAS_META][META_GAS_NAME]] = gasmix.gases[gas_id][MOLES]
	.["total_moles"] = gasmix.total_moles()
	.["temperature"] = gasmix.temperature
	.["volume"] = gasmix.volume
	.["pressure"] = gasmix.return_pressure()
	.["ref"] = REF(gasmix)
