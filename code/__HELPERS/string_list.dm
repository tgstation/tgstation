GLOBAL_LIST_EMPTY(string_lists)

///based proc that yeets a list in a glob list with an index unless it already existed, if it did just return that list. perfect for keeping 1 (one) instance. thanks rohesie very cool.
/datum/proc/string_list(list/values)
  var/string_id = values.Join("-")

  . = GLOB.string_lists[string_id]

  if(.)
    return

  return GLOB.string_lists[string_id] = values
