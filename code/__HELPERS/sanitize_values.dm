//general stuff
/proc/sanitize_integer(number, min=0, max=1, default=0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_text(text, default="")
	if(istext(text))
		return text
	return default

/proc/sanitize_inlist(value, list/List, default)
	if(value in List)	return value
	if(default)			return default
	if(List && List.len)return pick(List)



//more specialised stuff
/proc/sanitize_gender(gender,neuter=0,plural=0, default="male")
	switch(gender)
		if(MALE, FEMALE)return gender
		if(NEUTER)
			if(neuter)	return gender
			else		return default
		if(PLURAL)
			if(plural)	return gender
			else		return default
	return default


/proc/sanitize_hexcolor(color, desired_format=3, include_bang=0)
	var/bang = include_bang ? "#" : ""
	if(!istext(color))
		return bang + random_string(desired_format, zero_character_only)
	
	var/start = 1 + (text2ascii(color,1)==35)
	var/len = length(color)
	var/step_size = 1 + ((len+1)-start != desired_format)
	
	. = bang
	for(var/i=start, i<=len, i+=step_size)
		var/ascii = text2ascii(color,i)
		switch(ascii)
			if(48 to 57)	. += ascii2text(ascii)		//numbers 0 to 9
			if(97 to 102)	. += ascii2text(ascii)		//letters a to f
			if(65 to 70)	. += ascii2text(ascii+32)	//letters A to F - translates to lowercase
			else			return bang + random_string(desired_format, zero_character_only)
	
	return .