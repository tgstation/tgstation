/// Passes when the living mob held in a blackboard key has health below a fraction of its max health.
/datum/bt_node/decorator/target_health_below_fraction
	/// Blackboard key holding the mob to check.
	var/key = null
	/// Health fraction threshold (0.0–1.0). Passes when health < maxHealth * fraction.
	var/fraction = 0.75
	/// The mob currently being observed.
	VAR_FINAL/mob/living/observed_mob = null

/datum/bt_node/decorator/target_health_below_fraction/register_observe_signals(atom/pawn)
	var/mob/living/target = owning_controller?.blackboard[key]
	if(isliving(target))
		observed_mob = target
		RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_signal_changed))
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_mob_key_changed))
	return TRUE

/datum/bt_node/decorator/target_health_below_fraction/unregister_observe_signals(atom/pawn)
	if(observed_mob)
		UnregisterSignal(observed_mob, COMSIG_LIVING_HEALTH_UPDATE)
		observed_mob = null
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/datum/bt_node/decorator/target_health_below_fraction/proc/on_mob_key_changed(atom/source, ...)
	SIGNAL_HANDLER
	if(observed_mob)
		UnregisterSignal(observed_mob, COMSIG_LIVING_HEALTH_UPDATE)
		observed_mob = null
	var/mob/living/target = owning_controller?.blackboard[key]
	if(isliving(target))
		observed_mob = target
		RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_signal_changed))
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/target_health_below_fraction/check_condition(datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[key]
	if(!isliving(target))
		return FALSE
	return target.health < target.maxHealth * fraction
