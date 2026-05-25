#define BOT_NO_BEACON_PATH_PENALTY 30 SECONDS

// =============================================================================
// Bot search (base BT behavior for all bot-specific range searches)
// =============================================================================

/**
 * Searches for a valid target in oview and sets a blackboard key when found.
 * Subtypes override valid_target() to refine selection criteria.
 * looking_for is an optional typecache pre-filter; pass null to check all atoms via valid_target().
 */
/datum/bt_node/ai_behavior/bot_search
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/bot_search/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for = null, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = FALSE)
	if(!istype(controller))
		stack_trace("attempted to give [controller.pawn] the bot search behavior!")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_pawn = controller.pawn
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/list/objects_to_search = turf_search ? RANGE_TURFS(radius, controller.pawn) : oview(radius, controller.pawn)
	for(var/atom/potential_target as anything in objects_to_search)
		if(QDELETED(living_pawn))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		if(!isnull(looking_for) && !is_type_in_typecache(potential_target, looking_for))
			continue
		if(LAZYACCESS(ignore_list, potential_target))
			continue
		if(!valid_target(controller, potential_target))
			continue
		if(!can_see(controller.pawn, potential_target, radius))
			continue
		if(controller.set_if_can_reach(key = target_key, target = potential_target, distance = pathing_distance, bypass_add_to_blacklist = bypass_add_blacklist))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] bot_search ([type]): no valid target found in radius [radius]")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/bot_search/proc/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	return TRUE

// =============================================================================
// Drag target
// =============================================================================

/**
 * BT-native grab behavior. Calls start_pulling on the target; does NOT clear the blackboard key.
 * Callers are responsible for key cleanup (typically via on_stop_pulling signal handlers).
 */
/datum/bt_node/ai_behavior/drag_target

/datum/bt_node/ai_behavior/drag_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored || target.pulledby)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] drag_target: can't grab [target] (deleted=[QDELETED(target)], anchored=[target?.anchored], pulledby=[target?.pulledby])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/our_mob = controller.pawn
	if(get_dist(our_mob, target) > 0)
		return AI_BEHAVIOR_INSTANT
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[our_mob] grabbing [target]", get_turf(target), "Grab")
	our_mob.start_pulling(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Bot speech
// =============================================================================

/datum/bt_node/ai_behavior/bot_speech
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/bot_speech/perform(seconds_per_tick, datum/ai_controller/controller, list/list_to_pick_from, announce_key)
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[announce_key]
	if(isnull(announcement) || !length(list_to_pick_from))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	announcement.announce(pick(list_to_pick_from))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Bot interact
// =============================================================================

/datum/bt_node/ai_behavior/bot_interact
	var/clear_target = TRUE

/datum/bt_node/ai_behavior/bot_interact/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(living_pawn, target) > 0)
		return AI_BEHAVIOR_INSTANT
	living_pawn.UnarmedAttack(target, proximity_flag = TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/bot_interact/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(clear_target)
		controller.clear_blackboard_key(target_key)
	if(!succeeded && !isnull(target))
		controller.add_to_blacklist(target)

/// Variant that keeps the target key after interacting (caller must clear it).
/datum/bt_node/ai_behavior/bot_interact/keep_target
	clear_target = FALSE

// =============================================================================
// Use mob ability (BT-native — triggers a single ability from a blackboard key)
// =============================================================================

/datum/bt_node/ai_behavior/use_mob_ability

/datum/bt_node/ai_behavior/use_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller, ability_key)
	var/datum/action/using_action = controller.blackboard[ability_key]
	if(QDELETED(using_action) || !using_action.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(using_action.Trigger())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

// =============================================================================
// Beacon patrol behaviors
// =============================================================================

/datum/bt_node/ai_behavior/find_first_beacon_target

/datum/bt_node/ai_behavior/find_first_beacon_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
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

/datum/bt_node/ai_behavior/find_next_beacon_target
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/find_next_beacon_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/final_target
	var/obj/machinery/navbeacon/prev_beacon = controller.blackboard[BB_PREVIOUS_BEACON_TARGET]
	if(QDELETED(prev_beacon))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_next_beacon_target: previous beacon is deleted")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

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

	if(controller.set_if_can_reach(key = target_key, target = final_target, duration = 3 MINUTES, distance = controller.max_target_distance))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_next_beacon_target: can't reach [final_target], applying cooldown")
	controller.set_blackboard_key(BB_BOT_BEACON_COOLDOWN, world.time + BOT_NO_BEACON_PATH_PENALTY)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Records the beacon as visited and clears the target key once the bot is on the same turf.
/datum/bt_node/ai_behavior/arrive_at_beacon

/datum/bt_node/ai_behavior/arrive_at_beacon/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/obj/machinery/navbeacon/beacon = controller.blackboard[target_key]
	if(QDELETED(beacon))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, beacon) > 0)
		return AI_BEHAVIOR_INSTANT
	controller.set_blackboard_key(BB_PREVIOUS_BEACON_TARGET, beacon)
	controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Set blackboard cooldown
// =============================================================================

// Sets the given blackboard key to world.time + cooldown_duration
/datum/bt_node/ai_behavior/set_bb_cooldown

/datum/bt_node/ai_behavior/set_bb_cooldown/perform(seconds_per_tick, datum/ai_controller/controller, cooldown_key, cooldown_duration)
	controller.set_blackboard_key(cooldown_key, world.time + cooldown_duration)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Summon travel
// =============================================================================

/// Completes summon travel once the bot reaches the summon target's turf.
/datum/bt_node/ai_behavior/complete_summon_travel

/datum/bt_node/ai_behavior/complete_summon_travel/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
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

// =============================================================================
// Authority salute behaviors
// =============================================================================

/datum/bt_node/ai_behavior/find_valid_authority
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/find_valid_authority/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	for(var/mob/living/nearby_mob in oview(7, controller.pawn))
		if(!HAS_TRAIT(nearby_mob, TRAIT_COMMISSIONED))
			continue
		controller.set_blackboard_key(target_key, nearby_mob)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/salute_authority

/datum/bt_node/ai_behavior/salute_authority/perform(seconds_per_tick, datum/ai_controller/controller, target_key, salute_keys)
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

/datum/bt_node/ai_behavior/salute_authority/finish_action(datum/ai_controller/controller, succeeded, target_key, salute_keys)
	. = ..()
	controller.clear_blackboard_key(target_key)

// =============================================================================
// Shared BT subtrees
// =============================================================================

/// Travel to BB_BOT_SUMMON_TARGET if set, completing when on the same turf.
/datum/bt_node/subtree/bot_respond_to_summon
	behavior_tree_json = "bot_respond_to_summon.bt.json"
	behavior_nodes = BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
		BT_SEQUENCE(\
			BT_LEAF(/datum/bt_node/ai_behavior/move_to_target, BB_BOT_SUMMON_TARGET, 0, TRUE),\
			BT_LEAF(/datum/bt_node/ai_behavior/complete_summon_travel, BB_BOT_SUMMON_TARGET),\

		),\
		"key" = BB_BOT_SUMMON_TARGET\
	)

/// Salute any commissioned officer in range, rate-limited to BOT_COMMISSIONED_SALUTE_DELAY.
/datum/bt_node/subtree/bot_salute_authority
	behavior_tree_json = "bot_salute_authority.bt.json"
	behavior_nodes = BT_DECORATOR(/datum/bt_node/decorator/bb_key_cooldown,\
		BT_SEQUENCE(\
			BT_LEAF(/datum/bt_node/ai_behavior/find_valid_authority, BB_SALUTE_TARGET),\
			BT_LEAF(/datum/bt_node/ai_behavior/salute_authority, BB_SALUTE_TARGET, BB_SALUTE_MESSAGES),\
			BT_LEAF(/datum/bt_node/ai_behavior/set_bb_cooldown, BB_SALUTE_COOLDOWN, BOT_COMMISSIONED_SALUTE_DELAY)\
		),\
		"cooldown_key" = BB_SALUTE_COOLDOWN\
	)

/**
 * Patrol to navbeacons in sequence when autopatrol is enabled and not on cooldown.
 * Priority: travel to current target → find next in chain → find first (nearest) beacon.
 */
/datum/bt_node/subtree/bot_patrol
	behavior_tree_json = "bot_patrol.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/key_off_cooldown,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bot_mode_flag,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/is_at_distance,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/bb_key_set,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/composite/sequence,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BEACON_TARGET, 0)),\
													list("__t" = /datum/bt_node/ai_behavior/arrive_at_beacon, "default_behavior_args" = list(BB_BEACON_TARGET))\
												)\
											)\
										),\
										"key" = BB_BEACON_TARGET\
									)\
								),\
								"invert" = TRUE,\
								"target_key" = BB_BEACON_TARGET,\
								"required_distance" = 0\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/find_next_beacon_target, "default_behavior_args" = list(BB_BEACON_TARGET))\
								),\
								"key" = BB_PREVIOUS_BEACON_TARGET\
							),\
							list("__t" = /datum/bt_node/ai_behavior/find_first_beacon_target, "default_behavior_args" = list(BB_BEACON_TARGET))\
						)\
					)\
				),\
				"flag" = BOT_MODE_AUTOPATROL\
			)\
		),\
		"cooldown_key" = BB_BOT_BEACON_COOLDOWN\
	)
	// @bt-generated end


#undef BOT_NO_BEACON_PATH_PENALTY
