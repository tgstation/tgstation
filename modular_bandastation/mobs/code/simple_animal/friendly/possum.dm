/mob/living/basic/possum
	name = "опоссум"
	desc = "Небольшое сумчатое животное, питающееся падалью. \
	Ранее бывшее эндемиком Америки, но теперь по непонятной причине встречающееся по всему заселённому космосу. \
	Никто до конца не знает, как они перемещаются в столь отдалённые места. Среди основных теорий — контрабанда, \
	безбилетный провоз грузов, размножение спор грибов, телепортация или неизвестные квантовые эффекты."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "possum"
	icon_living = "possum"
	icon_dead = "possum_dead"
	icon_resting = "possum_sleep"
	var/icon_harm = "possum_aaa"
	speak_emote = list("Хммм", "Хиссс")
	maxHealth = 30
	health = 30
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE
	blood_volume = BLOOD_VOLUME_NORMAL
	melee_damage_type = STAMINA
	melee_damage_lower = 3
	melee_damage_upper = 8
	attack_verb_continuous = "грызет"
	attack_verb_simple = "кусает"
	attack_sound = 'sound/items/weapons/bite.ogg'
	see_in_dark = 5
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/food/meat = 2)

	held_state = "possum"
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_NORMAL
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

	ai_controller = /datum/ai_controller/basic_controller/possum

/mob/living/basic/possum/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	add_traits(list(TRAIT_FENCE_CLIMBER), INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)

/mob/living/basic/possum/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(user.combat_mode)
		icon_state = icon_harm
	else
		icon_state = initial(icon_state)
	. = ..()

/mob/living/basic/possum/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(user.combat_mode)
		icon_state = icon_harm
	else
		icon_state = initial(icon_state)
	. = ..()
