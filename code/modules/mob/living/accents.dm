var/list/vowels_lower = list("a","e","i","o","u")
var/list/vowels_upper = list("A","E","I","O","U")
var/list/consonants_lower = list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")
var/list/consonants_upper = list("B","C","D","F","G","H","J","K","L","M","N","P","Q","R","S","T","V","W","X","Y","Z")

/datum/parse_result
	var/string = ""
	var/chars_used = 0

/datum/text_roamer
	var/string = ""
	var/curr_char_pos = 0
	var/curr_char = ""
	var/prev_char = ""
	var/next_char = ""
	var/next_next_char = ""
	var/next_next_next_char = ""

/datum/text_roamer/New(var/str)
	if(isnull(str))
		qdel(src)
	string = str
	curr_char_pos = 1
	curr_char = copytext(string,curr_char_pos,curr_char_pos+1)
	if(length(string) > 1)
		next_char = copytext(string,curr_char_pos+1,curr_char_pos+2)
	if(length(string) > 2)
		next_next_char = copytext(string,curr_char_pos+2,curr_char_pos+3)
	if(length(string) > 3)
		next_next_next_char = copytext(string,curr_char_pos+3,curr_char_pos+4)

/datum/text_roamer/proc/in_word()
	if(prev_char != "" && prev_char != " " && next_char != "" && next_char != " ")
		return 1
	else
		return 0

/datum/text_roamer/proc/end_of_word()
	if(prev_char != "" && prev_char != " " && (next_char == "" || next_char == " ") )
		return 1
	else
		return 0

/datum/text_roamer/proc/alone()
	if((prev_char == "" || prev_char == " ") && (next_char == "" || next_char == " ") )
		return 1
	else
		return 0

/datum/text_roamer/proc/update()
	curr_char = copytext(string,curr_char_pos,curr_char_pos+1)

	if(curr_char_pos + 1 <= length(string))
		next_char = copytext(string,curr_char_pos+1,curr_char_pos+2)
	else
		next_char = ""

	if(curr_char_pos + 2 <= length(string))
		next_next_char = copytext(string,curr_char_pos+2,curr_char_pos+3)
	else
		next_next_char = ""

	if(curr_char_pos + 3 <= length(string))
		next_next_next_char = copytext(string,curr_char_pos+3,curr_char_pos+4)
	else
		next_next_next_char = ""

	if(curr_char_pos - 1  >= 1)
		prev_char = copytext(string,curr_char_pos-1,curr_char_pos)
	else
		prev_char = ""

	return

/datum/text_roamer/proc/next()
	if(curr_char_pos + 1 <= length(string))
		curr_char_pos++

	curr_char = copytext(string,curr_char_pos,curr_char_pos+1)

	if(curr_char_pos + 1 <= length(string))
		next_char = copytext(string,curr_char_pos+1,curr_char_pos+2)
	else
		next_char = ""

	if(curr_char_pos + 2 <= length(string))
		next_next_char = copytext(string,curr_char_pos+2,curr_char_pos+3)
	else
		next_next_char = ""

	if(curr_char_pos + 3 <= length(string))
		next_next_next_char = copytext(string,curr_char_pos+3,curr_char_pos+4)
	else
		next_next_next_char = ""

	if(curr_char_pos - 1  >= 1)
		prev_char = copytext(string,curr_char_pos-1,curr_char_pos)
	else
		prev_char = ""

	return

/datum/text_roamer/proc/prev()

	if(curr_char_pos - 1 >= 1)
		curr_char_pos--

	curr_char = copytext(string,curr_char_pos,curr_char_pos+1)

	if(curr_char_pos + 1 <= length(string))
		next_char = copytext(string,curr_char_pos+1,curr_char_pos+2)
	else
		next_char = ""

	if(curr_char_pos + 2 <= length(string))
		next_next_char = copytext(string,curr_char_pos+2,curr_char_pos+3)
	else
		next_next_char = ""

	if(curr_char_pos + 3 <= length(string))
		next_next_next_char = copytext(string,curr_char_pos+3,curr_char_pos+4)
	else
		next_next_next_char = ""

	if(curr_char_pos - 1  >= 1)
		prev_char = copytext(string,curr_char_pos-1,curr_char_pos)
	else
		prev_char = ""

	return


/proc/say_drunk(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i++)
		switch(T.curr_char)
			if("k")
				if(lowertext(T.prev_char) == "n" || lowertext(T.prev_char) == "c")
					modded += "gh"
				else
					modded += "g"
			if("K")
				if(lowertext(T.prev_char) == "N" || lowertext(T.prev_char) == "C")
					modded += "GH"
				else
					modded += "G"

			if("s")
				modded += "sh"
			if("S")
				modded += "SH"

			if("t")
				if(lowertext(T.next_char) == "h")
					modded += "du"
					T.curr_char_pos++
				else if(lowertext(T.prev_char) == "n")
					modded += "thf"
				else
					modded += "ff"
			if("T")
				if(lowertext(T.next_char) == "H")
					modded += "DU"
					T.curr_char_pos++
				else if(lowertext(T.prev_char) == "N")
					modded += "THF"
				else
					modded += "FF"
			else
				modded += T.curr_char
		T.curr_char_pos++
		T.update()

	return modded

// totally garbled drunk slurring

/proc/say_superdrunk(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i++)
		switch(T.curr_char)
			if("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")
				modded += pick(consonants_lower)
			if("B","C","D","F","G","H","J","K","L","M","N","P","Q","R","S","T","V","W","X","Y","Z")
				modded += pick(consonants_upper)
			else
				modded += T.curr_char
		T.curr_char_pos++
		T.update()

	return modded