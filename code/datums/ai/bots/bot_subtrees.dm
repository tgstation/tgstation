#define BOT_NO_BEACON_PATH_PENALTY 30 SECONDS

/**
 * Searches for a valid target in oview and sets a blackboard key when found.
 * Subtypes override valid_target() to refine selection criteria.
 * looking_for is an optional typecache pre-filter; pass null to check all atoms via valid_target().
 */
/datum/bt_node/ai_behavior/bot_search
	var/target_key
	var/looking_for = null
	var/radius = 5
	var/pathing_distance = 10
	var/bypass_add_blacklist = FALSE
	var/turf_search = FALSE
	/// How close the path must get to the target (0 = onto/adjacent). Repairbot raises this so it stops next to the walls/girders it repairs.
	var/minimum_distance = 0
	time_between_perform = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// Set while an async reachability search is going on
	var/is_searching = FALSE
	/// TRUE once the async search has written its result.
	var/async_search_done = FALSE
	/// Result of the async search: TRUE if a reachable target was found and set.
	var/async_search_succeeded = FALSE

/datum/bt_node/ai_behavior/bot_search/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	if(!istype(controller))
		stack_trace("attempted to give [controller.pawn] the bot search behavior!")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	// Async search in flight — stay RUNNING.
	if(is_searching)
		return AI_BEHAVIOR_DELAY

	// Async search just finished — consume result.
	if(async_search_done)
		return AI_BEHAVIOR_DELAY | (async_search_succeeded ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

	if(isnull(looking_for))
		looking_for = get_looking_for_typecache()

	// Build candidate list synchronously (no sleeping), then hand off to async.
	var/mob/living/living_pawn = controller.pawn
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/list/candidates = list()
	for(var/atom/potential_target as anything in (turf_search ? RANGE_TURFS(radius, controller.pawn) : oview(radius, controller.pawn)))
		if(!isnull(looking_for) && !is_type_in_typecache(potential_target, looking_for))
			continue
		if(LAZYACCESS(ignore_list, potential_target))
			continue
		if(!valid_target(controller, potential_target))
			continue
		if(!can_see(controller.pawn, potential_target, radius))
			continue
		candidates += potential_target

	if(!length(candidates))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] bot_search ([type]): no valid target found in radius [radius]")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	is_searching = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_search), controller, candidates)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/bot_search/proc/async_search(datum/ai_controller/basic_controller/bot/controller, list/candidates)
	var/mob/living/living_pawn = controller.pawn
	var/found = FALSE
	for(var/atom/potential_target as anything in candidates)
		if(!is_searching || QDELETED(living_pawn))
			break
		if(controller.set_if_can_reach(key = target_key, target = potential_target, distance = pathing_distance, bypass_add_to_blacklist = bypass_add_blacklist, minimum_distance = minimum_distance))
			found = TRUE
			break
	if(!is_searching)
		return
	if(!found)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] bot_search ([type]): no reachable target found")
	async_search_succeeded = found
	async_search_done = TRUE
	is_searching = FALSE

/datum/bt_node/ai_behavior/bot_search/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_searching = FALSE
	async_search_done = FALSE
	async_search_succeeded = FALSE

/datum/bt_node/ai_behavior/bot_search/proc/get_looking_for_typecache()
	return

/datum/bt_node/ai_behavior/bot_search/proc/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	return TRUE


///Performs bot speech from a list of options
/datum/bt_node/ai_behavior/bot_speech
	var/list/list_to_pick_from
	var/announce_key
	time_between_perform = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/bot_speech/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[announce_key]
	if(isnull(announcement) || !length(list_to_pick_from))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	announcement.announce(pick(list_to_pick_from))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


///Interact with an object. Could probably be moved to a generic behavior as the only unique thing is the blacklist.
/datum/bt_node/ai_behavior/bot_interact
	var/target_key
	var/clear_target = TRUE

/datum/bt_node/ai_behavior/bot_interact/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(living_pawn, target) > 1)
		return AI_BEHAVIOR_INSTANT
	living_pawn.UnarmedAttack(target, proximity_flag = TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/bot_interact/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(clear_target)
		controller.clear_blackboard_key(target_key)
	if(!succeeded && !isnull(target))
		controller.add_to_blacklist(target)

/// Variant that keeps the target key after interacting (caller must clear it).
/datum/bt_node/ai_behavior/bot_interact/keep_target
	clear_target = FALSE


/// Searches GLOB.deliverybeacons for a beacon whose location matches the tag in tag_key, and sets it as target_key.
/datum/bt_node/ai_behavior/find_delivery_beacon
	var/target_key
	/// Blackboard key holding the location tag string to match against beacon.location.
	var/tag_key
	time_between_perform = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/find_delivery_beacon/perform(seconds_per_tick, datum/ai_controller/controller)
	var/beacon_tag = controller.blackboard[tag_key]
	if(isnull(beacon_tag))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	for(var/obj/machinery/navbeacon/beacon as anything in GLOB.deliverybeacons)
		if(beacon.location != beacon_tag)
			continue
		controller.set_blackboard_key(target_key, beacon)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

///Find the closest beacon and set it as the target
/datum/bt_node/ai_behavior/find_first_beacon_target
	var/target_key

/datum/bt_node/ai_behavior/find_first_beacon_target/perform(seconds_per_tick, datum/ai_controller/controller)
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
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_first_beacon_target: no beacon found on z=[bot_pawn.z] (previous=[previous_target])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] first beacon target: [final_target]", get_turf(final_target), "Beacon")
	EVLOG_LINES(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "Beacon path", get_turf(bot_pawn), get_turf(final_target))
	controller.set_blackboard_key(target_key, final_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

///Find the next beacon from a previous target and set it as the new target
/datum/bt_node/ai_behavior/find_next_beacon_target
	var/target_key
	time_between_perform = 5 SECONDS
	/// Set while an async reachability check is still going on
	var/is_checking_reach = FALSE
	/// TRUE once the async check has written its result.
	var/async_check_done = FALSE
	/// Result of the async check.
	var/async_check_succeeded = FALSE

/datum/bt_node/ai_behavior/find_next_beacon_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	// Async check in flight — stay RUNNING.
	if(is_checking_reach)
		return AI_BEHAVIOR_DELAY

	// Async check just finished — consume result.
	if(async_check_done)
		return AI_BEHAVIOR_DELAY | (async_check_succeeded ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/obj/machinery/navbeacon/prev_beacon = controller.blackboard[BB_PREVIOUS_BEACON_TARGET]
	if(QDELETED(prev_beacon))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_next_beacon_target: previous beacon is deleted")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/final_target
	for(var/obj/machinery/navbeacon/beacon as anything in GLOB.navbeacons["[bot_pawn.z]"])
		if(beacon.location == prev_beacon.codes[NAVBEACON_PATROL_NEXT])
			final_target = beacon
			break

	if(isnull(final_target))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_next_beacon_target: no beacon with location=[prev_beacon.codes[NAVBEACON_PATROL_NEXT]] (prev=[prev_beacon])")
		controller.clear_blackboard_key(BB_PREVIOUS_BEACON_TARGET)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_PREVIOUS_BEACON_TARGET, final_target)
	controller.clear_blackboard_key(target_key)

	if(LAZYACCESS(controller.blackboard[BB_TEMPORARY_IGNORE_LIST], final_target) || get_dist(bot_pawn, final_target) > controller.max_target_distance)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_next_beacon_target: [final_target] ignored or out of range (dist=[get_dist(bot_pawn, final_target)] max=[controller.max_target_distance])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	is_checking_reach = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_check_beacon_reach), controller, final_target)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/find_next_beacon_target/proc/async_check_beacon_reach(datum/ai_controller/basic_controller/bot/controller, atom/final_target)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/reached = controller.set_if_can_reach(key = target_key, target = final_target, duration = 3 MINUTES, distance = controller.max_target_distance)
	if(!is_checking_reach || QDELETED(bot_pawn))
		return
	if(!reached)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_next_beacon_target: can't reach [final_target], applying cooldown")
		controller.set_blackboard_key(BB_BOT_BEACON_COOLDOWN, world.time + BOT_NO_BEACON_PATH_PENALTY)
	async_check_succeeded = reached
	async_check_done = TRUE
	is_checking_reach = FALSE

/datum/bt_node/ai_behavior/find_next_beacon_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_checking_reach = FALSE
	async_check_done = FALSE
	async_check_succeeded = FALSE

/// Records the beacon as visited and clears the target key once the bot is on the same turf.
/datum/bt_node/ai_behavior/arrive_at_beacon
	var/target_key

/datum/bt_node/ai_behavior/arrive_at_beacon/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	var/obj/machinery/navbeacon/beacon = controller.blackboard[target_key]
	if(QDELETED(beacon))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, beacon) > 0)
		return AI_BEHAVIOR_INSTANT
	controller.set_blackboard_key(BB_PREVIOUS_BEACON_TARGET, beacon)
	controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED


/// Completes summon travel once the bot reaches the summon target's turf.
/datum/bt_node/ai_behavior/complete_summon_travel
	var/target_key

/datum/bt_node/ai_behavior/complete_summon_travel/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(QDELETED(bot_pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/atom/target = controller.blackboard[target_key]
	if(get_dist(bot_pawn, target) > 0)
		return AI_BEHAVIOR_INSTANT
	bot_pawn.calling_ai_ref = null
	bot_pawn.update_bot_mode(new_mode = BOT_IDLE)
	controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

///Find a valid authority to salute and set them as the target
/datum/bt_node/ai_behavior/find_valid_authority
	var/target_key
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/find_valid_authority/perform(seconds_per_tick, datum/ai_controller/controller)
	for(var/mob/living/nearby_mob in oview(7, controller.pawn))
		if(!HAS_TRAIT(nearby_mob, TRAIT_COMMISSIONED))
			continue
		controller.set_blackboard_key(target_key, nearby_mob)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

///Salute the authority /(o.o)
/datum/bt_node/ai_behavior/salute_authority
	var/target_key
	var/salute_keys

/datum/bt_node/ai_behavior/salute_authority/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/salute_list = controller.blackboard[salute_keys]
	if(!length(salute_list))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/obj/item/our_hat = (locate(/obj/item/clothing/head) in bot_pawn)
	if(our_hat)
		salute_list += "tips [our_hat] at "
	bot_pawn.manual_emote(pick(salute_list) + " [controller.blackboard[target_key]]!")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/salute_authority/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)


/// Travel to BB_BOT_SUMMON_TARGET if set, completing when on the same turf.
/datum/bt_node/subtree/bot_respond_to_summon
	behavior_tree_json = "code/datums/ai/bots/bot_respond_to_summon.bt.json"

/// Salute any commissioned officer in range
/datum/bt_node/subtree/bot_salute_authority
	behavior_tree_json = "code/datums/ai/bots/bot_salute_authority.bt.json"

/**
 * Patrol to navbeacons in sequence when autopatrol is enabled and not on cooldown.
 * Priority: travel to current target -> find next in chain -> find first (nearest) beacon.
 */
/datum/bt_node/subtree/bot_patrol
	behavior_tree_json = "code/datums/ai/bots/bot_patrol.bt.json"


#undef BOT_NO_BEACON_PATH_PENALTY
