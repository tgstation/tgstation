/mob/living/basic/pet/fox
	death_sound = 'modular_bandastation/mobs/sound/fox_yelp.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/fox_yelp.ogg')

/mob/living/basic/pet/fox/fennec
	name = "фенек"
	real_name = "фенек"
	desc = "Миниатюрная лисичка с очень большими ушами. Фенек, фенек, зачем тебе такие большие уши? Чтобы избегать ужасов дормов?"
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "fennec"
	icon_living = "fennec"
	icon_dead = "fennec_dead"
	icon_resting = "fennec_rest"
	see_in_dark = 10
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/pet/fox/forest
	name = "лесной лис"
	real_name = "лесной лис"
	desc = "Лесная лисица. Может укусить."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	icon_resting = "fox_rest"
	melee_damage_type = BRUTE
	melee_damage_lower = 6
	melee_damage_upper = 12

	held_state = "fox"
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'
