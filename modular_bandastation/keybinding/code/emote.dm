/datum/keybinding/emote/link_to_emote(datum/emote/faketype)
	. = ..()
	if(initial(faketype.name))
		full_name = capitalize(initial(faketype.name))
