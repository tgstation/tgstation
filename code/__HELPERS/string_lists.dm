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
