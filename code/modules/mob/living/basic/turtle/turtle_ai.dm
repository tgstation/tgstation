/datum/ai_controller/basic_controller/turtle
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
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/express_happiness,
		/datum/ai_planning_subtree/use_mob_ability/turtle_tree,
	)

/datum/ai_planning_subtree/use_mob_ability/turtle_tree
	ability_key = BB_TURTLE_TREE_ABILITY

/datum/ai_planning_subtree/use_mob_ability/turtle_tree/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/happiness_count = controller.blackboard[BB_BASIC_HAPPINESS]
	if(!SPT_PROB(happiness_count / 50, seconds_per_tick))
		return
	return ..()


