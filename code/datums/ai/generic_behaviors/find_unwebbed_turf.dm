/// Find a nearby unwebbed turf to spin webs on and store it in a blackboard key.
/// Returns INSTANT SUCCESS if we already have a valid target, or if we find a new one.
/// Returns INSTANT FAILURE if no valid turf is nearby.
/datum/bt_node/ai_behavior/find_unwebbed_turf
	/// How many tiles outward to scan for valid turfs.
	var/scan_range = 3
	/// Blackboard key holding/storing the unwebbed turf.
	var/target_key

/datum/bt_node/ai_behavior/find_unwebbed_turf/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/spider = controller.pawn
	var/atom/current_target = controller.blackboard[target_key]
	if(current_target && !(locate(/obj/structure/spider/stickyweb) in current_target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	controller.clear_blackboard_key(target_key)
	var/turf/our_turf = get_turf(spider)
	if(is_valid_web_turf(our_turf, spider))
		controller.set_blackboard_key(target_key, our_turf)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	var/list/turfs_by_range = list()
	for(var/i in 1 to scan_range)
		turfs_by_range["[i]"] = list()
	for(var/turf/turf_in_view in oview(scan_range, our_turf))
		if(!is_valid_web_turf(turf_in_view, spider))
			continue
		turfs_by_range["[get_dist(our_turf, turf_in_view)]"] += turf_in_view

	var/list/final_turfs
	for(var/list/turf_list as anything in turfs_by_range)
		if(length(turfs_by_range[turf_list]))
			final_turfs = turfs_by_range[turf_list]
			break
	if(!length(final_turfs))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, pick(final_turfs))
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/find_unwebbed_turf/proc/is_valid_web_turf(turf/target_turf, mob/living/spider)
	if(locate(/obj/structure/spider/stickyweb) in target_turf)
		return FALSE
	if(HAS_TRAIT(target_turf, TRAIT_SPINNING_WEB_TURF))
		return FALSE
	return !target_turf.is_blocked_turf(source_atom = spider)
