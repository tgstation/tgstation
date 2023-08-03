/**
 * Attached to a mob that will then deal bonus damage to a victim with low, or potentially in the future, high health.
 */
/datum/component/bonus_damage
	/// At which percentage our target has to be for us to deal bonus damage
	var/damage_percentage = 20
	/// The amount of brute damage we will deal
	var/brute_damage_amount = 10

/datum/component/bonus_damage/Initialize(damage_percentage, brute_damage_amount)
	if(!isliving(parent))
		return ELEMENT_INCOMPATIBLE

	src.damage_percentage = damage_percentage
	src.brute_damage_amount = brute_damage_amount

/datum/component/bonus_damage/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_attacked))

/datum/component/bonus_damage/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET)

/// Add potential bonus damage to the person we attacked
/datum/component/bonus_damage/proc/on_attacked(mob/living/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	var/health_percentage = (living_target.health / living_target.maxHealth) * 100
	if(living_target.stat == DEAD || health_percentage > damage_percentage)
		return
	living_target.adjustBruteLoss(brute_damage_amount)
