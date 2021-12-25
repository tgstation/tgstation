/// Helper component to track events on
/datum/component/traitor_objective_mind_tracker
	dupe_mode = COMPONENT_DUPE_ALLOWED

	/// The target to track
	var/datum/mind/target
	/// Signals to listen out for mapped to procs to call
	var/list/signals
	/// Current registered target
	var/mob/current_registered_target

/datum/component/traitor_objective_mind_tracker/Initialize(datum/target, signals)
	. = ..()
	if(!istype(parent, /datum/traitor_objective))
		return COMPONENT_INCOMPATIBLE
	src.target = target
	src.signals = signals

/datum/component/traitor_objective_mind_tracker/RegisterWithParent()
	RegisterSignal(target, COMSIG_MIND_TRANSFERRED, .proc/handle_mind_transferred)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/delete_self)
	RegisterSignal(parent, list(COMSIG_TRAITOR_OBJECTIVE_COMPLETED, COMSIG_TRAITOR_OBJECTIVE_FAILED), .proc/delete_self)
	handle_mind_transferred(target)

/datum/component/traitor_objective_mind_tracker/UnregisterFromParent()
	UnregisterSignal(target, COMSIG_MIND_TRANSFERRED)
	parent.UnregisterSignal(target.current, signals)

/datum/component/traitor_objective_mind_tracker/proc/handle_mind_transferred(datum/source, mob/previous_body)
	SIGNAL_HANDLER
	if(current_registered_target)
		parent.UnregisterSignal(current_registered_target, signals)

	for(var/signal in signals)
		parent.RegisterSignal(target.current, signal, signals[signal])

/datum/component/traitor_objective_mind_tracker/proc/delete_self()
	SIGNAL_HANDLER
	qdel(src)
