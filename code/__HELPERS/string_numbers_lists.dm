GLOBAL_LIST_EMPTY(string_numbers_lists)

/**
 * Caches lists of numeric values.
 */
/datum/proc/string_numbers_list(list/values)
	//Just to to be extra-safe. If you try to shove in text or paths, you deserve the runtime errors.
	var/list/sum = 0
	for(var/number in values)
		sum += number

	var/string_id = values.Join("-")

	. = GLOB.string_numbers_lists[string_id]

	if(.)
		return .

	return GLOB.string_numbers_lists[string_id] = values
