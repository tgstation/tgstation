/datum/ai_controller/basic_controller/regal_rat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	// we pretty much do cheesy things (make the station worse) and don't deal with peasants (crew) unless they start to get in the way
	// summon the horde if we get into a fight and then let the horde take care of it while we skedaddle
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/targeted_mob_ability/riot,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/use_mob_ability/domain,
	)

/datum/ai_planning_subtree/targeted_mob_ability/riot
	target_key = BB_BASIC_MOB_FLEE_TARGET // we only want to trigger this when provoked, manpower is low nowadays
	ability_key = BB_RAISE_HORDE_ABILITY
	finish_planning = FALSE

/datum/ai_planning_subtree/use_mob_ability/domain
	ability_key = BB_DOMAIN_ABILITY
