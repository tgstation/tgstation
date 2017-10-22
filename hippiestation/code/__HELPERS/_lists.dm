/proc/is_type_in_ref_list(path, list/L)
	if(!ispath(path))//not a path
		return
	for(var/i in L)
		var/datum/D = i
		if(!istype(D))//not an usable reference
			continue
		if(istype(D, path))
			return TRUE