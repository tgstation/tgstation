/mob/living/proc/binarycheck()
	if (istype(src, /mob/living/silicon)) return 1
	if (!istype(src, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/proc/hivecheck()
	if (istype(src, /mob/living/carbon/alien)) return 1
	if (!istype(src, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_hive) return 1

/mob/living/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	if (length(message) >= 1)
		if (src.miming && copytext(message, 1, 2) != "*")
			return

	if (src.stat == 2)
		return src.say_dead(message)

	if (src.muted || src.silent)
		return

	// wtf?
	if (src.stat)
		return

	// Mute disability
	if (src.sdisabilities & 2)
		return

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		return

	// emotes
	if (copytext(message, 1, 2) == "*" && !src.stat)
		return src.emote(copytext(message, 2))

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && src.name != src.real_name)
		var/mob/living/carbon/human/H = src
		alt_name = " (as [H.get_visible_name()])"
	var/italics = 0
	var/message_range = null
	var/message_mode = null

	if (src.brainloss >= 60 && prob(50))
		if (ishuman(src))
			message_mode = "headset"
	// Special message handling
	else if (copytext(message, 1, 2) == ";")
		if (ishuman(src))
			message_mode = "headset"
		message = copytext(message, 2)

	else if (length(message) >= 2)
		var/channel_prefix = copytext(message, 1, 3)

		var/list/keys = list(
			  ":r" = "right hand",
			  ":l" = "left hand",
			  ":i" = "intercom",
			  ":h" = "department",
			  ":c" = "Command",
			  ":n" = "Science",
			  ":m" = "Medical",
			  ":e" = "Engineering",
			  ":s" = "Security",
			  ":w" = "whisper",
			  ":b" = "binary",
			  ":a" = "alientalk",
			  ":t" = "Syndicate",
			  ":d" = "Mining",
			  ":q" = "Cargo",

			  //kinda localization -- rastaf0
			  //same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
			  ":ê" = "right hand",
			  ":ä" = "left hand",
			  ":ø" = "intercom",
			  ":ð" = "department",
			  ":ñ" = "Command",
			  ":ò" = "Science",
			  ":ü" = "Medical",
			  ":ó" = "Engineering",
			  ":û" = "Security",
			  ":ö" = "whisper",
			  ":è" = "binary",
			  ":ô" = "alientalk",
			  ":å" = "Syndicate",
			  ":â" = "Mining",
			  ":é" = "Cargo",
		)

		message_mode = keys[channel_prefix]
		//world << "channel_prefix=[channel_prefix]; message_mode=[message_mode]"
		if (message_mode)
			message = trim(copytext(message, 3))
			if (!ishuman(src) && (message_mode=="department" || (message_mode in radiochannels)))
				message_mode = null //only humans can use headsets

	if (!message)
		return

	// :downs:
	if (src.brainloss >= 60)
		message = dd_replacetext(message, " am ", " ")
		message = dd_replacetext(message, " is ", " ")
		message = dd_replacetext(message, " are ", " ")
		message = dd_replacetext(message, "you", "u")
		message = dd_replacetext(message, "help", "halp")
		message = dd_replacetext(message, "grief", "grife")
		message = dd_replacetext(message, "space", "spess")
		message = dd_replacetext(message, "carp", "crap")
		if(prob(50))
			message = uppertext(message)
			message += "[stutter(pick("!", "!!", "!!!"))]"
		if(!src.stuttering && prob(15))
			message = stutter(message)

	if (src.stuttering)
		message = stutter(message)

/* //qw do not have beesease atm.
	if(src.virus)
		if(src.virus.name=="beesease" && src.virus.stage>=2)
			if(prob(src.virus.stage*10))
				var/bzz = length(message)
				message = "B"
				for(var/i=0,i<bzz,i++)
					message += "Z"
*/

	switch (message_mode)
		if ("headset")
			if (src:ears)
				src:ears.talk_into(src, message)

			message_range = 1
			italics = 1

		if ("secure headset")
			if (src:ears)
				src:ears.talk_into(src, message, 1)

			message_range = 1
			italics = 1

		if ("right hand")
			if (src.r_hand)
				src.r_hand.talk_into(src, message)

			message_range = 1
			italics = 1

		if ("left hand")
			if (src.l_hand)
				src.l_hand.talk_into(src, message)

			message_range = 1
			italics = 1

		if ("intercom")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message)

			message_range = 1
			italics = 1

		//I see no reason to restrict such way of whispering
		if ("whisper")
			src.whisper(message)
			return

		if ("binary")
			if(src.robot_talk_understand || src.binarycheck())
			//message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)) //seems redundant
				src.robot_talk(message)
			return

		if ("alientalk")
			if(src.alien_talk_understand || src.hivecheck())
			//message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)) //seems redundant
				src.alien_talk(message)
			return

		if ("department")
			if (src:ears)
				src:ears.talk_into(src, message, message_mode)
			message_range = 1
			italics = 1
/////SPECIAL HEADSETS START
		else
			//world << "SPECIAL HEADSETS"
			if (message_mode in radiochannels)
				if (src:ears)
					src:ears.talk_into(src, message, message_mode)
				message_range = 1
				italics = 1
/////SPECIAL HEADSETS END

	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	var/list/listening
	if(istype(src.loc, /obj/item/device/aicard)) // -- TLE
		var/obj/O = src.loc
		if(istype(O.loc, /mob))
			var/mob/M = O.loc
			listening = hearers(message_range, M)
		else
			listening = hearers(message_range, O)
	else
		listening = hearers(message_range, src)

	listening -= src
	listening += src

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/mob/M in listening)
		if (M.say_understands(src))
			heard_a += M
		else
			heard_b += M

	var/rendered = null
	if (length(heard_a))
		var/message_a = src.say_quote(message)

		if (italics)
			message_a = "<i>[message_a]</i>"

		if (!istype(src, /mob/living/carbon/human) || istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
			rendered = "<span class='game say'><span class='name'>[src.name]</span> <span class='message'>[message_a]</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] <span class='message'>[message_a]</span></span>"

		for (var/mob/M in heard_a)
			M.show_message(rendered, 2)

			for(var/obj/O in M) // This is terribly costly for such a unique circumstance, should probably do this a different way in the future -- TLE
				if(istype(O, /obj/item/device/aicard))
					for(var/mob/M2 in O)
						M2.show_message(rendered, 2)
						break
					break

	if (length(heard_b))
		var/message_b

		if (src.voice_message)
			message_b = src.voice_message
		else
			message_b = stars(message)
			message_b = src.say_quote(message_b)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> <span class='message'>[message_b]</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)

	message = src.say_quote(message)
	if (italics)
		message = "<i>[message]</i>"

	if (!istype(src, /mob/living/carbon/human) || istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		rendered = "<span class='game say'><span class='name'>[src.name]</span> <span class='message'>[message]</span></span>"
	else
		rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] <span class='message'>[message]</span></span>"

	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat >= 2 && !(M in heard_a))
			M.show_message(rendered, 2)

	log_say("[src.name]/[src.key] : [message]")