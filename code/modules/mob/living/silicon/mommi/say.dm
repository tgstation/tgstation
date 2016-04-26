/mob/living/silicon/robot/mommi/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, [text]";
	else if (ending == "!")
		return "declares, [text]";

	return "states, [text]";

/mob/living/silicon/robot/mommi/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	. = ..()
	if(.)
		return .
	if(src.keeper)
		speech.message = trim(speech.message)
		if (!speech.message)
			return

		var/turf/T = get_turf(src)
		var/msg = !T ? "Nullspace" : "[T.x],[T.y],[T.z]"
		log_say("[key_name(src)] (@[msg]) [damage_control_network]: [html_encode(speech.message)]")


		var/interior_message = say_quote("\"[html_encode(speech.message)]\"")
		var/rendered = "<i><span class='mommiradio'>[damage_control_network], <span class='name'>[name]</span> <span class='message'>[interior_message]</span></span></i>"

		for (var/mob/S in player_list)
			var/mob/living/silicon/robot/mommi/test = S
			// TODO: Add test.damage_control_network == damage_control_network to first test.
			if((istype(test) && test.keeper) || istype(S,/mob/dead/observer))
				handle_render(S,rendered,src)
		return 1
