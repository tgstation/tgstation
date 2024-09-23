/mob/proc/get_top_level_mob()
	if(ismob(loc) && (loc != src))
		var/mob/M = loc
		return M.get_top_level_mob()
	return src
