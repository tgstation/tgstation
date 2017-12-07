/proc/getviewsize(view)
	if(isnum(view))
		. = 1 + 2 * view
		return list(.,.)
	if(istext(view))
		. = splittext(view,"x")
		return list(text2num(.[1]),text2num(.[2]))
