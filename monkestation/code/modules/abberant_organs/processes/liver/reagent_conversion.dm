/datum/organ_process/reagent_conversion
	name = "Reagent Conversion"
	desc = "Converts reagents in your liver into something else"

	process_flags = ORGAN_LIVER
	var/datum/reagent/converted_reagent
	var/conversion_precent = 0.5

/datum/organ_process/reagent_conversion/New()
	. = ..()
	converted_reagent = /datum/reagent/consumable/ethanol

/datum/organ_process/reagent_conversion/trigger(datum/weakref/host, stability)
	if(!host)
		return
	var/mob/living/mob = host.resolve()
	if(!mob.reagents)
		return
	var/volume_to_use = mob.reagents.total_volume * conversion_precent
	mob.reagents.remove_all(volume_to_use)
	mob.reagents.add_reagent(converted_reagent, volume_to_use)
