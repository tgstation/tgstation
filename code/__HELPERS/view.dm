/proc/getviewsize(view)
	if(istext(view))
		return splittext(view,"x")
	else
		var/num = 1+2*view
		return list(num,num)
