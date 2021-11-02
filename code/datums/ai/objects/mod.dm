/datum/ai_controller/mod
	blackboard = list(
		BB_MOD_TARGET = null,
		BB_MOD_MODULE = null,
	)
	max_target_distance = 50
	ai_movement = /datum/ai_movement/jps

/datum/ai_controller/mod/SelectBehaviors(delta_time)
	current_behaviors = list()
	if(pawn.Adjacent(blackboard[BB_MOD_TARGET]))
		queue_behavior(/datum/ai_behavior/)
