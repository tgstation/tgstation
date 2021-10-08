/proc/getviewsize(view)
	if(isnum(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		return list(totalviewrange, totalviewrange)
	else
		var/list/viewrangelist = splittext(view,"x")
		return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))

/proc/in_view_range(mob/user, atom/A)
	var/list/view_range = getviewsize(user.client.view)
	var/turf/source = get_turf(user)
	var/turf/target = get_turf(A)
	return ISINRANGE(target.x, source.x - view_range[1], source.x + view_range[1]) && ISINRANGE(target.y, source.y - view_range[1], source.y + view_range[1])
