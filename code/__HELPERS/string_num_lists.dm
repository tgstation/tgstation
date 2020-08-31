GLOBAL_LIST_EMPTY(string_num_lists)


///based proc that yeets a list in a glob list with an index unless it already existed, if it did just return that list. perfect for keeping 1 (one) instance. thanks rohesie very cool.
/datum/proc/string_num_list(list/values)
  var/list/string_id = list()
  for(var/val in values)
    string_id += "[val]_[values[val]]"
  string_id.Join("-")

  . = GLOB.string_num_lists[string_id]

  if(.)
    return

  return GLOB.string_num_lists[string_id] = values
