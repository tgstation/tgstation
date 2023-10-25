/// Reduces the cooldown of a given action upon landing attacks, critting, or killing mobs.
/datum/component/recharging_attacks
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

/datum/component/recharging_attacks/Initialize(
	datum/action/cooldown/recharged_action,
	attack_refund = 1 SECONDS,
	crit_refund = 5 SECONDS,
)
	. = ..()
	if (!isbasicmob(parent) || !istype(recharged_action))
		return COMPONENT_INCOMPATIBLE
	src.recharged_action = recharged_action
	src.attack_refund = attack_refund
	src.crit_refund = crit_refund

/datum/component/recharging_attacks/Destroy()
	UnregisterSignal(recharged_action, COMSIG_QDELETING)
	recharged_action = null
	return ..()

/datum/component/recharging_attacks/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(set_old_stat))
	RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(check_stat))
	RegisterSignal(recharged_action, COMSIG_QDELETING, PROC_REF(on_action_qdel))

/datum/component/recharging_attacks/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_HOSTILE_POST_ATTACKINGTARGET))
	if(recharged_action)
		UnregisterSignal(recharged_action, COMSIG_QDELETING)

/datum/component/recharging_attacks/proc/set_old_stat(mob/attacker, mob/attacked)
	SIGNAL_HANDLER
	if(!isliving(attacked))
		return
	last_target = attacked
	last_stat = attacked.stat

/datum/component/recharging_attacks/proc/check_stat(mob/living/attacker, mob/living/attacked, success)
	SIGNAL_HANDLER
	if(!isliving(attacked) || attacked != last_target || attacker.faction_check_atom(attacked))
		return

	var/final_refund = attack_refund
	if(QDELETED(attacked) || (attacked.stat == DEAD && last_stat != DEAD)) //The target is dead and we killed them - full refund
		final_refund = recharged_action.cooldown_time
	else if(attacked.stat > CONSCIOUS && last_stat == CONSCIOUS) //We knocked the target unconscious - partial refund
		final_refund = crit_refund

	recharged_action.next_use_time -= final_refund
	recharged_action.build_all_button_icons()

/datum/component/recharging_attacks/proc/on_action_qdel()
	SIGNAL_HANDLER
	qdel(src)
