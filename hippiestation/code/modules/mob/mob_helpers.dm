/proc/muffledspeech(phrase)
	phrase = html_decode(phrase)
	var/leng=lentext(phrase)
	var/counter=lentext(phrase)
	var/newphrase=""
	var/newletter=""
	var/is_upper = FALSE
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		is_upper = FALSE
		if(uppertext(newletter) == newletter)
			is_upper = TRUE
		else if(lowertext(newletter) == newletter)
			is_upper = FALSE

		if(newletter in list(" ", "!", "?", ".", ","))
			//do nothing
		else if(lowertext(newletter) in list("a", "e", "i", "o", "u", "y"))
			if(is_upper)
				newletter = "PH"
			else
				newletter = "ph"
		else
			if(is_upper)
				newletter = "M"
			else
				newletter = "m"
		newphrase+="[newletter]"
		counter-=1
	return newphrase