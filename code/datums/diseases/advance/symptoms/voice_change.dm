/*Voice Change
 * Slight stealth reduction
 * Reduces resistance
 * Reduces stage speed
 * Increases transmissibility
 * Fatal level
 * Bonus: Changes the voice of the affected mob. Causing confusion in communication.
*/

/datum/symptom/voice_change
	name = "Voice Change"
	desc = "The virus alters the pitch and tone of the host's vocal cords, changing how their voice sounds."
	illness = "Mime Crisis"
	stealth = -1
	resistance = -2
	stage_speed = -2
	transmittable = 2
	level = 6
	severity = 2
	base_message_chance = 100
	symptom_delay_min = 60
	symptom_delay_max = 120
	required_organ = ORGAN_SLOT_TONGUE
	threshold_descs = list(
		"Transmission 14" = "The host's language center of the brain is damaged, leading to complete inability to speak or understand any language.",
		"Stage Speed 7" = "Changes voice more often.",
		"Stealth 3" = "The symptom remains hidden until active."
	)
	var/scramble_language = FALSE
	var/datum/language/current_language

/datum/symptom/voice_change/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 3)
		suppress_warning = TRUE
	if(A.totalStageSpeed() >= 7) //faster change of voice
		base_message_chance = 25
		symptom_delay_min = 25
		symptom_delay_max = 85
	if(A.totalTransmittable() >= 14) //random language
		scramble_language = TRUE

/datum/symptom/voice_change/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("Your throat hurts.", "You clear your throat.")]"))
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.override_voice = H.generate_random_mob_name()
				if(scramble_language && !current_language) // Last part prevents rerolling language with small amounts of cure.
					current_language = pick(subtypesof(/datum/language) - /datum/language/common)
					H.add_blocked_language(subtypesof(/datum/language) - current_language, source = LANGUAGE_VOICECHANGE)
					H.grant_language(current_language, source = LANGUAGE_VOICECHANGE)

/datum/symptom/voice_change/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.override_voice = ""
	if(scramble_language)
		A.affected_mob.remove_blocked_language(subtypesof(/datum/language), source = LANGUAGE_VOICECHANGE)
		A.affected_mob.remove_all_languages(LANGUAGE_VOICECHANGE) // In case someone managed to get more than one anyway.
