/mob/living/basic/axolotl
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
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_AQUATIC
	gold_core_spawnable = FRIENDLY_SPAWN

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"

	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	held_lh = 'icons/mob/inhands/animal_item_lefthand.dmi'
	held_rh = 'icons/mob/inhands/animal_item_righthand.dmi'
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/clothing/head/pets_head.dmi'

	ai_controller = /datum/ai_controller/basic_controller/axolotl

/mob/living/basic/axolotl/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_NODROWN, TRAIT_SWIMMER, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_AXOLOTL, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/datum/ai_controller/basic_controller/axolotl
	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
