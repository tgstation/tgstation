/// Weak mob spawned if a legion infests a monkey
/mob/living/basic/mining/legion/monkey
	name = "rabble"
	desc = "You can see what was once a monkey under the shifting mass of corruption. It doesn't have enough biomass to reproduce."
	icon_state = "legion_monkey"
	pass_flags = PASSTABLE
	speed = 5
	maxHealth = 40
	health = 40
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "mauls"
	attack_verb_simple = "maul"
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_sound = 'sound/items/weapons/bite.ogg'
	speak_emote = list("chimpers")
	corpse_type = /obj/effect/mob_spawn/corpse/human/monkey
	ai_controller = /datum/ai_controller/basic_controller/legion_monkey

/mob/living/basic/mining/legion/monkey/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddComponent(/datum/component/regenerator, outline_colour = COLOR_SOFT_RED)

/mob/living/basic/mining/legion/monkey/assign_abilities()
	return

/mob/living/basic/mining/legion/monkey/get_loot_list()
	return

/// Icebox variant
/mob/living/basic/mining/legion/monkey/snow
	name = "snow rabble"
	desc = "You can see what was once a monkey under the densely packed snow. It doesn't look friendly."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "snow_monkey"

/mob/living/basic/mining/legion/monkey/snow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/appearance_on_aggro, aggro_state = "snow_monkey_alive") // Surprise! I was real!

/// Opportunistically hops in and out of vents, if it can find one and is not biting someone.
/datum/ai_controller/basic_controller/legion_monkey
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_VENTCRAWL_COOLDOWN = 20 SECONDS,
		BB_TIME_TO_GIVE_UP_ON_VENT_PATHING = 30 SECONDS,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	// We understand that vents are nice little hidey holes through epigenetic inheritance, so we'll use them.
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/legion,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/opportunistic_ventcrawler,
	)
