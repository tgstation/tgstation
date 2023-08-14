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

/// Ensures that exporting and importing preferences functions
/datum/unit_test/preferences_export_import

/datum/unit_test/preferences_export_import/Run()
	// make default client
	var/datum/client_interface/mock_client = new
	mock_client.prefs = new(mock_client)

	// iterate over all default possible character slots to populate them with defaults
	for(var/slot_id in 1 to mock_client.prefs.max_save_slots)
		mock_client.prefs.load_character(slot_id)
		mock_client.prefs.save_character()

	// save them to populate the json tree
	mock_client.prefs.save_preferences()

	// now we export it and instantly reimport it
	var/json_export = mock_client.prefs.savefile.serialize_json()
	mock_client.prefs.handle_client_importing(json_export)
	TEST_ASSERT(!length(mock_client.prefs.last_import_error_map), "errors occured while importing valid preferences!")

	// now we fuck up the json format
	var/messed_json_export = "{{[json_export]"
	mock_client.prefs.handle_client_importing(messed_json_export)
	TEST_ASSERT(PREFERENCE_IMPORT_ERROR_INVALID_JSON in mock_client.prefs.last_import_error_map, "failed to identify malformed json")

	// now we test just not even passing in text
	mock_client.prefs.handle_client_importing(null)
	TEST_ASSERT(PREFERENCE_IMPORT_ERROR_INVALID_JSON in mock_client.prefs.last_import_error_map, "failed to identify invalid json")

	// check an empty string
	mock_client.prefs.handle_client_importing("")
	TEST_ASSERT(PREFERENCE_IMPORT_ERROR_INVALID_JSON in mock_client.prefs.last_import_error_map, "failed to identify empty json")

	// change a string peference to a number
	var/datum/preference/name/real_name = /datum/preference/name/real_name
	var/savefile_ident = initial(real_name.savefile_key)
	var/list/character_data = mock_client.prefs.savefile.get_entry("character1")
	character_data[savefile_ident] = 2
	var/wrong_json = mock_client.prefs.savefile.serialize_json()
	mock_client.prefs.handle_client_importing(wrong_json)
	TEST_ASSERT(PREFERENCE_IMPORT_ERROR_INVALID_VALUE in mock_client.prefs.last_import_error_map, "failed to identify invalid value")
