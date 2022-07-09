/datum/ai_planning_subtree/robot_customer/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_CUSTOMER_LEAVING])
		controller.queue_behavior(/datum/ai_behavior/leave_venue, BB_CUSTOMER_ATTENDING_VENUE)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(controller.blackboard[BB_CUSTOMER_CURRENT_TARGET])

		controller.queue_behavior(/datum/ai_behavior/break_spine, BB_CUSTOMER_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/datum/weakref/seat_ref = controller.blackboard[BB_CUSTOMER_MY_SEAT]
	var/obj/structure/holosign/robot_seat/seat_marker = seat_ref?.resolve()

	if(!seat_marker) //We havn't got a seat yet! find one!
		controller.queue_behavior(/datum/ai_behavior/find_seat)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.current_movement_target = seat_marker

	if(!controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]) //We havn't ordered yet even ordered yet. go on! go over there and go do it!
		controller.queue_behavior(/datum/ai_behavior/order_food)
		return SUBTREE_RETURN_FINISH_PLANNING
	else
		controller.queue_behavior(/datum/ai_behavior/wait_for_food)
