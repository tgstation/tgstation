/mob/living/silicon/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/say(var/message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat == 2)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return say_dead(message)

	//Must be concious to speak
	if (stat)
		return

	if (length(message) >= 2)
		var/prefix = copytext(message, 1, 3)
		if (department_radio_keys[prefix] == "binary")
			if(istype(src, /mob/living/silicon/pai) || istype(src, /mob/living/carbon/brain))
				return ..(message)
			message = copytext(message, 3)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			if(istype(src, /mob/living/silicon/robot/mommi))
				src << "Your binary communication device is set to receive only."
				return

			// TODO: move the component system up to silicon so we don't have to use this ugly hack..
			if(istype(src, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/R = src
				if(!R.is_component_functioning("comms"))
					src << "\red Your binary communications component isn't functional."
					return

			robot_talk(message)
		else if (department_radio_keys[prefix] == "department")
			if(isAI(src)&&client)//For patching directly into AI holopads.
				var/mob/living/silicon/ai/U = src
				message = copytext(message, 3)
				message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
				U.holopad_talk(message)
			else//Will not allow anyone by an active AI to use this function.
				src << "This function is not available to you."
				return
		else
			if(isMoMMI(src)&&client)//For patching directly into AI holopads.
				// Beep boop. Emotes are acceptable.
				if (copytext(message, 1, 2) == "*" && !stat)
					return ..(message)
				var/mob/living/silicon/robot/mommi/U = src
				if(U.keeper)
					U.mommi_talk(message)
					return
			return ..(message)
	else
		// Fix MoMMIs speaking one letter at a time.
		if(isMoMMI(src)&&client)
			var/mob/living/silicon/robot/mommi/U = src
			if(U.keeper)
				U.mommi_talk(message)
				return
		return ..(message)

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(var/message)

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/obj/machinery/hologram/holopad/T = src.current
	if(istype(T) && T.hologram && T.master == src)//If there is a hologram and its master is the user.
		var/message_a = say_quote(message)

		//Human-like, sorta, heard by those who understand humans.
		var/rendered_a = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span>"

		//Speach distorted, heard by those who do not understand AIs.
		message = stars(message)
		var/message_b = say_quote(message)
		var/rendered_b = "<span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span>"

		src << "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> <span class='message'>[message_a]</span></span></i>"//The AI can "hear" its own message.
		for(var/mob/M in hearers(T.loc))//The location is the object, default distance.
			if(M.say_understands(src))//If they understand AI speak. Humans and the like will be able to.
				M.show_message(rendered_a, 2)
			else//If they do not.
				M.show_message(rendered_b, 2)
		/*Radios "filter out" this conversation channel so we don't need to account for them.
		This is another way of saying that we won't bother dealing with them.*/
	else
		src << "No holopad connected."
	return

/mob/living/proc/robot_talk(var/message)

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/message_a = say_quote(message)
	var/rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/mob/living/S in living_mob_list)
		if(S.robot_talk_understand && (S.robot_talk_understand == robot_talk_understand)) // This SHOULD catch everything caught by the one below, but I'm not going to change it.
			if(istype(S , /mob/living/silicon/ai) && !isMoMMI(src))
				var/renderedAI = "<i><span class='game say'>Robotic Talk, <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src]'><span class='name'>[name]</span></a> <span class='message'>[message_a]</span></span></i>"
				S.show_message(renderedAI, 2)
			else if(istype(S , /mob/dead/observer) && S.stat == DEAD)
				var/rendered2 = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <a href='byond://?src=\ref[S];follow2=\ref[S];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span></i>"
				S.show_message(rendered2, 2)
			else
				S.show_message(rendered, 2)


		else if (S.binarycheck())
			if(istype(S , /mob/living/silicon/ai))
				var/renderedAI = "<i><span class='game say'>Robotic Talk, <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src]'><span class='name'>[name]</span></a> <span class='message'>[message_a]</span></span></i>"
				S.show_message(renderedAI, 2)
			else if(istype(S , /mob/dead/observer) && S.stat == DEAD)
				var/rendered2 = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <a href='byond://?src=\ref[S];follow2=\ref[S];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span></i>"
				S.show_message(rendered2, 2)
			else
				S.show_message(rendered, 2)

	var/list/listening = hearers(1, src)
	listening -= src
	listening += src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!istype(M, /mob/living/silicon) && !M.robot_talk_understand)
			heard += M

	if (length(heard))
		var/message_b

		message_b = "beep beep beep"
		message_b = say_quote(message_b)
		message_b = "<i>[message_b]</i>"

		rendered = "<i><span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, 2)

	message = say_quote(message)

	rendered = null

	for (var/mob/M in dead_mob_list)
		if(!istype(M,/mob/new_player) && !istype(M,/mob/living/carbon/brain) && isobserver(M)) //No meta-evesdropping
			rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span></i>"
			M.show_message(rendered, 2)