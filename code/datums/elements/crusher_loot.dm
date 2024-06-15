/**
 * Crusher Loot; which makes the attached mob drop a crusher trophy of some type if the majority damage was from a crusher!
 *
 * Used for all the mobs droppin' crusher trophies
 */
/datum/element/crusher_loot
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Path of the trophy dropped, may also be a list
	var/trophy_type
	/// chance to drop the trophy, lowered by the mob only taking partial crusher damage instead of full
	/// for example, 25% would mean ~4 mobs need to die before you find one.
	/// but it would be more if you didn't deal full crusher damage to them.
	var/drop_mod
	/// If true, will immediately spawn the item instead of putting it in butcher loot.
	var/drop_immediately

/datum/element/crusher_loot/Attach(datum/target, trophy_type, drop_mod = 25, drop_immediately = FALSE)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

	src.trophy_type = trophy_type
	src.drop_mod = drop_mod
	src.drop_immediately = drop_immediately

/datum/element/crusher_loot/Detach(datum/target)
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	return ..()

/datum/element/crusher_loot/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER

	var/mob/living/owner_mob = target

	var/datum/status_effect/crusher_damage/damage = target.has_status_effect(/datum/status_effect/crusher_damage)
	if(damage && prob((damage.total_damage/target.maxHealth) * drop_mod)) //on average, you'll need to kill 4 creatures before getting the item. by default.
		if(drop_immediately)
			if(islist(trophy_type))
				for(var/loot in trophy_type)
					new loot(owner_mob.drop_location())
			else
				new trophy_type(get_turf(target))
		else
			if(islist(trophy_type))
				for(var/loot in trophy_type)
					target.butcher_results[loot] = 1
			else
				target.butcher_results[trophy_type] = 1
	target.RemoveElement(type)
