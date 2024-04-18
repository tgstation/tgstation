// Fallback values for TTS voices

/mob/living/add_tts_component()
	AddComponent(/datum/component/tts_component)

/mob/living/basic/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/angel)

/mob/living/simple_animal/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/angel)

/mob/living/silicon/add_tts_component()
	AddComponent(/datum/component/tts_component, null, TTS_TRAIT_ROBOTIZE)

/mob/living/carbon/add_tts_component()
	var/random_tts_seed_key = SStts220.pick_tts_seed_by_gender(gender)
	var/datum/tts_seed/random_tts_seed = SStts220.tts_seeds[random_tts_seed_key]
	dna.tts_seed_dna = random_tts_seed
	AddComponent(/datum/component/tts_component, random_tts_seed)
