//Lallander was here
/mob/living/carbon/human/whisper(message as text)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_whisper("[src.name]/[src.key] : [message]")

	if (src.muted)
		return

	if (src.stat == 2)
		return src.say_dead(message)

	if (src.stat)
		return

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && src.name != src.real_name)
		if (src.wear_id)
			var/obj/item/weapon/card/id/id = src:wear_id
			if(istype(src:wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = src:wear_id
				id = pda.id
			alt_name = " (as [id:registered])"
		else
			alt_name = " (as Unknown)"

	// Mute disability
	if (src.sdisabilities & 2)
		return

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
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
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> whispers something.</span>"
		M.show_message(rendered, 2)

	if (length(heard_a))
		var/message_a = message

		if (italics)
			message_a = "<i>[message_a]</i>"

		if (!istype(src, /mob/living/carbon/human) || istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
			rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers, <span class='message'>\"[message_a]\"</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] whispers, <span class='message'>\"[message_a]\"</span></span>"

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
			if (!istype(src, /mob/living/carbon/human) || istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
				rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers, <span class='message'>\"[message_c]\"</span></span>"
			else
				rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] whispers, <span class='message'>\"[message_c]\"</span></span>"
			M.show_message(rendered, 2)
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> whispers something.</span>"
			M.show_message(rendered, 2)

	if (italics)
		message = "<i>[message]</i>"

	if (!istype(src, /mob/living/carbon/human) || istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers, <span class='message'>\"[message]\"</span></span>"
	else
		rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] whispers, <span class='message'>\"[message]\"</span></span>"

	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat > 1 && !(M in heard_a))
			M.show_message(rendered, 2)
