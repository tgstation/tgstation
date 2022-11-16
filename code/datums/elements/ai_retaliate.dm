/**
 * Attached to a mob with an AI controller, passes mobs which have damaged it to a blackboard.
 * The AI controller is responsible for doing anything with that information.
 */
/datum/element/ai_retaliate

/datum/element/ai_retaliate/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	// Boy this sure is a lot of ways to tell us that someone tried to attack us
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_generic))
	RegisterSignal(target, COMSIG_ATOM_ATTACK_PAW, PROC_REF(on_attack_generic))
	RegisterSignal(target, COMSIG_MOB_ATTACK_ALIEN, PROC_REF(on_attack_generic))
	RegisterSignal(target, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(on_attack_animal))
	RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignal(target, COMSIG_ATOM_HITBY, PROC_REF(on_hitby))
	RegisterSignal(target, COMSIG_ATOM_HULK_ATTACK, PROC_REF(on_attack_hulk))
	RegisterSignal(target, COMSIG_ATOM_ATTACK_MECH, PROC_REF(on_attack_mech))

/datum/element/ai_retaliate/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_ATTACK_ANIMAL, COMSIG_MOB_ATTACK_ALIEN, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_MECH))

/datum/element/ai_retaliate/proc/on_attackby(mob/target, obj/item/weapon, mob/attacker)
	SIGNAL_HANDLER
	if(weapon.force)
		retaliate(target, attacker)

/datum/element/ai_retaliate/proc/on_attack_generic(mob/target, mob/living/attacker, list/modifiers)
	SIGNAL_HANDLER
	if((attacker.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK)))
		retaliate(target, attacker)

/datum/element/ai_retaliate/proc/on_attack_animal(mob/target, mob/living/attacker)
	SIGNAL_HANDLER
	if(attacker.melee_damage_upper > 0)
		retaliate(target, attacker)

/datum/element/ai_retaliate/proc/on_bullet_act(mob/target, obj/projectile/hit_projectile)
	SIGNAL_HANDLER
	if(hit_projectile.nodamage)
		return
	if(!ismob(hit_projectile.firer))
		return
	retaliate(target, hit_projectile.firer)

/datum/element/ai_retaliate/proc/on_hitby(mob/target, atom/movable/hit_atom, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!isitem(hit_atom))
		return
	var/obj/item/hit_item = hit_atom
	if(!hit_item.throwforce)
		return
	var/mob/thrown_by = hit_item.thrownby?.resolve()
	if(!ismob(thrown_by))
		return
	retaliate(target, thrown_by)

/datum/element/ai_retaliate/proc/on_attack_hulk(mob/target, mob/attacker)
	SIGNAL_HANDLER
	retaliate(target, attacker)

/datum/element/ai_retaliate/proc/on_attack_mech(mob/target, obj/vehicle/sealed/mecha/mecha_attacker, mob/living/pilot)
	SIGNAL_HANDLER
	retaliate(target, mecha_attacker)

/// Add the attacker to the victim's list of enemies on its blackboard, if it has one
/datum/element/ai_retaliate/proc/retaliate(mob/victim, atom/new_enemy)
	if (!victim.ai_controller)
		return
	var/list/enemy_refs = victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if (!enemy_refs)
		enemy_refs = list()
	enemy_refs |= WEAKREF(new_enemy)
	victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST] = enemy_refs
