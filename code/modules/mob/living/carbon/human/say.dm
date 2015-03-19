/mob/living/carbon/human/say_quote(input, spans)
	if(!input)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	verb_say = dna.species.say_mod
	if(src.slurring)
		input = attach_spans(input, spans)
		return "slurs, \"[input]\""

	return ..()

/mob/living/carbon/human/treat_message(message)
	if(dna)
		message = dna.species.handle_speech(message,src)
	if(viruses.len)
		for(var/datum/disease/pierrot_throat/D in viruses)
			var/list/temp_message = text2list(message, " ") //List each word in the message
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++) //Create a second list for excluding words down the line
				pick_list += i
			for(var/i=1, ((i <= D.stage) && (i <= temp_message.len)), i++) //Loop for each stage of the disease or until we run out of words
				if(prob(3 * D.stage)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
					var/H = pick(pick_list)
					if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
					temp_message[H] = "HONK"
					pick_list -= H //Make sure that you dont HONK the same word twice
				message = list2text(temp_message, " ")
	message = ..(message)
	if(dna)
		message = dna.mutations_say_mods(message)
	return message

/mob/living/carbon/human/get_spans()
	return ..() | dna.mutations_get_spans()

/mob/living/carbon/human/GetVoice()
	if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = wear_mask
		if(V.vchange && wear_id)
			var/obj/item/weapon/card/id/idcard = wear_id.GetID()
			if(istype(idcard))
				return idcard.registered_name
			else
				return real_name
		else
			return real_name
	if(mind && mind.changeling && mind.changeling.mimicing)
		return mind.changeling.mimicing
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/IsVocal()
	if(mind)
		return !mind.miming
	return 1

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

/mob/living/carbon/human/binarycheck()
	if(ears)
		var/obj/item/device/radio/headset/dongle = ears
		if(!istype(dongle)) return 0
		if(dongle.translate_binary) return 1

/mob/living/carbon/human/radio(message, message_mode, list/spans)
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			if (ears)
				ears.talk_into(src, message, , spans)
			return ITALICS | REDUCE_RANGE

		if(MODE_SECURE_HEADSET)
			if (ears)
				ears.talk_into(src, message, 1, spans)
			return ITALICS | REDUCE_RANGE

		if(MODE_DEPARTMENT)
			if (ears)
				ears.talk_into(src, message, message_mode, spans)
			return ITALICS | REDUCE_RANGE

	if(message_mode in radiochannels)
		if(ears)
			ears.talk_into(src, message, message_mode, spans)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"

/mob/living/carbon/human/proc/forcesay(list/append)
	var/temp = winget(client, "input", "text")
	say(temp)
	winset(client, "input", "text=[null]")
