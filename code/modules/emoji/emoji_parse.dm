var/list/emoji_text

/proc/emoji_parse(text)
	if(!emoji_text)
		emoji_text = file2list("code/modules/emoji/emoji_names.txt")
	var/list/allowed_characters = list("_","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","q","r","s","t","u","v","w","x","y","z")
	var/textlen = 0
	var/parsed = ""
	var/pos = 1
	var/char = ""
	var/emoji = ""
	textlen = length(text)
	while(pos <= textlen)
		char = copytext(text, pos, pos+1)
		if(emoji)
			if(lowertext(char) in allowed_characters)
				emoji += char
			else if(char == ":" && emoji != ":")
				emoji = lowertext(copytext(emoji, 2))
				if(emoji in emoji_text)
					parsed += "<img class=icon src=\ref['icons/FOSS_emoji.dmi'] iconstate='[emoji]'>"
				else
					parsed += ":" + emoji + char
				emoji = ""
			else
				parsed += (emoji + char)
				emoji = ""
		else if(char == ":")
			emoji += ":"
		else
			parsed += char
		pos++
	if(emoji)
		parsed += emoji
	return parsed

