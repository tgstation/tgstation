GLOBAL_LIST_EMPTY(string_assoc_nested_lists)

/**
 * Caches associative nested lists with non-numeric stringify-able index keys and stringify-able values (text/typepath -> text/path/number).
 */
/proc/string_assoc_nested_list(list/list)
	var/list/string_id = list()
	for(var/key, value in list)
		string_id += "[key]_[islist(value) ? "ASSLIST([REF(string_assoc_nested_list(value))])" : value]"
	string_id = string_id.Join("-")

	. = GLOB.string_assoc_nested_lists[string_id]

	if(.)
		return .

	return GLOB.string_assoc_nested_lists[string_id] = list
