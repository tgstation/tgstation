/**
 * Species IDs are used in keyed_list config entries and their config values can either be set implicitly or explicitly.
 *
 * In order to accomplish this, the keyed_list looks for a specific splitter that is meant to separate the key from the value.
 *
 * While it supports multiple instances of the splitter (for example, space) being present, the intent is ambiguous.
 *
 * To combat that, this unit test runs through every species ID and make sure it doesn't contain the splitter character, so
 * valid config entries are never ambiguous.
 */
/datum/unit_test/species_config_sanity/Run()
	var/datum/config_entry/keyed_list/roundstart_races/first_config_type = /datum/config_entry/keyed_list/roundstart_races
	var/datum/config_entry/keyed_list/roundstart_no_hard_check/second_config_type = /datum/config_entry/keyed_list/roundstart_no_hard_check

	var/first_splitter = initial(first_config_type.splitter)
	var/second_splitter = initial(second_config_type.splitter)
	for(var/datum/species/species_type as anything in subtypesof(/datum/species))
		var/species_id = initial(species_type.id)
		if(findtext(species_id, first_splitter))
			Fail("A species ID contained a config_entry splitter: [species_type] | Splitter: (\"[first_splitter]\") | Species ID: (\"[species_id]\")")
		if(findtext(species_id, second_splitter))
			Fail("A species ID contained a config_entry splitter: [species_type] | Splitter: (\"[second_splitter]\") | Species ID: (\"[species_id]\")")
