/// Passes when the mob held in a blackboard key has a stat value at that is at least X. Higher is more dead.
/datum/bt_node/decorator/mob_stat_at_least
	/// Blackboard key holding the mob to check.
	var/key = null
	/// Minimum stat value (inclusive) for the condition to pass. Default: CONSCIOUS.
	var/min_stat = CONSCIOUS
	/// The mob currently being observed. Tracked so we can unregister when the key changes or teardown runs.
	var/mob/observed_mob = null

/datum/bt_node/decorator/mob_stat_at_least/register_observe_signals(atom/pawn)
	var/mob/target = owning_controller?.blackboard[key]
	if(target)
		observed_mob = target
		RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_signal_changed))
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_mob_key_changed))
	return TRUE

/datum/bt_node/decorator/mob_stat_at_least/unregister_observe_signals(atom/pawn)
	if(observed_mob)
		UnregisterSignal(observed_mob, COMSIG_MOB_STATCHANGE)
		observed_mob = null
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/// Fires when the blackboard key changes. Rebinds the stat observer to the new mob and re-evaluates.
/datum/bt_node/decorator/mob_stat_at_least/proc/on_mob_key_changed(atom/source, ...)
	SIGNAL_HANDLER
	if(observed_mob)
		UnregisterSignal(observed_mob, COMSIG_MOB_STATCHANGE)
		observed_mob = null
	var/mob/target = owning_controller?.blackboard[key]
	if(target)
		observed_mob = target
		RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_signal_changed))
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/mob_stat_at_least/check_condition(datum/ai_controller/controller)
	var/mob/target = controller.blackboard[key]
	if(!ismob(target))
		return FALSE
	return target.stat >= min_stat
