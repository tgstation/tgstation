/// Passes when the pawn's current health is below the configured threshold.
/datum/bt_node/decorator/pawn_health_below
	/// Health value that the pawn must be below for this decorator to pass
	var/health_threshold = 0
	/// blackboard value holding our threshold, if this is null, health_threshold will be used instead
	var/health_blackboard_key

/datum/bt_node/decorator/pawn_health_below/register_observe_signals(atom/pawn)
	RegisterSignal(pawn, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/pawn_health_below/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, COMSIG_LIVING_HEALTH_UPDATE)

/datum/bt_node/decorator/pawn_health_below/check_condition(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!isliving(living_pawn))
		return FALSE
	var/final_threshold = controller.blackboard[health_blackboard_key] || health_threshold
	return living_pawn.health < final_threshold
