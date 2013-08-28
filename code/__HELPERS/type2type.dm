/*
 * Holds procs designed to change one type of value, into another.
 * Contains:
 *			hex2num & num2hex
 *			text2list & list2text
 *			file2list
 *			angle2dir
 *			angle2text
 *			worldtime2text
 */

//Returns an integer given a hex input, supports negative values "-ff"
//skips preceding invalid characters
//breaks when hittin invalid characters thereafter
/proc/hex2num(hex)
	. = 0
	if(istext(hex))
		var/negative = 0
		var/len = length(hex)
		for(var/i=1, i<=len, i++)
			var/num = text2ascii(hex,i)
			switch(num)
				if(48 to 57)	num -= 48	//0-9
				if(97 to 102)	num -= 87	//a-f
				if(65 to 70)	num -= 55	//A-F
				if(45)			negative = 1//-
				else
					if(num)		break
					else		continue
			. *= 16
			. += num
		if(negative)
			. *= -1
	return .

//Returns the hex value of a decimal number
//len == length of returned string
//if len < 0 then the returned string will be as long as it needs to be to contain the data
//Only supports positive numbers
//if an invalid number is provided, it assumes num==0
//Note, unlike previous versions, this one works from low to high <-- that way
/proc/num2hex(num, len=2)
	if(!isnum(num))
		num = 0
	num = round(abs(num))
	. = ""
	var/i=0
	while(1)
		if(len<=0)
			if(!num)	break
		else
			if(i>=len)	break
		var/remainder = num/16
		num = round(remainder)
		remainder = (remainder - num) * 16
		switch(remainder)
			if(9,8,7,6,5,4,3,2,1)	. = "[remainder]" + .
			if(10,11,12,13,14,15)	. = ascii2text(remainder+87) + .
			else					. = "0" + .
		i++
	return .


//Attaches each element of a list to a single string seperated by 'seperator'.
/proc/dd_list2text(var/list/the_list, separator)
	var/total = the_list.len
	if(!total)
		return
	var/count = 2
	var/newText = "[the_list[1]]"
	while(count <= total)
		if(separator)
			newText += separator
		newText += "[the_list[count]]"
		count++
	return newText


//slower then dd_list2text, but correctly processes associative lists.
proc/tg_list2text(list/list, glue=",")
	if(!istype(list) || !list.len)
		return
	var/output
	for(var/i=1 to list.len)
		output += (i!=1? glue : null)+(!isnull(list["[list[i]]"])?"[list["[list[i]]"]]":"[list[i]]")
	return output


//Converts a text string into a list by splitting the string at each seperator found in text (discarding the seperator)
//Returns an empty list if the text cannot be split, or the split text in a list.
//Not giving a "" seperator will cause the text to be broken into a list of single letters.
/proc/text2list(text, seperator="\n")
	. = list()

	var/text_len = length(text)					//length of the input text
	var/seperator_len = length(seperator)		//length of the seperator text

	if(text_len >= seperator_len)
		var/i
		var/last_i = 1

		for(i=1,i<=(text_len+1-seperator_len),i++)
			if( cmptext(copytext(text,i,i+seperator_len), seperator) )
				if(i != last_i)
					. += copytext(text,last_i,i)
				last_i = i + seperator_len

		if(last_i <= text_len)
			. += copytext(text, last_i, 0)
	else
		. += text
	return .

//Converts a text string into a list by splitting the string at each seperator found in text (discarding the seperator)
//Returns an empty list if the text cannot be split, or the split text in a list.
//Not giving a "" seperator will cause the text to be broken into a list of single letters.
//Case Sensitive!
/proc/text2listEx(text, seperator="\n")
	. = list()

	var/text_len = length(text)					//length of the input text
	var/seperator_len = length(seperator)		//length of the seperator text

	if(text_len >= seperator_len)
		var/i
		var/last_i = 1

		for(i=1,i<=(text_len+1-seperator_len),i++)
			if( cmptextEx(copytext(text,i,i+seperator_len), seperator) )
				if(i != last_i)
					. += copytext(text,last_i,i)
				last_i = i + seperator_len

		if(last_i <= text_len)
			. += copytext(text, last_i, 0)
	else
		. += text
	return .

//Splits the text of a file at seperator and returns them in a list.
/proc/file2list(filename, seperator="\n")
	return text2list(return_file_text(filename),seperator)


//Turns a direction into text
/proc/dir2text(direction)
	switch(direction)
		if(1.0)
			return "north"
		if(2.0)
			return "south"
		if(4.0)
			return "east"
		if(8.0)
			return "west"
		if(5.0)
			return "northeast"
		if(6.0)
			return "southeast"
		if(9.0)
			return "northwest"
		if(10.0)
			return "southwest"
		else
	return

//Turns text into proper directions
/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10
		else
	return

//Converts an angle (degrees) into an ss13 direction
/proc/angle2dir(var/degree)

	// Will filter out extra rotations and negative rotations
	// E.g: 540 becomes 180. -180 becomes 180.
	// Thanks to Flexicode for the formula.
	degree = ((degree % 360 + 22.5) + 360) % 365

	if(degree < 45)		return NORTH
	if(degree < 90)		return NORTHEAST
	if(degree < 135)	return EAST
	if(degree < 180)	return SOUTHEAST
	if(degree < 225)	return SOUTH
	if(degree < 270)	return SOUTHWEST
	if(degree < 315)	return WEST
	return NORTH|WEST

//returns the north-zero clockwise angle in degrees, given a direction

/proc/dir2angle(var/D)
	switch(D)
		if(NORTH)		return 0
		if(SOUTH)		return 180
		if(EAST)		return 90
		if(WEST)		return 270
		if(NORTHEAST)	return 45
		if(SOUTHEAST)	return 135
		if(NORTHWEST)	return 315
		if(SOUTHWEST)	return 225
		else			return null

//Returns the angle in english
/proc/angle2text(var/degree)
	return dir2text(angle2dir(degree))


//Converts a rights bitfield into a string
/proc/rights2text(rights, seperator="", list/adds, list/subs)
	if(rights & R_BUILDMODE)	. += "[seperator]+BUILDMODE"
	if(rights & R_ADMIN)		. += "[seperator]+ADMIN"
	if(rights & R_BAN)			. += "[seperator]+BAN"
	if(rights & R_FUN)			. += "[seperator]+FUN"
	if(rights & R_SERVER)		. += "[seperator]+SERVER"
	if(rights & R_DEBUG)		. += "[seperator]+DEBUG"
	if(rights & R_POSSESS)		. += "[seperator]+POSSESS"
	if(rights & R_PERMISSIONS)	. += "[seperator]+PERMISSIONS"
	if(rights & R_STEALTH)		. += "[seperator]+STEALTH"
	if(rights & R_REJUVINATE)	. += "[seperator]+REJUVINATE"
	if(rights & R_VAREDIT)		. += "[seperator]+VAREDIT"
	if(rights & R_SOUNDS)		. += "[seperator]+SOUND"
	if(rights & R_SPAWN)		. += "[seperator]+SPAWN"

	for(var/verbpath in adds)
		. += "[seperator]+[verbpath]"
	for(var/verbpath in subs)
		. += "[seperator]-[verbpath]"
	return .

/proc/ui_style2icon(ui_style)
	switch(ui_style)
		if("Retro")		return 'icons/mob/screen_retro.dmi'
		if("Plasmafire")	return 'icons/mob/screen_plasmafire.dmi'
		else			return 'icons/mob/screen_midnight.dmi'

//colour formats
/proc/rgb2hsl(red, green, blue)
	red /= 255;green /= 255;blue /= 255;
	var/max = max(red,green,blue)
	var/min = min(red,green,blue)
	var/range = max-min

	var/hue=0;var/saturation=0;var/lightness=0;
	lightness = (max + min)/2
	if(range != 0)
		if(lightness < 0.5)	saturation = range/(max+min)
		else				saturation = range/(2-max-min)

		var/dred = ((max-red)/(6*max)) + 0.5
		var/dgreen = ((max-green)/(6*max)) + 0.5
		var/dblue = ((max-blue)/(6*max)) + 0.5

		if(max==red)		hue = dblue - dgreen
		else if(max==green)	hue = dred - dblue + (1/3)
		else				hue = dgreen - dred + (2/3)
		if(hue < 0)			hue++
		else if(hue > 1)	hue--

	return list(hue, saturation, lightness)

/proc/hsl2rgb(hue, saturation, lightness)
	var/red;var/green;var/blue;
	if(saturation == 0)
		red = lightness * 255
		green = red
		blue = red
	else
		var/a;var/b;
		if(lightness < 0.5)	b = lightness*(1+saturation)
		else				b = (lightness+saturation) - (saturation*lightness)
		a = 2*lightness - b

		red = round(255 * hue2rgb(a, b, hue+(1/3)))
		green = round(255 * hue2rgb(a, b, hue))
		blue = round(255 * hue2rgb(a, b, hue-(1/3)))

	return list(red, green, blue)

/proc/hue2rgb(a, b, hue)
	if(hue < 0)			hue++
	else if(hue > 1)	hue--
	if(6*hue < 1)	return (a+(b-a)*6*hue)
	if(2*hue < 1)	return b
	if(3*hue < 2)	return (a+(b-a)*((2/3)-hue)*6)
	return a