/proc/emoji_parse(text, mob/user)
	var/list/restricted_emojis = list("joctopusvernon", "joctopusbled", "joctopusagony", "joctopuspony", "joctopusupizda", "joctopusanimeebalo", "joctopusnoice", "joctopusgachi", "joctopusbee")
	var/list/bratki_emojis = list("alexs410", "joctopus", "drunktess")
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon('icons/emoji.dmi'))
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
					if(emoji in restricted_emojis)
						if(user.ckey in bratki_emojis)
							parsed += icon2html('icons/emoji.dmi', world, emoji)
							pos = search + 1
						else
							return 0
					else
						parsed += icon2html('icons/emoji.dmi', world, emoji)
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