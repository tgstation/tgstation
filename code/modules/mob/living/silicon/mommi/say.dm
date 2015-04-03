/mob/living/silicon/robot/mommi/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/robot/mommi/handle_inherent_channels(var/message, var/message_mode)
	. = ..()
	if(.)
		return .
	if(src.keeper)
		message = trim(message)
		if (!message)
			return

		log_say("[key_name(src)] (@[src.x],[src.y],[src.z])(MoMMItalk): [message]")

		var/interior_message = say_quote(message)
		var/rendered = text("<i><span class='mommi game say'>Damage Control, <span class='name'>[]</span> <span class='message'>[]</span></span></i>",name,interior_message)

		for (var/mob/S in player_list)
			var/mob/living/silicon/robot/mommi/test = S
			if((istype(test) && test.keeper) || istype(S,/mob/dead/observer))
				handle_render(S,rendered,src)
		return 1
