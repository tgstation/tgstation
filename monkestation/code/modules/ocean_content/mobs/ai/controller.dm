/datum/ai_controller/basic_controller/fish
	blackboard = list(
		BB_GROUP_DATUM = null
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_create_or_follow_commands/fish,
	)
