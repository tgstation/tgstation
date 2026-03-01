/**
 * Crusher Loot; which makes the attached mob drop a crusher trophy of some type if the majority damage was from a crusher!
 *
 * Used for all the mobs droppin' crusher trophies
 */
/datum/element/crusher_loot
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Path of the trophy dropped (or list of trophies)
	var/trophy_type
	/// Chance to drop the trophy, lowered by the mob only taking partial crusher damage instead of full
	/// For example, 25% would mean ~4 mobs need to die before you find one.
	/// But it would be more if you didn't deal full crusher damage to them.
	var/drop_mod
	/// If true, will immediately spawn the item instead of putting it in butcher loot.
	var/drop_immediately
	/// Crusher damage percentage at which the drop is guaranteed, if any
	var/guaranteed_drop
	/// Should crusher drops replace *all* spawned loot?
	var/replace_all

/datum/element/crusher_loot/Attach(datum/target, trophy_type, drop_mod = 25, drop_immediately = FALSE, guaranteed_drop = null, replace_all = FALSE)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

	src.trophy_type = trophy_type
	src.drop_mod = drop_mod
	src.guaranteed_drop = guaranteed_drop
	src.drop_immediately = drop_immediately
	src.replace_all = replace_all
	if (replace_all)
		RegisterSignal(target, COMSIG_LIVING_DROP_LOOT, PROC_REF(on_loot_drop))

/datum/element/crusher_loot/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_DROP_LOOT))
	return ..()

/datum/element/crusher_loot/proc/on_loot_drop(mob/living/target, list/spawn_loot, gibbed)
	SIGNAL_HANDLER
	// Prevent normal loot from being dropped if we have replace_all enabled
	return COMPONENT_NO_LOOT_DROP

/datum/element/crusher_loot/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER

	var/datum/status_effect/crusher_damage/damage = target.has_status_effect(/datum/status_effect/crusher_damage)
	if (!damage)
		return

	if (guaranteed_drop)
		if (damage.total_damage / target.maxHealth < guaranteed_drop)
			return
	else if (!prob((damage.total_damage / target.maxHealth) * drop_mod)) // On average, you'll need to kill 4 creatures before getting the item. by default.
		return

	if (replace_all && isanimal(target))
		var/mob/living/simple_animal/expiring_code = target
		if (!islist(trophy_type))
			expiring_code.loot = list(trophy_type)
			return

		var/list/trophies = trophy_type
		expiring_code.loot = trophies.Copy()
		return

	if(!islist(trophy_type))
		make_path(target, trophy_type)
		return

	if (replace_all)
		target.butcher_results?.Cut()
		target.guaranteed_butcher_results?.Cut()

	for(var/trophypath in trophy_type)
		make_path(target, trophypath)

/datum/element/crusher_loot/proc/make_path(mob/living/target, path)
	if(drop_immediately)
		new path(get_turf(target))
		return

	if (!target.guaranteed_butcher_results)
		target.guaranteed_butcher_results = list()

	target.guaranteed_butcher_results[path] = 1
