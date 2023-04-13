/// Search for a nearby location to put webs on
/datum/ai_planning_subtree/find_unwebbed_turf

/datum/ai_planning_subtree/find_unwebbed_turf/SelectBehaviors(datum/ai_controller/controller, delta_time)
	controller.queue_behavior(/datum/ai_behavior/find_unwebbed_turf)

/// Find an unwebbed nearby turf and store it
/datum/ai_behavior/find_unwebbed_turf
	action_cooldown = 5 SECONDS
	/// Where do we store the target data
	var/target_key = BB_SPIDER_WEB_TARGET
	/// How far do we look for unwebbed turfs?
	var/scan_range = 3

/datum/ai_behavior/find_unwebbed_turf/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/spider = controller.pawn
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/current_target = weak_target?.resolve()
	if (current_target && !(locate(/obj/structure/spider/stickyweb) in current_target))
		finish_action(controller, succeeded = FALSE) // Already got a target
		return

	controller.blackboard[target_key] = null
	var/turf/our_turf = get_turf(spider)
	if (is_valid_web_turf(our_turf))
		controller.blackboard[target_key] = WEAKREF(our_turf)
		finish_action(controller, succeeded = TRUE)
		return

	var/list/potential_turfs = list()
	for(var/turf/turf_in_view in oview(scan_range, our_turf))
		if (!is_valid_web_turf(turf_in_view))
			continue
		potential_turfs += turf_in_view

	if (!length(potential_turfs))
		finish_action(controller, succeeded = FALSE)
		return

	controller.blackboard[target_key] = WEAKREF(get_closest_atom(/turf/, potential_turfs, our_turf))
	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/find_unwebbed_turf/proc/is_valid_web_turf(turf/target_turf, mob/living/spider)
	if (locate(/obj/structure/spider/stickyweb) in target_turf)
		return FALSE
	return !target_turf.is_blocked_turf(source_atom = spider)

/// Run the spin web behaviour if we have an ability to use for it
/datum/ai_planning_subtree/spin_web
	/// Key where the web spinning action is stored
	var/action_key = BB_SPIDER_WEB_ACTION
	/// Key where the target turf is stored
	var/target_key = BB_SPIDER_WEB_TARGET

/datum/ai_planning_subtree/spin_web/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/weakref/weak_action = controller.blackboard[action_key]
	var/datum/action/cooldown/using_action = weak_action?.resolve()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/turf/target_turf = weak_target?.resolve()
	if (!using_action || !target_turf)
		return
	controller.queue_behavior(/datum/ai_behavior/spin_web, action_key, target_key)
	return SUBTREE_RETURN_FINISH_PLANNING

/// Move to an unwebbed nearby turf and web it up
/datum/ai_behavior/spin_web
	action_cooldown = 15 SECONDS // We don't want them doing this too quickly
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/spin_web/setup(datum/ai_controller/controller, action_key, target_key)
	var/datum/weakref/weak_action = controller.blackboard[action_key]
	var/datum/action/cooldown/web_action = weak_action?.resolve()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/turf/target_turf = weak_target?.resolve()
	if (!web_action || !target_turf)
		return FALSE

	set_movement_target(controller, target_turf)
	return ..()

/datum/ai_behavior/spin_web/perform(delta_time, datum/ai_controller/controller, action_key, target_key)
	. = ..()
	var/datum/weakref/weak_action = controller.blackboard[action_key]
	var/datum/action/cooldown/web_action = weak_action?.resolve()
	finish_action(controller, succeeded = web_action?.Trigger(), action_key = action_key, target_key = target_key)

/datum/ai_behavior/spin_web/finish_action(datum/ai_controller/controller, succeeded, action_key, target_key)
	controller.blackboard[target_key] = null
	return ..()
