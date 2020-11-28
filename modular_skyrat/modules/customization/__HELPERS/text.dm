/proc/prefix_a_or_an(text)
	var/start = lowertext(text[1])
	if(!start)
		return "a"
	if(start == "a" || start == "e" || start == "i" || start == "o" || start == "u")
		return "an"
	else
		return "a"
