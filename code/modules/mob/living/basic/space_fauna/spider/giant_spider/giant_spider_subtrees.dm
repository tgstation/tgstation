/// Search for a nearby location to put webs on
/datum/ai_planning_subtree/find_unwebbed_turf

/datum/ai_planning_subtree/find_unwebbed_turf/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/find_unwebbed_turf)

/// Find an unwebbed nearby turf and store it
/datum/ai_behavior/find_unwebbed_turf
	action_cooldown = 5 SECONDS
	/// Where do we store the target data
	var/target_key = BB_SPIDER_WEB_TARGET
	/// How far do we look for unwebbed turfs?
	var/scan_range = 3

/datum/ai_behavior/find_unwebbed_turf/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/spider = controller.pawn
	var/atom/current_target = controller.blackboard[target_key]
	if (current_target && !(locate(/obj/structure/spider/stickyweb) in current_target))
		// Already got a target
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.clear_blackboard_key(target_key)
	var/turf/our_turf = get_turf(spider)
	if (is_valid_web_turf(our_turf, spider))
		controller.set_blackboard_key(target_key, our_turf)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	var/list/turfs_by_range = list()
	for (var/i in 1 to scan_range)
		turfs_by_range["[i]"] = list()
	for (var/turf/turf_in_view in oview(scan_range, our_turf))
		if (!is_valid_web_turf(turf_in_view, spider))
			continue
		turfs_by_range["[get_dist(our_turf, turf_in_view)]"] += turf_in_view

	var/list/final_turfs
	for (var/list/turf_list as anything in turfs_by_range)
		if (length(turfs_by_range[turf_list]))
			final_turfs = turfs_by_range[turf_list]
			break
	if (!length(final_turfs))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, pick(final_turfs))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_unwebbed_turf/proc/is_valid_web_turf(turf/target_turf, mob/living/spider)
	if (locate(/obj/structure/spider/stickyweb) in target_turf)
		return FALSE
	if (HAS_TRAIT(target_turf, TRAIT_SPINNING_WEB_TURF))
		return FALSE
	return !target_turf.is_blocked_turf(source_atom = spider)

/// Run the spin web behaviour if we have an ability to use for it
/datum/ai_planning_subtree/spin_web
	/// Key where the web spinning action is stored
	var/action_key = BB_SPIDER_WEB_ACTION
	/// Key where the target turf is stored
	var/target_key = BB_SPIDER_WEB_TARGET

/datum/ai_planning_subtree/spin_web/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (controller.blackboard_key_exists(action_key) && controller.blackboard_key_exists(target_key))
		controller.queue_behavior(/datum/ai_behavior/spin_web, action_key, target_key)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Move to an unwebbed nearby turf and web it up
/datum/ai_behavior/spin_web
	action_cooldown = 15 SECONDS // We don't want them doing this too quickly
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/spin_web/setup(datum/ai_controller/controller, action_key, target_key)
	var/datum/action/cooldown/web_action = controller.blackboard[action_key]
	var/turf/target_turf = controller.blackboard[target_key]
	if (!web_action || !target_turf)
		return FALSE

	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/spin_web/perform(seconds_per_tick, datum/ai_controller/controller, action_key, target_key)
	var/datum/action/cooldown/web_action = controller.blackboard[action_key]
	if(web_action?.Trigger())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/spin_web/finish_action(datum/ai_controller/controller, succeeded, action_key, target_key)
	controller.clear_blackboard_key(target_key)
	return ..()
