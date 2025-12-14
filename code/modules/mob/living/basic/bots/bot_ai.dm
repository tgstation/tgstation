#define BOT_NO_BEACON_PATH_PENALTY 30 SECONDS

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
	planning_subtrees = list(
/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/salute_authority,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)
	max_target_distance = AI_BOT_PATH_LENGTH
	can_idle = FALSE
	///minimum distance we need to be from our target in path calculations
	var/minimum_distance = 0
	///keys to be reset when the bot is reseted
	var/list/reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/targeting_strategy/basic/bot/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/datum/ai_controller/basic_controller/bot/my_controller = living_mob.ai_controller
	if(isnull(my_controller))
		return FALSE
	if(!ishuman(the_target) || LAZYACCESS(my_controller.blackboard[BB_TEMPORARY_IGNORE_LIST], the_target))
		return FALSE
	var/mob/living/living_target = the_target
	if(isnull(living_target.mind))
		return FALSE
	if(get_turf(living_mob) == get_turf(living_target))
		return ..()
	var/list/path = get_path_to(living_mob, living_target, mintargetdist = my_controller.minimum_distance, max_distance = 10, access = my_controller.get_access())
	if(!length(path) || QDELETED(living_mob))
		my_controller?.add_to_blacklist(living_target)
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

/datum/ai_controller/basic_controller/bot/proc/add_to_blacklist(atom/target, duration)
	var/final_duration = duration || blackboard[BB_UNREACHABLE_LIST_COOLDOWN]
	set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, TRUE)
	addtimer(CALLBACK(src, PROC_REF(remove_from_blacklist), target), final_duration)

/datum/ai_controller/basic_controller/bot/proc/remove_from_blacklist(atom/target)
	if(QDELETED(target))
		return
	remove_from_blackboard_lazylist_key(BB_TEMPORARY_IGNORE_LIST, target)

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
		return AI_UNABLE_TO_RUN
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
/datum/ai_controller/basic_controller/bot/proc/set_if_can_reach(key, target, duration, distance = 10, bypass_add_to_blacklist = FALSE)
	if(can_reach_target(target, distance))
		set_blackboard_key(key, target)
		return TRUE
	if(bypass_add_to_blacklist)
		return FALSE
	var/final_duration = duration || blackboard[BB_UNREACHABLE_LIST_COOLDOWN]
	add_to_blacklist(target, final_duration)
	return FALSE

/datum/ai_controller/basic_controller/bot/proc/can_reach_target(target, distance = 10)
	if(!isdatum(target)) //we dont need to check if its not a datum!
		return TRUE
	if(get_turf(pawn) == get_turf(target))
		return TRUE
	var/list/path = get_path_to(pawn, target, simulated_only = !HAS_TRAIT(pawn, TRAIT_SPACEWALK), mintargetdist = minimum_distance, max_distance = distance, access = get_access())
	return (!!length(path))

/datum/ai_planning_subtree/find_patrol_beacon
	///travel towards beacon behavior
	var/travel_behavior = /datum/ai_behavior/travel_towards/beacon

/datum/ai_planning_subtree/find_patrol_beacon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn

	if(controller.blackboard[BB_BOT_BEACON_COOLDOWN] > world.time)
		return

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

/datum/ai_behavior/find_next_beacon_target
	action_cooldown = 5 SECONDS

/datum/ai_behavior/find_next_beacon_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
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
		controller.clear_blackboard_key(BB_PREVIOUS_BEACON_TARGET) //failed to find the next beacon, search for a first beacon again
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_PREVIOUS_BEACON_TARGET, final_target)
	controller.clear_blackboard_key(BB_BEACON_TARGET)

	if(LAZYACCESS(controller.blackboard[BB_TEMPORARY_IGNORE_LIST], final_target) || get_dist(bot_pawn, final_target) > controller.max_target_distance)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(controller.set_if_can_reach(key = BB_BEACON_TARGET, target = final_target, duration = 3 MINUTES, distance = controller.max_target_distance))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	controller.set_blackboard_key(BB_BOT_BEACON_COOLDOWN, world.time + BOT_NO_BEACON_PATH_PENALTY)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED


/datum/ai_behavior/travel_towards/beacon
	clear_target = TRUE
	new_movement_type = /datum/ai_movement/jps/bot/travel_to_beacon

/datum/ai_behavior/travel_towards/beacon/setup(datum/ai_controller/controller, target_key)
	var/atom/target_beacon = controller.blackboard[target_key]
	if(LAZYACCESS(controller.blackboard[BB_TEMPORARY_IGNORE_LIST], target_beacon))
		return FALSE
	return ..()

/datum/ai_behavior/travel_towards/beacon/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(!succeeded)
		controller.set_blackboard_key(BB_BOT_BEACON_COOLDOWN, world.time + BOT_NO_BEACON_PATH_PENALTY)
		controller.add_to_blacklist(target, 3 MINUTES)
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

/datum/ai_behavior/bot_search/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = FALSE)
	if(!istype(controller))
		stack_trace("attempted to give [controller.pawn] the bot search behavior!")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_pawn = controller.pawn
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/list/objects_to_search = turf_search ? RANGE_TURFS(radius, controller.pawn) : oview(radius, controller.pawn) //use range turfs instead of oview when we can for performance
	for(var/atom/potential_target as anything in objects_to_search)
		if(QDELETED(living_pawn))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		if(!is_type_in_typecache(potential_target, looking_for))
			continue
		if(LAZYACCESS(ignore_list, potential_target))
			continue
		if(!valid_target(controller, potential_target))
			continue
		if(!can_see(controller.pawn, potential_target, radius))
			continue
		if(controller.set_if_can_reach(key = target_key, target = potential_target, distance = pathing_distance, bypass_add_to_blacklist = bypass_add_blacklist))
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

///behavior to interact with atoms
/datum/ai_behavior/bot_interact
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	///should we remove the target afterwards?
	var/clear_target = TRUE

/datum/ai_behavior/bot_interact/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/bot_interact/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	living_pawn.UnarmedAttack(target, proximity_flag = TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/bot_interact/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(clear_target)
		controller.clear_blackboard_key(target_key)
	if(!succeeded && !isnull(target))
		controller.add_to_blacklist(target)

/datum/ai_behavior/bot_interact/keep_target
	clear_target = FALSE


#undef BOT_NO_BEACON_PATH_PENALTY
