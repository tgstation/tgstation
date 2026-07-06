/datum/ai_controller/basic_controller/bot/mulebot
	blackboard = list(
		BB_SALUTE_MESSAGES = list(
			"blinks its light in appreciation towards",
		)
	)
	ai_movement = /datum/ai_movement/jps/bot/mulebot
	max_target_distance = AI_MULEBOT_PATH_LENGTH
	planning_subtrees = list(
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/salute_authority,
		/datum/ai_planning_subtree/attempt_delivery,
		/datum/ai_planning_subtree/find_delivery_beacon,
	)
	reset_keys = list(
		BB_BOT_SUMMON_TARGET,
		BB_MULEBOT_DESTINATION_BEACON,
		BB_MULEBOT_TRAVEL_TARGET,
	)

/datum/ai_controller/basic_controller/bot/mulebot/get_able_to_run()
	var/mob/living/basic/bot/mulebot/bot_pawn = pawn
	if(!bot_pawn.has_power())
		return AI_UNABLE_TO_RUN
	return ..()

/datum/ai_controller/basic_controller/bot/mulebot/setup_able_to_run()
	. = ..()
	var/mob/living/basic/bot/my_bot = pawn
	var/static/list/wire_signals = list(
		COMSIG_MEND_WIRE(WIRE_POWER1), //this framework is insane
		COMSIG_MEND_WIRE(WIRE_POWER2),
		COMSIG_CUT_WIRE(WIRE_POWER1),
		COMSIG_CUT_WIRE(WIRE_POWER2),
	)
	RegisterSignals(my_bot.wires, wire_signals, PROC_REF(update_able_to_run))
	var/static/list/content_signals = list(
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_EXITED,
	)
	RegisterSignals(my_bot, content_signals, PROC_REF(update_able_to_run))

/datum/ai_planning_subtree/find_delivery_beacon
	///what behavior do we use to seek beacons
	var/find_beacon_behaviour = /datum/ai_behavior/find_delivery_beacon

/datum/ai_planning_subtree/find_delivery_beacon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/mulebot/bot_pawn = controller.pawn
	if(bot_pawn.wires.is_cut(WIRE_BEACON))
		return

	if(!controller.blackboard_key_exists(BB_MULEBOT_TRAVEL_TARGET))
		controller.queue_behavior(find_beacon_behaviour, BB_MULEBOT_TRAVEL_TARGET)

/datum/ai_behavior/find_delivery_beacon
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_delivery_beacon/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/bot/mulebot/bot_pawn = controller.pawn
	var/atom/delivery_beacon

	var/beacon_tag = null

	switch(bot_pawn.mode)
		if(BOT_DELIVER)
			beacon_tag = controller.blackboard[BB_MULEBOT_DESTINATION_BEACON]
		if(BOT_GO_HOME)
			beacon_tag = controller.blackboard[BB_MULEBOT_HOME_BEACON]
		else
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	for(var/obj/machinery/navbeacon/beacon as anything in GLOB.deliverybeacons)
		if(beacon.location == beacon_tag)
			delivery_beacon = beacon
			break

	if(isnull(delivery_beacon))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_MULEBOT_TRAVEL_TARGET, delivery_beacon)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/travel_towards/delivery_beacon
	new_movement_type = /datum/ai_movement/jps/bot/mulebot

/datum/ai_planning_subtree/attempt_delivery
	///behavior we use to unload crates
	var/delivery_behaviour = /datum/ai_behavior/handle_delivery

/datum/ai_planning_subtree/attempt_delivery/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_MULEBOT_TRAVEL_TARGET))
		return

	controller.queue_behavior(delivery_behaviour, BB_MULEBOT_TRAVEL_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/handle_delivery
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/handle_delivery/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/handle_delivery/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/obj/machinery/navbeacon/beacon = controller.blackboard[target_key]
	var/mob/living/basic/bot/mulebot/bot_pawn = controller.pawn

	var/load_direction = beacon.codes[NAVBEACON_DELIVERY_DIRECTION] // this will be the load/unload dir
	if(!load_direction)
		load_direction = beacon.dir // fallback

	load_direction = text2num(load_direction)

	if(bot_pawn.load)
		if(bot_pawn.mulebot_delivery_flags & MULEBOT_REPORT_DELIVERY_MODE)
			bot_pawn.radio_channel = RADIO_CHANNEL_SUPPLY //Supply channel
			bot_pawn.buzz(MULEBOT_MOOD_CHIME)
			bot_pawn.speak("Destination [RUNECHAT_BOLD("[beacon.location]")] reached. Unloading [bot_pawn.load].", bot_pawn.radio_channel)
			bot_pawn.unload(load_direction)

	else
		if(bot_pawn.mulebot_delivery_flags & MULEBOT_AUTO_PICKUP_MODE) // find a crate
			var/atom/movable/atom_to_pick_up
			if(bot_pawn.wires.is_cut(WIRE_LOADCHECK)) // if hacked, load first unanchored thing we find
				for(var/atom/movable/target_atom in get_step(bot_pawn.loc, load_direction))
					if(!target_atom.anchored)
						atom_to_pick_up = target_atom
						break
			else // otherwise, look for crates only
				atom_to_pick_up = locate(/obj/structure/closet/crate) in get_step(bot_pawn.loc, load_direction)
			if(atom_to_pick_up?.Adjacent(bot_pawn))
				bot_pawn.load(atom_to_pick_up)
				if(bot_pawn.mulebot_delivery_flags & MULEBOT_REPORT_DELIVERY_MODE)
					bot_pawn.speak("Now loading [bot_pawn.load] at [RUNECHAT_BOLD("[get_area_name(bot_pawn)]")].", bot_pawn.radio_channel)

	if((bot_pawn.mulebot_delivery_flags & MULEBOT_RETURN_MODE) && controller.blackboard[BB_MULEBOT_HOME_BEACON] && controller.blackboard[BB_MULEBOT_HOME_BEACON] != beacon.location)
		bot_pawn.update_bot_mode(new_mode = BOT_GO_HOME)
		controller.clear_blackboard_key(BB_MULEBOT_TRAVEL_TARGET)
	else
		bot_pawn.bot_reset() // otherwise go idle

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
