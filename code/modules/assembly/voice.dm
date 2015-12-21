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
