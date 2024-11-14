/*
* ## Killer Tomatoes
*
* Side effect from when you try to play God through genetic engineering. Feisty fuckers that want to eat you. Dangerous.
*/

/mob/living/basic/killer_tomato
	name = "Killer Tomato"
	desc = "It's a horrifyingly enormous beef tomato, and it's packing extra beef!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	gender = NEUTER
	speed = 1 // if you wanna touch this, keep in mind we want to incentivize people growing really good botany plants in order to make these buggers faster.
	maxHealth = 30
	health = 30
	butcher_results = list(/obj/item/food/meat/slab/killertomato = 2)
	response_help_continuous = "prods"
	response_help_simple = "prod"
	response_disarm_continuous = "pushes aside"
	response_disarm_simple = "push aside"
	response_harm_continuous = "smacks"
	response_harm_simple = "smack"
	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	faction = list(FACTION_PLANTS)

	habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = T0C - 130
	maximum_survivable_temperature = T0C + 230
	gold_core_spawnable = HOSTILE_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/killer_tomato

/mob/living/basic/killer_tomato/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/datum/ai_controller/basic_controller/killer_tomato
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/killer_tomato,
	)
