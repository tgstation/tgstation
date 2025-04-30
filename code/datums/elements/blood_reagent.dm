/// Element that blood reagents use to apply their data (not blood regen!) to mobs
/// Only added to blood drawn *from* someone, so don't put behavior that should work with any reagent onto this
/datum/element/blood_reagent
	/*
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	*/

/datum/element/blood_reagent/Attach(datum/reagent/target, mob/living/blood_source)
	. = ..()
	if (!istype(target) || !istype(blood_source))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_REAGENT_EXPOSE_MOB, PROC_REF(on_mob_expose))

/datum/element/blood_reagent/Detach(datum/reagent/target)
	. = ..()
	UnregisterSignal(target, list(
		COMSIG_REAGENT_EXPOSE_MOB,
	))

	/*
	data = list(
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = null,
		"resistances" = null,
		"trace_chem" = null,
		"mind" = null,
		"ckey" = null,
		"gender" = null,
		"real_name" = null,
		"cloneable" = null,
		"factions" = null,
		"quirks" = null)
	*/
