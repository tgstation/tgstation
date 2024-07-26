///this takes a key to hold, and on being attacked it will clear the BB_OBJECT_TARGET key, of its value
///then it will queue up retaliate so that it should switch to targetting the attacker over object
///faster

/datum/element/clear_target_key_and_retaliate
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/clear_target_key_and_retaliate/Attach(atom/movable/target)
	. = ..()

	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/element/clear_target_key_and_retaliate/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_WAS_ATTACKED)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/element/clear_target_key_and_retaliate/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER
	if(!victim.ai_controller.blackboard[BB_TEMPORARY_TARGET])
		return

	victim.ai_controller?.set_blackboard_key(BB_TEMPORARY_TARGET, FALSE)
	victim.ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, null)
