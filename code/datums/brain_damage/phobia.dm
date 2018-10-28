/datum/brain_trauma/mild/phobia
	name = "Phobia"
	desc = "Patient is unreasonably afraid of something."
	scan_desc = "phobia"
	gain_text = ""
	lose_text = ""
	var/phobia_type
	var/next_check = 0
	var/next_scare = 0
	var/list/trigger_words
	//instead of cycling every atom, only cycle the relevant types
	var/list/trigger_mobs
	var/list/trigger_objs //also checked in mob equipment
	var/list/trigger_turfs
	var/list/trigger_species

/datum/brain_trauma/mild/phobia/New(specific_type)
	phobia_type = specific_type
	if(!phobia_type)
		phobia_type = pick(SStraumas.phobia_types)

	gain_text = "<span class='warning'>You start finding [phobia_type] very unnerving...</span>"
	lose_text = "<span class='notice'>You no longer feel afraid of [phobia_type].</span>"
	scan_desc += " of [phobia_type]"
	trigger_words = SStraumas.phobia_words[phobia_type]
	trigger_mobs = SStraumas.phobia_mobs[phobia_type]
	trigger_objs = SStraumas.phobia_objs[phobia_type]
	trigger_turfs = SStraumas.phobia_turfs[phobia_type]
	trigger_species = SStraumas.phobia_species[phobia_type]
	..()

/datum/brain_trauma/mild/phobia/on_life()
	..()
	if(owner.has_trait(TRAIT_FEARLESS))
		return
	if(is_blind(owner))
		return
	if(world.time > next_check && world.time > next_scare)
		next_check = world.time + 50
		var/list/seen_atoms = view(7, owner)

		if(LAZYLEN(trigger_objs))
			for(var/obj/O in seen_atoms)
				if(is_type_in_typecache(O, trigger_objs))
					freak_out(O)
					return

		if(LAZYLEN(trigger_turfs))
			for(var/turf/T in seen_atoms)
				if(is_type_in_typecache(T, trigger_turfs))
					freak_out(T)
					return

		if(LAZYLEN(trigger_mobs) || LAZYLEN(trigger_objs))
			for(var/mob/M in seen_atoms)
				if(is_type_in_typecache(M, trigger_mobs))
					freak_out(M)
					return

				else if(ishuman(M)) //check their equipment for trigger items
					var/mob/living/carbon/human/H = M

					if(LAZYLEN(trigger_species) && H.dna && H.dna.species && is_type_in_typecache(H.dna.species, trigger_species))
						freak_out(H)

					for(var/X in H.get_all_slots() | H.held_items)
						var/obj/I = X
						if(!QDELETED(I) && is_type_in_typecache(I, trigger_objs))
							freak_out(I)
							return

/datum/brain_trauma/mild/phobia/on_hear(message, speaker, message_language, raw_message, radio_freq)
	if(!owner.can_hear() || world.time < next_scare) //words can't trigger you if you can't hear them *taps head*
		return message
	if(owner.has_trait(TRAIT_FEARLESS))
		return message
	for(var/word in trigger_words)
		var/regex/reg = regex("(\\b|\\A)[REGEX_QUOTE(word)]'?s*(\\b|\\Z)", "i")

		if(findtext(raw_message, reg))
			addtimer(CALLBACK(src, .proc/freak_out, null, word), 10) //to react AFTER the chat message
			message = reg.Replace(message, "<span class='phobia'>$1</span>")
			break
	return message

/datum/brain_trauma/mild/phobia/on_say(message)
	if(owner.has_trait(TRAIT_FEARLESS))
		return message
	for(var/word in trigger_words)
		var/regex/reg = regex("(\\b|\\A)[REGEX_QUOTE(word)]'?s*(\\b|\\Z)", "i")

		if(findtext(message, reg))
			to_chat(owner, "<span class='warning'>You can't bring yourself to say the word \"<span class='phobia'>[word]</span>\"!</span>")
			return ""
	return message

/datum/brain_trauma/mild/phobia/proc/freak_out(atom/reason, trigger_word)
	next_scare = world.time + 120
	if(owner.stat == DEAD)
		return
	var/message = pick("spooks you to the bone", "shakes you up", "terrifies you", "sends you into a panic", "sends chills down your spine")
	if(reason)
		to_chat(owner, "<span class='userdanger'>Seeing [reason] [message]!</span>")
	else if(trigger_word)
		to_chat(owner, "<span class='userdanger'>Hearing \"[trigger_word]\" [message]!</span>")
	else
		to_chat(owner, "<span class='userdanger'>Something [message]!</span>")
	var/reaction = rand(1,4)
	switch(reaction)
		if(1)
			to_chat(owner, "<span class='warning'>You are paralyzed with fear!</span>")
			owner.Stun(70)
			owner.Jitter(8)
		if(2)
			owner.emote("scream")
			owner.Jitter(5)
			owner.say("AAAAH!!", forced = "phobia")
			if(reason)
				owner.pointed(reason)
		if(3)
			to_chat(owner, "<span class='warning'>You shut your eyes in terror!</span>")
			owner.Jitter(5)
			owner.blind_eyes(10)
		if(4)
			owner.dizziness += 10
			owner.confused += 10
			owner.Jitter(10)
			owner.stuttering += 10
