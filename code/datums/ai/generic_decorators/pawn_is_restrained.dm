/// Gates on the pawn having TRAIT_RESTRAINED; reacts to trait add/remove signals.
/datum/bt_node/decorator/pawn_is_restrained
	observer_abort = BT_ABORT_LOWER_PRIORITY
	child_typepath = /datum/bt_node/ai_behavior/resist

/datum/bt_node/decorator/pawn_is_restrained/get_pawn_observe_signals()
	return list(SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED))

/datum/bt_node/decorator/pawn_is_restrained/check_condition(datum/ai_controller/controller)
	return HAS_TRAIT(controller.pawn, TRAIT_RESTRAINED)
