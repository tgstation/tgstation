//bitflag #defines for radio return.
#define ITALICS 1
#define REDUCE_RANGE 2
#define NOPASS 4

//message modes. you're not supposed to mess with these.
#define MODE_HEADSET "headset"
#define MODE_ROBOT "robot"
#define MODE_R_HAND "right hand"
#define MODE_L_HAND "left hand"
#define MODE_INTERCOM "intercom"
#define MODE_BINARY "binary"
#define MODE_WHISPER "whisper"
#define MODE_SECURE_HEADSET "secure headset"
#define MODE_DEPARTMENT "department"
#define MODE_ALIEN "alientalk"
#define MODE_HOLOPAD "holopad"
#define MODE_CHANGELING "changeling"

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

/mob/proc/binarycheck()
	return 0

/mob/living/say(message, bubble_type)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(stat == DEAD)
		say_dead(message)
		return

	if(stat)
		return

	if(check_emote(message))
		return

	if(!can_speak_basic(message)) //Stat is seperate so I can handle whispers properly.
		return

	var/message_mode = get_message_mode(message)

	if(message_mode == MODE_HEADSET || message_mode == MODE_ROBOT)
		message = copytext(message, 2)
	else if(message_mode)
		message = copytext(message, 3)
	if(findtext(message, " ", 1, 2))
		message = copytext(message, 2)

	if(handle_inherent_channels(message, message_mode)) //Hiveminds, binary chat & holopad.
		return

	if(!can_speak_vocal(message))
		return

	message = treat_message(message)

	if(!message || message == "")
		return

	var/message_range = 7
	var/radio_return = radio(message, message_mode)
	if(radio_return & NOPASS) //There's a whisper() message_mode, no need to continue the proc if that is called
		return
	if(radio_return & ITALICS)
		message = "<i>[message]</i>"
	if(radio_return & REDUCE_RANGE)
		message_range = 1

	send_speech(message, message_range, src, bubble_type)

	log_say("[name]/[key] : [message]")
	return 1

/mob/living/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
	if(!client)
		return
	var/deaf_message
	var/deaf_type
	if(speaker != src)
		if(!radio_freq) //These checks have to be seperate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "<span class='name'>[speaker]</span> talks but you cannot hear them."
			deaf_type = 1
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2 // Since you should be able to hear yourself without looking
	if(!(message_langs & languages) || force_compose) //force_compose is so AIs don't end up without their hrefs.
		message = compose_message(speaker, message_langs, raw_message, radio_freq)
	show_message(message, 2, deaf_message, deaf_type)
	return message

/mob/living/send_speech(message, message_range = 7, obj/source = src, bubble_type)
	var/list/listening = get_hearers_in_view(message_range, source)
	var/list/listening_dead = list()
	for(var/mob/M in player_list)
		if(M.stat == DEAD && ((M.client.prefs.toggles & CHAT_GHOSTEARS) || (get_dist(M, src) <= 7))&& client) // client is so that ghosts don't have to listen to mice
			listening_dead |= M

	listening -= listening_dead //so ghosts dont hear stuff twice

	var/rendered = compose_message(src, languages, message)
	for(var/atom/movable/AM in listening)
		AM.Hear(rendered, src, languages, message)

	for(var/mob/M in listening_dead)
		M.Hear(rendered, src, languages, message)

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in (listening + listening_dead))
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	spawn(0)
		flick_overlay(image('icons/mob/talk.dmi', src, "h[bubble_type][say_test(message)]",MOB_LAYER+1), speech_bubble_recipients, 30)

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
		return 0

	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "<span class='danger'>You cannot speak in IC (muted).</span>"
			return 0
		if(client.handle_spam_prevention(message,MUTE_IC))
			return 0

	return 1

/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno and ling channels
	if(!message)
		return 0

	if(sdisabilities & MUTE)
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
			if(2)
				var/msg = "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
				log_say("[mind.changeling.changelingID]/[src.key] : [message]")
				for(var/mob/M in mob_list)
					if(M.stat == DEAD && !istype(M, /mob/new_player))
						M << msg
					else
						switch(M.lingcheck())
							if(2)
								M << msg
							if(1)
								if(prob(30))
									M << "<i><font color=#800080>We can faintly sense another of our kind trying to communicate through the hivemind...</font></i>"
				return 1
			if(1)
				src << "<i><font color=#800080>Our senses have not evolved enough to be able to communicate this way...</font></i>"
				return 1
	return 0

/mob/living/proc/treat_message(message)
	if(getBrainLoss() >= 60)
		message = derpspeech(message, stuttering)

	if(stuttering)
		message = stutter(message)

	return message

/mob/living/proc/radio(message, message_mode, steps)
	switch(message_mode)
		if(MODE_R_HAND)
			if (r_hand)
				r_hand.talk_into(src, message)
			return ITALICS | REDUCE_RANGE

		if(MODE_L_HAND)
			if (l_hand)
				l_hand.talk_into(src, message)
			return ITALICS | REDUCE_RANGE

		if(MODE_INTERCOM)
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message)
			return ITALICS | REDUCE_RANGE

		if(MODE_BINARY)
			if(binarycheck())
				robot_talk(message)
			return ITALICS | REDUCE_RANGE //Does not return 0 since this is only reached by humans, not borgs or AIs.

		if(MODE_WHISPER)
			whisper(message)
			return NOPASS
	return 0

/mob/living/lingcheck() //Returns 1 if they are a changeling. Returns 2 if they are a changeling that can communicate through the hivemind
	if(mind && mind.changeling)
		if(mind.changeling.changeling_speak)
			return 2
		return 1
	return 0

/mob/living/say_quote()
	if (stuttering)
		return "stammers, \"[text]\""
	if (getBrainLoss() >= 60)
		return "gibbers, \"[text]\""
	return ..()
