/proc/emoji_parse(text)
	. = text
	if(!config.emojis)
		return
	var/static/list/emojis = icon_states(icon('hippiestation/icons/emoji.dmi'))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos+1)
			if(search)
				emoji = lowertext(copytext(text, pos+1, search))
				if(emoji in emojis)
<<<<<<< HEAD
					parsed += bicon(icon('hippiestation/icons/emoji.dmi', emoji))
=======
					parsed += icon2html('icons/emoji.dmi', world, emoji)
>>>>>>> f2cf4c2f5c... [ready]Makes bIcon better (#29690)
					pos = search + 1
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed

