/mob/living/basic/ant
	name = "giant ant"
	desc = "A writhing mass of ants, glued together to make an adorable pet!"
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "ant"
	icon_living = "ant"
	icon_dead = "ant_dead"
	speak_emote = list("buzzes", "chitters")
	gender = PLURAL // We are Ven-ant
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	obj_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	butcher_results = list(/obj/effect/decal/cleanable/ants = 3) //It's just a bunch of ants glued together into a larger ant
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list(FACTION_NEUTRAL)
	can_be_held = FALSE
	health = 100
	maxHealth = 100
	light_range = 1.5 // Bioluminescence!
	minimum_survivable_temperature = T20C - 100
	maximum_survivable_temperature = T20C + 120
	light_color = "#d43229" // The ants that comprise the giant ant still glow red despite the sludge.

	ai_controller = /datum/ai_controller/basic_controller/ant

/mob/living/basic/ant/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/pet_bonus, "clacks happily!")
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)

/datum/ai_controller/basic_controller/ant
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/ant,
	)
