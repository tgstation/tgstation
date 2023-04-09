/**
 * Attached to a mob with an AI controller, passes things which have damaged it to a blackboard.
 * The AI controller is responsible for doing anything with that information.
 */
/datum/component/ai_retaliate_advanced
	/// Callback to a mob for custom behaviour
	var/datum/callback/post_retaliate_callback

/datum/component/ai_retaliate_advanced/Initialize(datum/callback/post_retaliate_callback)
	if(!ismob(parent))
		return ELEMENT_INCOMPATIBLE

	src.post_retaliate_callback = post_retaliate_callback
	parent.AddElement(/datum/element/relay_attackers)

/datum/component/ai_retaliate_advanced/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/component/ai_retaliate_advanced/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/component/ai_retaliate_advanced/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER

	if (!victim.ai_controller)
		return
	var/list/enemy_refs = victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if (!enemy_refs)
		enemy_refs = list()
	enemy_refs |= WEAKREF(attacker)
	victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST] = enemy_refs
	post_retaliate_callback?.InvokeAsync(attacker)
