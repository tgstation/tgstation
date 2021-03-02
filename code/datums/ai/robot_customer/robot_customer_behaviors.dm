/datum/ai_behavior/find_seat
	action_cooldown = 8 SECONDS

/datum/ai_behavior/find_seat/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]

	var/obj/structure/holosign/robot_seat/found_seat

	for(var/obj/structure/holosign/robot_seat/potential_seat in oview(7, controller.pawn))

		if(potential_seat.linked_venue != controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]) //Incorrect venue
			continue

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
	required_distance = 0

/datum/ai_behavior/order_food/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]

	if(get_turf(controller.blackboard[BB_CUSTOMER_MY_SEAT]) == get_turf(customer_pawn))
		var/obj/structure/chair/my_seat = locate(/obj/structure/chair) in get_turf(customer_pawn)
		if(my_seat)
			controller.pawn.setDir(my_seat.dir) //Sit in your seat

	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	controller.blackboard[BB_CUSTOMER_CURRENT_ORDER] = attending_venue.order_food(customer_pawn, customer_data)

	finish_action(controller, TRUE)

/datum/ai_behavior/wait_for_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 0

/datum/ai_behavior/wait_for_food/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard[BB_CUSTOMER_EATING])
		finish_action(controller, TRUE)
		return

	controller.blackboard[BB_CUSTOMER_PATIENCE] -= delta_time
	if(controller.blackboard[BB_CUSTOMER_PATIENCE] < 0 || controller.blackboard[BB_CUSTOMER_LEAVING]) // Check if we're leaving because sometthing mightve forced us to
		finish_action(controller, FALSE)
		return

	if(DT_PROB(1, delta_time))
		var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
		var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
		customer_pawn.say(pick(customer_data.wait_for_food_lines))

	if(get_turf(controller.blackboard[BB_CUSTOMER_MY_SEAT]) == get_turf(controller.pawn))
		var/obj/structure/chair/my_seat = locate(/obj/structure/chair) in get_turf(controller.pawn)
		if(my_seat)
			controller.pawn.setDir(my_seat.dir) //Sit in your seat


	///Now check if theres a meal infront of us.
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	var/turf/infront_turf = get_step(controller.pawn, controller.pawn.dir)
	for(var/obj/item/I in infront_turf.contents)
		if(attending_venue.is_correct_order(I, controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]))
			var/datum/ai_controller/robot_customer/customer = controller
			customer.eat_order(I, attending_venue)
			break


/datum/ai_behavior/wait_for_food/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	controller.blackboard[BB_CUSTOMER_LEAVING] = TRUE
	customer_pawn.update_icon() //They might have a special leaving accesoiry (french flag)
	if(succeeded)
		customer_pawn.say(pick(customer_data.leave_happy_lines))
	else
		customer_pawn.say(pick(customer_data.leave_mad_lines))

/datum/ai_behavior/leave_venue
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1

/datum/ai_behavior/leave_venue/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	qdel(controller.pawn) //save the world, my final message, goodbye.
	finish_action(controller, TRUE)
