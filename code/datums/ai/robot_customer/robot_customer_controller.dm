/datum/ai_controller/robot_customer
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.8 SECONDS
	blackboard = list(BB_CUSTOMER_CURRENT_ORDER = null,
	BB_CUSTOMER_MY_SEAT = null,
	BB_CUSTOMER_PATIENCE = 999,
	BB_CUSTOMER_CUSTOMERINFO = null,
	BB_CUSTOMER_EATING = FALSE,
	BB_CUSTOMER_LEAVING = FALSE,
	BB_CUSTOMER_ATTENDING_VENUE = null)


/datum/ai_controller/robot_customer/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/simple_animal/robot_customer))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(new_pawn, COMSIG_LIVING_GET_PULLED, .proc/on_get_pulled)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/on_get_punched)
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY, COMSIG_LIVING_GET_PULLED, COMSIG_ATOM_ATTACK_HAND))
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/SelectBehaviors(delta_time)
	current_behaviors = list()
	if(blackboard[BB_CUSTOMER_LEAVING])
		var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
		current_movement_target = attending_venue.restaurant_portal
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/leave_venue)
		return

	if(blackboard[BB_CUSTOMER_CURRENT_TARGET])
		current_movement_target = blackboard[BB_CUSTOMER_CURRENT_TARGET]
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/break_spine/robot_customer)
		return

	var/obj/my_seat = blackboard[BB_CUSTOMER_MY_SEAT]

	if(!my_seat) //We havn't got a seat yet! find one!
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/find_seat)
		return

	current_movement_target = my_seat

	if(!blackboard[BB_CUSTOMER_CURRENT_ORDER]) //We havn't ordered yet even ordered yet. go on! go over there and go do it!
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/order_food)
		return
	else
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/wait_for_food)


/datum/ai_controller/robot_customer/proc/on_attackby(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	if(attending_venue.is_correct_order(I, blackboard[BB_CUSTOMER_CURRENT_ORDER]))
		to_chat(user, "<span class='notice'>You hand [I] to [pawn]</span>")
		eat_order(I, attending_venue)
		return COMPONENT_NO_AFTERATTACK
	else
		INVOKE_ASYNC(src, .proc/warn_greytider, user)


/datum/ai_controller/robot_customer/proc/eat_order(obj/item/order_item, datum/venue/attending_venue)
	if(!blackboard[BB_CUSTOMER_EATING])
		blackboard[BB_CUSTOMER_EATING] = TRUE
		attending_venue.on_get_order(pawn, order_item)


///Called when
/datum/ai_controller/robot_customer/proc/on_get_pulled(datum/source, mob/living/puller)
	SIGNAL_HANDLER


	INVOKE_ASYNC(src, .proc/async_on_get_pulled, source, puller)

/datum/ai_controller/robot_customer/proc/async_on_get_pulled(datum/source, mob/living/puller)
	var/mob/living/simple_animal/robot_customer/customer = pawn
	var/datum/customer_data/customer_data = blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	var/obj/item/card/id/used_id = puller.get_idcard(TRUE)

	if(used_id && (attending_venue.req_access in used_id?.GetAccess()))
		customer.say(customer_data.friendly_pull_line)
		return
	warn_greytider(puller)
	customer.resist()




/datum/ai_controller/robot_customer/proc/warn_greytider(mob/living/greytider)
	var/mob/living/simple_animal/robot_customer/customer = pawn
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	var/datum/customer_data/customer_data = blackboard[BB_CUSTOMER_CUSTOMERINFO]
	attending_venue.mob_blacklist[greytider] += 1

	switch(attending_venue.mob_blacklist[greytider])
		if(1)
			customer.say(customer_data.first_warning_line)
			return
		if(2)
			customer.say(customer_data.second_warning_line)
			return
		if(3)
			customer.say(customer_data.self_defense_line)
	blackboard[BB_CUSTOMER_CURRENT_TARGET] = greytider

	CancelActions()

/datum/ai_controller/robot_customer/proc/on_get_punched(datum/source, mob/living/living_hitter)
	SIGNAL_HANDLER

	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	var/obj/item/card/id/used_id = living_hitter.get_idcard(hand_first = TRUE)

	if(used_id && (attending_venue.req_access in used_id?.GetAccess()))
		return

	if(living_hitter.combat_mode)
		INVOKE_ASYNC(src, .proc/warn_greytider, living_hitter)
