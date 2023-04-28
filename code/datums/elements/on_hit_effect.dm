/**
 * ## On Hit Effect Element!
 *
 * Element for other elements/components to rely on for on-hit effects without duplicating the on-hit code.
 * See Lifesteal, or bane for examples
 */
/datum/element/on_hit_effect
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///callback used
	var/datum/callback/on_hit_callback

/datum/element/on_hit_effect/Attach(datum/target, on_hit_callback)
	. = ..()
	if(ismachinery(target) || isstructure(target) || isgun(target) || isprojectilespell(target))
		RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, PROC_REF(projectile_hit))
	else if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else if(ishostile(target))
		RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))
	else
		return ELEMENT_INCOMPATIBLE

/datum/element/on_hit_effect/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_PROJECTILE_ON_HIT, COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_POST_ATTACKINGTARGET))
	return ..()

/datum/element/on_hit_effect/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	on_hit_callback.Invoke(user, target)
	return COMPONENT_AFTERATTACK_PROCESSED_ITEM

/datum/element/on_hit_effect/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	on_hit_callback.Invoke(attacker, target)

/datum/element/on_hit_effect/proc/projectile_hit(datum/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	on_hit_callback.Invoke(firer, target)

/datum/element/venomous/projectile/proc/on_hit(datum/source, mob/firer, atom/target, angle, hit_limb)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	add_reagent(target)
