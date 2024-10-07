/datum/reagent
	///What can process this? REAGENT_ORGANIC, REAGENT_SYNTHETIC, or REAGENT_ORGANIC | REAGENT_SYNTHETIC?. We'll assume by default that it affects organics.
	var/process_flags = REAGENT_ORGANIC

/proc/reagent_process_flags_valid(mob/processor, datum/reagent/reagent)
	if(ishuman(processor))
		var/mob/living/carbon/human/human_processor = processor
		//Check if this mob's species is set and can process this type of reagent
		//If we somehow avoided getting a species or reagent_flags set, we'll assume we aren't meant to process ANY reagents
		if(human_processor.dna && human_processor.dna.species.reagent_flags)
			var/processor_flags = human_processor.dna.species.reagent_flags
			if((reagent.process_flags & REAGENT_SYNTHETIC) && (processor_flags & PROCESS_SYNTHETIC))		//SYNTHETIC-oriented reagents require PROCESS_SYNTHETIC
				return TRUE
			if((reagent.process_flags & REAGENT_ORGANIC) && (processor_flags & PROCESS_ORGANIC))		//ORGANIC-oriented reagents require PROCESS_ORGANIC
				return TRUE
		return FALSE
	else if(reagent.process_flags == REAGENT_SYNTHETIC)
		//We'll assume that non-human mobs lack the ability to process synthetic-oriented reagents (adjust this if we need to change that assumption)
		return FALSE
	return TRUE
