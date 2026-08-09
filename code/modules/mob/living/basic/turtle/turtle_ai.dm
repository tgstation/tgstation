/datum/ai_controller/basic_controller/turtle
	behavior_tree_json = "code/modules/mob/living/basic/turtle/turtle.bt.json"
	blackboard = list(
		BB_HAPPY_EMOTIONS = list(
			"wiggles its tree in excitement!",
			"raises its head up high!",
			"wags its tail enthusiastically!",
		),
		BB_MODERATE_EMOTIONS = list(
			"keeps its head level, eyes half-closed.",
			"basks in the light peacefully.",
		),
		BB_SAD_EMOTIONS = list(
			"looks towards the floor in dissapointment...",
			"the leaves on its tree droop...",
		),
	)
	ai_movement = /datum/ai_movement/basic_avoidance
