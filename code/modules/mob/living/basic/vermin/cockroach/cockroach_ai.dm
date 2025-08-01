
/// AI controller for normal roach
/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_OWNER_SELF_HARM_RESPONSES = list(
			"*me waves its antennae in disapproval.",
			"*me chitters sadly."
		)
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/// AI controller for aggressive roach
/datum/ai_controller/basic_controller/cockroach/aggro
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/// AI controller for roach who can shoot at you
/datum/ai_controller/basic_controller/cockroach/glockroach
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/glockroach, //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/glockroach
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/glockroach

/datum/ai_behavior/basic_ranged_attack/glockroach //Slightly slower, as this is being made in feature freeze ;)
	action_cooldown = 1 SECONDS

/// roach who shoots at you slightly slower
/datum/ai_controller/basic_controller/cockroach/mobroach
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/mobroach,
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/mobroach
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/mobroach

/datum/ai_behavior/basic_ranged_attack/mobroach
	action_cooldown = 2 SECONDS
