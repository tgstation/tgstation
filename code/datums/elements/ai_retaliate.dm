/**
 * Attached to a mob with an AI controller, passes things which have damaged it to a blackboard.
 * The AI controller is responsible for doing anything with that information.
 */
/datum/element/ai_retaliate
	element_flags = ELEMENT_BESPOKE
	/// What mob type the parent calls
	var/mob/living/mob_type
	/// In what range the parent calls the same mobs to retaliate
	var/call_range

/datum/element/ai_retaliate/Attach(datum/target, input_mob_type = null, input_call_range = 7)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	mob_type = input_mob_type
	call_range = input_call_range
	target.AddElement(/datum/element/relay_attackers)
	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/element/ai_retaliate/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_WAS_ATTACKED)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/element/ai_retaliate/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER

	if (!victim.ai_controller)
		return
	var/list/enemy_refs = victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if (!enemy_refs)
		enemy_refs = list()
	enemy_refs |= WEAKREF(attacker)
	victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST] = enemy_refs
	if(mob_type)
		for (var/mob/living/potential_victim in oview(victim, call_range))
			if (istype(potential_victim, mob_type) || !potential_victim.stat == DEAD)
				potential_victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST] = enemy_refs
