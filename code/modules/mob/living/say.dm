
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
	return 0

/mob/living/say(message, bubble_type, steps = 0)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	check_emote(message)

	if(!can_speak_basic(message) || stat) //Stat is seperate so I can handle whispers properly.
		return

	var/message_mode = get_message_mode(message)

	if(message_mode == "headset" || message_mode == "robot")
		message = copytext(message, 2)
	else if(message_mode)
		message = copytext(message, 3)

	if(handle_inherent_channels(message, message_mode)) //Hiveminds & binary chat.
		return

	if(!can_speak_vocal(message))
		return

	message = treat_message(message)
	if(!message || message == "")
		return

	var/message_range
	radio_return = radio(message, message_mode) //0 to 2
	if(!radio_return) //There's a whisper() message_mode, no need to continue the proc if that is called
		return
	else if(radio_return & 1)
		message = "<i>[message]</i>"
		message_range = 1
	//Only other possible output is 2, which means no radio was spoken into. In this case we can continue.

	var/alt_name = get_alt_name()

	var/list/listening = get_hearers_in_view(message_range, src)
	var/list/listening_dead
	for(var/mob/M in player_list)
		if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTEARS) && client) // client is so that ghosts don't have to listen to mice
			listening_dead |= M

	listening -= listening_dead //so ghosts dont hear stuff twice

	var/rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] <span class='message'>[message]</span></span>"
	for(var/atom/movable/AM in listening)
		AM.Hear(rendered, src, languages, message, 0)

	for(var/mob/M in listening_dead) //deaf ghosts is bad mkay
		M << rendered

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in (listening + listening_dead))
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	spawn(0)
		flick_overlay(image('icons/mob/talk.dmi', src, "h[bubble_type][say_test(message)]",MOB_LAYER+1), speech_bubble_recipients, 30)

	log_say("[name]/[key] : [message]")

/mob/living/Hear(message, atom/movable/speaker, message_langs, raw_message, steps, radio_freq)
	var/deaf_message
	var/deaf_type
	if(speaker != src)
		deaf_message = "<span class='name'>[name][alt_name]</span> talks but you cannot hear them."
		deaf_type = 1
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2 // Since you should be able to hear yourself without looking
	message = lang_treat(message, speaker, message_langs, raw_message)
	show_message(message, 2, deaf_message, deaf_type)

/mob/living/proc/GetVoice()
	return name

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

	if(stat == DEAD)
		say_dead(message)
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "<span class='danger'>You cannot speak in IC (muted).</span>"
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
	if (copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

/mob/living/proc/get_message_mode(message)
	if(copytext(message, 1, 2) == ";")
		return "headset"
	else if(length(message) > 2)
		return department_radio_keys[copytext(message, 1, 3)]

/mob/living/proc/handle_inherent_channels(message, message_mode)
	if(message_mode == "changeling")
		if(lingcheck())
			log_say("[mind.changeling.changelingID]/[src.key] : [message]")
			for(var/mob/M in mob_list)
				if(M.lingcheck() || M.stat == DEAD)
					M << "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
			return 1
	return 0

/mob/living/proc/treat_message(message)
	if(getBrainLoss() >= 60)
		message = derpspeech(message, stuttering)
	
	if(stuttering)
		message = stutter(message)
	
	return message

/mob/living/proc/IsVocal()
	return 1

/mob/living/proc/radio(message, message_mode, steps)
	switch(message_mode)
		if("right hand")
			if (r_hand)
				r_hand.talk_into(src, message)
			return 1

		if("left hand")
			if (l_hand)
				l_hand.talk_into(src, message)
			return 1

		if("intercom")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message)
			return 1

		if("binary")
			if(binarycheck())
				robot_talk(message)
			return 1

		if("whisper")
			whisper(message)
			return 0
	return 2

/mob/living/lingcheck()
	if(mind && mind.changeling)
		return 1

/mob/living/proc/get_alt_name()
	return
