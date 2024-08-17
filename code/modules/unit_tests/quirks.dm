/// Ensure every quirk has a unique icon
/datum/unit_test/quirk_icons

/datum/unit_test/quirk_icons/Run()
	var/list/used_icons = list()

	for (var/datum/quirk/quirk_type as anything in subtypesof(/datum/quirk))
		if (initial(quirk_type.abstract_parent_type) == quirk_type)
			continue

		var/icon = initial(quirk_type.icon)

		if (isnull(icon))
			TEST_FAIL("[quirk_type] has no icon!")
			continue

		if (icon in used_icons)
			TEST_FAIL("[icon] used in both [quirk_type] and [used_icons[icon]]!")
			continue

		used_icons[icon] = quirk_type

// Make sure all quirks start with a description in medical records
/datum/unit_test/quirk_initial_medical_records

/datum/unit_test/quirk_initial_medical_records/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)

	for(var/datum/quirk/quirk_type as anything in subtypesof(/datum/quirk))
		if (initial(quirk_type.abstract_parent_type) == quirk_type)
			continue

		if(!isnull(quirk_type.medical_record_text))
			continue

		//Add quirk to a patient - so we can pass quirks that add a medical record after being assigned someone
		patient.add_quirk(quirk_type)

		var/datum/quirk/quirk = patient.get_quirk(quirk_type)

		TEST_ASSERT_NOTNULL(quirk.medical_record_text,"[quirk_type] has no medical record description!")

		patient.remove_quirk(quirk_type)

/// Ensures the blood deficiency quirk updates its mail goodies correctly
/datum/unit_test/blood_deficiency_mail
	var/list/species_to_test = list(
		/datum/species/lizard = /obj/item/reagent_containers/blood/lizard,
		/datum/species/ethereal = /obj/item/reagent_containers/blood/ethereal,
		/datum/species/skeleton = null, // Anyone with noblood should not get a blood bag
		/datum/species/jelly = /obj/item/reagent_containers/blood/toxin,
		/datum/species/human = /obj/item/reagent_containers/blood/o_minus,
	)

/datum/unit_test/blood_deficiency_mail/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	dummy.add_quirk(/datum/quirk/blooddeficiency)
	var/datum/quirk/blooddeficiency/quirk = dummy.get_quirk(/datum/quirk/blooddeficiency)

	TEST_ASSERT((species_to_test[dummy.dna.species.type] in quirk.mail_goodies), "Blood deficiency quirk spawned with no mail goodies!")

	for(var/species_type in species_to_test)
		var/last_species = dummy.dna.species.type
		dummy.set_species(species_type)
		// Test that the new species has the correct blood bag
		if(!isnull(species_to_test[species_type]))
			TEST_ASSERT((species_to_test[species_type] in quirk.mail_goodies), \
				"Blood deficiency quirk did not update correctly! ([species_type] did not get its blood bag added)")
			TEST_ASSERT_EQUAL(length(quirk.mail_goodies), 1, \
				"Blood deficiency quirk got multiple blood bags for [species_type]!")
		else
			TEST_ASSERT_EQUAL(length(quirk.mail_goodies), 0, \
				"Blood deficiency quirk did not have an empty mail goody list for a noblood species!")
		// Test that we don't have the old species' blood bag
		if(!isnull(species_to_test[last_species]))
			TEST_ASSERT(!(species_to_test[last_species] in quirk.mail_goodies), \
				"Blood deficiency quirk did not update correctly for [species_type]! ([last_species] did not get its blood bag removed)")
