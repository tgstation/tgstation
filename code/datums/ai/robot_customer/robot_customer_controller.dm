/datum/ai_controller/robot_customer
	blackboard = list(BB_CUSTOMER_CURRENT_ORDER = null,
	BB_CUSTOMER_MY_SEAT = null,
	BB_CUSTOMER_PATIENCE = 999,
	BB_CUSTOMER_CUSTOMERINFO = null,
	BB_CUSTOMER_EATING = FALSE)


/datum/ai_controller/robot_customer/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/simple_animal/robot_customer))
		return AI_CONTROLLER_INCOMPATIBLE
	var/datum/venue_customer/customer_data = blackboard[BB_CUSTOMER_CUSTOMERINFO]
	blackboard[BB_CUSTOMER_PATIENCE] = customer_data.total_patience
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/UnpossessPawn(destroy)
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/mob/living/simple_animal/robot_customer = pawn
	var/obj/structure/chair/my_seat = blackboard[BB_CUSTOMER_MY_SEAT]

	if(!my_seat) //We havn't got a seat yet! find one!
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_seat)
		return

	if(robot_customer.loc != my_seat.loc) //We aren't at our seat yet. Lets go!!!
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/go_to_seat)
		return


