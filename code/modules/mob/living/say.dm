<<<<<<< HEAD
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

	if(!message)
		return

	//Log of what we've said, plain message, no spans or junk
	say_log += message

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
		if(M.stat == DEAD && M.client && ((M.client.prefs.chat_toggles & CHAT_GHOSTEARS) || (get_dist(M, src) <= 7)) && client) // client is so that ghosts don't have to listen to mice
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
				return 1
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
				return 1
			if(1)
				src << "<i><font color=#800080>Our senses have not evolved enough to be able to communicate this way...</font></i>"
				return 1
	if(message_mode == MODE_ALIEN)
		if(hivecheck())
			alien_talk(message)
			return 1
	return 0

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
			if (r_hand)
				r_hand.talk_into(src, message, , spans)
			return ITALICS | REDUCE_RANGE

		if(MODE_L_HAND)
			if (l_hand)
				l_hand.talk_into(src, message, , spans)
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
=======
//bitflag #defines for radio returns.
#define ITALICS 1
#define REDUCE_RANGE 2
#define NOPASS 4


#define SAY_MINIMUM_PRESSURE 10

/proc/message_mode_to_name(mode)
	switch(mode)
		if(MODE_WHISPER)
			return "whisper"
		if(MODE_SECURE_HEADSET)
			return "secure_headset"
		if(MODE_DEPARTMENT)
			return "department"
		if(MODE_ALIEN)
			return "alientalk"
		if(MODE_HOLOPAD)
			return "holopad"
		if(MODE_CHANGELING)
			return "changeling"
		if(MODE_CULTCHAT)
			return "cultchat"
		if(MODE_ANCIENT)
			return "ancientchat"
		else
			return "Unknown"
var/list/department_radio_keys = list(
	  ":0" = "Deathsquad",	"#0" = "Deathsquad",	".0" = "Deathsquad",

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
	  ":r" = "Response Team","#r" = "Response Team",".r" = "Response Team",
	  ":u" = "Supply",		"#u" = "Supply",		".u" = "Supply",
	  ":d" = "Service",     "#d" = "Service",       ".d" = "Service",
	  ":g" = "changeling",	"#g" = "changeling",	".g" = "changeling",
	  ":x" = "cultchat",	"#x" = "cultchat",		".x" = "cultchat",
	  ":y" = "ancientchat",	"#y" = "ancientchat",	".y" = "ancientchat",

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
	  ":R" = "Response Team","#R" = "Response Team",".R" = "Response Team",
	  ":U" = "Supply",		"#U" = "Supply",		".U" = "Supply",
	  ":D" = "Service",     "#D" = "Service",       ".D" = "Service",
	  ":G" = "changeling",	"#G" = "changeling",	".G" = "changeling",
	  ":X" = "cultchat",	"#X" = "cultchat",		".X" = "cultchat",
	  ":Y" = "ancientchat",	"#Y" = "ancientchat", 	".Y" = "ancientchat",

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

/mob/living/proc/get_default_language()
	if(!default_language)
		if(languages && languages.len)
			default_language = languages[1]
	return default_language

/mob/living/hivecheck()
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
/mob/living/say(var/message, bubble_type)
	say_testing(src, "/mob/living/say(\"[message]\", [bubble_type]")
	if(timestopped) return //under the effects of time magick
	message = trim(copytext(message, 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	say_testing(src, "Say start, message=[message]")
	if(!message) return

	var/message_mode = get_message_mode(message)
	if(silent)
		to_chat(src, "<span class='warning'>You can't speak while silenced.</span>")
		return
	if((status_flags & FAKEDEATH) && !stat && message_mode != MODE_CHANGELING)
		to_chat(src, "<span class='danger'>Talking right now would give us away!</span>")
		return

	//var/message_mode_name = message_mode_to_name(message_mode)
	if (stat == DEAD) // Dead.
		say_testing(src, "ur ded kid")
		say_dead(message)
		return
	if (stat) // Unconcious.
		if(message_mode == MODE_WHISPER) //Lets us say our last words.
			say_testing(src, "message mode was whisper.")
			whisper(copytext(message, 3))
		return
	if(check_emote(message))
		say_testing(src, "Emoted")
		return
	if(!can_speak_basic(message))
		say_testing(src, "we aren't able to talk")
		return

	if(message_mode == MODE_HEADSET || message_mode == MODE_ROBOT)
		say_testing(src, "Message mode was [message_mode == MODE_HEADSET ? "headset" : "robot"]")
		message = copytext(message, 2)
	else if(message_mode)
		say_testing(src, "Message mode is [message_mode]")
		message = copytext(message, 3)

	// SAYCODE 90.0!
	// We construct our speech object here.
	var/datum/speech/speech = create_speech(message)

	if(!speech.language)
		speech.language = parse_language(speech.message)
		say_testing(src, "Getting speaking language, got [istype(speech.language) ? speech.language.name : "null"]")
	if(istype(speech.language))
#ifdef SAY_DEBUG
		var/oldmsg = message
#endif
		speech.message = copytext(speech.message,2+length(speech.language.key))
		say_testing(src, "Have a language, oldmsg = [oldmsg], newmsg = [message]")
	else
		if(!isnull(speech.language))
#ifdef SAY_DEBUG
			var/oldmsg = message
#endif
			var/n = speech.language
			message = copytext(message,1+length(n))
			say_testing(src, "We tried to speak a language we don't have; length = [length(n)], oldmsg = [oldmsg] parsed message = [message]")
			speech.language = null
		speech.language = get_default_language()
		say_testing(src, "Didnt have a language, get_default_language() gave us [speech.language ? speech.language.name : "null"]")
	speech.message = trim_left(speech.message)
	if(handle_inherent_channels(speech, message_mode))
		say_testing(src, "Handled by inherent channel")
		returnToPool(speech)
		return
	if(!can_speak_vocal(speech.message))
		returnToPool(speech)
		return

	//parse the language code and consume it


	var/message_range = 7
	treat_speech(speech)
	var/radio_return = radio(speech, message_mode)
	if(radio_return & NOPASS) //There's a whisper() message_mode, no need to continue the proc if that is called
		returnToPool(speech)
		return

	if(radio_return & ITALICS)
		speech.message_classes.Add("italics")
	if(radio_return & REDUCE_RANGE)
		message_range = 1
	if(copytext(text, length(text)) == "!")
		message_range++


	send_speech(speech, message_range, bubble_type)
	var/turf/T = get_turf(src)
	log_say("[name]/[key] [T?"(@[T.x],[T.y],[T.z])":"(@[x],[y],[z])"] [speech.language ? "As [speech.language.name] ":""]: [message]")
	returnToPool(speech)
	return 1


/mob/living/Hear(var/datum/speech/speech, var/rendered_message = null)
	if(!rendered_message)
		rendered_message = speech.message
	if(!client)
		return
	say_testing(src, "[src] ([src.type]) has heard a message (lang=[speech.language ? speech.language.name : "null"])")
	var/deaf_message
	var/deaf_type
	var/type = 2
	if(speech.speaker != src)
		if(!speech.frequency) //These checks have to be seperate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "<span class='name'>[speech.speaker]</span> talks but you cannot hear them."
			deaf_type = 1
		else
			if(hear_radio_only())
				type = null //This kills the deaf check for radio only.
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2 // Since you should be able to hear yourself without looking
	var/atom/movable/AM = speech.speaker.GetSource()
	if(!say_understands((istype(AM) ? AM : speech.speaker),speech.language)|| force_compose) //force_compose is so AIs don't end up without their hrefs.
		rendered_message = render_speech(speech)
	show_message(rendered_message, type, deaf_message, deaf_type)
	return rendered_message

/mob/living/proc/hear_radio_only()
	return 0

/mob/living/send_speech(var/datum/speech/speech, var/message_range=7, var/bubble_type) // what is bubble type?
	say_testing(src, "/mob/living/send_speech() start, msg = [speech.message]; message_range = [message_range]; language = [speech.language ? speech.language.name : "None"]; speaker = [speech.speaker];")
	if(isnull(message_range)) message_range = 7

	var/list/listeners = get_hearers_in_view(message_range, speech.speaker) | observers

	var/rendered = render_speech(speech)

	for (var/atom/movable/listener in listeners)
		listener.Hear(speech, rendered)

	send_speech_bubble(speech.message, bubble_type, listeners)

/mob/living/proc/say_test(var/text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

/mob/living/can_speak(message) //For use outside of Say()
	if(can_speak_basic(message) && can_speak_vocal(message))
		return 1

/mob/living/proc/can_speak_basic(message) //Check BEFORE handling of xeno and ling channels
	if(!message || message == "")
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	return 1


/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno and ling channels
	if(!message)
		return

	if(sdisabilities & MUTE)
		return

	if(is_muzzled())
		return

	if(!IsVocal())
		return

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

/mob/living/proc/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	switch(message_mode)
		if(MODE_CHANGELING)
			if(lingcheck())
				var/turf/T = get_turf(src)
				log_say("[mind.changeling.changelingID]/[key_name(src)] (@[T.x],[T.y],[T.z]) Changeling Hivemind: [html_encode(speech.message)]")
				var/themessage = text("<i><font color=#800080><b>[]:</b> []</font></i>",mind.changeling.changelingID,html_encode(speech.message))
				for(var/mob/M in player_list)
					if(M.lingcheck() || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
						handle_render(M,themessage,src)
				return 1
		if(MODE_CULTCHAT)
			if(construct_chat_check(1)) /*sending check for humins*/
				var/turf/T = get_turf(src)
				log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Cult channel: [html_encode(speech.message)]")
				var/themessage = text("<span class='sinister'><b>[]:</b> []</span>",src.name,html_encode(speech.message))
				for(var/mob/M in player_list)
					if(M.construct_chat_check(2) /*receiving check*/ || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
						handle_render(M,themessage,src)
				return 1
		if(MODE_ANCIENT)
			if(isMoMMI(src))
				return 0 //Noice try, I really do appreciate the effort
			var/list/stone = search_contents_for(/obj/item/commstone)
			if(stone.len)
				var/obj/item/commstone/commstone = stone[1]
				if(commstone.commdevice)
					var/list/stones = commstone.commdevice.get_active_stones()
					var/themessage = text("<span class='ancient'>Ancient communication, <b>[]:</b> []</span>",src.name,html_encode(speech.message))
					var/turf/T = get_turf(src)
					log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Ancient chat: [html_encode(speech.message)]")
					for(var/thestone in stones)
						var/mob/M = get_holder_of_type(thestone,/mob)
						if(M)
							handle_render(M,themessage,src)
					for(var/M in dead_mob_list)
						if(!istype(M,/mob/new_player))
							handle_render(M,themessage,src)
					return 1
	return 0

/mob/living/proc/treat_speech(var/datum/speech/speech, genesay = 0)
	if(getBrainLoss() >= 60)
		speech.message = derpspeech(speech.message, stuttering)

	if(stuttering || (undergoing_hypothermia() == MODERATE_HYPOTHERMIA && prob(25)) )
		speech.message = stutter(speech.message)

/mob/living/proc/radio(var/datum/speech/speech, var/message_mode)
	switch(message_mode)
		if(MODE_R_HAND)
			say_testing(src, "/mob/living/radio() - MODE_R_HAND")
			var/obj/item/I = get_held_item_by_index(GRASP_RIGHT_HAND)
			if(I)
				I.talk_into(speech)
			return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			say_testing(src, "/mob/living/radio() - MODE_L_HAND")
			var/obj/item/I = get_held_item_by_index(GRASP_LEFT_HAND)
			if(I)
				I.talk_into(speech)
			return ITALICS | REDUCE_RANGE
		if(MODE_INTERCOM)
			say_testing(src, "/mob/living/radio() - MODE_INTERCOM")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(speech)
			return ITALICS | REDUCE_RANGE
		if(MODE_BINARY)
			say_testing(src, "/mob/living/radio() - MODE_BINARY")
			if(binarycheck())
				robot_talk(speech.message)
			return ITALICS | REDUCE_RANGE //Does not return 0 since this is only reached by humans, not borgs or AIs.
		if(MODE_WHISPER)
			say_testing(src, "/mob/living/radio() - MODE_WHISPER")
			whisper(speech.message, speech.language)
			return NOPASS
	return 0

/mob/living/lingcheck()
	if(mind && mind.changeling && !issilicon(src))
		return 1

/mob/living/construct_chat_check(var/setting = 0) //setting: 0 is to speak over general into cultchat, 1 is to speak over channel into cultchat, 2 is to hear cultchat
	if(!mind) return

	if(setting == 0) //overridden for constructs
		return
	if(setting == 1)
		if(mind in ticker.mode.cult && universal_cult_chat == 1)
			return 1
	if(setting == 2)
		if(mind in ticker.mode.cult)
			return 1

/mob/living/say_quote()
	if (stuttering)
		return "stammers, [text]"
	if (getBrainLoss() >= 60)
		return "gibbers, [text]"
	return ..()

/mob/living/proc/send_speech_bubble(var/message,var/bubble_type, var/list/hearers)
	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in hearers)
		M.heard(src)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	spawn(0)
		var/image/speech_bubble = image('icons/mob/talk.dmi', get_holder_at_turf_level(src), "h[bubble_type][say_test(message)]",MOB_LAYER+1)
		speech_bubble.plane = PLANE_BASE
		speech_bubble.appearance_flags = RESET_COLOR
		flick_overlay(speech_bubble, speech_bubble_recipients, 30)

/mob/proc/addSpeechBubble(image/speech_bubble)
	if(client)
		client.images += speech_bubble
		spawn(30)
			if(client) client.images -= speech_bubble

/obj/effect/speech_bubble
	var/mob/parent
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
