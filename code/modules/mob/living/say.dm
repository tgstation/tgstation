#define SAY_MINIMUM_PRESSURE 10
var/list/department_radio_keys = list(
	  ":r" = "right ear",	"#r" = "right ear",		".r" = "right ear", "!r" = "fake right ear",
	  ":l" = "left ear",	"#l" = "left ear",		".l" = "left ear",  "!l" = "fake left ear",
	  ":i" = "intercom",	"#i" = "intercom",		".i" = "intercom",
	  ":h" = "department",	"#h" = "department",	".h" = "department",
	  ":c" = "Command",		"#c" = "Command",		".c" = "Command",
	  ":n" = "Science",		"#n" = "Science",		".n" = "Science",
	  ":m" = "Medical",		"#m" = "Medical",		".m" = "Medical",
	  ":e" = "Engineering", "#e" = "Engineering",	".e" = "Engineering",
	  ":s" = "Security",	"#s" = "Security",		".s" = "Security",
	  ":w" = "whisper",		"#w" = "whisper",		".w" = "whisper",
	  ":b" = "binary",		"#b" = "binary",		".b" = "binary",
	  ":a" = "alientalk",	"#a" = "alientalk",		".a" = "alientalk",
	  ":t" = "Syndicate",	"#t" = "Syndicate",		".t" = "Syndicate",
	  ":u" = "Supply",		"#u" = "Supply",		".u" = "Supply",
	  ":d" = "Service",     "#d" = "Service",       ".d" = "Service",
	  ":g" = "changeling",	"#g" = "changeling",	".g" = "changeling",

	  ":R" = "right ear",	"#R" = "right ear",		".R" = "right ear", "!R" = "fake right ear",
	  ":L" = "left ear",	"#L" = "left ear",		".L" = "left ear",  "!L" = "fake left ear",
	  ":I" = "intercom",	"#I" = "intercom",		".I" = "intercom",
	  ":H" = "department",	"#H" = "department",	".H" = "department",
	  ":C" = "Command",		"#C" = "Command",		".C" = "Command",
	  ":N" = "Science",		"#N" = "Science",		".N" = "Science",
	  ":M" = "Medical",		"#M" = "Medical",		".M" = "Medical",
	  ":E" = "Engineering",	"#E" = "Engineering",	".E" = "Engineering",
	  ":S" = "Security",	"#S" = "Security",		".S" = "Security",
	  ":W" = "whisper",		"#W" = "whisper",		".W" = "whisper",
	  ":B" = "binary",		"#B" = "binary",		".B" = "binary",
	  ":A" = "alientalk",	"#A" = "alientalk",		".A" = "alientalk",
	  ":T" = "Syndicate",	"#T" = "Syndicate",		".T" = "Syndicate",
	  ":U" = "Supply",		"#U" = "Supply",		".U" = "Supply",
	  ":D" = "Service",     "#D" = "Service",       ".D" = "Service",
	  ":G" = "changeling",	"#G" = "changeling",	".G" = "changeling",

	  //kinda localization -- rastaf0
	  //same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	  ":ê" = "right ear",	"#ê" = "right ear",		".ê" = "right ear",
	  ":ä" = "left ear",	"#ä" = "left ear",		".ä" = "left ear",
	  ":ø" = "intercom",	"#ø" = "intercom",		".ø" = "intercom",
	  ":ð" = "department",	"#ð" = "department",	".ð" = "department",
	  ":ñ" = "Command",		"#ñ" = "Command",		".ñ" = "Command",
	  ":ò" = "Science",		"#ò" = "Science",		".ò" = "Science",
	  ":ü" = "Medical",		"#ü" = "Medical",		".ü" = "Medical",
	  ":ó" = "Engineering",	"#ó" = "Engineering",	".ó" = "Engineering",
	  ":û" = "Security",	"#û" = "Security",		".û" = "Security",
	  ":ö" = "whisper",		"#ö" = "whisper",		".ö" = "whisper",
	  ":è" = "binary",		"#è" = "binary",		".è" = "binary",
	  ":ô" = "alientalk",	"#ô" = "alientalk",		".ô" = "alientalk",
	  ":å" = "Syndicate",	"#å" = "Syndicate",		".å" = "Syndicate",
	  ":é" = "Supply",		"#é" = "Supply",		".é" = "Supply",
	  ":â" = "Service",     "#â" = "Service",       ".â" = "Service",
	  ":ï" = "changeling",	"#ï" = "changeling",	".ï" = "changeling"
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
		var/obj/item/device/radio/headset/dongle
		if(istype(H.ears,/obj/item/device/radio/headset))
			dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/proc/hivecheck()
	if (isalien(src)) return 1
	if (!ishuman(src)) return
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.ears,/obj/item/device/radio/headset))
			dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_hive) return 1


// /vg/edit: Added forced_by for handling braindamage messages and meme stuff
/mob/living/say(var/message, var/forced_by=null)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	if (!message)
		src << "\red You cannot say that ...? \black (SAYDEBUG: message == null)"
		return

	if(silent)
		src << "\red You can't speak while silenced."
		return

	if (stat == 2) // Dead.
		return say_dead(message)
	else if (stat) // Unconcious.
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message, MUTE_IC))
			src << "\red Stop spamming, shitbird."
			return

	// stat == 2 is handled above, so this stops transmission of uncontious messages
	if (stat)
		src << "\red You cannot find the strength to form the words."
		return

	// undo last word status.
	if(ishuman(src))
		var/mob/living/carbon/human/H=src
		if(H.said_last_words)
			H.said_last_words=0

	// Mute disability
	if (sdisabilities & MUTE)
		src << "\red Your words don't leave your mouth!"
		return

	// Muzzled.
	if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
		src << "\red [pick("Mmmrf!","Mmmf!","Hmmmf!")]"
		return

	// Emotes.
	if (copytext(message, 1, 2) == "*" && !stat)
		return emote(copytext(message, 2))

	/*
		Identity hiding.
	*/
	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && name != GetVoice())
		var/mob/living/carbon/human/H = src
		alt_name = " (as [H.get_id_name("Unknown")])"

	/*
		Now we get into the real meat of the say processing. Determining the message mode.
	*/

	var/italics = 0
	var/message_range = null
	var/message_mode = null
	var/datum/language/speaking = null //For use if a specific language is being spoken.

	var/braindam = getBrainLoss()
	if (braindam >= 60)
		if(prob(braindam/4))
			message = stutter(message)
		if(prob(braindam))
			message = uppertext(message)

	// General public key. Special message handling
	var/mmode
	var/cprefix = ""
	if(length(message) >= 2)
		cprefix = copytext(message, 1, 3)
		if(cprefix in department_radio_keys)
			mmode = department_radio_keys[cprefix]
	if (copytext(message, 1, 2) == ";" || (prob(braindam/2) && !mmode))
		message_mode = "headset"
		message = copytext(message, 2)
	// Begin checking for either a message mode or a language to speak.
	else if (length(message) >= 2)
		var/channel_prefix = copytext(message, 1, 3)

		//Check if the person is speaking a language that they know.
		if(languages.len)
			for(var/datum/language/L in languages)
				if(lowertext(channel_prefix) == ":[L.key]")
					speaking = L
					break
		message_mode = department_radio_keys[channel_prefix]
		if (message_mode || speaking || copytext(message,1,2) == ":")
			message = trim(copytext(message, 3))
			if (!(istype(src,/mob/living/carbon/human) || istype(src,/mob/living/carbon/monkey) || istype(src, /mob/living/simple_animal/parrot) || isrobot(src) && (message_mode=="department" || (message_mode in radiochannels))))
				message_mode = null //only humans can use headsets
			// Check changed so that parrots can use headsets. Other simple animals do not have ears and will cause runtimes.
			// And borgs -Sieve

/* /vg/ removals
	if(src.stunned > 2 || (traumatic_shock > 61 && prob(50)))
		message_mode = null //Stunned people shouldn't be able to physically turn on their radio/hold down the button to speak into it
*/
	if (!message)
		src << "\red You cannot say that ...? \black (SAYDEBUG: living/say.dm: message == null, before brainloss)"
		return

	// :downs:
	if (getBrainLoss() >= 60)
		message = replacetext(message, " am ", " ")
		message = replacetext(message, " is ", " ")
		message = replacetext(message, " are ", " ")
		message = replacetext(message, "you", "u")
		message = replacetext(message, "help", "halp")
		message = replacetext(message, "grief", "griff")
		message = replacetext(message, "murder", "griff")
		message = replacetext(message, "slipping", "griffing")
		message = replacetext(message, "slipped", "griffed")
		message = replacetext(message, "slip", "griff")
		message = replacetext(message, "sec", "shit")
		message = replacetext(message, "space", "spess")
		message = replacetext(message, "carp", "crap")
		message = replacetext(message, "reason", "raisin")
		message = replacetext(message, "mommi", "spidurr")
		message = replacetext(message, "spider", "spidurr")
		message = replacetext(message, "skitterbot", "spidurbutt")
		message = replacetext(message, "skitter", "spider sound")
		// /vg/: LOUDER
		message = uppertext(message)
		if(prob(50))
			message = uppertext(message)
			message += "[stutter(pick("!", "!!", "!!!"))]"
		if(!stuttering && prob(15))
			message = stutter(message)

	if (stuttering)
		message = stutter(message)

// BEGIN OLD RADIO CODE
/////////////////////////////////////////////////////////////////////////
	var/list/obj/item/used_radios = new
	var/is_speaking_radio = 0

	switch (message_mode)
		if ("headset")
			if (isrobot(src) && src:radio)
				src:radio.talk_into(src, message)
				used_radios += src:radio
				is_speaking_radio = 1

			if (!isrobot(src) && src:ears)
				src:ears.talk_into(src, message)
				used_radios += src:ears
				is_speaking_radio = 1

			message_range = 1
			italics = 1


		if ("secure headset")
			if (src:ears)
				src:ears.talk_into(src, message, 1)
				used_radios += src:ears
				is_speaking_radio = 1

			message_range = 1
			italics = 1

		if ("right hand")
			if (r_hand)
				r_hand.talk_into(src, message)
				used_radios += src:r_hand
				is_speaking_radio = 1

			message_range = 1
			italics = 1

		if ("left hand")
			if (l_hand)
				l_hand.talk_into(src, message)
				used_radios += src:l_hand
				is_speaking_radio = 1

			message_range = 1
			italics = 1

		if ("intercom")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message)
				used_radios += I
				is_speaking_radio = 1

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
			if(istype(src, /mob/living/carbon))
				if (src:ears)
					src:ears.talk_into(src, message, message_mode)
					used_radios += src:ears
					is_speaking_radio = 1
			else if(istype(src, /mob/living/silicon/robot))
				if (src:radio)
					src:radio.talk_into(src, message, message_mode)
					used_radios += src:radio
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
				log_say("[key_name(src)] ([mind.changeling.changelingID]): [message]")
				for(var/mob/Changeling in mob_list)
					if(istype(Changeling, /mob/living/silicon)) continue //WHY IS THIS NEEDED?
					if((Changeling.mind && Changeling.mind.changeling) || istype(Changeling, /mob/dead/observer))
						Changeling << "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
					else if(istype(Changeling,/mob/dead/observer)  && (Changeling.client && Changeling.client.prefs.toggles & CHAT_GHOSTEARS))
						Changeling << "<i><font color=#800080><b>[mind.changeling.changelingID] (:</b> <a href='byond://?src=\ref[Changeling];follow2=\ref[Changeling];follow=\ref[src]'>(Follow)</a> [message]</font></i>"
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

/////////////////////////////////////////////////////////////////////
// END OLD RADIO CODE

	/*
	///////////////////////////////////////////////////////////
	// VIDEO KILLED THE RADIO STAR V2.0
	//
	// EXPERIMENTAL CODE BY YOUR PALS AT /vg/
	///////////////////////////////////////////////////////////

	var/list/obj/item/used_radios = new

	// Actually speaking on the radio?
	var/is_speaking_radio = 0

	// Devices selected
	var/list/devices=list()

	// Select all always_talk devices
	//  Carbon lifeforms
	//if(istype(src, /mob/living/carbon))
	for(var/obj/item/device/radio/R in contents)
		if(R.always_talk)
			devices += R

	//src << "Speaking on [message_mode]: [message]"
	if(message_mode)
		switch (message_mode)
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

			// Select a headset and speak into it without actually sending a message
			if ("fake")
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:ears) used_radios += C:ears
				if(issilicon(src))
					var/mob/living/silicon/Ro=src
					if(Ro:radio) devices += Ro:radio
				message_range = 1
				italics = 1
			if ("fake left hand")
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:l_hand) used_radios += C:l_hand
				message_range = 1
				italics = 1
			if ("fake right hand")
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:r_hand) used_radios += C:r_hand
				message_range = 1
				italics = 1

			if ("intercom")
				for (var/obj/item/device/radio/intercom/I in view(1, null))
					devices += I
				message_mode=null
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

			if ("pAI")
				message_range = 1
				italics = 1

			if("changeling")
				if(mind && mind.changeling)
					log_say("[key_name(src)] ([mind.changeling.changelingID]): [message]")
					for(var/mob/Changeling in mob_list)
						if(istype(Changeling, /mob/living/silicon)) continue //WHY IS THIS NEEDED?
						if((Changeling.mind && Changeling.mind.changeling) || istype(Changeling, /mob/dead/observer))
							Changeling << "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
						else if(istype(Changeling,/mob/dead/observer)  && (Changeling.client && Changeling.client.prefs.toggles & CHAT_GHOSTEARS))
							Changeling << "<i><font color=#800080><b>[mind.changeling.changelingID] (:</b> <a href='byond://?src=\ref[Changeling];follow2=\ref[Changeling];follow=\ref[src]'>(Follow)</a> [message]</font></i>"
					return
			else // headset, department channels.
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:ears) devices += C:ears
				if(issilicon(src))
					var/mob/living/silicon/Ro=src
					if(Ro:radio) devices += Ro:radio
				message_range = 1
				italics = 1
	if(devices.len>0)
		for(var/obj/item/device/radio/R in devices)
			if(istype(R))
				R.talk_into(src, message, message_mode)
				used_radios += R
				is_speaking_radio = 1

	/////////////////////////////////////////////////////////////////
	// </NEW RADIO CODE>
	/////////////////////////////////////////////////////////////////
	*/

	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		var/pressure = environment.return_pressure()
		if (pressure < SAY_MINIMUM_PRESSURE)	//in space no one can hear you scream
			italics = 1
			message_range = 1

	var/list/listening

	listening = get_mobs_in_view(message_range, src)
	//var/list/onscreen = get_mobs_in_view(7, src)
	for(var/mob/M in player_list)
		if (!M.client)
			continue //skip monkeys and leavers
		if (istype(M, /mob/new_player))
			continue
		if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTEARS) && src.client) // src.client is so that ghosts don't have to listen to mice
			listening|=M

	var/turf/T = get_turf(src)
	var/list/W = hear(message_range, T)

	for (var/obj/O in ((W | contents)-used_radios))
		W |= O

	for (var/mob/M in W)
		W |= M.contents

	for (var/atom/A in W)
		if(istype(A, /mob/living/simple_animal/parrot)) //Parrot speech mimickry
			if(A == src)
				continue //Dont imitate ourselves

			var/mob/living/simple_animal/parrot/P = A
			if(P.speech_buffer.len >= 10)
				P.speech_buffer.Remove(pick(P.speech_buffer))
			P.speech_buffer.Add(message)

		if(istype(A, /obj/)) //radio in pocket could work, radio in backpack wouldn't --rastaf0
			var/obj/O = A
			spawn (0)
				if(O && !istype(O.loc, /obj/item/weapon/storage))
					O.hear_talk(src, message)


	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/M in listening)
		if(hascall(M,"say_understands"))
			if (M:say_understands(src,speaking))
				heard_a += M
			else
				heard_b += M
		else
			heard_a += M

	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/talk.dmi',src,"h[speech_bubble_test]")

	for(var/mob/M in hearers(5, src))
		if(M != src && is_speaking_radio)
			M:show_message("<span class='notice'>[src] talks into [used_radios.len ? used_radios[1] : "radio"]</span>")

	var/rendered = null
	if (length(heard_a))
		var/message_a=message
		if(ishuman(src))
			var/mob/living/carbon/human/H=src
			message_a=H.species.say_filter(src,message_a)
		message_a = say_quote(message,speaking)

		if (italics)
			message_a = "<i>[message_a]</i>"

		rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] <span class='message'>[message_a]</span></span>"
		var/rendered2 = null

		for (var/mob/M in heard_a)
		//BEGIN TELEPORT CHANGES
			if(!istype(M, /mob/new_player))
				if(M && M.stat == DEAD)
					if(forced_by)
						rendered2 = "<span class='game say'><span class='name'>[GetVoice()] (forced by [forced_by])</span></span>[alt_name] <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span>"
					else
						rendered2 = "<span class='game say'><span class='name'>[GetVoice()]</span></span> [alt_name] <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span>"
					M:show_message(rendered2, 2)
					continue
		//END CHANGES
			if(hascall(M,"show_message"))
				var/deaf_message = ""
				var/deaf_type = 1
				if(M != src)
					deaf_message = "<span class='name'>[name]</span>[alt_name] talks but you cannot hear them."
				else
					deaf_message = "<span class='notice'>You cannot hear yourself!</span>"
					deaf_type = 2 // Since you should be able to hear yourself without looking
				M:show_message(rendered, 2, deaf_message, deaf_type)
				M.addSpeechBubble(speech_bubble)

	if (length(heard_b))
		var/message_b
		if(speaking)
			message_b = speaking.say_misunderstood(src,message)
		else
			message_b = stars(message)
		message_b = say_quote(message_b,speaking)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[name]</span>[alt_name] <span class='message'>[message_b]</span></span>" //Voice_name isn't too useful. You'd be able to tell who was talking presumably.
		var/rendered2 = null

		for (var/M in heard_b)
			var/mob/MM
			if(istype(M, /mob))
				MM = M
			if(!istype(MM, /mob/new_player) && MM)
				if(MM && MM.stat == DEAD)
					if(forced_by)
						rendered2 = "<span class='game say'><span class='name'>[voice_name] (forced by [forced_by])</span></span> <a href='byond://?src=\ref[MM];follow2=\ref[MM];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_b]</span></span>"
					else
						rendered2 = "<span class='game say'><span class='name'>[voice_name]</span></span> <a href='byond://?src=\ref[MM];follow2=\ref[MM];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_b]</span></span>"
					MM:show_message(rendered2, 2)
					MM.addSpeechBubble(speech_bubble)
					continue
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

	//talking items
	for(var/obj/item/weapon/O in view(3,src))
		if(O.listening_to_players)
			O.catchMessage(message, src)

	log_say("[name]/[key] : [message]")

/mob/proc/addSpeechBubble(image/speech_bubble)
	if(client)
		client.images += speech_bubble
		spawn(30)
			client.images -= speech_bubble

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name


