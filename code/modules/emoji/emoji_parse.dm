var/list/emoji_text

/proc/emoji_parse(text)
	if(!emoji_text)
		emoji_text = icon_states(icon('icons/emoji.dmi'))
	var/list/allowed_characters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9")
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
					parsed += "<img class=icon src=\ref['icons/emoji.dmi'] iconstate='[emoji]'>"
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

