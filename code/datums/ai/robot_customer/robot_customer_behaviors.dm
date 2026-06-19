/// Searches nearby for an unclaimed seat belonging to the customer's venue.
/// Sets BB_CUSTOMER_MY_SEAT and claims it on success. Returns FAILURE if none found.
/datum/bt_node/ai_behavior/robot_customer/find_seat

/datum/bt_node/ai_behavior/robot_customer/find_seat/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	var/obj/structure/holosign/robot_seat/found_seat
	for(var/obj/structure/holosign/robot_seat/potential_seat in oview(7, customer_pawn))
		if(potential_seat.linked_venue != attending_venue)
			continue
		if(attending_venue.linked_seats[potential_seat])
			continue
		var/turf/seat_turf = get_turf(potential_seat)
		if(seat_turf.is_blocked_turf())
			continue
		found_seat = potential_seat
		break

	if(found_seat)
		INVOKE_ASYNC(customer_pawn, TYPE_PROC_REF(/atom/movable, say), pick(customer_data.found_seat_lines))
		controller.set_blackboard_key(BB_CUSTOMER_MY_SEAT, found_seat)
		attending_venue.linked_seats[found_seat] = customer_pawn
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(!controller.blackboard[BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE] || SPT_PROB(1.5, seconds_per_tick))
		INVOKE_ASYNC(customer_pawn, TYPE_PROC_REF(/atom/movable, say), pick(customer_data.cant_find_seat_lines))
		controller.set_blackboard_key(BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE, TRUE)

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED


/// Places the customer's food order once they are at their seat.
/datum/bt_node/ai_behavior/robot_customer/order_food
	/// Set while order_food is happening (sleeps)
	var/is_ordering = FALSE
	/// TRUE once the async order has completed.
	var/async_order_done = FALSE

/datum/bt_node/ai_behavior/robot_customer/order_food/perform(seconds_per_tick, datum/ai_controller/controller)
	if(is_ordering)
		return AI_BEHAVIOR_DELAY

	if(async_order_done)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	var/mob/living/basic/robot_customer/customer_pawn = controller.pawn
	var/obj/structure/holosign/robot_seat/seat_marker = controller.blackboard[BB_CUSTOMER_MY_SEAT]

	if(get_turf(seat_marker) == get_turf(customer_pawn))
		var/obj/structure/chair/my_seat = locate(/obj/structure/chair) in get_turf(customer_pawn)
		if(my_seat)
			customer_pawn.setDir(my_seat.dir)

	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	is_ordering = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_order), controller, customer_pawn, attending_venue, customer_data)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/robot_customer/order_food/proc/async_order(datum/ai_controller/controller, mob/living/basic/robot_customer/customer_pawn, datum/venue/attending_venue, datum/customer_data/customer_data)
	var/order
	if(!QDELETED(customer_pawn) && !QDELETED(attending_venue))
		order = attending_venue.order_food(customer_pawn, customer_data)
	if(!is_ordering)
		return
	if(!isnull(order))
		controller.set_blackboard_key(BB_CUSTOMER_CURRENT_ORDER, order)
	async_order_done = TRUE
	is_ordering = FALSE

/datum/bt_node/ai_behavior/robot_customer/order_food/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_ordering = FALSE
	async_order_done = FALSE


/// Waits at the seat for food to arrive. Ticks down patience and checks for food placed in front.
/// Succeeds when BB_CUSTOMER_EATING is set; fails when patience runs out or BB_CUSTOMER_LEAVING is set.
/// On finish, sets BB_CUSTOMER_LEAVING and says the appropriate departure line.
/datum/bt_node/ai_behavior/robot_customer/wait_for_food

/datum/bt_node/ai_behavior/robot_customer/wait_for_food/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard[BB_CUSTOMER_EATING])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	controller.add_blackboard_key(BB_CUSTOMER_PATIENCE, seconds_per_tick * -1 SECONDS)
	if(controller.blackboard[BB_CUSTOMER_PATIENCE] < 0 || controller.blackboard[BB_CUSTOMER_LEAVING])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(SPT_PROB(0.85, seconds_per_tick))
		var/mob/living/basic/robot_customer/customer_pawn = controller.pawn
		var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
		INVOKE_ASYNC(customer_pawn, TYPE_PROC_REF(/atom/movable, say), pick(customer_data.wait_for_food_lines))

	var/obj/structure/holosign/robot_seat/seat_marker = controller.blackboard[BB_CUSTOMER_MY_SEAT]
	if(get_turf(seat_marker) == get_turf(controller.pawn))
		var/obj/structure/chair/my_seat = locate(/obj/structure/chair) in get_turf(controller.pawn)
		if(my_seat)
			controller.pawn.setDir(my_seat.dir)

	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	var/turf/infront_turf = get_step(controller.pawn, controller.pawn.dir)
	for(var/obj/item/I in infront_turf.contents)
		if(attending_venue.is_correct_order(I, controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]))
			var/datum/ai_controller/robot_customer/customer = controller
			customer.eat_order(I, attending_venue)
			break

	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/robot_customer/wait_for_food/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/mob/living/greytider = controller.blackboard[BB_CUSTOMER_CURRENT_TARGET]
	// Don't switch to leaving if we're heading to beat someone up or if we're being deleted.
	if(greytider || QDELETED(src) || QDELETED(customer_pawn))
		return
	controller.set_blackboard_key(BB_CUSTOMER_LEAVING, TRUE)
	customer_pawn.update_icon()
	if(succeeded)
		customer_pawn.say(pick(customer_data.leave_happy_lines))
	else
		customer_pawn.say(pick(customer_data.leave_mad_lines))


/// Resolves the venue exit portal from attending_venue.current_visitors and stores it in BB_CUSTOMER_EXIT_PORTAL.
/datum/bt_node/ai_behavior/robot_customer/find_exit_portal

/datum/bt_node/ai_behavior/robot_customer/find_exit_portal/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!isnull(controller.blackboard[BB_CUSTOMER_EXIT_PORTAL]))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	if(isnull(attending_venue))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/datum/weakref/portal_ref = attending_venue.current_visitors[controller.pawn]
	var/atom/portal = portal_ref?.resolve()
	if(isnull(portal) || QDELETED(portal))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_CUSTOMER_EXIT_PORTAL, portal)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED


/// Deletes the pawn once they have reached the exit portal.
/datum/bt_node/ai_behavior/robot_customer/leave_venue

/datum/bt_node/ai_behavior/robot_customer/leave_venue/perform(seconds_per_tick, datum/ai_controller/controller)
	qdel(controller.pawn)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED


/// Applies full-body brute damage to BB_CUSTOMER_CURRENT_TARGET while pulling them.
/// Clears the target key on success so the customer returns to normal behavior.
/datum/bt_node/ai_behavior/robot_customer/break_spine_attack
	var/target_key
	var/give_up_distance = 10

/datum/bt_node/ai_behavior/robot_customer/break_spine_attack/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/batman = controller.blackboard[target_key]
	var/mob/living/big_guy = controller.pawn

	if(QDELETED(batman) || get_dist(batman, big_guy) >= give_up_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(batman.stat != CONSCIOUS)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	INVOKE_ASYNC(big_guy, TYPE_PROC_REF(/atom/movable, start_pulling), batman)
	big_guy.face_atom(batman)
	batman.visible_message(span_warning("[batman] gets a slightly too tight hug from [big_guy]!"), span_userdanger("You feel your body break as [big_guy] embraces you!"))
	for(var/zone in GLOB.all_body_zones - BODY_ZONE_HEAD)
		batman.apply_damage(15, BRUTE, zone, wound_bonus = 35)

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/robot_customer/break_spine_attack/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded)
		var/mob/living/bane = controller.pawn
		if(!QDELETED(bane))
			bane.stop_pulling()
		controller.clear_blackboard_key(target_key)
