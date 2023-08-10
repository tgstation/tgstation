/**
 * Attached to a mob that will then deal bonus damage to a victim with low, or potentially in the future, high health.
 */
/datum/element/bonus_damage
	/// At which percentage our target has to be for us to deal bonus damage
	var/damage_percentage
	/// The amount of brute damage we will deal
	var/brute_damage_amount

/datum/element/bonus_damage/Attach(datum/target, damage_percentage = 20, brute_damage_amount = 15)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.damage_percentage = damage_percentage
	src.brute_damage_amount = brute_damage_amount
	RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(attack_target))

/datum/element/bonus_damage/Detach(datum/source)
	UnregisterSignal(source, COMSIG_HOSTILE_POST_ATTACKINGTARGET)
	return ..()

/// Add potential bonus damage to the person we attacked
/datum/element/bonus_damage/proc/attack_target(mob/living/attacker, atom/target, success)
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
