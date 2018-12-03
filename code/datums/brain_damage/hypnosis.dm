/datum/brain_trauma/hypnosis
	name = "Hypnosis"
	desc = "Patient's unconscious is completely enthralled by a word or sentence, focusing their thoughts and actions on it."
	scan_desc = "looping thought pattern"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_SURGERY

	var/hypnotic_phrase = ""

/datum/brain_trauma/hypnosis/New(phrase)
	if(!phrase)
		qdel(src)
	hypnotic_phrase = phrase
	..()

/datum/brain_trauma/hypnosis/on_gain()
	message_admins("[ADMIN_LOOKUPFLW(owner)] was hypnotized with the phrase '[hypnotic_phrase]'.")
	log_game("[key_name(owner)] was hypnotized with the phrase '[hypnotic_phrase]'.")
	to_chat(owner, "<span class='reallybig hypnophrase'>[hypnotic_phrase]</span>")
	to_chat(owner, "<span class='notice'>[pick("You feel your thoughts focusing on this phrase... you can't seem to get it out of your head.",\
												"Your head hurts, but this is all you can think of. It must be vitally important.",\
												"You feel a part of your mind repeating this over and over. You need to follow these words.",\
												"Something about this sounds... right, for some reason. You feel like you should follow these words.",\
												"These words keep echoing in your mind. You find yourself completely fascinated by them.")]</span>")
	to_chat(owner, "<span class='boldwarning'>You've been hypnotized by this sentence. You must follow these words. If it isn't a clear order, you can freely interpret how to do so,\
										as long as you act like the words are your highest priority.</span>")
	..()

/datum/brain_trauma/hypnosis/on_lose()
	message_admins("[ADMIN_LOOKUPFLW(owner)] is no longer hypnotized with the phrase '[hypnotic_phrase]'.")
	log_game("[key_name(owner)] is no longer hypnotized with the phrase '[hypnotic_phrase]'.")
	to_chat(owner, "<span class='userdanger'>You suddenly snap out of your hypnosis. The phrase '[hypnotic_phrase]' no longer feels important to you.</span>")
	..()

/datum/brain_trauma/hypnosis/on_life()
	..()
	if(prob(2))
		switch(rand(1,2))
			if(1)
				to_chat(owner, "<i>...[lowertext(hypnotic_phrase)]...</i>")
			if(2)
				new /datum/hallucination/chat(owner, TRUE, FALSE, "<span class='hypnophrase'>[hypnotic_phrase]</span>")

/datum/brain_trauma/hypnosis/on_hear(message, speaker, message_language, raw_message, radio_freq)
	var/regex/target_phrase = new("(\\b[hypnotic_phrase]\\b)","ig")
	message = target_phrase.Replace(message, "<span class='hypnophrase'>$1</span>")
	return message