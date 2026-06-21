/datum/ai_controller/basic_controller/trooper
	behavior_tree_json = "code/modules/mob/living/basic/trooper/trooper.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "411 in progress, requesting backup!"
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_planning_subtree/basic_melee_attack_subtree/trooper
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack

/datum/ai_planning_subtree/attack_obstacle_in_path/trooper
	attack_behaviour = /datum/ai_behavior/attack_obstructions/trooper

/datum/ai_behavior/attack_obstructions/trooper
	time_between_perform = 1.2 SECONDS

/datum/ai_controller/basic_controller/trooper/calls_reinforcements
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "411 in progress, requesting backup!",
		BB_CALLS_REINFORCEMENTS = TRUE,
	)

/datum/ai_controller/basic_controller/trooper/peaceful
	behavior_tree_json = "code/modules/mob/living/basic/trooper/peaceful.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "411 in progress, requesting backup!",
		BB_CALLS_REINFORCEMENTS = TRUE
	)

/datum/bt_node/subtree/trooper_ranged
	behavior_tree_json = "code/modules/mob/living/basic/trooper/trooper_ranged.bt.json"


/datum/ai_controller/basic_controller/trooper/ranged
	behavior_tree_json = "code/modules/mob/living/basic/trooper/ranged.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "411 in progress, requesting backup!",
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 4
	)



/datum/ai_controller/basic_controller/trooper/ranged/burst
	behavior_tree_json = "code/modules/mob/living/basic/trooper/burst.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "411 in progress, requesting backup!",
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 2,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 3
	)

//lol my parser cant deal with two subtypes with the same name so this is just a peaceful burst :DDDD ebin
/datum/ai_controller/basic_controller/trooper/ranged/burst/peaceful_burst
	behavior_tree_json = "code/modules/mob/living/basic/trooper/peaceful_burst.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "411 in progress, requesting backup!",
		BB_CALLS_REINFORCEMENTS = TRUE
	)

/datum/ai_controller/basic_controller/trooper/ranged/shotgunner
	behavior_tree_json = "code/modules/mob/living/basic/trooper/shotgunner.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "411 in progress, requesting backup!",
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 2,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 3
	)



/datum/ai_controller/basic_controller/trooper/viscerator
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
