/datum/ai_behavior/find_seat
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 5 SECONDS


/datum/ai_behavior/find_seat/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]

	var/obj/structure/chair/found_seat

	for(var/obj/structure/chair/potential_seat in oview(src,7))
		if(SSrestaurant.claimed_seats[potential_seat]) //Someone called dibs
			continue
		var/turf/seat_turf = get_turf(potential_seat)

		if(seat_turf.is_blocked_turf()) //Someone called dibsies
			continue

		found_seat = potential_seat
		break

	if(found_seat)
		customer_pawn.say(pick(customer_data.found_seat_lines))
		controller.blackboard[BB_CUSTOMER_MY_SEAT] = found_seat
		SSrestaurant.claimed_seats[found_seat] = customer_pawn
		finish_action(controller, TRUE)
	else
		customer_pawn.say(pick(customer_data.cant_find_seat_lines))
		finish_action(controller, FALSE)


/datum/ai_behavior/order_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/order_food/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]

	var/obj/item/food_to_order = pickweight(customer_data.liked_objects)
	customer_pawn.say(customer_data.order_food_line())
	controller.blackboard[BB_CUSTOMER_CURRENT_ORDER] = food_to_order
	finish_action(controller, TRUE)

/datum/ai_behavior/wait_for_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/wait_for_food/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard[BB_CUSTOMER_EATING])
		finish_action(controller, TRUE)
		return

	controller.blackboard[BB_CUSTOMER_PATIENCE] -= delta_time
	if(controller.blackboard[BB_CUSTOMER_PATIENCE] < 0 || controller.blackboard[BB_BLACKBOARD_CUSTOMER_LEAVING]) // Check if we're leaving because sometthing mightve forced us to
		finish_action(controller, FALSE)
		return

	if(DT_PROB(2, delta_time))
		var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
		var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
		customer_pawn.say(pick(customer_data.wait_for_food_lines))

/datum/ai_behavior/wait_for_food/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	controller.blackboard[BB_BLACKBOARD_CUSTOMER_LEAVING] = TRUE
	if(succeeded)
		customer_pawn.say(pick(customer_data.leave_happy_lines))
	else
		customer_pawn.say(pick(customer_data.leave_mad_lines))

/datum/ai_behavior/leave_venue
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/leave_venue/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	qdel(controller.pawn) //save the world, my final message, goodbye.
	finish_action(controller, TRUE)
