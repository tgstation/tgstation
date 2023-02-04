#define SPIDER_ATTACK_COOLDOWN (2 SECONDS)

/// For now, essentially just a Simple Hostile but room for expansion
/datum/ai_controller/basic_controller/giant_spider
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/giant_spider,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/giant_spider,
		/datum/ai_planning_subtree/random_speech/insect, // Space spiders are taxonomically insects not arachnids, don't DM me
	)


/// Used by Araneus, who only attacks those who attack first
/datum/ai_controller/basic_controller/giant_spider/retaliate
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path/giant_spider,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/giant_spider,
		/datum/ai_planning_subtree/random_speech/insect,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/giant_spider
	attack_behaviour = /datum/ai_behavior/attack_obstructions/giant_spider

/datum/ai_behavior/attack_obstructions/giant_spider
	action_cooldown = SPIDER_ATTACK_COOLDOWN

/datum/ai_planning_subtree/basic_melee_attack_subtree/giant_spider
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/giant_spider

/datum/ai_behavior/basic_melee_attack/giant_spider
	action_cooldown = SPIDER_ATTACK_COOLDOWN

#undef SPIDER_ATTACK_COOLDOWN
