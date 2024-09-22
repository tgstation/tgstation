/datum/ai_controller/basic_controller/bot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SALUTE_MESSAGES = list(
			"performs an elaborate salute for",
			"nods in appreciation towards",
		),
		BB_UNREACHABLE_LIST_COOLDOWN = 45 SECONDS,
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
	can_idle = FALSE

/datum/targeting_strategy/basic/bot/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/datum/ai_controller/my_controller = living_mob.ai_controller
	if(isnull(my_controller))
		return FALSE
	if(!ishuman(the_target) || LAZYACCESS(my_controller.blackboard[BB_TEMPORARY_IGNORE_LIST], the_target))
		return FALSE
	var/mob/living/living_target = the_target
	if(isnull(living_target.mind))
		return FALSE
	if(get_turf(living_mob) == get_turf(living_target))
		return ..()
	var/list/path = get_path_to(living_mob, living_target, max_distance = 10, access = my_controller.get_access())
	if(!length(path) || QDELETED(living_mob))
		my_controller?.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, living_target, TRUE)
		return FALSE
	return ..()

/datum/ai_controller/basic_controller/bot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_BOT_RESET, PROC_REF(reset_bot))
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_BOT_SUMMON_TARGET), PROC_REF(clear_summon))
	RegisterSignal(new_pawn, COMSIG_MOB_AI_MOVEMENT_STARTED, PROC_REF(on_movement_start))

/datum/ai_controller/basic_controller/bot/proc/on_movement_start(mob/living/basic/bot/source, atom/target)
	SIGNAL_HANDLER
	if(current_movement_target == blackboard[BB_BEACON_TARGET])
		source.update_bot_mode(new_mode = BOT_PATROL)

/datum/ai_controller/basic_controller/bot/proc/clear_summon()
	SIGNAL_HANDLER

	var/mob/living/basic/bot/bot_pawn = pawn
	bot_pawn.bot_reset()

/datum/ai_controller/basic_controller/bot/setup_able_to_run()
	. = ..()
	RegisterSignal(pawn, COMSIG_BOT_MODE_FLAGS_SET, PROC_REF(update_able_to_run))

/datum/ai_controller/basic_controller/bot/clear_able_to_run()
	UnregisterSignal(pawn, list(COMSIG_BOT_MODE_FLAGS_SET))
	return ..()

/datum/ai_controller/basic_controller/bot/get_able_to_run()
	var/mob/living/basic/bot/bot_pawn = pawn
	if(!(bot_pawn.bot_mode_flags & BOT_MODE_ON))
		return FALSE
	return ..()

/datum/ai_controller/basic_controller/bot/get_access()
	var/mob/living/basic/bot/basic_bot = pawn
	return basic_bot.access_card?.access

/datum/ai_controller/basic_controller/bot/proc/reset_bot()
	SIGNAL_HANDLER
	CancelActions()
	if(!length(reset_keys))
		return
	for(var/key in reset_keys)
		clear_blackboard_key(key)

///set the target if we can reach them
/datum/ai_controller/basic_controller/bot/proc/set_if_can_reach(key, target, distance = 10, bypass_add_to_blacklist = FALSE)
	if(can_reach_target(target, distance))
		set_blackboard_key(key, target)
		return TRUE
	if(!bypass_add_to_blacklist)
		set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, TRUE)
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

/// subtree to manage our list of unreachables, we reset it every 15 seconds
/datum/ai_planning_subtree/manage_unreachable_list

/datum/ai_planning_subtree/manage_unreachable_list/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(isnull(controller.blackboard[BB_UNREACHABLE_LIST_COOLDOWN]) || controller.blackboard[BB_CLEAR_LIST_READY] > world.time)
		return
	controller.queue_behavior(/datum/ai_behavior/manage_unreachable_list, BB_TEMPORARY_IGNORE_LIST)

/datum/ai_behavior/manage_unreachable_list
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/manage_unreachable_list/perform(seconds_per_tick, datum/ai_controller/controller, list_key)
	if(!isnull(controller.blackboard[list_key]))
		controller.clear_blackboard_key(list_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/manage_unreachable_list/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.set_blackboard_key(BB_CLEAR_LIST_READY, controller.blackboard[BB_UNREACHABLE_LIST_COOLDOWN] + world.time)

/datum/ai_planning_subtree/find_patrol_beacon
	///travel towards beacon behavior
	var/travel_behavior = /datum/ai_behavior/travel_towards/beacon

/datum/ai_planning_subtree/find_patrol_beacon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(!(bot_pawn.bot_mode_flags & BOT_MODE_AUTOPATROL) || bot_pawn.mode == BOT_SUMMON)
		return

	if(controller.blackboard_key_exists(BB_BEACON_TARGET))
		controller.queue_behavior(travel_behavior, BB_BEACON_TARGET)
		return

	if(controller.blackboard_key_exists(BB_PREVIOUS_BEACON_TARGET))
		controller.queue_behavior(/datum/ai_behavior/find_next_beacon_target, BB_BEACON_TARGET)
		return

	controller.queue_behavior(/datum/ai_behavior/find_first_beacon_target, BB_BEACON_TARGET)

/datum/ai_behavior/find_first_beacon_target

/datum/ai_behavior/find_first_beacon_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/closest_distance = INFINITY
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/final_target
	var/atom/previous_target = controller.blackboard[BB_PREVIOUS_BEACON_TARGET]
	for(var/obj/machinery/navbeacon/beacon as anything in GLOB.navbeacons["[bot_pawn.z]"])
		var/dist = get_dist(bot_pawn, beacon)
		if(beacon == previous_target || dist <= 1)
			continue
		if(dist > closest_distance)
			continue
		closest_distance = dist
		final_target = beacon

	if(isnull(final_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_BEACON_TARGET, final_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_next_beacon_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/final_target
	var/obj/machinery/navbeacon/prev_beacon = controller.blackboard[BB_PREVIOUS_BEACON_TARGET]
	if(QDELETED(prev_beacon))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	for(var/obj/machinery/navbeacon/beacon as anything in GLOB.navbeacons["[bot_pawn.z]"])
		if(beacon.location == prev_beacon.codes[NAVBEACON_PATROL_NEXT])
			final_target = beacon
			break

	if(isnull(final_target))
		controller.clear_blackboard_key(BB_PREVIOUS_BEACON_TARGET)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_BEACON_TARGET, final_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/datum/ai_behavior/travel_towards/beacon
	clear_target = TRUE
	new_movement_type = /datum/ai_movement/jps/bot/travel_to_beacon

/datum/ai_behavior/travel_towards/beacon/finish_action(datum/ai_controller/controller, succeeded, target_key)
	var/atom/target = controller.blackboard[target_key]
	controller.set_blackboard_key(BB_PREVIOUS_BEACON_TARGET, target)
	return ..()

/datum/ai_planning_subtree/respond_to_summon

/datum/ai_planning_subtree/respond_to_summon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_BOT_SUMMON_TARGET))
		return
	controller.queue_behavior(/datum/ai_behavior/travel_towards/bot_summon, BB_BOT_SUMMON_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/travel_towards/bot_summon
	clear_target = TRUE
	new_movement_type = /datum/ai_movement/jps/bot/travel_to_beacon

/datum/ai_behavior/travel_towards/bot_summon/finish_action(datum/ai_controller/controller, succeeded, target_key)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(QDELETED(bot_pawn)) // pawn can be null at this point
		return ..()
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
	action_cooldown = BOT_COMMISSIONED_SALUTE_DELAY

/datum/ai_behavior/find_and_set/valid_authority/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/mob/living/nearby_mob in oview(search_range, controller.pawn))
		if(!HAS_TRAIT(nearby_mob, TRAIT_COMMISSIONED))
			continue
		return nearby_mob
	return null

/datum/ai_behavior/salute_authority

/datum/ai_behavior/salute_authority/perform(seconds_per_tick, datum/ai_controller/controller, target_key, salute_keys)
	if(!controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/salute_list = controller.blackboard[salute_keys]
	if(!length(salute_list))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	//special interaction if we are wearing a fedora
	var/obj/item/our_hat = (locate(/obj/item/clothing/head) in bot_pawn)
	if(our_hat)
		salute_list += "tips [our_hat] at "

	bot_pawn.manual_emote(pick(salute_list) + " [controller.blackboard[target_key]]!")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/salute_authority/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/bot_search
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/bot_search/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE)
	if(!istype(controller))
		stack_trace("attempted to give [controller.pawn] the bot search behavior!")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_pawn = controller.pawn
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/atom/potential_target as anything in oview(radius, controller.pawn))
		if(QDELETED(living_pawn))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		if(!is_type_in_typecache(potential_target, looking_for))
			continue
		if(LAZYACCESS(ignore_list, potential_target))
			continue
		if(!valid_target(controller, potential_target))
			continue
		if(controller.set_if_can_reach(target_key, potential_target, distance = pathing_distance, bypass_add_to_blacklist = bypass_add_blacklist))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/bot_search/proc/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	return TRUE

///behavior to make our bot talk
/datum/ai_behavior/bot_speech
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/bot_speech/perform(seconds_per_tick, datum/ai_controller/controller, list/list_to_pick_from, announce_key)
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[announce_key]

	if(isnull(announcement) || !length(list_to_pick_from))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	announcement.announce(pick(list_to_pick_from))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
