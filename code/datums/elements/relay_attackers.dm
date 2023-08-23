/**
 * This element registers to a shitload of signals which can signify "someone attacked me".
 * If anyone does it sends a single "someone attacked me" signal containing details about who done it.
 * This prevents other components and elements from having to register to the same list of a million signals, should be more maintainable in one place.
 */
/datum/element/relay_attackers

/datum/element/relay_attackers/Attach(datum/target)
	. = ..()
	// Boy this sure is a lot of ways to tell us that someone tried to attack us
	RegisterSignal(target, COMSIG_ATOM_ATTACK_MECH, PROC_REF(on_attack_mech))
	RegisterSignal(target, COMSIG_ATOM_PREHITBY, PROC_REF(on_hitby))
	RegisterSignal(target, COMSIG_LIVING_ATTACKED_BY, PROC_REF(on_attacked_by))
	RegisterSignal(target, COMSIG_LIVING_DISARM_HIT, PROC_REF(on_shoved))
	RegisterSignal(target, COMSIG_PROJECTILE_PREHIT, PROC_REF(on_bullet_act))

/datum/element/relay_attackers/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_ATOM_ATTACK_MECH,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_HITBY,
		COMSIG_ATOM_PREHITBY,
		COMSIG_LIVING_ATTACKED_BY,
		COMSIG_LIVING_DISARM_HIT,
		COMSIG_PROJECTILE_PREHIT,
	))

/datum/element/relay_attackers/proc/on_attacked_by(atom/target, mob/living/attacker, obj/item/weapon, obj/item/bodypart/hit_limb, damage, damage_type, armor_block)
	SIGNAL_HANDLER
	if(damage)
		relay_attacker(target, attacker, damage_type == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK)

/datum/element/relay_attackers/proc/on_shoved(atom/target, mob/living/attacker)
	SIGNAL_HANDLER
	relay_attacker(target, attacker, ATTACKER_SHOVING)

/// Even if another component blocked this hit, someone still shot at us
/datum/element/relay_attackers/proc/on_bullet_act(atom/target, list/bullet_args, obj/projectile/hit_projectile)
	SIGNAL_HANDLER
	if(!hit_projectile.is_hostile_projectile())
		return
	if(!ismob(hit_projectile.firer))
		return
	relay_attacker(target, hit_projectile.firer, hit_projectile.damage_type == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK)

/// Even if another component blocked this hit, someone still threw something
/datum/element/relay_attackers/proc/on_hitby(atom/target, atom/movable/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!isitem(hit_atom))
		return
	var/obj/item/hit_item = hit_atom
	if(!hit_item.throwforce)
		return
	var/mob/thrown_by = hit_item.thrownby?.resolve()
	if(!ismob(thrown_by))
		return
	relay_attacker(target, thrown_by, hit_item.damtype == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK)

/datum/element/relay_attackers/proc/on_attack_mech(atom/target, obj/vehicle/sealed/mecha/mecha_attacker, mob/living/pilot)
	SIGNAL_HANDLER
	relay_attacker(target, mecha_attacker, ATTACKER_DAMAGING_ATTACK)

/// Send out a signal identifying whoever just attacked us (usually a mob but sometimes a mech or turret)
/datum/element/relay_attackers/proc/relay_attacker(atom/victim, atom/attacker, attack_flags = NONE)
	SEND_SIGNAL(victim, COMSIG_ATOM_WAS_ATTACKED, attacker, attack_flags)
