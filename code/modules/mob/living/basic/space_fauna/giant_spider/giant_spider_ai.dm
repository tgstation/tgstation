/// For now, essentially just a Simple Hostile but room for expansion
/datum/ai_controller/basic_controller/giant_spider
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/giant_spider,
		/datum/ai_planning_subtree/random_speech/insect, // Space spiders are taconomically insects not arachnids, don't DM me
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/giant_spider
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/giant_spider

/datum/ai_behavior/basic_melee_attack/giant_spider
	action_cooldown = 2 SECONDS
