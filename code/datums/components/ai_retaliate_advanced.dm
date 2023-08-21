/**
 * Attached to a mob with an AI controller, passes things which have damaged it to a blackboard.
 * The AI controller is responsible for doing anything with that information.
 * Differs from the element as it passes new entries through a callback.
 */
/datum/component/ai_retaliate_advanced
	/// Callback to a mob for custom behaviour
	var/datum/callback/post_retaliate_callback

/datum/component/ai_retaliate_advanced/Initialize(datum/callback/post_retaliate_callback)
	if(!ismob(parent))
		return ELEMENT_INCOMPATIBLE

	src.post_retaliate_callback = post_retaliate_callback
	parent.AddElement(/datum/element/relay_attackers)

	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/ai_retaliate_advanced/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/component/ai_retaliate_advanced/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/component/ai_retaliate_advanced/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER

	if (!victim.ai_controller)
		return

	victim.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)
	post_retaliate_callback?.InvokeAsync(attacker)
