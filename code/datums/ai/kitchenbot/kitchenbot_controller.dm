/datum/ai_controller/kitchenbot
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.3 SECONDS
	blackboard = list(
	BB_KITCHENBOT_TASK_TEXT = "is happy about completing a task",
	BB_KITCHENBOT_TASK_SOUND = null,
	BB_KITCHENBOT_RADIAL_OPEN = FALSE,
	BB_KITCHENBOT_TARGET_DISPOSAL = null,
	BB_KITCHENBOT_MODE = KITCHENBOT_MODE_IDLE,
	BB_KITCHENBOT_REFUSE_LIST = list(),
	BB_KITCHENBOT_TARGET_TO_DISPOSE = null,
	BB_KITCHENBOT_ITEMS_WATCHED = list(),
	BB_KITCHENBOT_ITEMS_BANNED = list(),
	BB_KITCHENBOT_CHOSEN_GRIDDLE = null,
	BB_KITCHENBOT_TAKE_OFF_GRILL = list(),
	BB_KITCHENBOT_TARGET_IN_STOCKPILE = null,
	BB_KITCHENBOT_CUSTOMERS_NOTED = list(),
	BB_KITCHENBOT_ORDERS_WANTED = list(),
	BB_KITCHENBOT_VENUE = null,
	BB_KITCHENBOT_DISH_TO_SERVE = null
	)

/datum/ai_controller/kitchenbot/TryPossessPawn(atom/new_pawn)
	if(!ismovable(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/atom/movable/cool_pawn
	cool_pawn.pass_flags |= PASSTABLE | PASSMACHINE
	RegisterSignal(cool_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	return ..() //Run parent at end

/datum/ai_controller/kitchenbot/UnpossessPawn(destroy)
	var/atom/movable/cool_pawn = pawn
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND))
	cool_pawn.pass_flags = initial(cool_pawn.pass_flags)
	return ..() //Run parent at end

/datum/ai_controller/kitchenbot/SelectBehaviors(delta_time)
	current_behaviors = list()

	//jump out of hands if you're being held, unless you're in idle
	if(!ismob(pawn) && ismob(pawn.loc) && blackboard[BB_KITCHENBOT_MODE] == KITCHENBOT_MODE_IDLE)
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/item_escape_grasp)
	switch(blackboard[BB_KITCHENBOT_MODE])
		if(KITCHENBOT_MODE_IDLE)//off, or on but no mode
			return
		if(KITCHENBOT_MODE_REFUSE)//handle refuse
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_refuse)
			var/list/things_to_bin = blackboard[BB_KITCHENBOT_REFUSE_LIST]
			var/obj/target = blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE]
			if(!target)
				if(!things_to_bin.len)//we can't get a target either
					return
				target = pick(things_to_bin)
				blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE] = target
			if(!(target in pawn.contents))
				//not holding plate, should be where we're going now
				current_movement_target = target
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/forcemove_grab/grab_refuse)
				return
			var/obj/machinery/disposal/bin/disposal = locate(/obj/machinery/disposal/bin) in oview(7, pawn)
			if(disposal)
				current_movement_target = disposal
				blackboard[BB_KITCHENBOT_TARGET_DISPOSAL] = disposal
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/disposals_item/dump_refuse)
		if(KITCHENBOT_MODE_THE_GRIDDLER)
			var/list/take_off_grill = blackboard[BB_KITCHENBOT_TAKE_OFF_GRILL]
			var/obj/target = take_off_grill[1]
			if(take_off_grill.len) //don't let ANYTHING burn or you'll be scrapped faster than a blood cult iteration
				var/obj/machinery/griddle/possible_griddle = target.loc
				if(!istype(possible_griddle)) //sanity
					DidNotGrill(take_off_grill)
					return
				current_movement_target = possible_griddle
				blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE] = current_movement_target
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/take_off_grill)
				return
			if(!blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE])
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/find_stockpile_target)
				return //don't try and grab griddlable if we don't have one
			if(!(blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE] in pawn))
				current_movement_target = blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE]
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/forcemove_grab/grab_griddlable)
				return
			var/obj/machinery/griddle/griddle
			for(var/obj/machinery/griddle/possible_griddle in oview(7, pawn))
				if(possible_griddle.griddled_objects.len >= possible_griddle.max_items) //no room, this griddle won't do
					continue
				griddle = possible_griddle
			if(!griddle)
				return
			blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE] = griddle
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
			if(!customer || customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING]) //bad dish now!!!
				//drop item right at your feet
				current_movement_target = get_turf(pawn)
			else
				//deliver to customer
				current_movement_target = get_step(customer,customer.dir)
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/dropoff_item/drop_order_off)
		else
			stack_trace("Kitchenbot is in a mode it doesn't have named \"[blackboard[BB_KITCHENBOT_MODE]]\" - switching to idle")
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
	clear_signals()
	blackboard[BB_KITCHENBOT_MODE] = new_mode
	switch(blackboard[BB_KITCHENBOT_MODE])
		if(KITCHENBOT_MODE_WAITER)
			if(!blackboard[BB_KITCHENBOT_VENUE])
				//we need to begin listening for customers, and venues store that.
				blackboard[BB_KITCHENBOT_VENUE] = SSrestaurant.all_venues[/datum/venue/restaurant]
	pawn.update_appearance(UPDATE_ICON) //in case the pawn has a special sprite for this

/datum/ai_controller/kitchenbot/proc/on_attack_hand(datum/source, mob/living/radial_user)
	SIGNAL_HANDLER

	if(radial_user.combat_mode)
		//don't pass COMPONENT_CANCEL_ATTACK_CHAIN so they may attack
		return
	if(blackboard[BB_KITCHENBOT_RADIAL_OPEN])
		to_chat(radial_user, "<span class='warning'>Someone is already setting [pawn]'s mode!</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	blackboard[BB_KITCHENBOT_RADIAL_OPEN] = TRUE
	INVOKE_ASYNC(src, .proc/mode_radial, radial_user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/ai_controller/kitchenbot/proc/mode_radial(mob/living/radial_user)
	if(!in_range(pawn, radial_user))
		blackboard[BB_KITCHENBOT_RADIAL_OPEN] = FALSE
		return
	var/list/tool_list = list() //create the list with initial size of 5 so we're accessing something in bounds
	tool_list[RADIAL_FORGET_BUTTON] = image(icon = 'icons/mob/aibots.dmi', icon_state = "forget_everything")
	tool_list[RADIAL_IDLE_BUTTON] = image(icon = 'icons/mob/aibots.dmi', icon_state = "kitchenbot1")
	tool_list[RADIAL_REFUSE_BUTTON] = image(icon = 'icons/mob/aibots.dmi', icon_state = "kitchenbot2")
	tool_list[RADIAL_THE_GRIDDLER_BUTTON] = image(icon = 'icons/mob/aibots.dmi', icon_state = "kitchenbot3")
	tool_list[RADIAL_WAITER_BUTTON] = image(icon = 'icons/mob/aibots.dmi', icon_state = "kitchenbot4")
	var/result = show_radial_menu(radial_user, pawn, tool_list, require_near = TRUE, tooltips = TRUE)
	blackboard[BB_KITCHENBOT_RADIAL_OPEN] = FALSE
	if(!result || !in_range(pawn, radial_user))
		return
	if(result == RADIAL_FORGET_BUTTON)
		forget_everything()
		return
	//because byond is retarded with assoc lists defined by numbers
	var/result2mode = list(
		RADIAL_IDLE_BUTTON = KITCHENBOT_MODE_IDLE,
		RADIAL_REFUSE_BUTTON = KITCHENBOT_MODE_REFUSE,
		RADIAL_THE_GRIDDLER_BUTTON = KITCHENBOT_MODE_THE_GRIDDLER,
		RADIAL_WAITER_BUTTON = KITCHENBOT_MODE_WAITER)
	var/new_mode = result2mode[result]
	if(blackboard[BB_KITCHENBOT_MODE] == result)
		return
	change_mode(new_mode)

/datum/ai_controller/kitchenbot/proc/forget_everything()
	//kitchenbot forgets a lot of stuff when you turn them off (lets them relearn new things)
	current_movement_target = null
	blackboard[BB_KITCHENBOT_MODE] = KITCHENBOT_MODE_IDLE
	blackboard[BB_KITCHENBOT_REFUSE_LIST] = list()
	var/obj/item/held_refuse = blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE]
	if(held_refuse && (held_refuse in src))
		held_refuse.forceMove(pawn.drop_location())
	blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE] = null
	blackboard[BB_KITCHENBOT_ITEMS_WATCHED] = list()
	var/obj/item/held_grillable = blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE]
	if(held_grillable && (held_grillable in src))
		held_grillable.forceMove(pawn.drop_location())
	blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE] = null
