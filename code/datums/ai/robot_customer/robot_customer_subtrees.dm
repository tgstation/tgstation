/datum/ai_planning_subtree/robot_customer/SelectBehaviors(datum/ai_controller/controller, delta_time)
	current_behaviors = list()
	if(blackboard[BB_CUSTOMER_LEAVING])
		var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
		current_movement_target = attending_venue.restaurant_portal
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/leave_venue)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(blackboard[BB_CUSTOMER_CURRENT_TARGET])
		current_movement_target = blackboard[BB_CUSTOMER_CURRENT_TARGET]
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/break_spine/robot_customer)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/obj/my_seat = blackboard[BB_CUSTOMER_MY_SEAT]

	if(!my_seat) //We havn't got a seat yet! find one!
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_seat)
		return SUBTREE_RETURN_FINISH_PLANNING

	current_movement_target = my_seat

	if(!blackboard[BB_CUSTOMER_CURRENT_ORDER]) //We havn't ordered yet even ordered yet. go on! go over there and go do it!
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/order_food)
		return SUBTREE_RETURN_FINISH_PLANNING
	else
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/wait_for_food)
