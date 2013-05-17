//Lallander was here
//moved to /mob/living from /mob/living/carbon/human
/mob/living/whisper(message as text, isquote = 0 as num) //set isquote to 1 for things that whisper in quotes like /mob/living/silicon/*

	if(!src.can_whisper)
		usr << "\red This mob cannot whisper! Try something else!"
		return
	if(!IsVocal())
		return

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	message = trim(copytext(strip_html_simple(message), 1, MAX_MESSAGE_LEN))

	if (!message || silent)
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

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && src.name != GetVoice())
		var/mob/living/carbon/human/H = src
		alt_name = " (as [H.get_id_name("Unknown")])"
	// Mute disability
	if (src.sdisabilities & MUTE)
		return

	//removed italic var as its kinda pointless, it will only change if whisper is overriden or the base code was changed.
	var/message_range = 1
	var/w_text = ""

	//moved mask code to /mob/living/carbon/whisper.dm

	if (src.stuttering)
		message = stutter(message)

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	var/mob/held_by = src.get_holder()
	var/list/listening = hearers(message_range, src)
	listening -= src
	listening += src
	if(held_by)
		listening -= held_by
		listening += held_by
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

	if(isquote)
		w_text = "quietly"
	else
		if(!src.voice_message)
			w_text = "whispers,"
		else
			w_text = "quietly [src.voice_message],"

	for (var/mob/M in watching)
		if (M.say_understands(src))
			rendered = "<span class='game say'><span class='name'>[src.name]</span> [w_text] something.</span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [w_text] something.</span>"
		M.show_message(rendered, 2)

	if (length(heard_a))
		var/message_a = message
		if(isquote)
			message_a = src.say_quote("<i>[message]</i>")
		else
			message_a = "\"<i>[message]</i>\""
		//This appears copied from carbon/living say.dm so the istype check for mob is probably not needed. Appending for src is also not needed as the game will check that automatically.
		rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [w_text] <span class='message'>[message_a]</span></span>"

		for (var/mob/M in heard_a)
			M.show_message(rendered, 2)

	if (length(heard_b))
		var/message_b

		if (src.voice_message)
			message_b = src.voice_message
		else
			message_b = stars(message)

		message_b = "\"<i>[message_b]</i>\""

		rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [w_text] <span class='message'>[message_b]</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)

	for (var/mob/M in eavesdropping)
		if (M.say_understands(src))
			var/message_c
			message_c = "\"<i>[stars(message)]<\i>\""
			rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [w_text] <span class='message'>[message_c]</span></span>"
			M.show_message(rendered, 2)
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [w_text] something.</span>"
			M.show_message(rendered, 2)

	if(isquote)
		message = src.say_quote("<i>[message]</i>")
	else
		message = "\"<i>[message]</i>\""
	rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [w_text] <span class='message'>[message]</span></span>"

	for (var/mob/M in dead_mob_list)
		if (!(M.client))
			continue
		if (M.stat > 1 && !(M in heard_a))
			M.show_message(rendered, 2)