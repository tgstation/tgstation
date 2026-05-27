/// Passes when the pawn's current health is below the configured threshold.
/datum/bt_node/decorator/pawn_health_below
	/// Health value that the pawn must be below for this decorator to pass
	var/health_threshold = 0

/datum/bt_node/decorator/pawn_health_below/get_pawn_observe_signals()
	return list(COMSIG_LIVING_HEALTH_UPDATE)

/datum/bt_node/decorator/pawn_health_below/check_condition(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!isliving(living_pawn))
		return FALSE
	return living_pawn.health < health_threshold
