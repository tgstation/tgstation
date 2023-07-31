GLOBAL_LIST_EMPTY(string_assoc_lists)

/**
 * Caches associative lists with non-numeric stringify-able index keys and stringify-able values (text/typepath -> text/path/number).
 */
/datum/proc/string_assoc_list(list/values)
	var/list/string_id = list()
	for(var/val in values)
		string_id += "[val]_[values[val]]"
	string_id = string_id.Join("-")

	. = GLOB.string_assoc_lists[string_id]

	if(.)
		return .

	return GLOB.string_assoc_lists[string_id] = values
