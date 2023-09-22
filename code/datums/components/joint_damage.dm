/*
 * A component given to mobs to damage a linked mob
 */
/datum/component/joint_damage
	///the mob we will damage
	var/datum/weakref/overlord_mob

/datum/component/joint_damage/Initialize(mob/overlord_mob)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(overlord_mob)
		src.overlord_mob = WEAKREF(overlord_mob)

/datum/component/joint_damage/RegisterWithParent()
	if(!HAS_TRAIT(parent, TRAIT_RELAYING_ATTACKER))
		parent.AddElement(/datum/element/relay_attackers)
	RegisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(damage_overlord))

/datum/component/joint_damage/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED)

/datum/component/joint_damage/Destroy()
	overlord_mob = null
	return ..()

/datum/component/joint_damage/proc/damage_overlord(datum/source, atom/attacker, attack_flags, damage_value)
	SIGNAL_HANDLER

	var/mob/living/overlord_to_damage = overlord_mob?.resolve()
	if(attacker == overlord_to_damage)
		return
	if(isnull(overlord_to_damage))
		return
	if(attack_flags & ATTACKER_DAMAGING_ATTACK)
		overlord_to_damage.apply_damage(damage_value)
