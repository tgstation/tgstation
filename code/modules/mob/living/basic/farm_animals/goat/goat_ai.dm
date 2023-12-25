/// Goats are normally content to sorta hang around and crunch any plant in sight, but they will go ape on someone who attacks them.
/datum/ai_controller/basic_controller/goat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/capricious_retaliate, // Capricious like Capra, get it?
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/goat,
	)

/datum/ai_planning_subtree/random_speech/goat
	speech_chance = 3
	emote_hear = list("brays.")
	emote_see = list("shakes their head.", "stamps a foot.", "glares around.")
	speak = list("EHEHEHEHEH", "eh?")
