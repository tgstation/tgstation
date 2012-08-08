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

//Returns an integer given a hex input
/proc/hex2num(hex)
	if (!( istext(hex) ))
		return

	var/num = 0
	var/power = 0
	var/i = null
	i = length(hex)
	while(i > 0)
		var/char = copytext(hex, i, i + 1)
		switch(char)
			if("0")
				//Apparently, switch works with empty statements, yay! If that doesn't work, blame me, though. -- Urist
			if("9", "8", "7", "6", "5", "4", "3", "2", "1")
				num += text2num(char) * 16 ** power
			if("a", "A")
				num += 16 ** power * 10
			if("b", "B")
				num += 16 ** power * 11
			if("c", "C")
				num += 16 ** power * 12
			if("d", "D")
				num += 16 ** power * 13
			if("e", "E")
				num += 16 ** power * 14
			if("f", "F")
				num += 16 ** power * 15
			else
				return
		power++
		i--
	return num

//Returns the hex value of a number given a value assumed to be a base-ten value
/proc/num2hex(num, placeholder)

	if (placeholder == null)
		placeholder = 2
	if (!( isnum(num) ))
		return
	if (!( num ))
		return "0"
	var/hex = ""
	var/i = 0
	while(16 ** i < num)
		i++
	var/power = null
	power = i - 1
	while(power >= 0)
		var/val = round(num / 16 ** power)
		num -= val * 16 ** power
		switch(val)
			if(9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0)
				hex += text("[]", val)
			if(10.0)
				hex += "A"
			if(11.0)
				hex += "B"
			if(12.0)
				hex += "C"
			if(13.0)
				hex += "D"
			if(14.0)
				hex += "E"
			if(15.0)
				hex += "F"
			else
		power--
	while(length(hex) < placeholder)
		hex = text("0[]", hex)
	return hex

//Text 'text' will be added as elements of a list when seperated by 'seperator'
/proc/dd_text2list(text, separator, var/list/withinList)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	if(withinList && !withinList.len) withinList = null
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	var/loops = 999
	while(loops) //Byond will think 1000+ iterations of a loop is an infinite loop
		findPosition = findtext(text, separator, searchPosition, 0)
		var/buggyText = copytext(text, searchPosition, findPosition)
		if(!withinList || (buggyText in withinList)) textList += "[buggyText]"
		if(!findPosition) return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			textList += ""
			return textList
		loops--
	return

//Text 'text' will be added as elements of a list when seperated by 'seperator'. The separator is case sensitive.
/proc/dd_text2list_case(text, separator, var/list/withinList)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	if(withinList && !withinList.len) withinList = null
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	var/loops = 999
	while(loops) //Byond will think 1000+ iterations of a loop is an infinite loop
		findPosition = findtextEx(text, separator, searchPosition, 0)
		var/buggyText = copytext(text, searchPosition, findPosition)
		if(!withinList || (buggyText in withinList)) textList += "[buggyText]"
		if(!findPosition) return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			textList += ""
			return textList
		loops--
	return

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

//tg_text2list is faster then dd_text2list
//not case sensitive version
proc/tg_text2list(string, separator=",")
	if(!string)
		return
	var/list/output = new
	var/seplength = length(separator)
	var/strlength = length(string)
	var/prev = 1
	var/index
	do
		index = findtext(string, separator, prev, 0)
		output += copytext(string, prev, index)
		if(!index)
			break
		prev = index+seplength
		if(prev>strlength)
			break
	while(index)
	return output

//case sensitive version
proc/tg_text2list_case(string, separator=",")
	if(!string)
		return
	var/list/output = new
	var/seplength = length(separator)
	var/strlength = length(string)
	var/prev = 1
	var/index
	do
		index = findtextEx(string, separator, prev, 0)
		output += copytext(string, prev, index)
		if(!index)
			break
		prev = index+seplength
		if(prev>strlength)
			break
	while(index)
	return output

//slower then dd_list2text, but correctly processes associative lists.
proc/tg_list2text(list/list, glue=",")
	if(!istype(list) || !list.len)
		return
	var/output
	for(var/i=1 to list.len)
		output += (i!=1? glue : null)+(!isnull(list["[list[i]]"])?"[list["[list[i]]"]]":"[list[i]]")
	return output

//Gets a file and adds its contents to a list.
/proc/dd_file2list(file_path, separator)
	var/file
	if(separator == null)
		separator = "\n"
	if(isfile(file_path))
		file = file_path
	else
		file = file(file_path)
	return dd_text2list(file2text(file), separator)

//Converts an angle (degrees) into an ss13 direction
/proc/angle2dir(var/degree)
	degree = ((degree+22.5)%365)
	if(degree < 45)		return NORTH
	if(degree < 90)		return NORTH|EAST
	if(degree < 135)	return EAST
	if(degree < 180)	return SOUTH|EAST
	if(degree < 225)	return SOUTH
	if(degree < 270)	return SOUTH|WEST
	if(degree < 315)	return WEST
	return NORTH|WEST

//Returns the angle in english
/proc/angle2text(var/degree)
	return dir2text(angle2dir(degree))

//Returns the world time in english
proc/worldtime2text()
	return "[round(world.time / 36000)+12]:[(world.time / 600 % 60) < 10 ? add_zero(world.time / 600 % 60, 1) : world.time / 600 % 60]"