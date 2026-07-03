/mob/living/basic/crab
	death_sound = 'modular_bandastation/mobs/sound/crack_death2.ogg'
	mob_size = MOB_SIZE_SMALL
	response_help_continuous = "гладит"
	response_help_simple = "гладит"
	response_disarm_continuous = "отталкивает"
	response_disarm_simple = "отталкивает"
	response_harm_continuous = "сдавливает"
	response_harm_simple   = "щипает"

	held_state = "crab"
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_SMALL
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/crab/old
	name = "старый краб"
	desc = "Когда-то такие населяли моря и аквариумы."
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "crab_old"
	icon_living = "crab_old"
	icon_dead = "crab_old_dead"
	health = 35
	maxHealth = 35

/mob/living/basic/crab/sea
	name = "морской краб"
	desc = "Кто проживает на дне океана?"
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "bluecrab"
	icon_living = "bluecrab"
	icon_dead = "bluecrab_dead"
	response_help_continuous = "гладит"
	response_help_simple = "гладит"
	response_disarm_continuous = "отталкивает"
	response_disarm_simple = "отталкивает"
	response_harm_continuous = "сдавливает"
	response_harm_simple   = "щипает"
	health = 50
	maxHealth = 50
	butcher_results = list(/obj/item/food/meat = 3)

/mob/living/basic/crab/royal
	name = "королевский краб"
	desc = "Величественный королевский краб."
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "royalcrab"
	icon_living = "royalcrab"
	icon_dead = "royalcrab_dead"
	response_help_continuous = "с уважением гладит"
	response_help_simple = "с уважением гладит"
	response_disarm_continuous = "с уважением отталкивает"
	response_disarm_simple = "с уважением отталкивает"
	response_harm_continuous = "презрительно щипает"
	response_harm_simple   = "щипает без уважения"
	health = 50
	maxHealth = 50
	butcher_results = list(/obj/item/food/meat = 5)

/mob/living/basic/crab/evil
	held_state = "evilcrab"
