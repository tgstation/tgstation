/proc/getviewsize(view)
	var/viewX
	var/viewY
	if(isnum(view))
		var/totalviewrange = 1 + 2 * view
		viewX = totalviewrange
		viewY = totalviewrange
	else
		var/list/viewrangelist = splittext(view,"x")
		viewX = text2num(viewrangelist[1])
		viewY = text2num(viewrangelist[2])
	return list(viewX, viewY)