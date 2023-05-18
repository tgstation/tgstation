/**
 * This element registers to a shitload of signals which can signify "someone attacked me".
 * If anyone does it sends a single "someone attacked me" signal containing details about who done it.
 * This prevents other components and elements from having to register to the same list of a million signals, should be more maintainable in one place.
 */
/datum/element/relay_attackers

/datum/element/relay_attackers/Attach(datum/target)
	. = ..()
	// Boy this sure is a lot of ways to tell us that someone tried to attack us
	RegisterSignal(target, COMSIG_LIVING_ATTACKED_BY, PROC_REF(on_attacked_by))
	RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignal(target, COMSIG_ATOM_HITBY, PROC_REF(on_hitby))
	RegisterSignal(target, COMSIG_ATOM_ATTACK_MECH, PROC_REF(on_attack_mech))

/datum/element/relay_attackers/proc/on_attacked_by(atom/target, mob/living/attacker, obj/item/weapon)
	SIGNAL_HANDLER
	relay_attacker(target, attacker)

/datum/element/relay_attackers/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_HITBY,
		COMSIG_ATOM_ATTACK_MECH,
		COMSIG_LIVING_ATTACKED_BY,
	))

/datum/element/relay_attackers/proc/on_bullet_act(atom/target, obj/projectile/hit_projectile)
	SIGNAL_HANDLER
	if(!hit_projectile.is_hostile_projectile())
		return
	if(!ismob(hit_projectile.firer))
		return
	relay_attacker(target, hit_projectile.firer)

/datum/element/relay_attackers/proc/on_hitby(atom/target, atom/movable/hit_atom, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!isitem(hit_atom))
		return
	var/obj/item/hit_item = hit_atom
	if(!hit_item.throwforce)
		return
	var/mob/thrown_by = hit_item.thrownby?.resolve()
	if(!ismob(thrown_by))
		return
	relay_attacker(target, thrown_by)

/datum/element/relay_attackers/proc/on_attack_mech(atom/target, obj/vehicle/sealed/mecha/mecha_attacker, mob/living/pilot)
	SIGNAL_HANDLER
	relay_attacker(target, mecha_attacker)

/// Send out a signal identifying whoever just attacked us (usually a mob but sometimes a mech or turret)
/datum/element/relay_attackers/proc/relay_attacker(atom/victim, atom/attacker)
	SEND_SIGNAL(victim, COMSIG_ATOM_WAS_ATTACKED, attacker)
