/**
 * Organ damage; some simple mobs can damage your organs directly.
 *
 * Used for the clockwork golem!
 */
/datum/element/organ_damage
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	/// Which organ type is targeted.
	var/organ_type
	///	How much damage will be dealt to that organ.
	var/damage_amount

/datum/element/organ_damage/Attach(datum/target, organ_type, damage_amount)
	. = ..()

	if(isgun(target))
		RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)
	else if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/item_afterattack)
	else if(ishostile(target) || isbasicmob(target))
		RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, .proc/hostile_attackingtarget)
	else
		return ELEMENT_INCOMPATIBLE

	src.organ_type = organ_type
	src.damage_amount = damage_amount

/datum/element/organ_damage/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_PROJECTILE_ON_HIT, COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_POST_ATTACKINGTARGET))
	return ..()

/datum/element/organ_damage/proc/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	do_organ_damage(target)

/datum/element/organ_damage/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	do_organ_damage(target)

/datum/element/organ_damage/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	do_organ_damage(target)

/datum/element/organ_damage/proc/do_organ_damage(mob/living/carbon/target)
	if(!istype(target))
		return
	if(target.stat == DEAD)
		return
	var/obj/item/organ/organ = target.getorganslot(organ_type)
	if(!organ)
		return //Returns if there is no organ in the organ slot.
	organ.applyOrganDamage(damage_amount)
