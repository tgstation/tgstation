/// Gates on whether a mob ability stored in a blackboard key is currently available. Needs to poll since we dont have nice signals to register too : (
/datum/bt_node/decorator/ability_available
	/// Blackboard key holding the ability datum
	var/ability_key = BB_GENERIC_ACTION

/datum/bt_node/decorator/ability_available/check_condition(datum/ai_controller/controller)
	var/datum/action/action = controller.blackboard[ability_key]
	return !QDELETED(action) && action.IsAvailable()
