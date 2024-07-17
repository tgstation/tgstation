/// Stops a mob from hitting someone in crit. doesn't account for projectiles or spells
/datum/component/no_crit_hitting

/datum/component/no_crit_hitting/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignals(parent, list(COMSIG_MOB_ITEM_ATTACK), PROC_REF(check_attack))

/datum/component/no_crit_hitting/proc/check_attack(mob/living/attacker, atom/attacked)
	SIGNAL_HANDLER

	if(!isliving(attacked))
		return

	var/mob/living/liver = attacked
	if(liver.stat == HARD_CRIT)
		liver.balloon_alert(attacker, "is in crit!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
