
var/list/department_radio_keys = list(
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
	  ":g" = "changeling",

	  ":R" = "right hand",
	  ":L" = "left hand",
	  ":I" = "intercom",
	  ":H" = "department",
	  ":C" = "Command",
	  ":N" = "Science",
	  ":M" = "Medical",
	  ":E" = "Engineering",
	  ":S" = "Security",
	  ":W" = "whisper",
	  ":B" = "binary",
	  ":A" = "alientalk",
	  ":T" = "Syndicate",
	  ":D" = "Mining",
	  ":Q" = "Cargo",
	  ":G" = "changeling",

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
	  ":ï" = "changeling"
)

/mob/living/proc/binarycheck()
	if (istype(src, /mob/living/silicon/pai))
		return
	if (issilicon(src))
		return 1
	if (!ishuman(src))
		return
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/proc/hivecheck()
	if (isalien(src)) return 1
	if (!ishuman(src)) return
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_hive) return 1

/mob/living/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	if (stat == 2)
		return say_dead(message)

	if (src.client)
		if(client.muted_ic)
			src << "\red You cannot speak in IC (muted by admins)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	// stat == 2 is handled above, so this stops transmission of uncontious messages
	if (stat)
		return

	// Mute disability
	if (sdisabilities & MUTE)
		return

	if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return

	// emotes
	if (copytext(message, 1, 2) == "*" && !stat)
		return emote(copytext(message, 2))

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && name != real_name)
		var/mob/living/carbon/human/H = src
		alt_name = " (as [H.get_id_name("Unknown")])"
	var/italics = 0
	var/message_range = null
	var/message_mode = null

	if (getBrainLoss() >= 60 && prob(50))
		if (ishuman(src))
			message_mode = "headset"
	// Special message handling
	else if (copytext(message, 1, 2) == ";")
		if (ishuman(src))
			message_mode = "headset"
		else if(ispAI(src) || isrobot(src))
			message_mode = "pAI"
		message = copytext(message, 2)

	else if (length(message) >= 2)
		var/channel_prefix = copytext(message, 1, 3)

		message_mode = department_radio_keys[channel_prefix]
		//world << "channel_prefix=[channel_prefix]; message_mode=[message_mode]"
		if (message_mode)
			message = trim(copytext(message, 3))
			if (!(ishuman(src) || isanimal(src) || isrobot(src) && (message_mode=="department" || (message_mode in radiochannels))))
				message_mode = null //only humans can use headsets
			// Check removed so parrots can use headsets!
			// And borgs -Sieve

	if (!message)
		return

	// :downs:
	if (getBrainLoss() >= 60)
		message = dd_replacetext(message, " am ", " ")
		message = dd_replacetext(message, " is ", " ")
		message = dd_replacetext(message, " are ", " ")
		message = dd_replacetext(message, "you", "u")
		message = dd_replacetext(message, "help", "halp")
		message = dd_replacetext(message, "grief", "grife")
		message = dd_replacetext(message, "space", "spess")
		message = dd_replacetext(message, "carp", "crap")
		message = dd_replacetext(message, "reason", "raisin")
		if(prob(50))
			message = uppertext(message)
			message += "[stutter(pick("!", "!!", "!!!"))]"
		if(!stuttering && prob(15))
			message = stutter(message)

	if (stuttering)
		message = stutter(message)

/* //qw do not have beesease atm.
	if(virus)
		if(virus.name=="beesease" && virus.stage>=2)
			if(prob(virus.stage*10))
				var/bzz = length(message)
				message = "B"
				for(var/i=0,i<bzz,i++)
					message += "Z"
*/
	var/list/obj/item/used_radios = new

	switch (message_mode)
		if ("headset")
			if (src:ears)
				src:ears.talk_into(src, message)
				used_radios += src:ears

			message_range = 1
			italics = 1


		if ("secure headset")
			if (src:ears)
				src:ears.talk_into(src, message, 1)
				used_radios += src:ears

			message_range = 1
			italics = 1

		if ("right hand")
			if (r_hand)
				r_hand.talk_into(src, message)
				used_radios += src:r_hand

			message_range = 1
			italics = 1

		if ("left hand")
			if (l_hand)
				l_hand.talk_into(src, message)
				used_radios += src:l_hand

			message_range = 1
			italics = 1

		if ("intercom")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message)
				used_radios += I

			message_range = 1
			italics = 1

		//I see no reason to restrict such way of whispering
		if ("whisper")
			whisper(message)
			return

		if ("binary")
			if(robot_talk_understand || binarycheck())
			//message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)) //seems redundant
				robot_talk(message)
			return

		if ("alientalk")
			if(alien_talk_understand || hivecheck())
			//message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)) //seems redundant
				alien_talk(message)
			return

		if ("department")
			if (src:ears)
				src:ears.talk_into(src, message, message_mode)
				used_radios += src:ears
			message_range = 1
			italics = 1

		if ("pAI")
			if (src:radio)
				src:radio.talk_into(src, message)
				used_radios += src:radio
			message_range = 1
			italics = 1

		if("changeling")
			if(mind && mind.changeling)
				for(var/mob/Changeling in mob_list)
					if((Changeling.mind && Changeling.mind.changeling) || istype(Changeling, /mob/dead/observer))
						Changeling << "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
				return
////SPECIAL HEADSETS START
		else
			//world << "SPECIAL HEADSETS"
			if (message_mode in radiochannels)
				if(isrobot(src))//Seperates robots to prevent runtimes from the ear stuff
					var/mob/living/silicon/robot/R = src
					if(R.radio)//Sanityyyy
						R.radio.talk_into(src, message, message_mode)
						used_radios += R.radio
				else
					if (src:ears)
						src:ears.talk_into(src, message, message_mode)
						used_radios += src:ears
				message_range = 1
				italics = 1
/////SPECIAL HEADSETS END

	var/list/listening

	listening = get_mobs_in_view(message_range, src)
	for(var/mob/M in player_list)
		if (!M.client)
			continue //skip monkeys and leavers
		if (istype(M, /mob/new_player))
			continue
		if(M.stat == 2 && M.client.ghost_ears)
			listening|=M

	var/turf/T = get_turf(src)
	var/list/V = view(message_range, T)
	var/list/W = V

	for (var/obj/O in ((W | contents)-used_radios))
		W |= O

	for (var/mob/M in W)
		W |= M.contents

	for (var/obj/O in W) //radio in pocket could work, radio in backpack wouldn't --rastaf0
		spawn (0)
			if(O && !istype(O.loc, /obj/item/weapon/storage))
				O.hear_talk(src, message)


/*			Commented out as replaced by code above from BS12
	for (var/obj/O in ((V | contents)-used_radios)) //radio in pocket could work, radio in backpack wouldn't --rastaf0
		spawn (0)
			if (O)
				O.hear_talk(src, message)
*/
	if(isbrain(src))//For brains to properly talk if they are in an MMI..or in a brain. Could be extended to other mobs I guess.
		for(var/obj/O in loc)//Kinda ugly but whatever.
			if(O)
				spawn(0)
					O.hear_talk(src, message)



	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/M in listening)
		if(hascall(M,"say_understands"))
			if (M:say_understands(src))
				heard_a += M
			else
				heard_b += M

	var/rendered = null
	if (length(heard_a))
		var/message_a = say_quote(message)

		if (italics)
			message_a = "<i>[message_a]</i>"
		if (!istype(src, /mob/living/carbon/human))
			rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span>"
		else if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
			if(wear_mask:vchange)
				rendered = "<span class='game say'><span class='name'>[wear_mask:voice]</span> <span class='message'>[message_a]</span></span>"
			else
				rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] <span class='message'>[message_a]</span></span>"

		for (var/M in heard_a)
			if(hascall(M,"show_message"))
				M:show_message(rendered, 2)

	if (length(heard_b))
		var/message_b

		if (voice_message)
			message_b = voice_message
		else
			message_b = stars(message)
			message_b = say_quote(message_b)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span>"


		for (var/M in heard_b)
			if(hascall(M,"show_message"))
				M:show_message(rendered, 2)

			/*
			if(M.client)

				if(!M.client.bubbles || M == src)
					var/image/I = image('icons/effects/speechbubble.dmi', B, "override")
					I.override = 1
					M << I
			*/ /*

		flick("[presay]say", B)

		if(istype(loc, /turf))
			B.loc = loc
		else
			B.loc = loc.loc

		spawn()
			sleep(11)
			del(B)
		*/


	log_say("[name]/[key] : [message]")


