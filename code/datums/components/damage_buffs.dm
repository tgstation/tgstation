/**
 * Attached to a mob so it can change or do actions based on the fact it got attacked.
 */
/datum/component/damage_buffs
	/// Callback to a mob for health changes
	var/datum/callback/health_callback

/datum/component/damage_buffs/Initialize(datum/callback/health_callback)
	if(!ismob(parent))
		return ELEMENT_INCOMPATIBLE

	src.health_callback = health_callback
	parent.AddElement(/datum/element/relay_attackers)

/datum/component/damage_buffs/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/component/damage_buffs/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/component/damage_buffs/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER

	health_callback?.InvokeAsync(attacker)
