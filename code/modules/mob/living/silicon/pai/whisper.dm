//Lallander was here
//And so was Ktulu, moved from human/whisper.dm to here and hacked up to work for a pAI
/mob/living/silicon/pai/whisper(message as text)

	if(!IsVocal())
		return

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	message = trim(copytext(strip_html_simple(message), 1, MAX_MESSAGE_LEN))
	if (!message || silence_time)
		return

	log_whisper("[src.name]/[src.key] : [message]")

	if (src.client)
		if (src.client.prefs.muted & MUTE_IC)
			src << "\red You cannot whisper (muted)."
			return

		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return


	if (src.stat == 2)
		return src.say_dead(message)

	if (src.stat)
		return

	var/italics = 1
	var/message_range = 1


	if (src.stuttering)
		message = stutter(message)

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	var/list/listening = hearers(message_range, src)
	listening -= src
	listening += src
	if(src.card.held_by) //if we are held by  a mob then amke sure they can hear us as long as we are in their posession
		listening -= src.card.held_by
		listening += src.card.held_by
	var/list/eavesdropping = hearers(2, src)
	eavesdropping -= src
	eavesdropping -= listening
	var/list/watching  = hearers(5, src)
	watching  -= src
	watching  -= listening
	watching  -= eavesdropping

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/mob/M in listening)
		if (M.say_understands(src))
			heard_a += M
		else
			heard_b += M

	var/rendered = null

	for (var/mob/M in watching)
		if (M.say_understands(src))
			rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers something.</span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers something.</span>"
		M.show_message(rendered, 2)

	if (length(heard_a))
		var/message_a = message
		message_a = trim(message_a)
		if (italics)
			message_a = say_quote(message_a,1)
		else
			message_a = say_quote(message_a)
		//This appears copied from carbon/living say.dm so the istype check for mob is probably not needed. Appending for src is also not needed as the game will check that automatically.
		rendered = "<span class='game say'><span class='name'>[GetVoice()]</span> quietly <span class='message'>[message_a]</span></span>"

		for (var/mob/M in heard_a)
			M.show_message(rendered, 2)

	if (length(heard_b))
		var/message_b

		if (src.voice_message)
			message_b = src.voice_message
		else
			message_b = stars(message)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers <span class='message'>[message_b]</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)

	for (var/mob/M in eavesdropping)
		if (M.say_understands(src))
			var/message_c
			message_c = stars(message)
			rendered = "<span class='game say'><span class='name'>[GetVoice()]</span> whispers <span class='message'>[message_c]</span></span>"
			M.show_message(rendered, 2)
		else
			rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers something.</span>"
			M.show_message(rendered, 2)

	if (italics)
		message = trim(message)
		message = say_quote(message,1)
	else
		message = trim(message)
		message = say_quote(message)
	rendered = "<span class='game say'><span class='name'>[GetVoice()]</span> quietly <span class='message'>[message]</span></span>"

	for (var/mob/M in dead_mob_list)
		if (!(M.client))
			continue
		if (M.stat > 1 && !(M in heard_a))
			M.show_message(rendered, 2)
