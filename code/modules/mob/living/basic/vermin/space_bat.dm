/mob/living/basic/bat
	name = "Space Bat"
	desc = "A rare breed of bat which roosts in spaceships, probably not vampiric."
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"

	maxHealth = 15
	health = 15
	melee_damage_lower = 5
	melee_damage_upper = 6

	response_help_continuous = "brushes aside"
	response_help_simple = "brush aside"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	verb_say = "squeaks"

	faction = list(FACTION_HOSTILE)
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	butcher_results = list(/obj/item/food/meat/slab = 1)
	pass_flags = PASSTABLE

	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	environment_smash = ENVIRONMENT_SMASH_NONE
	mob_size = MOB_SIZE_TINY
	obj_damage = 0
	unsuitable_atmos_damage = 0

	ai_controller = /datum/ai_controller/basic_controller/space_bat

/mob/living/basic/bat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)
	add_traits(list(TRAIT_SPACEWALK, TRAIT_VENTCRAWLER_ALWAYS, TRAIT_NO_MIRROR_REFLECTION), INNATE_TRAIT)

///Controller for space bats, has nothing unique, just retaliation.
/datum/ai_controller/basic_controller/space_bat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

///Subtype used in the caves away mission
/mob/living/basic/bat/away_caves
	name = "cave bat"
	desc = "A rare breed of bat which roosts deep in caves."
	minimum_survivable_temperature = 0
	gold_core_spawnable = NO_SPAWN
