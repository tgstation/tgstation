/datum/ai_planning_subtree/punpun_shenanigans/SelectBehaviors(datum/ai_controller/monkey/controller, delta_time)

	controller.set_trip_mode(mode = FALSE) // pun pun doesn't fuck around

	if(prob(5))
		controller.queue_behavior(/datum/ai_behavior/use_in_hand)

	if(!DT_PROB(MONKEY_SHENANIGAN_PROB, delta_time))
		return

	if(!controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET])
		controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_MONKEY_CURRENT_PRESS_TARGET, /obj/structure/desk_bell, 2)
	else if(prob(50))
		controller.queue_behavior(/datum/ai_behavior/use_on_object, BB_MONKEY_CURRENT_PRESS_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!controller.blackboard[BB_MONKEY_CURRENT_GIVE_TARGET])
		controller.queue_behavior(/datum/ai_behavior/find_and_set/pawn_must_hold_item, BB_MONKEY_CURRENT_GIVE_TARGET, /mob/living, 2)
	else if(prob(30))
		controller.queue_behavior(/datum/ai_behavior/give, BB_MONKEY_CURRENT_GIVE_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

