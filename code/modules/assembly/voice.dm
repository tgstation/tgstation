/obj/item/device/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1;engineering=1"
	flags = HEAR
	attachable = 1
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	var/listening = 0
	var/recorded = "" //the activation message
	var/mode = 1
	var/static/list/modes = list("inclusive",
								 "exclusive",
								 "recognizer",
								 "voice sensor")

/obj/item/device/assembly/voice/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Use a multitool to swap between \"inclusive\", \"exclusive\", \"recognizer\", and \"voice sensor\" mode.</span>")

/obj/item/device/assembly/voice/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(speaker == src)
		return

	if(listening && !radio_freq)
		record_speech(speaker, raw_message, message_language)
	else
		if(check_activation(speaker, raw_message))
			addtimer(CALLBACK(src, .proc/pulse, 0), 10)

/obj/item/device/assembly/voice/proc/record_speech(atom/movable/speaker, raw_message, datum/language/message_language)
	switch(mode)
		if(1)
			recorded = raw_message
			listening = 0
			say("Activation message is '[recorded]'.", message_language)
		if(2)
			recorded = raw_message
			listening = 0
			say("Activation message is '[recorded]'.", message_language)
		if(3)
			recorded = speaker.GetVoice()
			listening = 0
			say("Your voice pattern is saved.", message_language)
		if(4)
			if(length(raw_message))
				addtimer(CALLBACK(src, .proc/pulse, 0), 10)

/obj/item/device/assembly/voice/proc/check_activation(atom/movable/speaker, raw_message)
	. = 0
	switch(mode)
		if(1)
			if(findtext(raw_message, recorded))
				. = 1
		if(2)
			if(raw_message == recorded)
				. = 1
		if(3)
			if(speaker.GetVoice() == recorded)
				. = 1
		if(4)
			if(length(raw_message))
				. = 1

/obj/item/device/assembly/voice/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		mode %= modes.len
		mode++
		to_chat(user, "You set [src] into a [modes[mode]] mode.")
		listening = 0
		recorded = ""
	else
		return ..()

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
