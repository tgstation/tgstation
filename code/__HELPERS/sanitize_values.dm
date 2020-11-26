//general stuff
/proc/sanitize_integer(number, min=0, max=1, default=0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_float(number, min=0, max=1, accuracy=1, default=0)
	if(isnum(number))
		number = round(number, accuracy)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_text(text, default="")
	if(istext(text))
		return text
	return default

/proc/sanitize_islist(value, default)
	if(islist(value) && length(value))
		return value
	if(default)
		return default

/proc/sanitize_inlist(value, list/List, default)
	if(value in List)
		return value
	if(default)
		return default
	if(List?.len)
		return pick(List)



//more specialised stuff
/proc/sanitize_gender(gender,neuter=0,plural=1, default="male")
	switch(gender)
		if(MALE, FEMALE)
			return gender
		if(NEUTER)
			if(neuter)
				return gender
			else
				return default
		if(PLURAL)
			if(plural)
				return gender
			else
				return default
	return default

/proc/sanitize_hexcolor(color, desired_format=3, include_crunch=0, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// RRGGBB -> RGB but awful
	var/convert_to_shorthand = desired_format == 3 && length_char(color) > 3

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		switch(text2ascii(char))
			if(48 to 57)		//numbers 0 to 9
				. += char
			if(97 to 102)		//letters a to f
				. += char
			if(65 to 70)		//letters A to F
				. += lowertext(char)
			else
				break
		i += length(char)
		if(convert_to_shorthand && i <= len) //skip next one
			i += length(color[i])

	if(length_char(.) != desired_format)
		if(default)
			return default
		return crunch + repeat_string(desired_format, "0")

	return crunch + .

/// Makes sure the input color is text with a # at the start followed by 6 hexadecimal characters. Examples: "#ff1234", "#A38321", COLOR_GREEN_GRAY
/proc/sanitize_ooccolor(color)
	var/static/regex/color_regex = regex(@"^#[0-9a-fA-F]{6}$")
	return findtext(color, color_regex) ? color : GLOB.normal_ooc_colour
