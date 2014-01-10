/mob/living/carbon/human/whisper(message as text)

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


	if (src.stat == DEAD)
		return src.say_dead(message)

	var/alt_name = ""
	if (src.name != GetVoice())
		alt_name = " (as [get_id_name("Unknown")])"
	// Mute disability
	if (src.sdisabilities & MUTE)
		return

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		return

	var/whispers = "whispers"


	var/critical = InCritical()

	// We are unconscious but not in critical, so don't allow them to whisper.
	if(stat == UNCONSCIOUS && !critical)
		return

	// If whispering your last words, limit the whisper based on how close you are to death.
	if(critical)
		var/health_diff = round(-config.health_threshold_dead + health)
		// If we cut our message short, abruptly end it with a-..
		var/message_len = length(message)
		message = copytext(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
		message = Ellipsis(message, 10, 1)
		whispers = "whispers in their final breath"

	var/italics = 1
	var/message_range = 1

	if(src.wear_mask)
		message = wear_mask.speechModification(message)

	if (src.stuttering)
		message = stutter(message)

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	var/list/listening = hearers(message_range, src)
	listening -= src
	if(!critical)
		listening += src
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
			rendered = "<span class='game say'><span class='name'>[src.name]</span> [whispers] something.</span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [whispers] something.</span>"
		M.show_message(rendered, 2)

	if (length(heard_a))
		var/message_a = message

		if (italics)
			message_a = "<i>[message_a]</i>"
		//This appears copied from carbon/living say.dm so the istype check for mob is probably not needed. Appending for src is also not needed as the game will check that automatically.
		rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [whispers], <span class='message'>\"[message_a]\"</span></span>"

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

		rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [whispers], <span class='message'>\"[message_b]\"</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)

	for (var/mob/M in eavesdropping)
		if (M.say_understands(src))
			var/message_c
			message_c = stars(message)
			rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [whispers], <span class='message'>\"[message_c]\"</span></span>"
			M.show_message(rendered, 2)
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [whispers] something.</span>"
			M.show_message(rendered, 2)

	if (italics)
		message = "<i>[message]</i>"
	rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [whispers], <span class='message'>\"[message]\"</span></span>"

	for (var/mob/M in dead_mob_list)
		if (!(M.client))
			continue
		if (M.stat > 1 && !(M in heard_a))
			M.show_message(rendered, 2)

	// We whispered our final breath, now we die and show the message you have sent
	// since it might have been cut off and it would be annoying not being able to know.
	if(critical)
		src << rendered
		succumb(1)
