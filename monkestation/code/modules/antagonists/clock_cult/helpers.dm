//simple proc to check if something is in the reebe area or not, I would do this based off of z level but im unsure how to get a lazytemplate's z level
//macro might be better here
/proc/on_reebe(atom/checked_atom)
	var/area/in_area = get_area(checked_atom) //is this even needed?
	if(istype(in_area, /area/ruin/powered/reebe/city) || istype(in_area, /area/ruin/powered/reebe/space)) //might want to use a typecache for this
		return TRUE
	return FALSE
