/**
 * Heals the user (if attached to an item) or the mob itself (if attached to a hostile simple mob)
 * by a flat amount whenever a successful attack is performed against another living mob.
 */
/datum/element/lifesteal
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// heals a constant amount every time a hit occurs
	var/flat_heal
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/datum/element/lifesteal/Attach(datum/target, flat_heal)
	. = ..()
	if(ismachinery(target) || isstructure(target) || isgun(target) || isprojectilespell(target))
		RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, PROC_REF(projectile_hit))
	else if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else if(ishostile(target))
		RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))
	else
		return ELEMENT_INCOMPATIBLE

	src.flat_heal = flat_heal

/datum/element/lifesteal/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_PROJECTILE_ON_HIT, COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_POST_ATTACKINGTARGET))
	return ..()

/datum/element/lifesteal/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	do_lifesteal(user, target)
	return COMPONENT_AFTERATTACK_PROCESSED_ITEM

/datum/element/lifesteal/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	do_lifesteal(attacker, target)

/datum/element/lifesteal/proc/projectile_hit(datum/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	do_lifesteal(firer, target)

/datum/element/lifesteal/proc/do_lifesteal(atom/heal_target, atom/damage_target)
	if(isliving(heal_target) && isliving(damage_target))
		var/mob/living/healing = heal_target
		var/mob/living/damaging = damage_target
		if(damaging.stat != DEAD)
			healing.heal_ordered_damage(flat_heal, damage_heal_order)
