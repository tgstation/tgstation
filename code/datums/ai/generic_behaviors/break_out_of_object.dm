/// Attacks an escape target until the pawn is no longer buckled to or contained by it.
/datum/bt_node/ai_behavior/break_out_of_object
	time_between_perform = 0.2 SECONDS
	/// The object to break out of by attacking it.
	var/atom/target_atom

/datum/bt_node/ai_behavior/break_out_of_object/setup(datum/ai_controller/controller)
	if (!should_attack_target(controller, target_atom))
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/break_out_of_object/perform(seconds_per_tick, datum/ai_controller/controller)
	if (!should_attack_target(controller, target_atom))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = target_atom, combat_mode = TRUE)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/break_out_of_object/proc/should_attack_target(datum/ai_controller/controller, atom/target)
	if (QDELETED(target))
		return FALSE
	var/mob/living/pawn = controller.pawn
	if (!target.IsReachableBy(pawn))
		return FALSE
	return pawn.loc == target || pawn.buckled == target

// DEPRECATED — port to /datum/bt_node/ai_behavior/break_out_of_object
/datum/ai_behavior/break_out_of_object
	parent_type = /datum/bt_node/ai_behavior/break_out_of_object

/// Variant that reads the escape target from a blackboard key instead of a direct reference.
/datum/bt_node/ai_behavior/break_out_of_object/from_bb
	/// Blackboard key holding the object to break out of.
	var/target_key

/datum/bt_node/ai_behavior/break_out_of_object/from_bb/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	return should_attack_target(controller, target)

/datum/bt_node/ai_behavior/break_out_of_object/from_bb/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!should_attack_target(controller, target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = target, combat_mode = TRUE)
	return AI_BEHAVIOR_DELAY
