
var/list/department_radio_keys = list(
	  ":r" = "right ear",
	  ":l" = "left ear",
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

	  ":R" = "right ear",
	  ":L" = "left ear",
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
	if (H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear,/obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/proc/hivecheck()
	if (isalien(src)) return 1
	if (!ishuman(src)) return
	var/mob/living/carbon/human/H = src
	if (H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear,/obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
		if(!istype(dongle)) return
		if(dongle.translate_hive) return 1

/mob/living/say(var/message)
	var/message_old = message
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!speech_allowed && usr == src)
		usr << "\red You can't speak."
		return

	if (!message)
		return

	if (length(message) >= 1)
		if (miming && copytext(message, 1, 2) != "*")
			return

	if (stat == 2)
		return say_dead(message)

	if (silent)
		return

	if (src.client && (client.muted || src.client.muted_complete))
		src << "You are muted."
		return

	// stat == 2 is handled above, so this stops transmission of uncontious messages
	if (stat)
		return

	// Mute disability
	if (disabilities & 64)
		return

	if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return

	// emotes
	if (copytext(message, 1, 2) == "*" && !stat)
		return emote(copytext(message, 2))

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(H.get_face_name() != real_name)
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
			if (!(ishuman(src) || isanimal(src) && (message_mode=="department" || (message_mode in radiochannels) || message_mode == "right ear" || message_mode == "left ear")))
				message_mode = null //only humans can use headsets
			// Check removed so parrots can use headsets!

	if (!message)
		return

	//work out if we're speaking skrell or not
	var/is_speaking_skrell = 0

	if(copytext(message, 1, 3) == ":k" || copytext(message, 1, 3) == ":K")
		message = copytext(message, 3)
		if(skrell_talk_understand || universal_speak)
			is_speaking_skrell = 1

	//work out if we're speaking soghun or not
	var/is_speaking_soghun = 0
	if(copytext(message, 1, 3) == ":o" || copytext(message, 1, 3) == ":O")
		message = copytext(message, 3)
		if(soghun_talk_understand || universal_speak)
			is_speaking_soghun = 1

	if( !message_mode && (disease_symptoms & DISEASE_WHISPER))
		message_mode = "whisper"

	if(src.stunned > 2 || (traumatic_shock > 61 && prob(50)))
		message_mode = "" //Stunned people shouldn't be able to physically turn on their radio/hold down the button to speak into it


	message = capitalize(message) //capitalize the first letter of what they actually say

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
			message = NewStutter(message,stunned)

	if (stuttering)
		message = NewStutter(message,stunned)
	if (slurring)
		message = slur(message)

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
			if (src:l_ear && istype(src:l_ear,/obj/item/device/radio))
				src:l_ear.talk_into(src, message)
				used_radios += src:l_ear
			else if (src:r_ear)
				src:r_ear.talk_into(src, message)
				used_radios += src:r_ear

			message_range = 1
			italics = 1


		if ("secure headset")
			if (src:l_ear && istype(src:l_ear,/obj/item/device/radio))
				src:l_ear.talk_into(src, message, 1)
				used_radios += src:l_ear
			else if (src:r_ear)
				src:r_ear.talk_into(src, message, 1)
				used_radios += src:r_ear

			message_range = 1
			italics = 1

		if ("right ear")
			if (src:r_ear)
				src:r_ear.talk_into(src, message)
				used_radios += src:r_ear

			message_range = 1
			italics = 1

		if ("left ear")
			if (src:l_ear)
				src:l_ear.talk_into(src, message)
				used_radios += src:l_ear

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
			whisper(trim(copytext(message_old, 3)))
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
			if (src:l_ear && istype(src:l_ear,/obj/item/device/radio))
				src:l_ear.talk_into(src, message, message_mode)
				used_radios += src:l_ear
			else if (src:r_ear)
				src:r_ear.talk_into(src, message, message_mode)
				used_radios += src:r_ear
			message_range = 1
			italics = 1
		if ("pAI")
			if (src:radio)
				src:radio.talk_into(src, message)
				used_radios += src:radio
			message_range = 1
			italics = 1
		if("changeling")
			if(src.changeling)
				for(var/mob/aChangeling in world)
					if(aChangeling.changeling || istype(aChangeling, /mob/dead/observer))
						aChangeling << "<i><font color=#800080><b>[gender=="male"?"Mr.":"Mrs."] [changeling.changelingID]:</b> [message]</font></i>"
				return
////SPECIAL HEADSETS START
		else
			//world << "SPECIAL HEADSETS"
			if (message_mode in radiochannels)
				if (src:l_ear && istype(src:l_ear,/obj/item/device/radio))
					src:l_ear.talk_into(src, message, message_mode)
					used_radios += src:l_ear
				else if (src:r_ear)
					src:r_ear.talk_into(src, message, message_mode)
					used_radios += src:r_ear
				message_range = 1
				italics = 1
/////SPECIAL HEADSETS END

	var/list/listening

	listening = get_mobs_in_view(message_range, src)
	for(var/mob/M in world)
		if (!M.client)
			continue //skip monkeys and leavers
		if (istype(M, /mob/new_player))
			continue
		if(M.stat == 2 && M.client.ghost_ears)
			listening|=M

	var/turf/T = get_turf(src)
	var/list/V = view(message_range, T)
	var/list/W = V

	var/list/eavesdroppers = get_mobs_in_view(7, src)
	for(var/mob/M in listening)
		eavesdroppers.Remove(M)
	for(var/mob/M in eavesdroppers)
		if(M.stat || !M.client || istype(M, /mob/living/silicon/pai) || M == src)
			eavesdroppers.Remove(M)

	for (var/obj/O in ((W | contents)-used_radios))
		W |= O

	for (var/mob/M in W)
		W |= M.contents
		if(hasorgans(M))
			var/mob/living/carbon/G = M
			for(var/name in G:organs)
				var/datum/organ/external/F = G:organs[name]
				for(var/obj/item/weapon/implant/I in F.implant)
					W |= I

	for (var/obj/item/device/pda/M in W)
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

	for (var/mob/M in listening)
		//if speaking in skrell, only let other skrell understand
		if (M.say_understands(src) && !is_speaking_skrell && !is_speaking_soghun) //This could probably be merged into say_understands(), but I'm too lazy
			heard_a += M
		else if(is_speaking_skrell && (M.skrell_talk_understand || M.universal_speak))
			heard_a += M
		else if(is_speaking_soghun && (M.soghun_talk_understand || M.universal_speak))
			heard_a += M
		else
			heard_b += M

	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('talk.dmi',src,"h[speech_bubble_test]")

	var/rendered = null
	if (length(heard_a))
		var/message_a = say_quote(message,is_speaking_soghun,is_speaking_skrell)
		if (italics)
			message_a = "<i>[message_a]</i>"
		if (!istype(src, /mob/living/carbon/human))
			rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span>"
		else if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
			var/mob/living/carbon/human/H = src
			if(wear_mask:vchange)
				rendered = "<span class='game say'><span class='name'>[wear_mask:voice]</span> <span class='message'>[message_a]</span></span>"
			else
				rendered = "<span class='game say'><span class='name'>[H.get_visible_name()]</span> <span class='message'>[message_a]</span></span>"
		else
			var/mob/living/carbon/human/H = src
			rendered = "<span class='game say'><span class='name'>[H.get_face_name()]</span>[alt_name] <span class='message'>[message_a]</span></span>"

/*
		// Create speech bubble
		var/obj/effect/speech_bubble/B = new/obj/effect/speech_bubble
		B.icon = 'speechbubble.dmi'
		B.parent = src
		B.mouse_opacity = 0
		B.invisibility = invisibility
		B.layer = 10

		// Determine if the speech bubble's going to have a special look
		var/presay = ""
		if(istype(src, /mob/living/silicon))
			presay = "bot"
		if(istype(src, /mob/living/carbon/alien))
			presay = "xeno"
		if(istype(src, /mob/living/carbon/metroid))
			presay = "metroid"
*/
		//talking crystals

		for(var/obj/item/weapon/talkingcrystal/O in view(3,src))
			O.catchMessage(message,src)


		for (var/mob/M in heard_a)

			M.show_message(rendered, 2)
			M << speech_bubble
		spawn(30) del(speech_bubble)
		//spawn(30) del(speech_bubble)
			/*
			if(M.client)

				// If this client has bubbles disabled, obscure the bubble
				if(!M.client.bubbles || M == src)
					var/image/I = image('speechbubble.dmi', B, "override")
					I.override = 1
					M << I
			*/
		/*
		// find the suffix, if bot, human or monkey
		var/punctuation = ""
		if(presay == "bot" || presay == "")
			var/ending = copytext(text, length(text))
			if (ending == "?")
				punctuation = "question"
			else if (ending == "!")
				punctuation = "exclamation"
			else
				punctuation = ""

		// flick the bubble
		flick("[presay]say[punctuation]", B)

		if(istype(loc, /turf))
			B.loc = loc
		else
			B.loc = loc.loc

		spawn()
			sleep(11)
			del(B)
		*/

	if (length(heard_b))
		var/message_b

		if (voice_message)
			message_b = voice_message
		else
			message_b = stars(message)
			message_b = say_quote(message_b,is_speaking_soghun,is_speaking_skrell)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span>"


		/*
		// Create speech bubble
		var/obj/effect/speech_bubble/B = new/obj/effect/speech_bubble
		B.icon = 'speechbubble.dmi'
		B.parent = src
		B.mouse_opacity = 0
		B.invisibility = invisibility
		B.layer = 10

		// Determine if the speech bubble's going to have a special look
		var/presay = ""
		if(istype(src, /mob/living/silicon))
			presay = "bot"
		if(istype(src, /mob/living/carbon/alien))
			presay = "xeno"
		if(istype(src, /mob/living/carbon/metroid))
			presay = "metroid"
		*/

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)
			M << speech_bubble
		spawn(30) del(speech_bubble)

			/*
			if(M.client)

				if(!M.client.bubbles || M == src)
					var/image/I = image('speechbubble.dmi', B, "override")
					I.override = 1
					M << I


		flick("[presay]say", B)

		if(istype(loc, /turf))
			B.loc = loc
		else
			B.loc = loc.loc

		spawn()
			sleep(11)
			del(B)
		*/

	if (length(eavesdroppers))

		for (var/mob/M in eavesdroppers)
			M << "\blue [src] speaks into their radio..."
			M << speech_bubble
		spawn(30) del(speech_bubble)

	log_say("[name]/[key] : [message]")



/obj/effect/speech_bubble
	var/mob/parent