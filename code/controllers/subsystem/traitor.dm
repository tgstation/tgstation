SUBSYSTEM_DEF(traitor)
	name = "Traitor"
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
	)
	ss_flags = SS_NO_FIRE

	/// A list of all uplink items mapped by type
	var/list/uplink_items_by_type = list()
	/// A list of all uplink items
	var/list/uplink_items = list()

	/// List of code words for traitors
	var/syndicate_code_phrase
	/// List of code responses for traitors
	var/syndicate_code_response
	/// Regex of code words for traitors
	var/regex/syndicate_code_phrase_regex
	/// Regex of code responses for traitors
	var/regex/syndicate_code_response_regex

/datum/controller/subsystem/traitor/Initialize()
	for(var/theft_item in subtypesof(/datum/objective_item/steal))
		new theft_item

	syndicate_code_phrase = generate_code_phrase(return_list = TRUE)
	syndicate_code_phrase_regex = new("([jointext(syndicate_code_phrase, "|")])", "ig")
	syndicate_code_response = generate_code_phrase(return_list = TRUE)
	syndicate_code_response_regex = new("([jointext(syndicate_code_response, "|")])", "ig")
	return SS_INIT_SUCCESS
