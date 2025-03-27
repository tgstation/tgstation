/mob/living/basic/snake/banded
	name = "banded snake"
	desc = "A colourful stripy snake. It's either a harmless asteroid kingsnake or a highly venomous and aggressive nebula viper. There's a mnemonic to tell them apart, you just need to look at the colours and examine them closely..."
	icon_state = "bandedsnake"
	icon_living = "bandedsnake"
	icon_dead = "bandedsnake_dead"
	venom_dose = 2
	var/poison_reagent = /datum/reagent/toxin/cyanide
	health = 30
	maxHealth = 30
	melee_damage_upper = 10
	gold_core_spawnable = HOSTILE_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/snake/banded
	var/list/rhymes_dangerous = list(
		"Yellow on red, it'll kill you dead.",
		"Black on yellow, nasty little fellow.",
		"Yellow on black, stay the hell back.",
		"Yellow on black, it's bound to attack.",
		)
	var/list/rhymes_harmless = list(
		"Red on yellow, friendly old fellow.",
		"Yellow on red, it's pretty good. Wait, that doesn't rhyme...",
		"Yellow on black, will not attack.",
		"Black on yellow, chill and mellow.",
		)

/mob/living/basic/snake/banded/Initialize(mapload, special_reagent)
	special_reagent = src.poison_reagent
	AddComponent(/datum/component/swarming)
	return ..()

/mob/living/basic/snake/banded/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You examine the bands on the snake very closely...</i>")
	if(src.poison_reagent == (/datum/reagent/consumable/milk))
		. += span_info("[pick(src.rhymes_harmless)]")
		. += span_notice("This snake is not dangerous!")
	else
		. += span_info("[pick(src.rhymes_dangerous)]")
		. += span_notice("This snake is dangerous!")
	return .

/datum/ai_controller/basic_controller/snake/banded
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/snake,
	)


/mob/living/basic/snake/banded/harmless
	venom_dose = 0.4
	poison_reagent = /datum/reagent/consumable/milk
	melee_damage_lower = 1
	melee_damage_upper = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/snake
