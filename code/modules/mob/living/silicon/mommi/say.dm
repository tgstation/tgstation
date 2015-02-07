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
		var/rendered = "<i><span class='mommi game say'>Damage Control, <span class='name'>[name]</span> <span class='message'>[interior_message]</span></span></i>"

		for (var/mob/living/silicon/robot/mommi/S in mob_list)
			if(S && istype(S) && S.keeper)
				S.show_message(rendered, 2)

		for (var/mob/M in dead_mob_list)
			if(!istype(M,/mob/new_player) && !istype(M,/mob/living/carbon/brain)) //No meta-evesdropping
				rendered = "<i><span class='mommi game say'>Damage Control, <span class='name'>[name]</span> <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[interior_message]</span></span></i>"
				M.show_message(rendered, 2)
		return 1
