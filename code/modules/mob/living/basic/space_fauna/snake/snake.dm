
/mob/living/basic/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")

	health = 20
	maxHealth = 20
	melee_damage_lower = 5
	melee_damage_upper = 6
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	//how many units of venom are injected in target per attack
	var/venom_dose = 4

	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "steps on"
	response_harm_simple = "step on"

	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL

	faction = list(FACTION_HOSTILE)
	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_REPTILE
	gold_core_spawnable = FRIENDLY_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/snake

	/// List of stuff (mice) that we want to eat
	var/static/list/edibles = list(
		/mob/living/basic/mouse,
		/obj/item/food/deadmouse,
	)

/mob/living/basic/snake/Initialize(mapload, special_reagent)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SNAKE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

	AddElement(/datum/element/basic_eating, heal_amt = 2, food_types = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

	AddComponent(\
		/datum/component/tameable,\
		food_types = list(/obj/item/food/deadmouse),\
		tame_chance = 75,\
		bonus_tame_chance = 10,\
	) // snakes are really fond of food, especially in the cold darkness of space :)

	if(isnull(special_reagent))
		special_reagent = /datum/reagent/toxin

	AddElement(/datum/element/venomous, special_reagent, venom_dose)

/mob/living/basic/snake/befriend(mob/living/new_friend)
	. = ..()
	if(!.)
		return
	visible_message("[src] hisses happily as it seems to bond with [new_friend].")

/// Snakes are primarily concerned with getting those tasty, tasty mice, but aren't afraid to strike back at those who attack them
/datum/ai_controller/basic_controller/snake
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/snake,
	)
