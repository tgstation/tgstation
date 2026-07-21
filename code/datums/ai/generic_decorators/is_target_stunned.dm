/// Gates child on the mob held in a blackboard key being paralyzed (stunned and on the ground).
/// Use "invert": true to gate on the target NOT being stunned. Used by arrest bots like ED209 to close in once the target is incapacitated.
/datum/bt_node/decorator/is_target_stunned
	/// Blackboard key holding the mob to check.
	var/key = BB_CURRENT_TARGET

/datum/bt_node/decorator/is_target_stunned/check_condition(datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[key]
	if(QDELETED(target) || !isliving(target))
		return FALSE
	return !!target.IsParalyzed()
