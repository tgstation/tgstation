// The taxonomy of polar vs space bear left to imagination of the reader
/mob/living/basic/mining/polarbear
	name = "polar bear"
	desc = "An aggressive animal that defends its territory with incredible power. These beasts don't run from their enemies."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "polarbear"
	icon_living = "polarbear"
	icon_dead = "polarbear_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_MINING

	friendly_verb_continuous = "growls at"
	friendly_verb_simple = "growl at"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW

	habitable_atmos = null
	speed = 2
	maxHealth = 300
	health = 300
	obj_damage = 40
	melee_damage_lower = 25
	melee_damage_upper = 25
	wound_bonus = -5
	exposed_wound_bonus = 10
	sharpness = SHARP_EDGED

	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/food/meat/slab/bear = 3, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide = 1)
	crusher_loot = /obj/item/crusher_trophy/bear_paw

	ai_controller = /datum/ai_controller/basic_controller/polar

/mob/living/basic/mining/polarbear/Initialize(mapload)
	. = ..()

	add_traits(list(TRAIT_SPACEWALK, TRAIT_SWIMMER, TRAIT_FENCE_CLIMBER, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BEAR, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/change_force_on_death, move_force = MOVE_FORCE_DEFAULT, move_resist = MOVE_RESIST_DEFAULT, pull_force = PULL_FORCE_DEFAULT)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)

/mob/living/basic/mining/polarbear/lesser
	name = "magic polar bear"
	desc = "It seems sentient somehow."
	faction = list(FACTION_NEUTRAL)

/datum/ai_controller/basic_controller/polar
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 2,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/enrage,
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/bear,
	)
