/**
 * Component that handles incrementing the crusher damage tracker's total damage on enemies that are eligible
 * for that damage. Also applies the crusher damage tracker status effect if the enemy doesn't have one already.
 * Arguments:
 * - damage_to_increment - the damage we add to the victim's crusher damage counter
 * - apply_with - determines the type of the attack to determine extra behavior for damage application, see code\__DEFINES\mining.dm for define list
 */
/datum/component/crusher_damage_ticker
	/// How much damage do we deal to the enemy and want to increment the tracker's damage for
	var/damage_to_increment
	/// What do we count the source of the damage as?
	var/apply_with

/datum/component/crusher_damage_ticker/Initialize(apply_with, damage_to_increment)
	if(isnull(apply_with))
		stack_trace("crusher_damage_ticker component was not passed an apply_with for [parent] to determine the signal to listen to.")
		return COMPONENT_INCOMPATIBLE

	src.apply_with = apply_with
	src.damage_to_increment = damage_to_increment

/datum/component/crusher_damage_ticker/RegisterWithParent()
	switch(apply_with)
		if(APPLY_WITH_MELEE)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_melee_attack))
			RegisterSignals(parent, list(COMSIG_TWOHANDED_POST_WIELD, COMSIG_TWOHANDED_POST_UNWIELD), PROC_REF(on_melee_wield))
		if(APPLY_WITH_PROJECTILE)
			RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_hit))
		if(APPLY_WITH_MOB_ATTACK)
			RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_mob_attack))
		if(APPLY_WITH_SPELL)
			RegisterSignal(parent, COMSIG_CRUSHER_SPELL_HIT, PROC_REF(on_applied_spell))

/datum/component/crusher_damage_ticker/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_PRE_ATTACK, COMSIG_TWOHANDED_POST_WIELD, COMSIG_TWOHANDED_POST_UNWIELD, COMSIG_PROJECTILE_ON_HIT, COMSIG_CRUSHER_SPELL_HIT, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))

///Tries to apply a crusher damage status effect. Returns either a new one or an already existing status effect.
/datum/component/crusher_damage_ticker/proc/try_apply_damage_tracker(mob/living/living_target)
	var/has_tracker = living_target.has_status_effect(/datum/status_effect/crusher_damage)
	if(has_tracker)
		return has_tracker
	var/new_apply_tracker = living_target.apply_status_effect(/datum/status_effect/crusher_damage)
	if(!new_apply_tracker)
		stack_trace("crusher damage tracking failed to apply the crusher damage status effect on [living_target].")
	return new_apply_tracker

///Handles applying and incrementing crusher damage done with a melee item attack.
/datum/component/crusher_damage_ticker/proc/on_melee_attack(datum/source, mob/living/target, mob/user, params)
	SIGNAL_HANDLER

	if(target.mob_size < MOB_SIZE_LARGE)
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(target)
	target_tracker.total_damage += damage_to_increment

///Handles updating the component's damage to increment trackers with when the parent item changes its melee damage when (un)wielded.
/datum/component/crusher_damage_ticker/proc/on_melee_wield(datum/source, mob/living/carbon/user, force, sharpened_increase, require_twohands)
	SIGNAL_HANDLER

	damage_to_increment = force

///Handles applying and incrementing crusher damage done with a crusher-caused projectile.
/datum/component/crusher_damage_ticker/proc/on_projectile_hit(datum/source, atom/movable/firer, atom/target, angle, hit_limb)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.mob_size < MOB_SIZE_LARGE)
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(living_target)
	target_tracker.total_damage += damage_to_increment

///Handles applying and incrementing crusher damage done with a crusher-caused "spell", e.g. hierophant chaser.
/datum/component/crusher_damage_ticker/proc/on_applied_spell(datum/source, mob/living/target, mob/living/caster, damage_dealt)
	SIGNAL_HANDLER

	if(target.mob_size < MOB_SIZE_LARGE)
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(target)
	target_tracker.total_damage += damage_dealt ? damage_dealt : damage_to_increment

///Handles applying and incrementing crusher damage done by a crusher-summoned mob.
/datum/component/crusher_damage_ticker/proc/on_mob_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.mob_size < MOB_SIZE_LARGE)
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(living_target)
	target_tracker.total_damage += damage_to_increment
