/datum/ai_controller/basic_controller/syndicate
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/syndicate()
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/syndicate
	)

/datum/targetting_datum/basic/syndicate
	stat_attack = HARD_CRIT

/datum/ai_planning_subtree/basic_melee_attack_subtree/syndicate
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/syndicate

/datum/ai_behavior/basic_melee_attack/syndicate
	action_cooldown = 1.2 SECONDS

/datum/ai_controller/basic_controller/syndicate/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/syndicate
	)
/datum/ai_planning_subtree/basic_ranged_attack_subtree/syndicate
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/syndicate

/datum/ai_behavior/basic_ranged_attack/syndicate
	required_distance = 5

/datum/ai_controller/basic_controller/syndicate/ranged/burst
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/syndicate_burst
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/syndicate_burst
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/syndicate_burst

/datum/ai_behavior/basic_ranged_attack/syndicate_burst
	shots = 3
	action_cooldown = 3 SECONDS

/datum/ai_controller/basic_controller/syndicate/ranged/shotgunner
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/syndicate_shotgun
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/syndicate_shotgun
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/syndicate_shotgun

/datum/ai_behavior/basic_ranged_attack/syndicate_shotgun
	shots = 2
	burst_interval = 0.6 SECONDS
	action_cooldown = 3 SECONDS
	required_distance = 1

/datum/ai_controller/basic_controller/viscerator
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)

	ai_movement = /datum/ai_movement/dumb
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/syndicate
	)
