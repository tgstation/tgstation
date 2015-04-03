//bitflag #defines for radio returns.
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
#define MODE_CULTCHAT "cultchat"
#define MODE_ANCIENT "ancientchat"

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
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	if(!message) return

	if(silent)
		src << "\red You can't speak while silenced."
		return

	var/message_mode = get_message_mode(message)
	if (stat == DEAD) // Dead.
		say_dead(message)
		return
	if (stat) // Unconcious.
		if(message_mode == MODE_WHISPER) //Lets us say our last words.
			whisper(copytext(message, 3))
		return
	if(check_emote(message))
		return
	if(!can_speak_basic(message))
		return

	if(message_mode == MODE_HEADSET || message_mode == MODE_ROBOT)
		message = copytext(message, 2)
	else if(message_mode)
		message = copytext(message, 3)
	if(findtext(message, " ",1, 2))
		message = copytext(message, 2)

	if(handle_inherent_channels(message, message_mode))
		return
	if(!can_speak_vocal(message))
		return

	var/message_range = 7
	var/raw_message = message
	message = treat_message(message)
	var/radio_return = radio(message, message_mode, raw_message)
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
	var/list/listeners = get_hearers_in_view(message_range, source) | observers

	var/rendered = compose_message(src, languages, message)

	for (var/atom/movable/listener in listeners)
		listener.Hear(rendered, src, languages, message)

	send_speech_bubble(message, bubble_type, listeners)

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
	if(copytext(message, 1, 2) == "*")
		emote(copytext(message, 2))
		return 1


/mob/living/proc/get_message_mode(message)
	if(copytext(message, 1, 2) == ";")
		return MODE_HEADSET
	else if(length(message) > 2)
		return department_radio_keys[copytext(message, 1, 3)]

/mob/living/proc/handle_inherent_channels(message, message_mode)
	switch(message_mode)
		if(MODE_CHANGELING)
			if(lingcheck())
				log_say("[mind.changeling.changelingID]/[src.key] : [message]")
				var/themessage = text("<i><font color=#800080><b>[]:</b> []</font></i>",mind.changeling.changelingID,message)
				for(var/mob/M in player_list)
					if(M.lingcheck() || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
						handle_render(M,themessage,src)
				return 1
		if(MODE_CULTCHAT)
			if(construct_chat_check(1)) /*sending check for humins*/
				log_say("Cult channel: [src.name]/[src.key] : [message]")
				var/themessage = text("<span class='sinister'><b>[]:</b> []</span>",src.name,message)
				for(var/mob/M in player_list)
					if(M.construct_chat_check(2) /*receiving check*/ || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
						handle_render(M,themessage,src)
				return 1
		if(MODE_ANCIENT)
			if(isMoMMI(src)) return 0 //Noice try, I really do appreciate the effort
			var/list/stone = search_contents_for(/obj/item/commstone)
			if(stone.len)
				var/obj/item/commstone/commstone = stone[1]
				if(commstone.commdevice)
					var/list/stones = commstone.commdevice.get_active_stones()
					var/themessage = text("<span class='ancient'>Ancient communication, <b>[]:</b> []</span>",src.name,message)
					log_say("Ancient chat: [src.name]/[src.key] : [message]")
					for(var/thestone in stones)
						var/mob/M = find_holder_of_type(thestone,/mob)
						handle_render(M,themessage,src)
					for(var/M in dead_mob_list)
						if(!istype(M,/mob/new_player))
							handle_render(M,themessage,src)
					return 1
	return 0

/mob/living/proc/treat_message(message, genesay = 0)
	if(getBrainLoss() >= 60)
		message = derpspeech(message, stuttering)

	if(stuttering)
		message = stutter(message)

	return message

/mob/living/proc/radio(message, message_mode, raw_message)
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
			whisper(raw_message)
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
		return "stammers, \"[text]\""
	if (getBrainLoss() >= 60)
		return "gibbers, \"[text]\""
	return ..()

/mob/living/proc/send_speech_bubble(var/message,var/bubble_type, var/list/hearers)
	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in hearers)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	spawn(0)
		flick_overlay(image('icons/mob/talk.dmi', src, "h[bubble_type][say_test(message)]",MOB_LAYER+1), speech_bubble_recipients, 30)

/mob/proc/addSpeechBubble(image/speech_bubble)
	if(client)
		client.images += speech_bubble
		spawn(30)
			if(client) client.images -= speech_bubble

/obj/effect/speech_bubble
	var/mob/parent

