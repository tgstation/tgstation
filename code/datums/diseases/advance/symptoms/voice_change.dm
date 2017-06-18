/*
//////////////////////////////////////

Voice Change

	Noticeable.
	Lowers resistance.
	Decreases stage speed.
	Increased transmittable.
	Fatal Level.

Bonus
	Changes the voice of the affected mob. Causing confusion in communication.

//////////////////////////////////////
*/

/datum/symptom/voice_change

	name = "Voice Change"
	stealth = -1
	resistance = -2
	stage_speed = -2
	transmittable = 2
	level = 6
	severity = 2
	base_message_chance = 100
	symptom_delay_min = 60
	symptom_delay_max = 120
	var/scramble_language = FALSE
	var/datum/language/current_language
	var/datum/language_holder/original_language

/datum/symptom/voice_change/Start(datum/disease/advance/A)
	..()
	if(A.properties["stealth"] >= 3)
		suppress_warning = TRUE
	if(A.properties["stage_rate"] >= 7) //faster change of voice
		base_message_chance = 25
		symptom_delay_min = 25
		symptom_delay_max = 85
	if(A.properties["transmittable"] >= 14) //random language
		scramble_language = TRUE
		var/mob/living/M = A.affected_mob
		var/datum/language_holder/mob_language = M.get_language_holder()
		original_language = mob_language.copy()

/datum/symptom/voice_change/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("Your throat hurts.", "You clear your throat.")]</span>")
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.SetSpecialVoice(H.dna.species.random_name(H.gender))
				if(scramble_language)
					H.remove_language(current_language)
					current_language = pick(subtypesof(/datum/language) - /datum/language/common)
					H.grant_language(current_language)
					var/datum/language_holder/mob_language = H.get_language_holder()
					mob_language.only_speaks_language = current_language

/datum/symptom/voice_change/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.UnsetSpecialVoice()
	if(scramble_language)
		var/mob/living/M = A.affected_mob
		M.copy_known_languages_from(original_language, TRUE)
		current_language = null
		QDEL_NULL(original_language)
