/mob/living/basic/mothroach/wrynroach
	name = "wrynroach"
	desc = "Милейшее создание, напоминающее не то пчелу, не то таракана. Такое пушистое, и такое глупенькое."
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "wrynroach"
	icon_living = "wrynroach"
	icon_dead = "wrynroach_dead"
	held_state = "wrynroach"
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/mothroach/wrynroach/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/lillia)
