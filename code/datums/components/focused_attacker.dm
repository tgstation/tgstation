/**
 * Increases our attack damage every time we attack the same target
 * Not compatible with any other component or status effect which modifies attack damage
 */
/datum/component/focused_attacker
	/// Amount of damage we gain per attack
	var/gain_per_attack
	/// Maximum amount by which we can increase our attack power
	var/maximum_gain
	/// The last thing we attacked
	var/atom/last_target

/datum/component/focused_attacker/Initialize(gain_per_attack = 5, maximum_gain = 25)
	. = ..()
	if (!isliving(parent) && !isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.maximum_gain = maximum_gain
	src.gain_per_attack = gain_per_attack

/datum/component/focused_attacker/Destroy(force)
	if (!isnull(last_target))
		UnregisterSignal(last_target, COMSIG_QDELETING)
	return ..()

/datum/component/focused_attacker/RegisterWithParent()
	if (isliving(parent))
		RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(pre_mob_attack))
	else
		RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(pre_item_attack))

/datum/component/focused_attacker/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_ITEM_PRE_ATTACK))

/// Before a mob attacks, try increasing its attack power
/datum/component/focused_attacker/proc/pre_mob_attack(mob/living/attacker, atom/target)
	SIGNAL_HANDLER
	if (isnull(target) || isturf(target))
		return
	if (target == last_target)
		if (attacker.melee_damage_lower - initial(attacker.melee_damage_lower) >= maximum_gain)
			return
		attacker.melee_damage_lower += gain_per_attack
		attacker.melee_damage_upper += gain_per_attack
		return

	attacker.melee_damage_lower = initial(attacker.melee_damage_lower)
	attacker.melee_damage_upper = initial(attacker.melee_damage_upper)
	register_new_target(target)

/// Before an item attacks, try increasing its attack power
/datum/component/focused_attacker/proc/pre_item_attack(obj/item/weapon, atom/target, mob/user, params)
	SIGNAL_HANDLER
	if (target == last_target)
		if (weapon.force - initial(weapon.force) < maximum_gain)
			weapon.force += gain_per_attack
		return

	weapon.force = initial(weapon.force)
	register_new_target(target)

/// Register a new target
/datum/component/focused_attacker/proc/register_new_target(atom/target)
	if (!isnull(last_target))
		UnregisterSignal(last_target, COMSIG_QDELETING)
	last_target = target
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))

/// Drop our target ref on deletion
/datum/component/focused_attacker/proc/on_target_deleted(target)
	SIGNAL_HANDLER
	last_target = null
