/**
 * Component that handles incrementing the crusher damage tracker's total damage on enemies that are eligible
 * for that damage. Also applies the crusher damage tracker status effect if the enemy doesn't have one already.
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
	. = ..()

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
	return ..()

/datum/component/crusher_damage_ticker/proc/try_apply_damage_tracker(mob/living/living_target)
	var/has_tracker = living_target.has_status_effect(/datum/status_effect/crusher_damage)
	if(has_tracker)
		to_chat(world, span_notice("[living_target] already has a crusher damage tracker")) //debug
		return has_tracker
	to_chat(world, span_green("[living_target] has received a crusher damage tracker")) //debug
	return living_target.apply_status_effect(/datum/status_effect/crusher_damage)

/datum/component/crusher_damage_ticker/proc/on_melee_attack(datum/source, mob/living/target, mob/user, params)
	SIGNAL_HANDLER

	if(target.mob_size < MOB_SIZE_LARGE)
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(target)
	target_tracker.total_damage += damage_to_increment
	to_chat(world, span_cult("[target] has received [damage_to_increment] crusher damage via [parent], total damage: [target_tracker.total_damage]")) //debug

/datum/component/crusher_damage_ticker/proc/on_melee_wield(datum/source, mob/living/carbon/user, force, sharpened_increase, require_twohands)
	SIGNAL_HANDLER

	src.damage_to_increment = force
	to_chat(world, span_notice(("damage_to_increment changed to [damage_to_increment] with [force]"))) //debug

/datum/component/crusher_damage_ticker/proc/on_projectile_hit(datum/source, atom/movable/firer, atom/target, angle, hit_limb)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.mob_size < MOB_SIZE_LARGE)
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(living_target)
	target_tracker.total_damage += damage_to_increment
	to_chat(world, span_blue("[living_target] has received [damage_to_increment] crusher damage, via [parent] total damage: [target_tracker.total_damage]")) //debug

/datum/component/crusher_damage_ticker/proc/on_applied_spell(datum/source, mob/living/target, mob/living/caster, damage_dealt)
	SIGNAL_HANDLER

	if(target.mob_size < MOB_SIZE_LARGE)
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(target)
	target_tracker.total_damage += damage_dealt ? damage_dealt : damage_to_increment
	to_chat(world, span_revendanger("[target] has received [damage_dealt ? damage_dealt : damage_to_increment] crusher damage via [parent], total damage: [target_tracker.total_damage]")) //debug

/datum/component/crusher_damage_ticker/proc/on_mob_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.mob_size < MOB_SIZE_LARGE)
		return
	var/datum/status_effect/crusher_damage/target_tracker = try_apply_damage_tracker(living_target)
	target_tracker.total_damage += damage_to_increment
	to_chat(world, span_clown(("[living_target] has received [damage_to_increment] crusher damage via [parent], total damage: [target_tracker.total_damage]"))) //debug
