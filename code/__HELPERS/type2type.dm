/*
 * Holds procs designed to change one type of value, into another.
 * Contains:
 *			hex2num & num2hex
 *			text2list & list2text
 *			file2list
 *			angle2dir
 *			angle2text
 *			worldtime2text
 *			text2dir_extended & dir2text_short
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


// Concatenates a list of strings into a single string.  A seperator may optionally be provided.
/proc/list2text(list/ls, sep)
	if(ls.len <= 1) // Early-out code for empty or singleton lists.
		return ls.len ? ls[1] : ""

	var/l = ls.len // Made local for sanic speed.
	var/i = 0 // Incremented every time a list index is accessed.

	if(sep != null)
		// Macros expand to long argument lists like so: sep, ls[++i], sep, ls[++i], sep, ls[++i], etc...
		#define S1    sep, ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		// Having the small concatenations come before the large ones boosted speed by an average of at least 5%.
		if(l-1 & 0x01) // 'i' will always be 1 here.
			. = text("[][][]", ., S1) // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][][][][][]", ., S4) // And so on....
		if(l-i & 0x08)
			. = text("[][][][][][][][][][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

	else
		// Macros expand to long argument lists like so: ls[++i], ls[++i], ls[++i], etc...
		#define S1    ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		if(l-1 & 0x01) // 'i' will always be 1 here.
			. += "[S1]" // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][]", ., S4) // And so on...
		if(l-i & 0x08)
			. = text("[][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1


//slower then list2text, but correctly processes associative lists.
/proc/tg_list2text(list/list, glue=",")
	if(!istype(list) || !list.len)
		return
	var/output
	for(var/i=1 to list.len)
		output += (i!=1? glue : null)+(!isnull(list["[list[i]]"])?"[list["[list[i]]"]]":"[list[i]]")
	return output


//Converts a string into a list by splitting the string at each delimiter found. (discarding the seperator)
/proc/text2list(text, delimiter="\n")
	var/delim_len = length(delimiter)
	if(delim_len < 1) return list(text)
	. = list()
	var/last_found = 1
	var/found
	do
		found = findtext(text, delimiter, last_found, 0)
		. += copytext(text, last_found, found)
		last_found = found + delim_len
	while(found)

//Case Sensitive!
/proc/text2listEx(text, delimiter="\n")
	var/delim_len = length(delimiter)
	if(delim_len < 1) return list(text)
	. = list()
	var/last_found = 1
	var/found
	do
		found = findtextEx(text, delimiter, last_found, 0)
		. += copytext(text, last_found, found)
		last_found = found + delim_len
	while(found)

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

	degree = SimplifyDegrees(degree)

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

//Converts a blend_mode constant to one acceptable to icon.Blend()
/proc/blendMode2iconMode(blend_mode)
	switch(blend_mode)
		if(BLEND_MULTIPLY) return ICON_MULTIPLY
		if(BLEND_ADD)      return ICON_ADD
		if(BLEND_SUBTRACT) return ICON_SUBTRACT
		else               return ICON_OVERLAY

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

// Very ugly, BYOND doesn't support unix time and rounding errors make it really hard to convert it to BYOND time.
// returns "YYYY-MM-DD" by default
/proc/unix2date(timestamp, seperator = "-")

	if(timestamp < 0)
		return 0 //Do not accept negative values

	var/year = 1970 //Unix Epoc begins 1970-01-01
	var/dayInSeconds = 86400 //60secs*60mins*24hours
	var/daysInYear = 365 //Non Leap Year
	var/daysInLYear = daysInYear + 1//Leap year
	var/days = round(timestamp / dayInSeconds) //Days passed since UNIX Epoc
	var/tmpDays = days + 1 //If passed (timestamp < dayInSeconds), it will return 0, so add 1
	var/monthsInDays = list() //Months will be in here ***Taken from the PHP source code***
	var/month = 1 //This will be the returned MONTH NUMBER.
	var/day //This will be the returned day number.

	while(tmpDays > daysInYear) //Start adding years to 1970
		year++
		if(isLeap(year))
			tmpDays -= daysInLYear
		else
			tmpDays -= daysInYear

	if(isLeap(year)) //The year is a leap year
		monthsInDays = list(-1,30,59,90,120,151,181,212,243,273,304,334)
	else
		monthsInDays = list(0,31,59,90,120,151,181,212,243,273,304,334)

	var/mDays = 0;
	var/monthIndex = 0;

	for(var/m in monthsInDays)
		monthIndex++
		if(tmpDays > m)
			mDays = m
			month = monthIndex

	day = tmpDays - mDays //Setup the date

	return "[year][seperator][((month < 10) ? "0[month]" : month)][seperator][((day < 10) ? "0[day]" : day)]"

/*
var/list/test_times = list("December" = 1323522004, "August" = 1123522004, "January" = 1011522004,
						   "Jan Leap" = 946684800, "Jan Normal" = 978307200, "New Years Eve" = 1009670400,
						   "New Years" = 1009836000, "New Years 2" = 1041372000, "New Years 3" = 1104530400,
						   "July Month End" = 744161003, "July Month End 12" = 1343777003, "End July" = 1091311200)
for(var/t in test_times)
	world.log << "TEST: [t] is [unix2date(test_times[t])]"
*/

/proc/isLeap(y)
	return ((y) % 4 == 0 && ((y) % 100 != 0 || (y) % 400 == 0))

// A copy of text2dir, extended to accept one and two letter
//  directions, and to clearly return 0 otherwise.
/proc/text2dir_extended(direction)
	switch(uppertext(direction))
		if("NORTH", "N")
			return 1
		if("SOUTH", "S")
			return 2
		if("EAST", "E")
			return 4
		if("WEST", "W")
			return 8
		if("NORTHEAST", "NE")
			return 5
		if("NORTHWEST", "NW")
			return 9
		if("SOUTHEAST", "SE")
			return 6
		if("SOUTHWEST", "SW")
			return 10
		else
	return 0



// A copy of dir2text, which returns the short one or two letter
//  directions used in tube icon states.
/proc/dir2text_short(direction)
	switch(direction)
		if(1)
			return "N"
		if(2)
			return "S"
		if(4)
			return "E"
		if(8)
			return "W"
		if(5)
			return "NE"
		if(6)
			return "SE"
		if(9)
			return "NW"
		if(10)
			return "SW"
		else
	return




//Turns a Body_parts_covered bitfield into a list of organ/limb names.
//(I challenge you to find a use for this)
/proc/body_parts_covered2organ_names(var/bpc)
	var/list/covered_parts = list()

	if(!bpc)
		return 0

	if(bpc & FULL_BODY)
		covered_parts |= list("l_arm","r_arm","head","chest","l_leg","r_leg")

	else
		if(bpc & HEAD)
			covered_parts |= list("head")
		if(bpc & CHEST)
			covered_parts |= list("chest")
		if(bpc & GROIN)
			covered_parts |= list("chest")

		if(bpc & ARMS)
			covered_parts |= list("l_arm","r_arm")
		else
			if(bpc & ARM_LEFT)
				covered_parts |= list("l_arm")
			if(bpc & ARM_RIGHT)
				covered_parts |= list("r_arm")

		if(bpc & HANDS)
			covered_parts |= list("l_arm","r_arm")
		else
			if(bpc & HAND_LEFT)
				covered_parts |= list("l_arm")
			if(bpc & HAND_RIGHT)
				covered_parts |= list("r_arm")

		if(bpc & LEGS)
			covered_parts |= list("l_leg","r_leg")
		else
			if(bpc & LEG_LEFT)
				covered_parts |= list("l_leg")
			if(bpc & LEG_RIGHT)
				covered_parts |= list("r_leg")

		if(bpc & FEET)
			covered_parts |= list("l_leg","r_leg")
		else
			if(bpc & FOOT_LEFT)
				covered_parts |= list("l_leg")
			if(bpc & FOOT_RIGHT)
				covered_parts |= list("r_leg")

	return covered_parts



//adapted from http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/
/proc/heat2colour(temp)
	return rgb(heat2colour_r(temp), heat2colour_g(temp), heat2colour_b(temp))


/proc/heat2colour_r(temp)
	temp /= 100
	if(temp <= 66)
		. = 255
	else
		. = max(0, min(255, 329.698727446 * (temp - 60) ** -0.1332047592))


/proc/heat2colour_g(temp)
	temp /= 100
	if(temp <= 66)
		. = max(0, min(255, 99.4708025861 * log(temp) - 161.1195681661))
	else
		. = max(0, min(255, 288.1221685293 * ((temp - 60) ** -0.075148492)))


/proc/heat2colour_b(temp)
	temp /= 100
	if(temp >= 66)
		. = 255
	else
		if(temp <= 16)
			. = 0
		else
			. = max(0, min(255, 138.5177312231 * log(temp - 10) - 305.0447927307))

/proc/color2hex(var/color)	//web colors
	if(!color)
		return "#000000"

	switch(color)
		if("white")
			return "#FFFFFF"
		if("black")
			return "#000000"
		if("gray")
			return "#808080"
		if("brown")
			return "#A52A2A"
		if("red")
			return "#FF0000"
		if("darkred")
			return "#8B0000"
		if("crimson")
			return "#DC143C"
		if("orange")
			return "#FFA500"
		if("yellow")
			return "#FFFF00"
		if("green")
			return "#008000"
		if("lime")
			return "#00FF00"
		if("darkgreen")
			return "#006400"
		if("cyan")
			return "#00FFFF"
		if("blue")
			return "#0000FF"
		if("navy")
			return "#000080"
		if("teal")
			return "#008080"
		if("purple")
			return "#800080"
		if("indigo")
			return "#4B0082"
		else
			return "#FFFFFF"