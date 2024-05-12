/datum/ai_controller/basic_controller/bot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SALUTE_MESSAGES = list(
			"salutes",
			"nods in appreciation towards",
			"fist bumps",
		)
	)

	ai_movement = /datum/ai_movement/jps/bot
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/salute_authority,
		/datum/ai_planning_subtree/find_patrol_beacon,
		/datum/ai_planning_subtree/manage_unreachable_list,
	)
	max_target_distance = AI_BOT_PATH_LENGTH
	///keys to be reset when the bot is reseted
	var/list/reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
	///how many times we tried to reach the target
	var/current_pathing_attempts = 0
	///if we cant reach it after this many attempts, add it to our ignore list
	var/max_pathing_attempts = 25
	can_idle = FALSE // we want these to be running always

/datum/ai_controller/basic_controller/bot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_BOT_RESET, PROC_REF(reset_bot))

/datum/ai_controller/basic_controller/bot/able_to_run()
	var/mob/living/basic/bot/bot_pawn = pawn
	if(!(bot_pawn.bot_mode_flags & BOT_MODE_ON))
		return FALSE
	return ..()

/datum/ai_controller/basic_controller/bot/get_access()
	var/mob/living/basic/bot/basic_bot = pawn
	return basic_bot.access_card?.access

/datum/ai_controller/basic_controller/bot/proc/reset_bot()
	SIGNAL_HANDLER

	if(!length(reset_keys))
		return
	for(var/key in reset_keys)
		clear_blackboard_key(key)

///set the target if we can reach them
/datum/ai_controller/basic_controller/bot/proc/set_if_can_reach(key, target, distance = 10)
	if(can_reach_target(target, distance))
		set_blackboard_key(key, target)
		return TRUE
	return FALSE

/datum/ai_controller/basic_controller/bot/proc/can_reach_target(target, distance = 10)
	if(!isdatum(target)) //we dont need to check if its not a datum!
		return TRUE
	if(get_turf(pawn) == get_turf(target))
		return TRUE
	var/list/path = get_path_to(pawn, target, max_distance = distance, access = get_access())
	if(!length(path))
		return FALSE
	return TRUE

///check if the target is too far away, and delete them if so and add them to the unreachables list
/datum/ai_controller/basic_controller/bot/proc/reachable_key(key, distance = 10)
	var/datum/target = blackboard[key]
	if(QDELETED(target))
		return FALSE
	var/datum/last_attempt = blackboard[BB_LAST_ATTEMPTED_PATHING]
	if(last_attempt != target)
		current_pathing_attempts = 0
		set_blackboard_key(BB_LAST_ATTEMPTED_PATHING, target)
	else
		current_pathing_attempts++
	if(current_pathing_attempts >= max_pathing_attempts || !can_reach_target(target, distance))
		clear_blackboard_key(key)
		clear_blackboard_key(BB_LAST_ATTEMPTED_PATHING)
		set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, TRUE)
		return FALSE
	return TRUE

/// subtree to manage our list of unreachables, we reset it every 15 seconds
/datum/ai_planning_subtree/manage_unreachable_list

/datum/ai_planning_subtree/manage_unreachable_list/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/manage_unreachable_list, BB_TEMPORARY_IGNORE_LIST)

/datum/ai_behavior/manage_unreachable_list
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 45 SECONDS

/datum/ai_behavior/manage_unreachable_list/perform(seconds_per_tick, datum/ai_controller/controller, list_key)
	. = ..()
	if(!isnull(controller.blackboard[list_key]))
		controller.clear_blackboard_key(list_key)
	finish_action(controller, TRUE)


/datum/ai_planning_subtree/find_patrol_beacon

/datum/ai_planning_subtree/find_patrol_beacon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(!(bot_pawn.bot_mode_flags & BOT_MODE_AUTOPATROL) || bot_pawn.mode == BOT_SUMMON)
		return

	if(controller.blackboard_key_exists(BB_BEACON_TARGET))
		bot_pawn.update_bot_mode(new_mode = BOT_PATROL)
		controller.queue_behavior(/datum/ai_behavior/travel_towards/beacon, BB_BEACON_TARGET)
		return

	if(controller.blackboard_key_exists(BB_PREVIOUS_BEACON_TARGET))
		controller.queue_behavior(/datum/ai_behavior/find_next_beacon_target, BB_BEACON_TARGET)
		return

	controller.queue_behavior(/datum/ai_behavior/find_first_beacon_target, BB_BEACON_TARGET)

/datum/ai_behavior/find_first_beacon_target

/datum/ai_behavior/find_first_beacon_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/closest_distance = INFINITY
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/final_target
	var/atom/previous_target = controller.blackboard[BB_PREVIOUS_BEACON_TARGET]
	for(var/obj/machinery/navbeacon/beacon as anything in GLOB.navbeacons["[bot_pawn.z]"])
		if(beacon == previous_target)
			continue
		var/dist = get_dist(bot_pawn, beacon)
		if(dist > closest_distance)
			continue
		closest_distance = dist
		final_target = beacon

	if(isnull(final_target))
		finish_action(controller, FALSE)
		return
	controller.set_blackboard_key(BB_BEACON_TARGET, final_target)
	finish_action(controller, TRUE)

/datum/ai_behavior/find_next_beacon_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/final_target
	var/obj/machinery/navbeacon/prev_beacon = controller.blackboard[BB_PREVIOUS_BEACON_TARGET]
	if(QDELETED(prev_beacon))
		finish_action(controller, FALSE)
		return

	for(var/obj/machinery/navbeacon/beacon as anything in GLOB.navbeacons["[bot_pawn.z]"])
		if(beacon.location == prev_beacon.codes[NAVBEACON_PATROL_NEXT])
			final_target = beacon
			break

	if(isnull(final_target))
		controller.clear_blackboard_key(BB_PREVIOUS_BEACON_TARGET)
		finish_action(controller, FALSE)

	controller.set_blackboard_key(BB_BEACON_TARGET, final_target)
	finish_action(controller, TRUE)


/datum/ai_behavior/travel_towards/beacon
	clear_target = TRUE

/datum/ai_behavior/travel_towards/beacon/finish_action(datum/ai_controller/controller, succeeded, target_key)
	var/atom/target = controller.blackboard[target_key]
	controller.set_blackboard_key(BB_PREVIOUS_BEACON_TARGET, target)
	return ..()

/datum/ai_planning_subtree/respond_to_summon

/datum/ai_planning_subtree/respond_to_summon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_BOT_SUMMON_TARGET))
		return
	controller.clear_blackboard_key(BB_PREVIOUS_BEACON_TARGET)
	controller.clear_blackboard_key(BB_BEACON_TARGET)
	controller.queue_behavior(/datum/ai_behavior/travel_towards/bot_summon, BB_BOT_SUMMON_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/travel_towards/bot_summon
	clear_target = TRUE

/datum/ai_behavior/travel_towards/bot_summon/finish_action(datum/ai_controller/controller, succeeded, target_key)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	bot_pawn.calling_ai_ref = null
	bot_pawn.update_bot_mode(new_mode = BOT_IDLE)
	return ..()

/datum/ai_planning_subtree/salute_authority

/datum/ai_planning_subtree/salute_authority/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	//we are criminals, dont salute the dirty pigs
	if(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)
		return
	if(controller.blackboard_key_exists(BB_SALUTE_TARGET))
		controller.queue_behavior(/datum/ai_behavior/salute_authority, BB_SALUTE_TARGET, BB_SALUTE_MESSAGES)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/valid_authority, BB_SALUTE_TARGET)


/datum/ai_behavior/find_and_set/valid_authority
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 30 SECONDS

/datum/ai_behavior/find_and_set/valid_authority/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/mob/living/robot in oview(search_range, controller.pawn))
		if(istype(robot, /mob/living/simple_animal/bot/secbot))
			return robot
		if(!istype(robot, /mob/living/basic/bot/cleanbot))
			continue
		var/mob/living/basic/bot/cleanbot/potential_bot = robot
		if(potential_bot.comissioned)
			return potential_bot
	return null

/datum/ai_behavior/salute_authority

/datum/ai_behavior/salute_authority/perform(seconds_per_tick, datum/ai_controller/controller, target_key, salute_keys)
	. = ..()
	if(!controller.blackboard_key_exists(target_key))
		finish_action(controller, FALSE, target_key)
		return
	var/list/salute_list = controller.blackboard[salute_keys]
	if(!length(salute_list))
		finish_action(controller, FALSE, target_key)
		return
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	//special interaction if we are wearing a fedora
	var/obj/item/our_hat = (locate(/obj/item/clothing/head) in bot_pawn)
	if(our_hat)
		salute_list += "tips [our_hat] at "

	bot_pawn.manual_emote(pick(salute_list) + " [controller.blackboard[target_key]]")
	finish_action(controller, TRUE, target_key)
	return

/datum/ai_behavior/salute_authority/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
