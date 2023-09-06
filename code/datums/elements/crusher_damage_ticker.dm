/**
 * Element that handles incrementing the crusher damage tracker's total damage on enemies that are eligible
 * for that damage. Also applies the crusher damage tracker status effect if the enemy doesn't have one already.
 */
/datum/element/crusher_damage_ticker
	/// How much damage do we deal to the enemy and want to increment the tracker's damage for
	var/damage_to_increment

/datum/element/crusher_damage_ticker/Attach(datum/target, listen_to, damage_to_increment)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(isnull(listen_to))
		stack_trace("crusher_damage_ticker element was not passed a listen_to for [target] to determine what to listen to.")
		return ELEMENT_INCOMPATIBLE
	switch(listen_to)
		if(APPLY_WITH_MELEE)
			RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_melee_attack))
			RegisterSignal(target, COMSIG_TWOHANDED_FORCE_UPDATED, PROC_REF(on_melee_wield))
		if(APPLY_WITH_PROJECTILE)
			RegisterSignal(target, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_hit))
		if(APPLY_WITH_SPELL)
			RegisterSignal(target, COMSIG_CRUSHER_SPELL_HIT, PROC_REF(on_applied_spell))
		if(APPLY_WITH_MOB_ATTACK)
			RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_mob_attack))

	src.damage_to_increment = damage_to_increment

/datum/element/crusher_damage_ticker/Detach(datum/source, ...)
	UnregisterSignal(source, list(COMSIG_ITEM_PRE_ATTACK, COMSIG_TWOHANDED_FORCE_UPDATED, COMSIG_PROJECTILE_ON_HIT, COMSIG_CRUSHER_SPELL_HIT, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/datum/element/crusher_damage_ticker/proc/try_apply_damage_tracker(mob/living/living_target)
	var/has_tracker = living_target.has_status_effect(/datum/status_effect/crusher_damage)
	if(has_tracker)
		message_admins("[living_target] already has a crusher damage tracker") //debug
		return has_tracker
	message_admins("[living_target] has received a crusher damage tracker") //debug
	return living_target.apply_status_effect(/datum/status_effect/crusher_damage)

/datum/element/crusher_damage_ticker/proc/on_melee_attack(datum/source, mob/living/target, mob/user, params)
	SIGNAL_HANDLER

	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(target)
	target_tracker.total_damage += damage_to_increment
	message_admins("[target] has received [damage_to_increment] crusher damage, total damage: [target_tracker.total_damage]") //debug

/datum/element/crusher_damage_ticker/proc/on_melee_wield(datum/source, force)
	SIGNAL_HANDLER

	src.damage_to_increment = force
	message_admins("damage_to_increment changed to [damage_to_increment] with [force]") //debug

/datum/element/crusher_damage_ticker/proc/on_projectile_hit(datum/source, atom/movable/firer, atom/target, angle, hit_limb)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(target)
	target_tracker.total_damage += damage_to_increment
	message_admins("[target] has received [damage_to_increment] crusher damage, total damage: [target_tracker.total_damage]") //debug

/datum/element/crusher_damage_ticker/proc/on_applied_spell(datum/source, atom/target, mob/living/caster, damage_dealt)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(target)
	target_tracker.total_damage += damage_dealt ? damage_dealt : damage_to_increment
	message_admins("[target] has received [damage_dealt ? damage_dealt : damage_to_increment] crusher damage, total damage: [target_tracker.total_damage]") //debug

/datum/element/crusher_damage_ticker/proc/on_mob_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(target)
	target_tracker.total_damage += damage_to_increment
	message_admins("[target] has received [damage_to_increment] crusher damage, total damage: [target_tracker.total_damage]") //debug
