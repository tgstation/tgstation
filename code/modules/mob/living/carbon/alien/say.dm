/mob/living/carbon/alien/say_understands(var/other)
	if (istype(other, /mob/living/carbon/alien))
		return 1
	return ..()

/mob/living/carbon/alien/say(var/message)

	if (length(message) >= 2)
		if (copytext(message, 1, 3) == ":a")
			message = copytext(message, 3)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			src.alien_talk(message)
		else
			return ..(message)
	else

// ~lol~
/mob/living/carbon/alien/say_quote(var/text)
//	var/ending = copytext(text, length(text))

	return "[src.say_message], \"[text]\"";

/mob/living/proc/alien_talk(var/message)

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/message_a = src.say_quote(message)
	var/rendered = "<i><span class='game say'>Hivemind, <span class='name'>[src.name]</span> <span class='message'>[message_a]</span></span></i>"
	for (var/mob/living/S in world)
		if(!S.stat)
			if(S.alien_talk_understand)
				if(S.alien_talk_understand == src.alien_talk_understand)
					S.show_message(rendered, 2)

	var/list/listening = hearers(1, src)
	listening -= src
	listening += src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!istype(M, /mob/living/carbon/alien) && !M.alien_talk_understand)
			heard += M


	if (length(heard))
		var/message_b

		message_b = "hsssss"
		message_b = src.say_quote(message_b)
		message_b = "<i>[message_b]</i>"

		rendered = "<i><span class='game say'><span class='name'>[src.voice_name]</span> <span class='message'>[message_b]</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, 2)

	message = src.say_quote(message)

	rendered = "<i><span class='game say'>Hivemind, <span class='name'>[src.name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat > 1)
			M.show_message(rendered, 2)