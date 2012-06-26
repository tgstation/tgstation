/mob/living/carbon/human/whisper(message as text)
	//Figured it out.  If you use say :w (message) it HTML encodes it, THEN passes it to the whisper code, which does so again.  Jeez.  --SkyMarshal
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_whisper("[src.name]/[src.key] : [message]")

	if (src.client && (src.client.muted || src.client.muted_complete))
		src << "You are muted."
		return

	if(!speech_allowed && usr == src)
		usr << "\red You can't speak."
		return

	if (src.stat == 2)
		return src.say_dead(message)

	if (src.stat)
		return

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && src.name != src.real_name)
		var/mob/living/carbon/human/H = src
		alt_name = " (as [H.get_id_name("Unknown")])"
	// Mute disability
	if (src.disabilities & 64)
		return

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		return

	var/italics = 1
	var/message_range = 1

	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja)&&src.wear_mask:voice=="Unknown")
		if(copytext(message, 1, 2) != "*")
			var/list/temp_message = dd_text2list(message, " ")
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++)
				pick_list += i
			for(var/i=1, i <= abs(temp_message.len/3), i++)
				var/H = pick(pick_list)
				if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
				temp_message[H] = ninjaspeak(temp_message[H])
				pick_list -= H
			message = dd_list2text(temp_message, " ")
			message = dd_replaceText(message, "o", "¤")
			message = dd_replaceText(message, "p", "þ")
			message = dd_replaceText(message, "l", "£")
			message = dd_replaceText(message, "s", "§")
			message = dd_replaceText(message, "u", "µ")
			message = dd_replaceText(message, "b", "ß")

	message = capitalize(message)

	if (src.stuttering)
		message = NewStutter(message,stunned)
	if (src.slurring)
		message = slur(message)

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	var/list/listening = get_mobs_in_view(message_range, src)
//	listening -= src
//	listening += src
// WAT.
	var/list/eavesdropping = get_mobs_in_view(message_range, src)
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
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> whispers something.</span>"
		M.show_message(rendered, 2)

	if (length(heard_a))
		var/message_a = message

		if (italics)
			message_a = "<i>[message_a]</i>"
		//This appears copied from carbon/living say.dm so the istype check for mob is probably not needed. Appending for src is also not needed as the game will check that automatically.
		if (!istype(src, /mob/living/carbon/human))
			rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message_a]\"</span></span>"
		else if (istype(wear_mask, /obj/item/clothing/mask/gas/voice))
			if (wear_mask:vchange)
				rendered = "<span class='game say'><span class='name'>[wear_mask:voice]</span> whispers, <span class='message'>\"[message_a]\"</span></span>"
			else
				rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message_a]\"</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] whispers, <span class='message'>\"[message_a]\"</span></span>"

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

		rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> whispers, <span class='message'>\"[message_b]\"</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)

	for (var/mob/M in eavesdropping)
		if (M.say_understands(src))
			var/message_c
			message_c = stars(message)
			if (!istype(src, /mob/living/carbon/human))
				rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message_c]\"</span></span>"
			else if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
				if(wear_mask:vchange)
					rendered = "<span class='game say'><span class='name'>[wear_mask:voice]</span> whispers, <span class='message'>\"[message_c]\"</span></span>"
				else
					rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message_c]\"</span></span>"
			else
				rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] whispers, <span class='message'>\"[message_c]\"</span></span>"
			M.show_message(rendered, 2)
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> whispers something.</span>"
			M.show_message(rendered, 2)

	if (italics)
		message = "<i>[message]</i>"

	if (!istype(src, /mob/living/carbon/human))
		rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message]\"</span></span>"
	else if (istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		if(wear_mask:vchange)
			rendered = "<span class='game say'><span class='name'>[wear_mask:voice]</span> whispers, <span class='message'>\"[message]\"</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[name]</span> whispers, <span class='message'>\"[message]\"</span></span>"
	else
		rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] whispers, <span class='message'>\"[message]\"</span></span>"

	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat > 1 && !(M in heard_a) && M.client.ghost_ears)
			M.show_message(rendered, 2)
