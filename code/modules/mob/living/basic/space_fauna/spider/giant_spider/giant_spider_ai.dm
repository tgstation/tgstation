/// Attacks people it can see, spins webs if it can't see anything to attack.
/datum/ai_controller/basic_controller/giant_spider
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED | PAUSE_DURING_DO_AFTER
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/insect, // Space spiders are taxonomically insects not arachnids, don't DM me
		/datum/ai_planning_subtree/find_unwebbed_turf,
		/datum/ai_planning_subtree/spin_web,
	)

/// Giant spider which won't attack structures
/datum/ai_controller/basic_controller/giant_spider/weak
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/find_unwebbed_turf,
		/datum/ai_planning_subtree/spin_web,
	)

/// Used by Araneus, who only attacks those who attack first. He is house-trained and will not web up the HoS office.
/datum/ai_controller/basic_controller/giant_spider/retaliate
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/insect,
	)

/// Retaliates, hunts other maintenance creatures, runs away from larger attackers, and spins webs.
/datum/ai_controller/basic_controller/giant_spider/pest
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/ours_or_smaller, // Hunt mobs our size
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/larger, // Run away from mobs bigger than we are
	)
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/find_unwebbed_turf,
		/datum/ai_planning_subtree/spin_web,
	)
