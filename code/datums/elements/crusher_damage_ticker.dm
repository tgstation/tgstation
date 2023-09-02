/**
 * Element that handles applying a crusher damage tracker status effect on a struck target.
 */
/datum/element/crusher_damage_ticker

/datum/element/crusher_damage_ticker/Attach(datum/target, listen_to)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(isnull(listen_to))
		stack_trace("crusher_damage_ticker element was not passed a listen_to for [target] to determine what to listen to.")
		return ELEMENT_INCOMPATIBLE

	switch(listen_to)
		if(APPLY_WITH_MELEE)
			RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_melee_attack))
		if(APPLY_WITH_PROJECTILE)
			RegisterSignal(target, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_hit))
		if(APPLY_WITH_SPELL)
			RegisterSignal(target, COMSIG_CRUSHER_SPELL_HIT, PROC_REF(on_applied_spell))
		if(APPLY_WITH_MOB_ATTACK)
			RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_mob_attack))

/datum/element/crusher_damage_ticker/Detach(datum/source, ...)
	UnregisterSignal(source, list(COMSIG_ITEM_PRE_ATTACK, COMSIG_PROJECTILE_ON_HIT, COMSIG_CRUSHER_SPELL_HIT))
	return ..()

/datum/element/crusher_damage_ticker/proc/try_apply_damage_tracker(mob/living/living_target)
	if(living_target.has_status_effect(/datum/status_effect/crusher_damage))
		message_admins("[living_target] already has a crusher damage tracker") //debug
		return
	living_target.apply_status_effect(/datum/status_effect/crusher_damage)
	message_admins("[living_target] has received a crusher damage tracker") //debug

/datum/element/crusher_damage_ticker/proc/on_melee_attack(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	try_apply_damage_tracker(target)

/datum/element/crusher_damage_ticker/proc/on_projectile_hit(datum/source, atom/movable/firer, atom/target, angle, hit_limb)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	try_apply_damage_tracker(target)

/datum/element/crusher_damage_ticker/proc/on_applied_spell(datum/source, atom/target, mob/living/caster)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	try_apply_damage_tracker(target)

/datum/element/crusher_damage_ticker/proc/on_mob_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	try_apply_damage_tracker(target)
