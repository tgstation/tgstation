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
	  ":o" = "AI Private",	"#o" = "AI Private",	".o" = "AI Private",
	  ":g" = "changeling",	"#g" = "changeling",	".g" = "changeling",
	  ":y" = "Centcom",		"#y" = "Centcom",		".y" = "Centcom",
	  ":x" = "cords",		"#x" = "cords",			".x" = "cords",

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
	  ":O" = "AI Private",	"#O" = "AI Private",	".O" = "AI Private",
	  ":G" = "changeling",	"#G" = "changeling",	".G" = "changeling",
	  ":Y" = "Centcom",		"#Y" = "Centcom",		".Y" = "Centcom",
	  ":X" = "cords",		"#X" = "cords",			".X" = "cords",

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

var/list/crit_allowed_modes = list(MODE_WHISPER,MODE_CHANGELING,MODE_ALIEN)

/mob/living/say(message, bubble_type,var/list/spans = list())
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return


	if(stat == DEAD)
		say_dead(message)
		return

	if(check_emote(message))
		return

	if(!can_speak_basic(message)) //Stat is seperate so I can handle whispers properly.
		return

	var/message_mode = get_message_mode(message)

	if(stat && !(message_mode in crit_allowed_modes))
		return

	if(message_mode == MODE_HEADSET || message_mode == MODE_ROBOT)
		message = copytext(message, 2)
	else if(message_mode)
		message = copytext(message, 3)
	if(findtext(message, " ", 1, 2))
		message = copytext(message, 2)

	if(handle_inherent_channels(message, message_mode)) //Hiveminds, binary chat & holopad.
		return

	if(!can_speak_vocal(message))
		src << "<span class='warning'>You find yourself unable to speak!</span>"
		return

	if(message_mode != MODE_WHISPER) //whisper() calls treat_message(); double process results in "hisspering"
		message = treat_message(message)

	spans += get_spans()

	//Log what we've said with an associated timestamp, using the list's len for safety/to prevent overwriting messages
	say_log["[LAZYLEN(say_log) + 1]\[[time_stamp()]\]"] = message

	var/message_range = 7
	var/radio_return = radio(message, message_mode, spans)
	if(radio_return & NOPASS) //There's a whisper() message_mode, no need to continue the proc if that is called
		return
	if(radio_return & ITALICS)
		spans |= SPAN_ITALICS
	if(radio_return & REDUCE_RANGE)
		message_range = 1

	//No screams in space, unless you're next to someone.
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = (environment)? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE)
		message_range = 1

	if(pressure < ONE_ATMOSPHERE*0.4) //Thin air, let's italicise the message
		spans |= SPAN_ITALICS

	send_speech(message, message_range, src, bubble_type, spans)

	log_say("[name]/[key] : [message]")
	return 1

/mob/living/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(!client)
		return
	var/deaf_message
	var/deaf_type
	if(speaker != src)
		if(!radio_freq) //These checks have to be seperate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "<span class='name'>[speaker]</span> [speaker.verb_say] something but you cannot hear them."
			deaf_type = 1
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2 // Since you should be able to hear yourself without looking
	if(!(message_langs & languages_understood) || force_compose) //force_compose is so AIs don't end up without their hrefs.
		message = compose_message(speaker, message_langs, raw_message, radio_freq, spans)
	show_message(message, 2, deaf_message, deaf_type)
	return message

/mob/living/send_speech(message, message_range = 7, obj/source = src, bubble_type = bubble_icon, list/spans)
	var/list/listening = get_hearers_in_view(message_range, source)
	for(var/mob/M in player_list)
		if(M.stat == DEAD && M.client && ((M.client.prefs.chat_toggles & CHAT_GHOSTEARS) || (get_dist(M, src) <= 7 && M.z == z)) && client) // client is so that ghosts don't have to listen to mice
			listening |= M

	var/rendered = compose_message(src, languages_spoken, message, , spans)
	for(var/atom/movable/AM in listening)
		AM.Hear(rendered, src, languages_spoken, message, , spans)

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	var/image/I = image('icons/mob/talk.dmi', src, "[bubble_type][say_test(message)]", FLY_LAYER)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	spawn(0)
		flick_overlay(I, speech_bubble_recipients, 30)

/mob/proc/binarycheck()
	return 0

/mob/living/can_speak(message) //For use outside of Say()
	if(can_speak_basic(message) && can_speak_vocal(message))
		return 1

/mob/living/proc/can_speak_basic(message) //Check BEFORE handling of xeno and ling channels
	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "<span class='danger'>You cannot speak in IC (muted).</span>"
			return 0
		if(client.handle_spam_prevention(message,MUTE_IC))
			return 0

	return 1

/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno and ling channels
	if(disabilities & MUTE)
		return 0

	if(is_muzzled())
		return 0

	if(!IsVocal())
		return 0

	return 1

/mob/living/proc/check_emote(message)
	if(copytext(message, 1, 2) == "*")
		emote(copytext(message, 2))
		return 1

/mob/living/proc/get_message_mode(message)
	if(copytext(message, 1, 2) == ";")
		return MODE_HEADSET
	else if(length(message) > 2)
		return department_radio_keys[copytext(message, 1, 3)]

/mob/living/proc/handle_inherent_channels(message, message_mode)
	if(message_mode == MODE_CHANGELING)
		switch(lingcheck())
			if(3)
				var/msg = "<i><font color=#800040><b>[src.mind]:</b> [message]</font></i>"
				for(var/mob/M in mob_list)
					if(M in dead_mob_list)
						var/link = FOLLOW_LINK(M, src)
						M << "[link] [msg]"
					else
						switch(M.lingcheck())
							if(3)
								M << msg
							if(2)
								M << msg
							if(1)
								if(prob(40))
									M << "<i><font color=#800080>We can faintly sense an outsider trying to communicate through the hivemind...</font></i>"
			if(2)
				var/msg = "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
				log_say("[mind.changeling.changelingID]/[src.key] : [message]")
				for(var/mob/M in mob_list)
					if(M in dead_mob_list)
						var/link = FOLLOW_LINK(M, src)
						M << "[link] [msg]"
					else
						switch(M.lingcheck())
							if(3)
								M << msg
							if(2)
								M << msg
							if(1)
								if(prob(40))
									M << "<i><font color=#800080>We can faintly sense another of our kind trying to communicate through the hivemind...</font></i>"
			if(1)
				src << "<i><font color=#800080>Our senses have not evolved enough to be able to communicate this way...</font></i>"
		return TRUE
	if(message_mode == MODE_ALIEN)
		if(hivecheck())
			alien_talk(message)
		return TRUE
	if(message_mode == MODE_VOCALCORDS)
		if(iscarbon(src))
			var/mob/living/carbon/C = src
			var/obj/item/organ/vocal_cords/V = C.getorganslot("vocal_cords")
			if(V && V.can_speak_with())
				C.say(V.speak_with(message), spans = V.spans)
		return TRUE
	return FALSE

/mob/living/proc/treat_message(message)
	if(getBrainLoss() >= 60)
		message = derpspeech(message, stuttering)

	if(stuttering)
		message = stutter(message)

	if(slurring)
		message = slur(message)

	if(cultslurring)
		message = cultslur(message)

	message = capitalize(message)

	return message

/mob/living/proc/radio(message, message_mode, list/spans)
	switch(message_mode)
		if(MODE_R_HAND)
			for(var/obj/item/r_hand in get_held_items_for_side("r", all = TRUE))
				if (r_hand)
					return r_hand.talk_into(src, message, , spans)
				return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			for(var/obj/item/l_hand in get_held_items_for_side("l", all = TRUE))
				if (l_hand)
					return l_hand.talk_into(src, message, , spans)
				return ITALICS | REDUCE_RANGE

		if(MODE_INTERCOM)
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message, , spans)
			return ITALICS | REDUCE_RANGE

		if(MODE_BINARY)
			if(binarycheck())
				robot_talk(message)
			return ITALICS | REDUCE_RANGE //Does not return 0 since this is only reached by humans, not borgs or AIs.

		if(MODE_WHISPER)
			whisper(message)
			return NOPASS
	return 0

/mob/living/lingcheck() //1 is ling w/ no hivemind. 2 is ling w/hivemind. 3 is ling victim being linked into hivemind.
	if(mind && mind.changeling)
		if(mind.changeling.changeling_speak)
			return 2
		return 1
	if(mind && mind.linglink)
		return 3
	return 0

/mob/living/say_quote(input, list/spans)
	var/tempinput = attach_spans(input, spans)
	if (stuttering)
		return "stammers, \"[tempinput]\""
	if (getBrainLoss() >= 60)
		return "gibbers, \"[tempinput]\""
	return ..()
