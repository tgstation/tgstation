//Uncategorized mobs

/mob/living/silicon/ai/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/glados, list(/datum/singleton/sound_effect/robot))

/obj/item/nullrod/scythe/talking/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/sylvanas)

/mob/living/basic/shade/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/kelthuzad)

/mob/living/basic/bot/add_tts_component()
	return

/mob/living/basic/slime/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/chen)

/mob/living/carbon/human/species/monkey/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/sniper)

/mob/living/carbon/human/species/monkey/punpun/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/chen)

/mob/living/basic/bot/add_tts_component()
	return
