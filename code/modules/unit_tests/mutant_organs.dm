/**
 * Iterates over all species to ensure that organs are valid after being set to a mutant species
 */
/datum/unit_test/mutant_organs

/datum/unit_test/mutant_organs/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(/mob/living/carbon/human/consistent)
	var/list/ignore = list(
		/datum/species/dullahan,
	)
	var/list/species = subtypesof(/datum/species) - ignore
	var/static/list/organs_we_care_about = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_APPENDIX,
	)

	for(var/datum/species/species_type as anything in species)
		// change them to the species
		dummy.set_species(species_type)

		// check all their organs
		for(var/organ_slot in organs_we_care_about)
			var/expected_type = slot_to_species_organ_type(organ_slot, species_type)
			var/obj/item/organ/actual_organ = dummy.getorganslot(organ_slot)
			if(isnull(actual_organ))
				if(!isnull(expected_type))
					TEST_FAIL("[species_type] did not update their [organ_slot] organ to [expected_type], no organ was found")
					continue
			else
				if(isnull(expected_type))
					TEST_FAIL("[species_type] did not remove their [organ_slot] organ")
					continue

				if(actual_organ.type != expected_type)
					TEST_FAIL("[species_type] did not update their [organ_slot] organ to [expected_type], instead it was [actual_organ.type]")
					continue

/datum/unit_test/mutant_organs/proc/slot_to_species_organ_type(slot, datum/species/species)
	switch(slot)
		if(ORGAN_SLOT_BRAIN)
			return initial(species.mutantbrain)
		if(ORGAN_SLOT_HEART)
			return initial(species.mutantheart)
		if(ORGAN_SLOT_LUNGS)
			return initial(species.mutantlungs)
		if(ORGAN_SLOT_EYES)
			return initial(species.mutanteyes)
		if(ORGAN_SLOT_EARS)
			return initial(species.mutantears)
		if(ORGAN_SLOT_TONGUE)
			return initial(species.mutanttongue)
		if(ORGAN_SLOT_LIVER)
			return initial(species.mutantliver)
		if(ORGAN_SLOT_STOMACH)
			return initial(species.mutantstomach)
		if(ORGAN_SLOT_APPENDIX)
			return initial(species.mutantappendix)
	CRASH("Invalid organ slot [slot]") // just incase someone adds an organ we care about and forgets to add it here
