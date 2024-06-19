/datum/ai_behavior/find_seat
	action_cooldown = 8 SECONDS

/datum/ai_behavior/find_seat/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	var/obj/structure/holosign/robot_seat/found_seat

	for(var/obj/structure/holosign/robot_seat/potential_seat in oview(7, controller.pawn))

		if(potential_seat.linked_venue != attending_venue) //Incorrect venue
			continue

		if(attending_venue.linked_seats[potential_seat]) //Someone called dibs
			continue
		var/turf/seat_turf = get_turf(potential_seat)

		if(seat_turf.is_blocked_turf()) //Someone called dibsies
			continue

		found_seat = potential_seat
		break

	if(found_seat)
		customer_pawn.say(pick(customer_data.found_seat_lines))
		controller.set_blackboard_key(BB_CUSTOMER_MY_SEAT, found_seat)
		attending_venue.linked_seats[found_seat] = customer_pawn
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	// SPT_PROB 1.5 is about a 60% chance that the tourist will have vocalised at least once every minute.
	if(!controller.blackboard[BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE] || SPT_PROB(1.5, seconds_per_tick))
		customer_pawn.say(pick(customer_data.cant_find_seat_lines))
		controller.set_blackboard_key(BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE, TRUE)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/order_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 0

/datum/ai_behavior/order_food/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/obj/structure/holosign/robot_seat/seat_marker = controller.blackboard[BB_CUSTOMER_MY_SEAT]
	if(get_turf(seat_marker) == get_turf(customer_pawn))
		var/obj/structure/chair/my_seat = locate(/obj/structure/chair) in get_turf(customer_pawn)
		if(my_seat)
			controller.pawn.setDir(my_seat.dir) //Sit in your seat

	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	controller.set_blackboard_key(BB_CUSTOMER_CURRENT_ORDER, attending_venue.order_food(customer_pawn, customer_data))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/wait_for_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 0

/datum/ai_behavior/wait_for_food/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard[BB_CUSTOMER_EATING])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	controller.add_blackboard_key(BB_CUSTOMER_PATIENCE, seconds_per_tick * -1 SECONDS) // Convert seconds_per_tick to a SECONDS equivalent.
	if(controller.blackboard[BB_CUSTOMER_PATIENCE] < 0 || controller.blackboard[BB_CUSTOMER_LEAVING]) // Check if we're leaving because sometthing mightve forced us to
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	// SPT_PROB 1.5 is about a 40% chance that the tourist will have vocalised at least once every minute.
	if(SPT_PROB(0.85, seconds_per_tick))
		var/mob/living/basic/robot_customer/customer_pawn = controller.pawn
		var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
		customer_pawn.say(pick(customer_data.wait_for_food_lines))

	var/obj/structure/holosign/robot_seat/seat_marker = controller.blackboard[BB_CUSTOMER_MY_SEAT]
	if(get_turf(seat_marker) == get_turf(controller.pawn))
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

	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/wait_for_food/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/mob/living/greytider = controller.blackboard[BB_CUSTOMER_CURRENT_TARGET]
	//usually if we stop waiting, it's because we're done with the venue. but here we're either beating some dude up
	//or are being qdeleted and don't want runtime errors, so don't switch to leaving
	if(greytider || QDELETED(src) || QDELETED(customer_pawn))
		return
	controller.set_blackboard_key(BB_CUSTOMER_LEAVING, TRUE)
	customer_pawn.update_icon() //They might have a special leaving accesoiry (french flag)
	if(succeeded)
		customer_pawn.say(pick(customer_data.leave_happy_lines))
	else
		customer_pawn.say(pick(customer_data.leave_mad_lines))

/datum/ai_behavior/leave_venue
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/leave_venue/setup(datum/ai_controller/controller, venue_key)
	. = ..()
	var/datum/venue/attending_venue = controller.blackboard[venue_key]
	set_movement_target(controller, attending_venue.restaurant_portal)

/datum/ai_behavior/leave_venue/perform(seconds_per_tick, datum/ai_controller/controller, venue_key)
	qdel(controller.pawn) //save the world, my final message, goodbye.
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
