/*
 * Holds procs designed to change one type of value, into another.
 * Contains:
 *			splittext & jointext
 *			file2list
 *			angle2dir
 *			angle2text
 *			worldtime2text
 */

//slower then jointext, but correctly processes associative lists.
proc/tg_jointext(list/list, glue = ",")
	if(!istype(list) || !list.len)
		return
	for(var/i=1 to list.len)
		. += (i != 1 ? glue : null)+	\
		(!isnull(list["[list[i]]"]) ?	\
		"[list["[list[i]]"]]" :			\
		"[list[i]]")
	return .

// Yeah, so jointext doesn't do assoc values, tg_jointext only does assoc values if they're available, and NTSL needs to stay relatively simple.
/proc/vg_jointext(var/list/list, var/glue = ", ", var/assoc_glue = " = ")
	if(!islist(list) || !list.len)
		return // Valid lists you nerd.

	for(var/i = 1 to list.len)
		if(isnull(list[list[i]]))
			. += "[list[i]][glue]"
		else
			. += "[list[i]][assoc_glue][list[list[i]]][glue]"

	. = copytext(., 1, length(.) - length(glue) + 1) // Shush. (cut out the glue which is added to the end.)

// HTTP GET URL query builder thing.
// list("a"="b","c"="d") -> ?a=b&c=d
/proc/buildurlquery(list/list,sep="&")
	if(!istype(list) || !list.len)
		return
	var/output
	var/i=0
	var/start
	var/qmark="?" // God damnit byond
	for(var/key in list)
		start = i ? sep : qmark
		output += "[start][key]=[list[key]]"
		i++
	return output

/proc/n_splittext(text, delimiter = "\n")
	return splittext(text, delimiter)

//Case Sensitive!
/proc/splittextEx(text, delimiter="\n")
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
	return splittext(return_file_text(filename),seperator)


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
	degree = ((degree+22.5)%365)
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

//returns the east-zero counter-clockwise angle in degrees, given a direction

/proc/dir2angle_t(const/D)
	switch(D)
		if(EAST)		return 0
		if(NORTHEAST)	return 45
		if(NORTH)		return 90
		if(NORTHWEST)	return 135
		if(WEST)		return 180
		if(SOUTHWEST)	return 225
		if(SOUTH)		return 270
		if(SOUTHEAST)	return 315

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
/proc/rights2text(rights,seperator="")
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
	if(rights & R_MOD)			. += "[seperator]+MODERATOR"
	if(rights & R_ADMINBUS)		. += "[seperator]+ADMINBUS"
	return .

/proc/ui_style2icon(ui_style)
	switch(ui_style)
		if("old")		return 'icons/mob/screen1_old.dmi'
		if("Orange")	return 'icons/mob/screen1_Orange.dmi'
		else			return 'icons/mob/screen1_Midnight.dmi'

/proc/num2septext(var/theNum, var/sigFig = 7,var/sep=",") // default sigFig (1,000,000)
	var/finalNum = num2text(theNum, sigFig)

	// Start from the end, or from the decimal point
	var/end = findtextEx(finalNum, ".") || length(finalNum) + 1

	// Moving towards start of string, insert comma every 3 characters
	for(var/pos = end - 3, pos > 1, pos -= 3)
		finalNum = copytext(finalNum, 1, pos) + sep + copytext(finalNum, pos)

	return finalNum
