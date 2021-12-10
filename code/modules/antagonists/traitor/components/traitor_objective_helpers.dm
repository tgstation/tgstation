/// Helper component that registers signals on an object
/// This is not necessary to use and gives little control over the conditions
/datum/component/traitor_objective_register
	dupe_mode = COMPONENT_DUPE_ALLOWED

	/// The target to apply the succeed/fail signals onto
	var/datum/target
	/// Signals to listen out for to automatically succeed the objective
	var/succeed_signals
	/// Signals to listen out for to automatically fail the objective.
	var/fail_signals

/datum/component/traitor_objective_register/Initialize(datum/target, succeed_signals, fail_signals)
	. = ..()
	if(!istype(parent, /datum/traitor_objective))
		return COMPONENT_INCOMPATIBLE
	src.target = target
	src.succeed_signals = succeed_signals
	src.fail_signals = fail_signals

/datum/component/traitor_objective_register/RegisterWithParent()
	RegisterSignal(target, succeed_signals, .proc/on_success)
	RegisterSignal(target, fail_signals, .proc/on_fail)
	RegisterSignal(parent, list(COMSIG_TRAITOR_OBJECTIVE_COMPLETED, COMSIG_TRAITOR_OBJECTIVE_FAILED), .proc/delete_self)

/datum/component/traitor_objective_register/UnregisterFromParent()
	UnregisterSignal(target, succeed_signals)
	UnregisterSignal(target, fail_signals)
	UnregisterSignal(parent, list(
		COMSIG_TRAITOR_OBJECTIVE_COMPLETED,
		COMSIG_TRAITOR_OBJECTIVE_FAILED
	))

/datum/component/traitor_objective_register/proc/on_fail()
	SIGNAL_HANDLER
	var/datum/traitor_objective/objective = parent
	objective.fail_objective()

/datum/component/traitor_objective_register/proc/on_success()
	SIGNAL_HANDLER
	var/datum/traitor_objective/objective = parent
	objective.succeed_objective()

/datum/component/traitor_objective_register/proc/delete_self()
	SIGNAL_HANDLER
	qdel(src)
