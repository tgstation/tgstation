//Uncategorized mobs

/mob/living/silicon/ai/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/glados, TTS_TRAIT_ROBOTIZE)

/obj/item/nullrod/scythe/talking/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/sylvanas)

/mob/living/basic/shade/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/kelthuzad)

/mob/living/simple_animal/bot/add_tts_component()
	return

/mob/living/basic/slime/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/chen)

/mob/living/carbon/human/species/monkey/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/sniper)

/mob/living/carbon/human/species/monkey/punpun/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/chen)

/mob/living/basic/bot/add_tts_component()
	return
