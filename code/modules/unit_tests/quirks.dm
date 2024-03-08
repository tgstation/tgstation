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
