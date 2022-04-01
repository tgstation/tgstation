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
	/// Whether failing has a penalty
	var/penalty = 0

/datum/component/traitor_objective_register/Initialize(datum/target, succeed_signals, fail_signals, penalty)
	. = ..()
	if(!istype(parent, /datum/traitor_objective))
		return COMPONENT_INCOMPATIBLE
	src.target = target
	src.succeed_signals = succeed_signals
	src.fail_signals = fail_signals
	src.penalty = penalty

/datum/component/traitor_objective_register/RegisterWithParent()
	if(succeed_signals)
		register_signal(target, succeed_signals, .proc/on_success)
	if(fail_signals)
		register_signal(target, fail_signals, .proc/on_fail)
	register_signal(parent, list(COMSIG_TRAITOR_OBJECTIVE_COMPLETED, COMSIG_TRAITOR_OBJECTIVE_FAILED), .proc/delete_self)

/datum/component/traitor_objective_register/UnregisterFromParent()
	if(target)
		if(succeed_signals)
			unregister_signal(target, succeed_signals)
		if(fail_signals)
			unregister_signal(target, fail_signals)
	unregister_signal(parent, list(
		COMSIG_TRAITOR_OBJECTIVE_COMPLETED,
		COMSIG_TRAITOR_OBJECTIVE_FAILED
	))

/datum/component/traitor_objective_register/proc/on_fail(datum/traitor_objective/source)
	SIGNAL_HANDLER
	var/datum/traitor_objective/objective = parent
	objective.fail_objective(penalty)

/datum/component/traitor_objective_register/proc/on_success()
	SIGNAL_HANDLER
	var/datum/traitor_objective/objective = parent
	objective.succeed_objective()

/datum/component/traitor_objective_register/proc/delete_self()
	SIGNAL_HANDLER
	qdel(src)
