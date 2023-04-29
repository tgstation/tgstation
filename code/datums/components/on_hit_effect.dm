/**
 * ## On Hit Effect Component!
 *
 * Component for other elements/components to rely on for on-hit effects without duplicating the on-hit code.
 * See Lifesteal, or bane for examples.
 *
 * THIS COULD EASILY SUPPORT COMPONENT_DUPE_ALLOWED but the getcomponent makes it throw errors. if you can figure that out feel free to readd the dupe types
 */
/datum/component/on_hit_effect
	///callback used by other components to apply effects
	var/datum/callback/on_hit_callback
	///callback optionally used for more checks
	var/datum/callback/extra_check_callback

/datum/component/on_hit_effect/Initialize(on_hit_callback, extra_check_callback)
	src.on_hit_callback = on_hit_callback
	src.extra_check_callback = extra_check_callback
	if(!(ismachinery(parent) || isstructure(parent) || isgun(parent) || isprojectilespell(parent) || isitem(parent) || isanimal_or_basicmob(parent) || isprojectile(parent)))
		return ELEMENT_INCOMPATIBLE

/datum/component/on_hit_effect/RegisterWithParent()
	if(ismachinery(parent) || isstructure(parent) || isgun(parent) || isprojectilespell(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
	else if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else if(isanimal_or_basicmob(parent))
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

	if(extra_check_callback)
		if(!extra_check_callback.Invoke(user, target))
			return
	on_hit_callback.Invoke(source, user, target, user.zone_selected)
	return COMPONENT_AFTERATTACK_PROCESSED_ITEM

/datum/component/on_hit_effect/proc/hostile_attackingtarget(mob/living/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return

	if(extra_check_callback)
		if(!extra_check_callback.Invoke(attacker, target))
			return
	on_hit_callback.Invoke(attacker, attacker, target, attacker.zone_selected)

/datum/component/on_hit_effect/proc/on_projectile_hit(datum/fired_from, atom/movable/firer, atom/target, angle, obj/item/bodypart/hit_limb)
	SIGNAL_HANDLER

	if(extra_check_callback)
		if(!extra_check_callback.Invoke(firer, target))
			return
	on_hit_callback.Invoke(fired_from, firer, target, hit_limb.body_zone)

/datum/component/on_hit_effect/proc/on_projectile_self_hit(datum/source, mob/firer, atom/target, angle, obj/item/bodypart/hit_limb)
	SIGNAL_HANDLER

	if(extra_check_callback)
		if(!extra_check_callback.Invoke(firer, target))
			return
	on_hit_callback.Invoke(source, firer, target, hit_limb.body_zone)
