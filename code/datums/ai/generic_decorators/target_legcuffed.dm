/// Gates child on the carbon held in a blackboard key being legcuffed. Use "invert": true to gate on not being legcuffed.
/datum/bt_node/decorator/target_legcuffed
	/// Blackboard key holding the mob to check.
	var/key = BB_CURRENT_TARGET

/datum/bt_node/decorator/target_legcuffed/check_condition(datum/ai_controller/controller)
	var/mob/living/carbon/target = controller.blackboard[key]
	if(!iscarbon(target))
		return FALSE
	return !isnull(target.legcuffed)
