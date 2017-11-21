/proc/getviewsize(view)
	if(isnum(view))
		var/totalviewrange = 1 + 2 * client.view
		viewX = totalviewrange
		viewY = totalviewrange
	else
		var/list/viewrangelist = splittext(view,"x")
		viewX = text2num(viewrangelist[1])
		viewY = text2num(viewrangelist[2])
	return list(viewX, viewY)