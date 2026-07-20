/// Gates child on the pawn having a given trait from a specific source. Use "invert": true to gate on the trait being absent.
/datum/bt_node/decorator/pawn_has_trait_from
	/// The trait to check for.
	var/trait = null
	/// The source the trait must originate from.
	var/source = null

/datum/bt_node/decorator/pawn_has_trait_from/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(SIGNAL_ADDTRAIT(trait), SIGNAL_REMOVETRAIT(trait)), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/pawn_has_trait_from/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(SIGNAL_ADDTRAIT(trait), SIGNAL_REMOVETRAIT(trait)))

/datum/bt_node/decorator/pawn_has_trait_from/check_condition(datum/ai_controller/controller)
	return HAS_TRAIT_FROM(controller.pawn, trait, source)
