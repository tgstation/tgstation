/proc/getviewsize(view)
	if(isnum(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		return list(totalviewrange, totalviewrange)
	else
		var/list/viewrangelist = splittext(view,"x")
		return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))

/// Returns whether the target is in view range of the source, using either the source's client view, or the world view.
/mob/proc/in_view_range(atom/target)
	if(z != target.z)
		return FALSE
	var/user_view = client?.view || world.view
	if(isnum(user_view))
		if(get_dist(src, target) < user_view)
			return TRUE
		return FALSE
	var/list/view_range_list = splittext(user_view, "x")
	if(abs(x - target.x) < ((text2num(view_range_list[1]) - 1) / 2) && abs(y - target.y) < ((text2num(view_range_list[2]) - 1) / 2))
		return TRUE
	return FALSE

/// Returns whether the target is in range.Assumes the mob to have its vision unimpeded by opaque objects.
/mob/proc/in_ghost_sight_range(atom/target, message_range_x = DEFAULT_MESSAGE_RANGE, message_range_y = DEFAULT_MESSAGE_RANGE)
	if(z != target.z)
		return FALSE
	if(abs(x - target.x) >= message_range_x || abs(y - target.y) >= message_range_y)
		return FALSE
	return TRUE
