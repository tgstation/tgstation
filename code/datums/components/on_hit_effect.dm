/**
 * ## On Hit Effect Component!
 *
 * Element for other elements/components to rely on for on-hit effects without duplicating the on-hit code.
 * See Lifesteal, or bane for examples
 */
/datum/component/on_hit_effect
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///callback used
	var/datum/callback/on_hit_callback

/datum/component/on_hit_effect/Initialize(on_hit_callback)
	src.on_hit_callback = on_hit_callback
	if(!(ismachinery(parent) || isstructure(parent) || isgun(parent) || isprojectilespell(parent) || isitem(parent) || ishostile(parent) || isprojectile(parent)))
		return ELEMENT_INCOMPATIBLE

/datum/component/on_hit_effect/RegisterWithParent()
	if(ismachinery(parent) || isstructure(parent) || isgun(parent) || isprojectilespell(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
	else if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else if(ishostile(parent))
		RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))
	else if(isprojectile(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_self_hit))

/datum/component/on_hit_effect/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PROJECTILE_ON_HIT,
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_HOSTILE_POST_ATTACKINGTARGET,
		COMSIG_PROJECTILE_SELF_ON_HIT,
	))

/datum/component/on_hit_effect/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	on_hit_callback.Invoke(user, target)
	return COMPONENT_AFTERATTACK_PROCESSED_ITEM

/datum/component/on_hit_effect/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	on_hit_callback.Invoke(attacker, target)

/datum/component/on_hit_effect/proc/on_projectile_hit(datum/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	on_hit_callback.Invoke(firer, target)

/datum/component/on_hit_effect/proc/on_projectile_self_hit(datum/source, mob/firer, atom/target, angle, hit_limb)
	SIGNAL_HANDLER

	on_hit_callback.Invoke(firer, target)
