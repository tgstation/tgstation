///Returns all the objects that we are nested within the contents of starting with ourself then adding our previous loc's loc, does not include our turf
/atom/movable/proc/get_locs_recursive()
	var/atom/movable/current_loc = loc
	var/list/locs_list = list(src)
	if(!current_loc)
		return locs_list

	var/sanity = 0 //you REALLY should not have something nested in 500 layers of contents
	while(!isturf(current_loc))
		sanity++
		locs_list += current_loc
		if(sanity > 500 || !ismovable(current_loc))
			return locs_list

		current_loc = current_loc.loc
	return locs_list //if sanity is 0 then that means our loc is a turf and we are the highest level loc

///Returns our highest level loc that is not a turf or ourselves if we are directly in a turf, if we were in a box in the backpack of a mob we would return that mob
/atom/movable/proc/get_highest_non_turf_loc()
	var/list/locs_list = get_locs_recursive()
	return locs_list[length(locs_list)]

/atom/proc/effective_contents(list/typecache = null)
	var/static/list/default_typecache
	if(!typecache)
		default_typecache ||= typecacheof(list(/obj/effect, /atom/movable/screen))
		typecache = default_typecache
	return typecache_filter_list_reverse(src.contents, typecache)
