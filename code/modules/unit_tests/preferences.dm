/// Requires all preferences to implement required methods.
/datum/unit_test/preferences_implement_everything

/datum/unit_test/preferences_implement_everything/Run()
	var/datum/preferences/preferences = new(new /datum/client_interface)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (preference.savefile_identifier == PREFERENCE_CHARACTER)
			preference.apply_to_human(human, preference.create_informed_default_value(preferences))

		if (istype(preference, /datum/preference/choiced))
			var/datum/preference/choiced/choiced_preference = preference
			choiced_preference.init_possible_values()

		// Smoke-test is_valid
		preference.is_valid(TRUE)
		preference.is_valid("string")
		preference.is_valid(100)
		preference.is_valid(list(1, 2, 3))

/// Requires all preferences to have a valid, unique savefile_identifier.
/datum/unit_test/preferences_valid_savefile_key

/datum/unit_test/preferences_valid_savefile_key/Run()
	var/list/known_savefile_keys = list()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (!istext(preference.savefile_key))
			TEST_FAIL("[preference_type] has an invalid savefile_key.")

		if (preference.savefile_key in known_savefile_keys)
			TEST_FAIL("[preference_type] has a non-unique savefile_key `[preference.savefile_key]`!")

		known_savefile_keys += preference.savefile_key

/// Requires all main features have a main_feature_name
/datum/unit_test/preferences_valid_main_feature_name

/datum/unit_test/preferences_valid_main_feature_name/Run()
	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/choiced/preference = GLOB.preference_entries[preference_type]
		if (!istype(preference))
			continue

		if (preference.category != PREFERENCE_CATEGORY_FEATURES && preference.category != PREFERENCE_CATEGORY_CLOTHING)
			continue

		TEST_ASSERT(!isnull(preference.main_feature_name), "Preference [preference_type] does not have a main_feature_name set!")
