/**
 * Attached to a mob with an AI controller, passes things which have damaged its current target.
 * The AI controller is responsible for doing anything with that information.
 */
/datum/element/ai_target_damagesource

/datum/element/ai_target_damagesource/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	target.AddElement(/datum/element/relay_attackers)
	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/element/ai_target_damagesource/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_WAS_ATTACKED)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/element/ai_target_damagesource/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER

	if (!victim.ai_controller)
		return
	victim.ai_controller.CancelActions()
	victim.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = WEAKREF(attacker)
