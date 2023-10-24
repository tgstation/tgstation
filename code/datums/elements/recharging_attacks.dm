/// Reduces the cooldown of a given action upon landing attacks, critting, or killing mobs.
/datum/element/recharging_attacks
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The target of the most recent attack
	var/last_target
	/// The stat of the most recently attacked mob
	var/last_stat
	/// The action to recharge when attacking
	var/datum/action/cooldown/recharged_action
	/// The amount of cooldown to refund on a successful attack
	var/attack_refund
	/// The amount of cooldown to refund when putting a target into critical
	var/crit_refund

/datum/element/recharging_attacks/Attach(
	datum/target,
	last_target,
	last_stat,
	datum/action/cooldown/recharged_action,
	attack_refund = 1 SECONDS,
	crit_refund = 5 SECONDS,
)
	. = ..()
	if (!isbasicmob(target) || !istype(recharged_action, /datum/action/cooldown))
		return ELEMENT_INCOMPATIBLE
	src.recharged_action = recharged_action
	src.attack_refund = attack_refund
	src.crit_refund = crit_refund
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(set_old_stat))
	RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(check_stat))

/datum/element/recharging_attacks/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_HOSTILE_POST_ATTACKINGTARGET))
	return ..()

/datum/element/recharging_attacks/proc/set_old_stat(mob/attacker, mob/attacked)
	SIGNAL_HANDLER
	if(!isliving(attacked))
		return
	last_target = attacked
	last_stat = attacked.stat

/datum/element/recharging_attacks/proc/check_stat(mob/living/attacker, mob/living/attacked, success)
	SIGNAL_HANDLER
	if(!isliving(attacked) || attacked != last_target || attacker.faction_check_atom(attacked))
		return

	var/final_refund = 0 SECONDS
	if(QDELETED(attacked) || (attacked.stat == DEAD && last_stat != DEAD)) //The target is dead and we killed them - full refund
		final_refund = recharged_action.cooldown_time
	else if(attacked.stat > CONSCIOUS && last_stat == CONSCIOUS) //We knocked the target unconscious - partial refund
		final_refund = crit_refund
	else
		final_refund = attack_refund

	recharged_action.next_use_time -= final_refund
	recharged_action.build_all_button_icons()
