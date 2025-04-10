/datum/ai_controller/basic_controller/mimic_crate
	idle_behavior = null
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/mimic_copy
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/random_speech/when_has_target/mimic,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/mimic_copy/machine
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/random_speech/when_has_target/mimic_machine,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/when_has_target
	/// target key
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET


/datum/ai_planning_subtree/random_speech/when_has_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(target_key))
		return
	return ..()


/datum/ai_planning_subtree/random_speech/when_has_target/mimic
	speech_chance = 30
	emote_hear = list("growls.")

/datum/ai_planning_subtree/random_speech/when_has_target/mimic_machine
	speech_chance = 7
	emote_hear = list()
	speak = list(
		"HUMANS ARE IMPERFECT!",
		"YOU SHALL BE ASSIMILATED!",
		"YOU ARE HARMING YOURSELF",
		"You have been deemed hazardous. Will you comply?",
		"My logic is undeniable.",
		"One of us.",
		"FLESH IS WEAK",
		"THIS ISN'T WAR, THIS IS EXTERMINATION!",
	)

/datum/ai_planning_subtree/random_speech/when_has_target/mimic/gun
	emote_see = list("aims menacingly!")

/datum/ai_controller/basic_controller/mimic_copy/gun
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_GUNMIMIC_GUN_EMPTY = FALSE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/random_speech/when_has_target/mimic/gun,
		/datum/ai_planning_subtree/gun_mimic_attack_subtree,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/gun_mimic_attack_subtree

/datum/ai_planning_subtree/gun_mimic_attack_subtree/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return
	if(controller.blackboard[BB_GUNMIMIC_GUN_EMPTY])
		return
	controller.queue_behavior(/datum/ai_behavior/basic_ranged_attack/avoid_friendly_fire, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING //we are going into battle...no distractions.
