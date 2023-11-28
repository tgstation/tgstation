/// Ensure every quirk has a unique icon
/datum/unit_test/quirk_icons
// Make sure all quirks start with a description in medical records
/datum/unit_test/quirk_initial_medical_records

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

/datum/unit_test/quirk_initial_medical_records/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	//So anything that needs the mind doesn't fail (theres a few)
	patient.mind_initialize()
	//So anything that needs the client doesn't fail (i.e. food allergy)
	patient.mock_client = new();

	for(var/datum/quirk/quirk_type as anything in subtypesof(/datum/quirk))
		if (initial(quirk_type.abstract_parent_type) == quirk_type)
			continue
		//Add quirk to a patient - so we can pass quirks that add a medical record after being assigned someone
		patient.add_quirk(quirk_type);

		// Get added quirk from patient
		var/datum/quirk/quirk = patient.get_quirk(quirk_type);

		if(isnull(quirk.medical_record_text))
			TEST_FAIL("[quirk_type] has no medical record description!")

		patient.remove_quirk(quirk_type);
