// NOTE THAT HEARD AND UNHEARD USE GENDER_REPLACE SYNTAX SINCE BYOND IS STUPID
/mob/living/carbon/human/whisper(var/message as text, var/unheard=" whispers something", var/heard="whispers,", var/apply_filters=1, var/allow_lastwords=1)
	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	// N3X15'S AWFUL GENDER SHIT
	unheard=gender_replace(src.gender,unheard)
	heard=gender_replace(src.gender,heard)

	message = trim(copytext(strip_html_simple(message), 1, MAX_MESSAGE_LEN))

	if (!message || silent || miming)
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

	if (src.stat && said_last_words) // TIME TO WHISPER WHILE IN CRIT
		return

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && src.name != GetVoice())
		var/mob/living/carbon/human/H = src
		alt_name = " (as [H.get_id_name("Unknown")])"

	// Mute disability
	if (src.sdisabilities & MUTE)
		return

	if(M_WHISPER in src.mutations)
		src.say(message)

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		return

	var/italics = 1
	var/message_range = 1
	//var/orig_text=message
	if(apply_filters)
		if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja)&&src.wear_mask:voice=="Unknown")
			if(copytext(message, 1, 2) != "*")
				var/list/temp_message = text2list(message, " ")
				var/list/pick_list = list()
				for(var/i = 1, i <= temp_message.len, i++)
					pick_list += i
				for(var/i=1, i <= abs(temp_message.len/3), i++)
					var/H = pick(pick_list)
					if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
					temp_message[H] = ninjaspeak(temp_message[H])
					pick_list -= H
				message = dd_list2text(temp_message, " ")
				message = replacetext(message, "o", "�")
				message = replacetext(message, "p", "�")
				message = replacetext(message, "l", "�")
				message = replacetext(message, "s", "�")
				message = replacetext(message, "u", "�")
				message = replacetext(message, "b", "�")

		if (src.stuttering)
			message = stutter(message)

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	var/list/listening = hearers(message_range, src)
	listening |= src

	//Pass whispers on to anything inside the immediate listeners.
	for(var/mob/L in listening)
		for(var/mob/C in L.contents)
			if(istype(C,/mob/living))
				listening += C

	var/list/eavesdropping = hearers(2, src)
	eavesdropping -= src
	eavesdropping -= listening

	var/list/watching  = hearers(5, src)
	watching  -= src
	watching  -= listening
	watching  -= eavesdropping

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us
	var/and_passes_on=""

	if(!said_last_words && src.isInCrit())
		and_passes_on=" - and passes on"

		said_last_words=src.stat


	for (var/mob/M in listening)
		if (M.say_understands(src))
			heard_a += M
		else
			heard_b += M

	var/rendered = null

	for (var/mob/M in watching)
		if (!(M.client) || istype(M, /mob/new_player))
			continue
		if (M.say_understands(src))
			rendered = "<span class='game say'><span class='name'>[src.name]</span> [unheard][and_passes_on].</span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [unheard][and_passes_on].</span>"
		M.show_message(rendered, 2)

	if (length(heard_a))
		var/message_a = message

		if (italics)
			message_a = "<i>[message_a]</i>"
		//This appears copied from carbon/living say.dm so the istype check for mob is probably not needed. Appending for src is also not needed as the game will check that automatically.
		rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [heard] <span class='message'>\"[message_a]\"</span>[and_passes_on]</span>"

		for (var/mob/M in heard_a)
			if (!(M.client) || istype(M, /mob/new_player))
				continue
			M.show_message(rendered, 2)

	if (length(heard_b))
		var/message_b

		message_b = stars(message)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [heard] <span class='message'>\"[message_b]\"</span>[and_passes_on]</span>"

		for (var/mob/M in heard_b)
			if (!(M.client) || istype(M, /mob/new_player))
				continue
			M.show_message(rendered, 2)

	for (var/mob/M in eavesdropping)
		if (!(M.client) || istype(M, /mob/new_player))
			continue
		if (M.say_understands(src))
			var/message_c
			message_c = stars(message)
			rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [heard] <span class='message'>\"[message_c]\"</span>[and_passes_on]</span>"
			M.show_message(rendered, 2)
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> [unheard][and_passes_on].</span>"
			M.show_message(rendered, 2)

	if (italics)
		message = "<i>[message]</i>"
	rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] [heard] <span class='message'>\"[message]\"</span>[and_passes_on]</span>"

	for (var/mob/M in dead_mob_list)
		if (!(M.client) || istype(M, /mob/new_player))
			continue
		if (M.stat > 1 && !(M in heard_a) && (M.client.prefs.toggles & CHAT_GHOSTEARS))
			M.show_message(rendered, 2)

	if(said_last_words)
		// Kill 'em.
		src.stat = DEAD
		src.death(0)
		src.regenerate_icons()
