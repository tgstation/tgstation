/// AI for handling blood-drunk miner behavior
/datum/ai_controller/blood_drunk_miner
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/no_gutted_mobs,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_AGGRO_RANGE = 18, // oh fuck oh shit
		//BB_THETHING_ATTACKMODE = TRUE, //Whether we are using our melee abilities right now
		//BB_THETHING_NOAOE = TRUE, // Restricts us to only melee abilities
		//BB_THETHING_LASTAOE = null, // Last AOE ability key executed
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		///datum/ai_planning_subtree/thing_boss_aoe,
		///datum/ai_planning_subtree/thing_boss_melee,
	)
