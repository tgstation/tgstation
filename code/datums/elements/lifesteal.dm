/**
 * Heals the user (if attached to an item) or the mob itself (if attached to a hostile simple mob)
 * by a flat amount whenever a successful attack is performed against another living mob.
 */
/datum/element/lifesteal
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// heals a constant amount every time a hit occurs
	var/flat_heal
	/// static list shared that tells which order of damage types to prioritize
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/datum/element/lifesteal/Attach(datum/target, flat_heal = 10)
	. = ..()
	src.flat_heal = flat_heal
	target.AddElementTrait(TRAIT_ON_HIT_EFFECT, REF(src), /datum/element/on_hit_effect)
	RegisterSignal(target, COMSIG_ON_HIT_EFFECT, PROC_REF(do_lifesteal))

/datum/element/lifesteal/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ON_HIT_EFFECT)
	REMOVE_TRAIT(source, TRAIT_ON_HIT_EFFECT, REF(src))
	return ..()

/datum/element/lifesteal/proc/do_lifesteal(datum/source, atom/heal_target, atom/damage_target, hit_zone, throw_hit)
	SIGNAL_HANDLER
	if(isliving(heal_target) && isliving(damage_target))
		var/mob/living/healing = heal_target
		var/mob/living/damaging = damage_target
		if(damaging.stat != DEAD)
			healing.heal_ordered_damage(flat_heal, damage_heal_order)
