<<<<<<< HEAD
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
	var/global/list/modes = list("inclusive",
								 "exclusive",
								 "recognizer",
								 "voice sensor")

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
		if(1)
			recorded = raw_message
			listening = 0
			say("Activation message is '[recorded]'.")
		if(2)
			recorded = raw_message
			listening = 0
			say("Activation message is '[recorded]'.")
		if(3)
			recorded = speaker.GetVoice()
			listening = 0
			say("Your voice pattern is saved.")
		if(4)
			if(length(raw_message))
				spawn(10)
					pulse(0)

/obj/item/device/assembly/voice/proc/check_activation(atom/movable/speaker, raw_message)
	. = 0
	switch(mode)
		if(1)
			if(findtextEx(raw_message, recorded))
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
		user << "You set [src] into a [modes[mode]] mode."
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
=======
/obj/item/device/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	starting_materials = list(MAT_IRON = 500, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=1"
	flags = HEAR

	var/listening = 0
	var/recorded = "" //the activation message
	var/muted = 0 //If 1, the voice analyzer won't say ANYTHING ever

	accessible_values = list("Recording activation message" = "listening;number",\
		"Activation message" = "recorded;text",\
		"Muted" = "muted;num")

/obj/item/device/assembly/voice/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(!speech.speaker || speech.speaker == src)
		return
	if(listening && !speech.frequency)
		recorded = speech.message
		listening = 0
		say("Activation message is '[html_encode(speech.message)]'.")
	else
		if(findtext(speech.message, recorded))
			if(istype(speech.speaker, /obj/item/device/assembly) || istype(speech.speaker, /obj/item/device/assembly_frame))
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 25, 1)
			else
				pulse(0)

/obj/item/device/assembly/voice/attackby(obj/item/W, mob/user)
	if(ismultitool(W))
		muted = !muted

		if(muted)
			to_chat(user, "<span class='info'>You mute \the [src]'s speaker. This should keep it quiet.</span>")
		else
			to_chat(user, "<span class='info'>You unmute \the [src]'s speaker. It will now talk again.</span>")

	return ..()

/obj/item/device/assembly/voice/activate()
	if(secured)
		if(!holder)
			listening = !listening
			say("[listening ? "Now" : "No longer"] recording input.")

/obj/item/device/assembly/voice/attack_self(mob/user)
	if(!user)	return 0
	activate()
	return 1

/obj/item/device/assembly/voice/say_quote(text)
	return "beeps, [text]"

/obj/item/device/assembly/voice/toggle_secure()
	. = ..()
	listening = 0

/obj/item/device/assembly/voice/say()
	if(muted) return //Don't say anything if muted

	. = ..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
