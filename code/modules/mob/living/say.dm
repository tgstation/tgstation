
var/list/department_radio_keys = list(
	  ":r" = "right hand",	"#r" = "right hand",	".r" = "right hand",
	  ":l" = "left hand",	"#l" = "left hand",		".l" = "left hand",
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
	  ":v" = "Service",		"#v" = "Service",		".v" = "Service",
	  ":g" = "changeling",	"#g" = "changeling",	".g" = "changeling",

	  ":R" = "right hand",	"#R" = "right hand",	".R" = "right hand",
	  ":L" = "left hand",	"#L" = "left hand",		".L" = "left hand",
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
	  ":V" = "Service",		"#V" = "Service",		".V" = "Service",
	  ":G" = "changeling",	"#G" = "changeling",	".G" = "changeling",

	  //kinda localization -- rastaf0
	  //same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	  ":ê" = "right hand",	"#ê" = "right hand",	".ê" = "right hand",
	  ":ä" = "left hand",	"#ä" = "left hand",		".ä" = "left hand",
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
		var/obj/item/device/radio/headset/dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/proc/IsVocal()
	return 1

/mob/living/proc/hivecheck()
	if (isalien(src)) return 1
	if (!ishuman(src)) return
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_hive) return 1

/mob/living/say(var/message, var/bubble_type)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	if (stat == 2)
		return say_dead(message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	// stat == 2 is handled above, so this stops transmission of uncontious messages
	if (stat)
		return

	// Mute disability
	if (sdisabilities & MUTE)
		return

	// emotes
	if (copytext(message, 1, 2) == "*" && !stat)
		return emote(copytext(message, 2))

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && name != GetVoice())
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
			if (!(ishuman(src) || istype(src, /mob/living/simple_animal/parrot) || isrobot(src) && (message_mode=="department" || (message_mode in radiochannels))))
				message_mode = null //only humans can use headsets
			// Check changed so that parrots can use headsets. Other simple animals do not have ears and will cause runtimes.
			// And borgs -Sieve

	if (!message)
		return

	// :downs:
	if (getBrainLoss() >= 60)
		message = replacetext(message, " am ", " ")
		message = replacetext(message, " is ", " ")
		message = replacetext(message, " are ", " ")
		message = replacetext(message, "you", "u")
		message = replacetext(message, "help", "halp")
		message = replacetext(message, "grief", "grife")
		message = replacetext(message, "space", "spess")
		message = replacetext(message, "carp", "crap")
		message = replacetext(message, "reason", "raisin")
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

	if(!IsVocal())
		return

	var/list/listening

	listening = get_mobs_in_view(message_range, src)
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


/*			Commented out as replaced by code above from BS12
	for (var/obj/O in ((V | contents)-used_radios)) //radio in pocket could work, radio in backpack wouldn't --rastaf0
		spawn (0)
			if (O)
				O.hear_talk(src, message)
*/

/*	if(isbrain(src))//For brains to properly talk if they are in an MMI..or in a brain. Could be extended to other mobs I guess.
		for(var/obj/O in loc)//Kinda ugly but whatever.
			if(O)
				spawn(0)
					O.hear_talk(src, message)
*/


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

		rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] <span class='message'>[message_a]</span></span>"

		for (var/M in heard_a)
			if(hascall(M,"show_message"))
				var/deaf_message = ""
				var/deaf_type = 1
				if(M != src)
					deaf_message = "<span class='name'>[name][alt_name]</span> talks but you cannot hear them."
				else
					deaf_message = "<span class='notice'>You cannot hear yourself!</span>"
					deaf_type = 2 // Since you should be able to hear yourself without looking
				M:show_message(rendered, 2, deaf_message, deaf_type)

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

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in heard_a + heard_b)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	spawn(0)
		flick_overlay(image('icons/mob/talk.dmi', src, "h[bubble_type][say_test(message)]",MOB_LAYER+1), speech_bubble_recipients, 30)

	log_say("[name]/[key] : [message]")

/mob/living/proc/GetVoice()
	return name

/mob/living/proc/say_test(var/text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"
