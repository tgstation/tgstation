/// Searches for a nearby mineral wall the pawn can mine and sets the target key.
/datum/bt_node/ai_behavior/find_mineral_wall
	time_between_perform = 2 SECONDS
	/// Blackboard key to store the found mineral wall in.
	var/target_key

/datum/bt_node/ai_behavior/find_mineral_wall/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living_pawn = controller.pawn
	for(var/turf/closed/mineral/potential_wall in oview(9, living_pawn))
		if(!check_if_mineable(controller, potential_wall))
			continue
		controller.set_blackboard_key(target_key, potential_wall)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Returns TRUE if the given wall can be approached and mined.
/datum/bt_node/ai_behavior/find_mineral_wall/proc/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/mob/living/source = controller.pawn
	var/direction_to_turf = get_dir(target_wall, source)
	if(!ISDIAGONALDIR(direction_to_turf))
		return TRUE
	for(var/direction_check in GLOB.cardinals)
		if(!(direction_check & direction_to_turf))
			continue
		var/turf/test_turf = get_step(target_wall, direction_check)
		if(isnull(test_turf))
			continue
		if(!test_turf.is_blocked_turf(ignore_atoms = list(source)))
			return TRUE
	return FALSE

/// Mines the mineral wall at target_key when adjacent. Clears the target key on finish.
/datum/bt_node/ai_behavior/mine_wall
	time_between_perform = 15 SECONDS
	/// Blackboard key holding the mineral wall to mine.
	var/target_key

/datum/bt_node/ai_behavior/mine_wall/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/closed/mineral/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!living_pawn.Adjacent(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/is_gibtonite = istype(target, /turf/closed/mineral/gibtonite)
	if(!controller.ai_interact(target = target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(is_gibtonite)
		living_pawn.manual_emote("sighs...")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/mine_wall/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)
