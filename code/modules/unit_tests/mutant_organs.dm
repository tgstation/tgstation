/**
 * Iterates over all species to ensure that organs are valid after being set to a mutant species.
 */
/datum/unit_test/mutant_organs

/datum/unit_test/mutant_organs/Run()
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
		// get our dummy
		var/mob/living/carbon/human/consistent/dummy = allocate(/mob/living/carbon/human/consistent)

		// change them to the species
		dummy.set_species(species_type)

		// check all their organs
		for(var/organ_slot in organs_we_care_about)
			var/expected_type = dummy.dna.species.get_mutant_organ_type_for_slot(organ_slot)
			var/obj/item/organ/actual_organ = dummy.get_organ_slot(organ_slot)
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
