/datum/ai_controller/kitchenbot
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.3 SECONDS
	blackboard = list(
	BB_KITCHENBOT_MODE = KITCHENBOT_MODE_IDLE,
	BB_KITCHENBOT_CHOSEN_DISPOSALS = null,
	BB_KITCHENBOT_FAILED_LAST_TARGET_SEARCH = FALSE,
	BB_KITCHENBOT_TARGET_TO_DISPOSE = null,
	BB_KITCHENBOT_CHOSEN_GRIDDLE = null,
	BB_KITCHENBOT_CHOSEN_STOCKPILE = null,
	BB_KITCHENBOT_ITEMS_WATCHED = list(),
	BB_KITCHENBOT_ITEMS_BANNED = list(),
	BB_KITCHENBOT_TAKE_OFF_GRILL = list(),
	BB_KITCHENBOT_TARGET_IN_STOCKPILE = null,
	BB_KITCHENBOT_CUSTOMERS_NOTED = list(),
	BB_KITCHENBOT_ORDERS_WANTED = list(),
	BB_KITCHENBOT_VENUE = null,
	BB_KITCHENBOT_DISH_TO_SERVE = null
	)


/datum/ai_controller/kitchenbot/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/simple_animal/bot/kitchenbot))
		return AI_CONTROLLER_INCOMPATIBLE
	return ..() //Run parent at end

/datum/ai_controller/kitchenbot/SelectBehaviors(delta_time)
	current_behaviors = list()
	switch(blackboard[BB_KITCHENBOT_MODE])
		if(KITCHENBOT_MODE_IDLE)//off, or on but no mode
			return
		if(KITCHENBOT_MODE_REFUSE)//handle refuse
			var/obj/chosen_disposals = blackboard[BB_KITCHENBOT_CHOSEN_DISPOSALS]
			var/obj/target_refuse = blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE]
			if(!chosen_disposals)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_disposals) //no return to search for trash at the same time
			if(!target_refuse)
				if(blackboard[BB_KITCHENBOT_FAILED_LAST_TARGET_SEARCH])
					current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_refuse)
				else
					current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_refuse/fast)
				return
			if(!(target_refuse in pawn.contents))
				//not holding plate, should be where we're going now
				current_movement_target = target_refuse
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/forcemove_grab/grab_refuse)
				return
			//holding plate, knows a disposals to dump it. get to work
			current_movement_target = chosen_disposals
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/disposals_item/dump_refuse)
		if(KITCHENBOT_MODE_THE_GRIDDLER)
			var/obj/machinery/griddle/griddle = blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE]
			var/obj/stockpile = blackboard[BB_KITCHENBOT_CHOSEN_STOCKPILE]
			var/list/take_off_grill = blackboard[BB_KITCHENBOT_TAKE_OFF_GRILL]
			if(!griddle)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_griddle) //no return to search for stockpile at the same time
			if(!stockpile)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_stockpile)
				return
			if(take_off_grill.len)
				current_movement_target = griddle
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/take_off_grill)
				return
			if(griddle.griddled_objects.len >= griddle.max_items)
				return
			if(!blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE])
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_stockpile_target)
				return //don't try and grab griddlable if we don't have one
			if(!(blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE] in pawn))
				current_movement_target = blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE]
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/forcemove_grab/grab_griddlable)
				return
			current_movement_target = griddle
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/put_on_grill)
		if(KITCHENBOT_MODE_WAITER)
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/listen_for_customers/kitchenbot)
			var/obj/dish_to_serve = blackboard[BB_KITCHENBOT_DISH_TO_SERVE]
			if(!dish_to_serve)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_customer_order/kitchenbot)
				return
			if(!(dish_to_serve in pawn.contents)) //haven't gotten it
				current_movement_target = dish_to_serve
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/forcemove_grab/grab_customer_order)
				return
			//we have the dish, we need to find customer and go to em'
			var/mob/living/simple_animal/robot_customer/customer = find_customer(dish_to_serve)
			//get the turf they want to go
			current_movement_target = get_step(customer,customer.dir)
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/dropoff_item/drop_order_off)
		else
			stack_trace("Kitchenbot is in a mode it doesn't have named [blackboard[BB_KITCHENBOT_MODE]] - switching to idle")
			change_mode(KITCHENBOT_MODE_IDLE)

/datum/ai_controller/kitchenbot/proc/find_customer(obj/item/what_they_want)
	var/datum/venue/bb_venue = blackboard[BB_KITCHENBOT_VENUE]
	for(var/mob/living/simple_animal/robot_customer/customer as anything in bb_venue.current_visitors)
		var/their_order = customer.ai_controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]
		if(their_order == what_they_want.type)
			return customer

/datum/ai_controller/kitchenbot/proc/DidNotGrill(obj/item/failed_grill)
	SIGNAL_HANDLER

	//no longer grilling, remove from watched items
	blackboard[BB_KITCHENBOT_ITEMS_WATCHED] -= failed_grill

/datum/ai_controller/kitchenbot/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	blackboard[BB_KITCHENBOT_TAKE_OFF_GRILL] += grilled_result

/datum/ai_controller/kitchenbot/proc/clear_signals()
	var/list/items_watched = blackboard[BB_KITCHENBOT_ITEMS_WATCHED]
	for(var/unregister_from in items_watched)
		UnregisterSignal(unregister_from, COMSIG_GRILL_COMPLETED)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY))

/datum/ai_controller/kitchenbot/proc/change_mode(new_mode)
	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = pawn
	if(!kitchenbot.on)
		return //no mode switching while off
	clear_signals()
	blackboard[BB_KITCHENBOT_MODE] = new_mode
	switch(blackboard[BB_KITCHENBOT_MODE])
		if(KITCHENBOT_MODE_THE_GRIDDLER)
			RegisterSignal(kitchenbot, COMSIG_PARENT_ATTACKBY, .proc/point_in_the_right_direction)
		if(KITCHENBOT_MODE_WAITER)
			if(!blackboard[BB_KITCHENBOT_VENUE])
				//we need to begin listening for customers, and venues store that.
				blackboard[BB_KITCHENBOT_VENUE] = SSrestaurant.all_venues[/datum/venue/restaurant]

/datum/ai_controller/kitchenbot/proc/point_in_the_right_direction(datum/source, obj/item/grillable, mob/user)
	SIGNAL_HANDLER

	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = pawn
	var/obj/machinery/griddle/chosen_griddle = blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE]
	var/obj/stockpile = blackboard[BB_KITCHENBOT_CHOSEN_STOCKPILE]
	if(!chosen_griddle)//no griddle
		to_chat(user, "<span class='warning'>[pawn] shrugs. It hasn't found a grill to man!</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		return COMPONENT_NO_AFTERATTACK
	if(chosen_griddle.griddled_objects.len >= chosen_griddle.max_items)//too many things
		to_chat(user, "<span class='warning'>[pawn] shrugs. It needs a holo-projected stockpile to take griddlable food from!</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		return COMPONENT_NO_AFTERATTACK
	to_chat(user, "<span class='warning'>[pawn] points to the food stockpile. If you add food to the stockpile, it will griddle it!</span>")
	playsound(kitchenbot, 'sound/machines/chime.ogg', 50, FALSE)
	kitchenbot.point_at(stockpile)

	return COMPONENT_NO_AFTERATTACK

