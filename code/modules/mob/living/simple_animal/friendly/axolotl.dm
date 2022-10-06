/mob/living/simple_animal/axolotl
	name = "axolotl"
	desc = "Quite the colorful amphibian!"
	icon_state = "axolotl"
	icon_living = "axolotl"
	icon_dead = "axolotl_dead"
	maxHealth = 10
	health = 10
	attack_verb_continuous = "nibbles" //their teeth are just for gripping food, not used for self defense nor even chewing
	attack_verb_simple = "nibble"
	butcher_results = list(/obj/item/food/nugget = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	worn_slot_flags = ITEM_SLOT_HEAD
	held_lh = 'icons/mob/inhands/animal_item_lefthand.dmi'
	held_rh = 'icons/mob/inhands/animal_item_righthand.dmi'
	head_icon = 'icons/mob/clothing/head/animal_item_head.dmi'

/mob/living/simple_animal/axolotl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
