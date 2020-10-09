GLOBAL_LIST_EMPTY(string_lists)

/**
  * Caches lists with non-numeric stringify-able values (text or typepath).
  */
/datum/proc/string_list(list/values)
	var/string_id = values.Join("-")

	. = GLOB.string_lists[string_id]

	if(.)
		return

	return GLOB.string_lists[string_id] = values

///A wrapper for baseturf string lists, to help preserve functionality
/datum/proc/baseturfs_string_list(list/values, var/turf/T)
	if(!islist(values))
		return values
	if(length(values) > 100)
		CRASH("The baseturfs list of [T] at [T.x], [T.y], [T.x] is [length(values)], it should never be this long, investigate.")
	return string_list(values)
