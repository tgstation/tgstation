/*
* ## Lizards
*
* Green things that crawl around and eat bugs. Not to be confused with the human species lizardpersons, these are just small little fellas.
*/

/mob/living/basic/lizard
	name = "Lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	icon_gib = "lizard_gib"
	speak_emote = list("hisses")
	health = 10
	maxHealth = 10
	faction = list(FACTION_LIZARD)
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	melee_damage_lower = 1
	melee_damage_upper = 2
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_REPTILE
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	held_lh = 'icons/mob/inhands/animal_item_lefthand.dmi'
	held_rh = 'icons/mob/inhands/animal_item_righthand.dmi'
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/clothing/head/pets_head.dmi'
	ai_controller = /datum/ai_controller/basic_controller/lizard

	/// Typecache of things that we seek out to eat. Yummy.
	var/static/list/edibles = typecacheof(list(
		/mob/living/basic/butterfly,
		/mob/living/basic/cockroach,
	))

/mob/living/basic/lizard/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/pet_bonus, "sticks its tongue out contentedly!")
	AddElement(/datum/element/basic_eating, heal_amt = 5, food_types = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, edibles)

/datum/ai_controller/basic_controller/lizard
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/lizard,
	)

//Subtypes of lizards follow.

/// Lizards that can survive in space.
/mob/living/basic/lizard/space
	name = "Space Lizard"
	desc = "A cute tiny lizard with a tiny space helmet."
	icon_state = "lizard_space"
	icon_living = "lizard_space"
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 40

/// Janitor's pet lizard.
/mob/living/basic/lizard/wags_his_tail
	name = "Wags-His-Tail"
	desc = "The janitorial department's trusty pet lizard."

/// Another pet lizard for the janitor.
/mob/living/basic/lizard/eats_the_roaches
	name = "Eats-The-Roaches"
	desc = "The janitorial department's less trusty pet lizard."
