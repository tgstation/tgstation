/datum/species/human/get_species_description()
	return "The Hominins of Sol-Terra."

/datum/species/human/get_species_lore()
	return list(
		"As a Human:",
		" + You have an example rule. ",
		" - You have an example restriction. ",
		"Lore unfinished."
	)

/datum/species/human/create_pref_unique_perks()
	var/list/to_add = list()

	if(CONFIG_GET(number/default_laws) == 0 || CONFIG_GET(flag/silicon_asimov_superiority_override)) // Default lawset is set to Asimov
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "robot",
			SPECIES_PERK_NAME = "Asimov Superiority",
			SPECIES_PERK_DESC = "The AI and their cyborgs are, by default, subservient only \
				to humans. As a human, silicons are required to both protect and obey you.",
		))

	var/human_authority_setting = CONFIG_GET(string/human_authority)

	if(human_authority_setting == HUMAN_AUTHORITY_NON_HUMAN_WHITELIST || human_authority_setting == HUMAN_AUTHORITY_ENFORCED)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bullhorn",
			SPECIES_PERK_NAME = "Chain of Command",
			SPECIES_PERK_DESC = "Nanotrasen only recognizes humans for command roles, such as Captain.",
		))

		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON,
			SPECIES_PERK_NAME = "Ulterior motives",
			SPECIES_PERK_DESC = "Your goals may not align with the station or her crew. IMPORTANT: This is not a license to grief.",
		))
	return to_add
