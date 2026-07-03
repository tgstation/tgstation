/mob/living/basic/cockroach
	death_sound = 'modular_bandastation/mobs/sound/crack_death2.ogg'

/mob/living/basic/parrot
	held_state = "parrot"
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_SMALL
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/headslug
	attack_verb_continuous = "грызёт"
	attack_verb_simple = "грызёт"

	held_state = "headslug"
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/walrus // seal?
	name = "морж"
	desc = "Любит купаться в холодных водах на Крещение."
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "walrus"
	icon_living = "walrus"
	icon_dead = "walrus_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("мычит","вызывающе мычит","протяженно мычит")
	speed = 3
	butcher_results = list(/obj/item/food/meat/slab/grassfed = 10)
	health = 80
	maxHealth = 80
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	death_sound = 'modular_bandastation/mobs/sound/seal_death.ogg'
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL

	ai_controller = /datum/ai_controller/basic_controller/base_animal

// TODO: /mob/living/basic/clown/goblin

