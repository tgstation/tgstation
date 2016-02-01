#define	MODE1			"inclusive"
#define	MODE2			"exclusive"
#define	MODE3			"recognizer"
#define	MODE4			"voice sensor"
#define INCLUSIVE		1
#define EXCLUSIVE		2
#define RECOGNIZER		3
#define VOICE_SENSOR	4


/obj/item/device/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1"
	flags = HEAR
	attachable = 1
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	var/listening = 0
	var/recorded = "" //the activation message
	var/mode = INCLUSIVE
	var/global/list/modes = list(MODE1,
								 MODE2,
								 MODE3,
								 MODE4)

/obj/item/device/assembly/voice/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(speaker == src)
		return

	if(listening && !radio_freq)
		record_speech(speaker, raw_message)
	else
		if(check_activation(speaker, raw_message))
			spawn(10)
				pulse(0)

/obj/item/device/assembly/voice/proc/record_speech(atom/movable/speaker, raw_message)
	switch(mode)
		if(INCLUSIVE)
			recorded = raw_message
			listening = 0
			say("Activation message is '[recorded]'.")
		if(EXCLUSIVE)
			recorded = raw_message
			listening = 0
			say("Activation message is '[recorded]'.")
		if(RECOGNIZER)
			recorded = speaker.GetVoice()
			listening = 0
			say("Your voice pattern is saved.")
		if(VOICE_SENSOR)
			if(length(raw_message))
				spawn(10)
					pulse(0)

/obj/item/device/assembly/voice/proc/check_activation(atom/movable/speaker, raw_message)
	. = 0
	switch(mode)
		if(INCLUSIVE)
			if(findtextEx(raw_message, recorded))
				. = 1
		if(EXCLUSIVE)
			if(raw_message == recorded)
				. = 1
		if(RECOGNIZER)
			if(speaker.GetVoice() == recorded)
				. = 1
		if(VOICE_SENSOR)
			if(length(raw_message))
				. = 1

/obj/item/device/assembly/voice/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		mode %= modes.len
		mode++
		user << "You set [src] into a [modes[mode]] mode."
		listening = 0
		recorded = ""

/obj/item/device/assembly/voice/activate()
	if(secured)
		if(!holder)
			listening = !listening
			say("[listening ? "Now" : "No longer"] recording input.")

/obj/item/device/assembly/voice/attack_self(mob/user)
	if(!user)
		return 0
	activate()
	return 1

/obj/item/device/assembly/voice/toggle_secure()
	. = ..()
	listening = 0

#undef	MODE1
#undef	MODE2
#undef	MODE3
#undef	MODE4
#undef 	INCLUSIVE
#undef 	EXCLUSIVE
#undef	RECOGNIZER
#undef 	VOICE_SENSOR