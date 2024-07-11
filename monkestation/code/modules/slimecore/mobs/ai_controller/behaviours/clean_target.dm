/datum/ai_behavior/execute_clean_slime
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/execute_clean_slime/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/execute_clean_slime/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	living_pawn.balloon_alert_to_viewers("cleaned")
	living_pawn.visible_message(span_notice("[living_pawn] dissolves \the [target]."))
	SEND_SIGNAL(living_pawn, COMSIG_MOB_FEED, target, 20)
	qdel(target) // Sent to the shadow realm to never be seen again
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/execute_clean_slime/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || is_type_in_typecache(target, controller.blackboard[BB_HUNTABLE_TRASH]))
		return
	if(!iscarbon(target))
		controller.clear_blackboard_key(target_key)
		return
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/find_and_set/in_list/clean_targets_slime
	action_cooldown = 1.2 SECONDS

/datum/ai_behavior/find_and_set/in_list/clean_targets_slime/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/obj/closest
	var/closest_dist
	var/closest_path
	for(var/obj/trash as anything in view(search_range, controller.pawn))
		if(QDELETED(trash))
			continue
		if(!is_type_in_typecache(trash, locate_paths) && !HAS_TRAIT(trash, TRAIT_TRASH_ITEM))
			continue
		if(trash.loc == controller.pawn.loc)
			return trash
		var/dist = get_dist(get_turf(controller.pawn), get_turf(trash))
		var/path_length
		if(!QDELETED(closest))
			if(dist > (closest_dist + 2)) // leeway to try to avoid "shorter dist but longer path" targets
				continue
			path_length = length(get_path_to(controller.pawn, trash))
			if(closest_path <= path_length)
				continue
		else
			path_length = length(get_path_to(controller.pawn, trash))
		closest = trash
		closest_dist = dist
		closest_path = path_length
	return closest
